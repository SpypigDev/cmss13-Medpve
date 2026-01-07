/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species/anomaly
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = SPECIES_ANOMALY
	name_plural = "Anomalies"

/datum/species/anomaly/larva_impregnated(obj/item/alien_embryo/embryo)
	return

/// Override to add an emote panel to a species
/datum/species/anomaly/open_emote_panel()
	return

/datum/species/anomaly/handle_npc(mob/living/carbon/human/H)
	return

/datum/species/anomaly/attempt_rock_paper_scissors()
	return

/datum/species/anomaly/attempt_high_five()
	return

/datum/species/anomaly/attempt_fist_bump()
	return

/datum/species/anomaly/apply_signals(mob/living/carbon/human/H)
	return

//Only used by horrors at the moment. Only triggers if the mob is alive and not dead.
/datum/species/anomaly/handle_unique_behavior(mob/living/carbon/human/H)
	return

// Used for checking on how each species would scream when they are burning
/datum/species/anomaly/handle_on_fire(humanoidmob)
	// call this for each species so each has their own unique scream options when burning alive
	// heebie-jebies made me do all this effort, I HATE YOU
	return

/datum/species/anomaly/handle_head_loss(mob/living/carbon/human/human)
	return

/datum/species/anomaly/handle_paygrades()
	return

/datum/ai_action/anomaly
	action_flags = ACTION_UNIQUE

/datum/ai_action/anomaly/short_lighting
	name = "Short Nearby Lighting"
	var/ability_range = 4

	COOLDOWN_DECLARE(action_cooldown)

/datum/ai_action/anomaly/short_lighting/Added()
	. = ..()
	COOLDOWN_START(src, action_cooldown, 5 SECONDS)

/datum/ai_action/anomaly/short_lighting/get_weight(datum/human_ai_brain/brain)
	if(!is_type_in_list(src, brain.unique_actions))
		return 0
	return 20

/datum/ai_action/anomaly/short_lighting/trigger_action()
	. = ..()
	if(!COOLDOWN_FINISHED(src, action_cooldown))
		return
	COOLDOWN_START(src, action_cooldown, 5 SECONDS)
	var/mob/tied_mob = brain.tied_human
	var/area/mob_area = get_area(tied_mob)
	if(!mob_area)
		return
	var/list/nearby_lights = list()
	for(var/obj/structure/machinery/light/light as anything in mob_area.all_lights)
		if(!light.on || get_dist(light, tied_mob) > ability_range)
			continue
		nearby_lights |= light
	// breaks more lights if used in combat, but always at least 1
	for(var/i in 1 to rand(1, (brain.in_combat * 4 + 1)))
		if(!length(nearby_lights))
			break
		var/obj/structure/machinery/light/target_light = pick(nearby_lights)
		if(prob(50))
			addtimer(CALLBACK(target_light, TYPE_PROC_REF(/obj/structure/machinery/light, flicker)), rand(1, 3) SECONDS)
		else
			addtimer(CALLBACK(target_light, TYPE_PROC_REF(/obj/structure/machinery/light, broken), FALSE, FALSE), rand(1, 3) SECONDS)
		nearby_lights -= target_light
