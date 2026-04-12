#define TESTING TRUE

/datum/human_ai_brain
	/// If TRUE, AI is currently in some form of cover
	var/in_cover = FALSE

	/// Reference to atom currently selected as a cover place
	var/atom/current_cover

	COOLDOWN_DECLARE(cover_search_cooldown)

/datum/human_ai_brain/proc/end_cover()
#if defined(TESTING) || defined(HUMAN_AI_TESTING)
	if(current_cover)
		current_cover.color = null
		current_cover.maptext = null
#endif
	current_cover = null
	in_cover = FALSE

/datum/human_ai_brain/proc/on_shot_inside_cover(angle, atom/source)
	// Cover isn't working. Charge!
	end_cover()

/// Try to get the AI to find a suitable cover tile based on the angle a projectile came from.
/datum/human_ai_brain/proc/try_cover(angle, atom/source)
	if(!COOLDOWN_FINISHED(src, cover_search_cooldown))
		return

	if(!(cover_without_gun || primary_weapon))
		return

	COOLDOWN_START(src, cover_search_cooldown, 10 SECONDS)

	var/list/turf_dict = list()
	var/cover_dir = reverse_direction(angle2dir4ai(angle))

	SShuman_ai_cover.register_data_request(src, CALLBACK(src, PROC_REF(cover_processing)), cover_dir)

#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_cover_value_debug), turf_dict.Copy()), 60 SECONDS)
#endif

	//cover_processing(turf_dict)
	//squad_cover_processing(turf_dict)

/// If an AI decides to go into cover, any squadmates in their view range will process on the same view dictionary so as to help with performance
/datum/human_ai_brain/proc/squad_cover_processing(list/turf_dict)
	if(!squad_id)
		return

	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
	if(!squad)
		return

	for(var/datum/human_ai_brain/brain as anything in squad.ai_in_squad)
		if(brain == src)
			continue

		if(get_dist(tied_human, brain.tied_human) > view_distance)
			continue

		if(brain.tied_human.is_mob_incapacitated())
			continue

		COOLDOWN_START(brain, cover_search_cooldown, 15 SECONDS)

		//brain.cover_processing(turf_dict, TRUE)

/datum/human_ai_brain/proc/clear_cover_value_debug(list/turf_list)
	for(var/turf/T as anything in turf_list)
		T.maptext = null

/datum/human_ai_brain/proc/cover_processing(turf/best_cover, list/turf_dict, from_squad = FALSE)
	current_cover = best_cover
	return
