#define COVER_DATA_REQUEST_DENIED 0
#define COVER_DATA_GENERATION_DENIED 1
#define COVER_DATA_REQUEST_ALLOWED 2

SUBSYSTEM_DEF(human_ai_cover)
	name = "Human AI Cover Processing"
	priority = SS_PRIORITY_HUMAN_AI_COVER
	flags = SS_NO_INIT|SS_TICKER|SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 10
	var/chunk_data_array[5][20][20]
	var/list/chunk_generation_requests = list()
	var/list/datum/ai_cover_data_request/cover_data_requests = list()
	var/list/datum/ai_cover_data_request/indexed_data_requests = list()

/datum/controller/subsystem/human_ai_cover/fire(resumed = FALSE)

	if(!length(GLOB.human_ai_brains))
		return

	// divides the subsystem timing evenly between its three contained modules
	MC_SPLIT_TICK_INIT(3)

	// -----------------------------
	// COVER REQUEST CONTROLLER
	// manages incoming cover data requests
	// -----------------------------

	MC_SPLIT_TICK

	// Used to kill the data requests controller when it runs overtime.
	// Saves time by skipping future MC_TICK_CHECKs once it returns true
	var/kill_request_controller = FALSE

	for(var/datum/ai_cover_data_request/data_request as anything in cover_data_requests)
		if(kill_request_controller)			// salvages what we can of the list, and delete the rest
			cover_data_requests -= data_request
			QDEL_NULL(data_request)
			continue
		if(MC_TICK_CHECK)
			cover_data_requests -= data_request
			QDEL_NULL(data_request)
			kill_request_controller = TRUE	// dont bother with tick check math for subsequent items
			continue

		var/data_request_status = validate_data_request(data_request)

		if(data_request_status == COVER_DATA_REQUEST_DENIED)	// you aint on the list buddy
			cover_data_requests -= data_request
			QDEL_NULL(data_request)
			continue

		// checks for pre-processed chunk data at requester location. returns false if not found
		// will schedule chunk processing for authorised requests (not REQUEST_GENERATION_DENIED)
		request_chunk_data(data_request, data_request_status)

	// -----------------------------
	// COVER REQUEST PROCESSOR
	//
	// -----------------------------

	MC_SPLIT_TICK

	var/kill_request_processor = FALSE

	for(var/datum/ai_cover_data_request/data_request in cover_data_requests)
		var/list/raw_chunk_data = list()
		var/list/processed_cover_locations = list()

		if(kill_request_processor)
			data_request.to_return.Invoke()
			cover_data_requests -= data_request
			QDEL_NULL(data_request)
			continue

		for(var/datum/ai_cover_data_chunk/chunk as anything in data_request.data_chunks)
			raw_chunk_data |= chunk.turf_dict

		var/most_weight = -INFINITY
		var/turf/best_cover
		for(var/turf/cover_turf as anything in raw_chunk_data)
			var/weight = raw_chunk_data[cover_turf]
			var/turf_distance = get_dist(cover_turf, data_request.requester_mob)
			if(turf_distance >= 9)
				raw_chunk_data -= cover_turf
				continue
			weight -= turf_distance
			if(weight <= 0)
				raw_chunk_data -= cover_turf
				continue
			if(data_request.direction_preference in get_related_directions(get_dir(data_request.requester_mob, cover_turf)))
				weight |= 5
			if(weight > most_weight)
				most_weight = weight
				best_cover = cover_turf

		if(best_cover && best_cover != data_request.requesting_turf)
			data_request.final_cover_location = best_cover

		if(MC_TICK_CHECK)
			kill_request_processor = TRUE
			continue

	// -----------------------------
	// CENTRAL CHUNK CONTROLLER
	//
	// -----------------------------

	for(var/datum/ai_cover_data_request/data_request in cover_data_requests)
		var/turf/final_cover_location = data_request.final_cover_location
		if(!final_cover_location)	// doesnt qdel yet, data may still be needed by the chunk controller
			data_request.to_return.Invoke()
			continue
		data_request.to_return.Invoke(final_cover_location)
		cover_data_requests -= data_request
		QDEL_NULL(data_request)

	// -----------------------------
	// CENTRAL CHUNK CONTROLLER
	//
	// -----------------------------

	MC_SPLIT_TICK

	for(var/chunk_processing_request in chunk_generation_requests)
		var/list/unpacked_chunk_data = chunk_processing_request
		var/datum/ai_cover_data_chunk/chunk = unpacked_chunk_data["chunk"]
		var/chunk_x = unpacked_chunk_data["x"]
		var/chunk_y = unpacked_chunk_data["y"]
		var/chunk_z = unpacked_chunk_data["z"]
		var/turf/requester_turf = unpacked_chunk_data["requester_turf"]
		var/turf/middle_turf = locate(chunk_x * 13 + 7, chunk_y * 13 + 7, chunk_z)
		var/list/scannable_turfs = list(middle_turf)

		// i know how clunky this looks, but believe me, its easier
		chunk_data_array[chunk_z][chunk_x][chunk_y] = chunk

		if(isclosedturf(middle_turf) && requester_turf)
			scannable_turfs = list(requester_turf)	// the middle of the chunk is a wall. start at the original request

		var/first_iteration = TRUE
		var/list/scanned_turfs = list()

		while(length(scannable_turfs))
			var/turf/scan_turf = scannable_turfs[1]
			scannable_turfs.Cut(scan_turf)
			chunk.turf_dict[scan_turf] = 0
			scanned_turfs |= scan_turf
			var/list/turf_contents = scan_turf.contents.Copy()
			var/list/soft_cover_list = list()
			for(var/atom/movable/atom as anything in turf_contents)
				if(atom.density)
					if(istype(atom, /obj/structure))
						soft_cover_list |= atom
						continue
					if(first_iteration)
						break // We don't wanna end our cover search on self
					turf_contents -= atom
				else
					if(istype(atom, /obj/item/explosive/mine))
						turf_contents -= atom
						continue

			for(var/cardinal in GLOB.cardinals)
				var/turf/nearby_turf = get_step(scan_turf, cardinal)
				if(!nearby_turf)
					continue

				if(nearby_turf in scanned_turfs)
					continue

				if(isclosedturf(nearby_turf))
					chunk.turf_dict[scan_turf] += 2 // Near a wall is a bit safer
					continue

				if(abs(middle_turf.x - nearby_turf.x) > 6 || abs(middle_turf.y - nearby_turf.y) > 6)
					continue

				scannable_turfs |= nearby_turf

		chunk_generation_requests -= chunk_processing_request

		if(MC_TICK_CHECK)
			break

