#define COVER_DATA_REQUEST_DENIED 0
#define COVER_DATA_GENERATION_DENIED 1
#define COVER_DATA_REQUEST_ALLOWED 2

SUBSYSTEM_DEF(human_ai_cover)
	name = "Human AI Cover Processing"
	priority = SS_PRIORITY_HUMAN_AI_COVER
	flags = SS_NO_INIT|SS_TICKER|SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 1
	var/list/chunk_data_array = list()
	var/list/chunk_generation_requests = list()
	var/list/datum/ai_cover_data_request/cover_data_requests = list()
	var/list/datum/ai_cover_data_request/indexed_data_requests = list()


	/// A list of mobs scheduled to process
	var/list/datum/ai_cover_data_chunk/current_processing = list()
	/// A list of paths to calculate
	var/list/datum/ai_cover_data_chunk/paths_to_calculate = list()
	/// Tracks how many times human_ai_cover has been overtick aborted
	var/tick_overtime_count = 0	// as well as how many shots you need to take
	var/list/hash_path = list()
	var/current_position = 1

/datum/controller/subsystem/human_ai_cover/stat_entry(msg)
	msg = "P:[length(paths_to_calculate)]"
	return ..()

/datum/controller/subsystem/human_ai_cover/fire(resumed = FALSE)
	if(!resumed)
		current_processing = paths_to_calculate.Copy()

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
			qdel(data_request)
			continue
		if(MC_TICK_CHECK)
			cover_data_requests -= data_request
			qdel(data_request)
			kill_request_controller = TRUE	// dont bother with tick check math for subsequent items
			continue

		var/data_request_status = validate_data_request(data_request)

		if(data_request_status == COVER_DATA_REQUEST_DENIED)	// you aint on the list buddy
			cover_data_requests -= data_request
			qdel(data_request)
			continue

		// checks for pre-processed chunk data at requester location. returns false if not found
		// will schedule chunk processing for authorised requests (not REQUEST_GENERATION_DENIED)
		var/datum/ai_cover_data_chunk/data_chunk = request_chunk_data(data_request, data_request_status)
		if(!data_chunk)				// we couldnt find anything, and we arent allowed to go fetch
			cover_data_requests -= data_request
			qdel(data_request)
			continue
		data_request.data_chunks |= data_chunk

	// -----------------------------
	// COVER REQUEST PROCESSOR
	//
	// -----------------------------

	MC_SPLIT_TICK



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

		var/turf/middle_turf = locate(chunk_x + 6, chunk_y + 6, chunk_z)
		//ifcheck
		var/list/scannable_turfs = list(middle_turf)
		var/first_iteration = TRUE

		for(var/turf/scan_turf as anything in scannable_turfs)
			scannable_turfs -= scan_turf

			if(sqrt((middle_turf.x - scan_turf.x)^2) >= 6 || sqrt((middle_turf.y - scan_turf.y)^2) >= 6)
				continue

			if(scan_turf in chunk.turf_dict)
				continue

			chunk.turf_dict[scan_turf] = 0

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

				if(isclosedturf(nearby_turf))
					chunk.turf_dict[scan_turf] += 2 // Near a wall is a bit safer
					continue

				scannable_turfs |= nearby_turf

		if(MC_TICK_CHECK)
			break
















/// Manages cover request cooldowns to make sure nobody is asking for data too often
/datum/controller/subsystem/human_ai_cover/proc/register_data_request(/datum/human_ai_brain/target_brain, direction_preference)
	if(cover_data_requests[target_brain.tied_human])
		return FALSE
	var/datum/ai_cover_data_request/data_request = new /datum/ai_cover_data_request
	data_request.requester_brain = target_brain
	data_request.requester_mob = target_brain.tied_human
	data_request.target_faction = target_brain.tied_human.faction
	if(target_brain.squad_id)
		data_request.target_squad = target_brain.squad_id
	data_request.requesting_turf = get_turf(target_brain.tied_human)
	data_request.request_time = world.time
	data_request.direction_preference = direction_preference

	cover_data_requests[target_brain.tied_human] = data_request

/// Manages cover request cooldowns to make sure nobody is asking for data too often
/datum/controller/subsystem/human_ai_cover/proc/validate_data_request(/datum/ai_cover_data_request/request)
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
/// Manages cover request cooldowns to make sure nobody is asking for data too often
/datum/controller/subsystem/human_ai_cover/proc/request_chunk_data(/datum/ai_cover_data_request/request, data_generation_allowed = FALSE)
	var/turf/requesting_turf = request.requesting_turf

	var/x_array_index = ceil(requesting_turf.x / 13)
	var/y_array_index = ceil(requesting_turf.y / 13)
	var/chunk_data_index = chunk_data_array[x_array_index][y_array_index][requesting_turf.z]

	if(!chunk_data_index)
		if(data_generation_allowed == COVER_DATA_REQUEST_ALLOWED)
			var/datum/ai_cover_data_chunk/chunk_template = new /datum/ai_cover_data_chunk
			chunk_generation_requests |= list(
				list(
					"x" = x_array_index,
					"y" = y_array_index,
					"z" = requesting_turf.z,
					"chunk" = chunk_template
					)
				)
		return FALSE
	return chunk_data_index

/datum/ai_cover_data_request
	var/datum/human_ai_brain/requester_brain
	var/mob/living/carbon/human/requester_mob
	var/datum/faction/target_faction
	var/datum/squad/target_squad
	var/turf/requesting_turf
	var/request_time
	var/direction_preference

	var/list/data_chunks = list()

/datum/ai_cover_data_chunk
	var/list/turf/turf_dict = list()