/**
 * Human AI cover subsystem receptionist. Called by AI brains when they want to take cover.
 *
 * Fills out a new /datum/ai_cover_data_request, and writes down everything the subsystem needs
*/
/datum/controller/subsystem/human_ai_cover/proc/register_data_request(datum/human_ai_brain/target_brain, callback, direction_preference)
	var/datum/ai_cover_data_request/data_request = new /datum/ai_cover_data_request
	data_request.requester_brain = target_brain
	data_request.requester_mob = target_brain.tied_human
	data_request.target_faction = target_brain.tied_human.faction
	data_request.to_return = callback
	if(target_brain.squad_id)
		data_request.target_squad = target_brain.squad_id
	data_request.requesting_turf = get_turf(target_brain.tied_human)
	data_request.request_time = world.time
	data_request.direction_preference = direction_preference

	cover_data_requests |= data_request

/// Manages cover request cooldowns to make sure nobody is asking for data too often
/datum/controller/subsystem/human_ai_cover/proc/validate_data_request(datum/ai_cover_data_request/request)
	var/datum/human_ai_brain/requester = request.requester_brain

	if(!requester)
		// delete the request
		return COVER_DATA_REQUEST_DENIED

	// this is your first request - proceed
	if(!indexed_data_requests[requester])
		indexed_data_requests[requester] = world.time
		return COVER_DATA_REQUEST_ALLOWED

	var/last_request_time = request.request_time - indexed_data_requests[requester]

	// you requested more than 10 seconds ago - proceed
	if(last_request_time > 10 SECONDS)
		indexed_data_requests[requester] = request.request_time
		return COVER_DATA_REQUEST_ALLOWED

	// you requested data a bit too soon - we'll resend what you last got
	if(last_request_time >= 5 SECONDS)
		return COVER_DATA_GENERATION_DENIED

	// you requested data WAY too soon - you get nothing
	return COVER_DATA_REQUEST_DENIED

// refactor
/**
 * Called by the "Cover Request Controller" module in subsystem/fire() when an area of the map needs to be processed for viable cover locations
 *
 * Searches the contents of a 13 square tile zone, and processes each turf for cover viability,
 * then adds them to the semi-static chunk_data_array list on the cover subsystem.
 *
 * Scanned chunks are stored in a /datum/ai_cover_data_chunk containing a turf_dictionary, indexed by chunk [x, y, z]
 *
 * CPU INTENSIVE | NOT TO BE MANUALLY CALLED
 */
/datum/controller/subsystem/human_ai_cover/proc/request_chunk_data(datum/ai_cover_data_request/request, data_generation_allowed = FALSE)
	var/turf/requesting_turf = request.requesting_turf

	var/x_array_index = floor(requesting_turf.x / 13)
	var/y_array_index = floor(requesting_turf.y / 13)
	var/datum/ai_cover_data_chunk/chunk_data_index
	if(chunk_data_array[requesting_turf.z][x_array_index][y_array_index])
		chunk_data_index = chunk_data_array[requesting_turf.z][x_array_index][y_array_index]
	//var/chunk_data_index = chunk_array_fetch(x_array_index, y_array_index, requesting_turf.z)

	if(chunk_data_index)
		request.data_chunks |= chunk_data_index
		return TRUE
	switch(data_generation_allowed)
		if(COVER_DATA_GENERATION_DENIED)	// we couldnt find anything, and we arent allowed to go fetch
			cover_data_requests -= request
			QDEL_NULL(request)
		if(COVER_DATA_REQUEST_ALLOWED)		// we couldnt find anything, but we'll go fetch
			var/datum/ai_cover_data_chunk/chunk_template = new /datum/ai_cover_data_chunk
			chunk_template.index_x = x_array_index
			chunk_template.index_y = y_array_index
			chunk_template.index_z = requesting_turf.z
			chunk_generation_requests |= list(
				list(
					"x" = x_array_index,
					"y" = y_array_index,
					"z" = requesting_turf.z,
					"chunk" = chunk_template,
					"requester_turf" = request.requesting_turf
					)
				)
	return FALSE

/datum/ai_cover_data_request
	var/datum/human_ai_brain/requester_brain
	var/mob/living/carbon/human/requester_mob
	var/datum/faction/target_faction
	var/datum/squad/target_squad
	var/turf/requesting_turf
	var/request_time
	var/direction_preference
	var/datum/callback/to_return
	var/turf/final_cover_location

	var/list/data_chunks = list()

/datum/ai_cover_data_request/Destroy(force)
	requester_brain = null
	requester_mob = null
	target_faction = null
	target_squad = null
	requesting_turf = null

	final_cover_location = null
	data_chunks = null
	return ..()

/datum/ai_cover_data_chunk
	var/list/turf/turf_dict = list()
	var/index_x
	var/index_y
	var/index_z

/datum/ai_cover_data_chunk/Destroy(force)
	turf_dict = null
	return ..()
