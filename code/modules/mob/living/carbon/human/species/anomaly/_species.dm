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

/datum/emote/living/carbon/human/anomaly
	species_type_allowed_typecache = list(/datum/species/anomaly)
	emote_type = EMOTE_AUDIBLE

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
	var/ability_range = 9
	var/static/list/action_sound_effect_list = list(
		'sound/ambience/ambimalf.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/ambience/ambigen9.ogg',
		'sound/ambience/ambigen5.ogg',
		'sound/ambience/ambigen2.ogg',
		'sound/ambience/ambimo2.ogg',
		'sound/ambience/ambisin2.ogg'
	)

	var/static/list/sound_effect_list = list(
		'sound/machines/resource_node/node_marine_die.ogg',
		'sound/machines/resource_node/node_marine_die_2.ogg',
		'sound/machines/resource_node/node_marine_harvest.ogg',
		'sound/machines/resource_node/node_turn_off.ogg'
	)

	COOLDOWN_DECLARE(action_cooldown)
	COOLDOWN_DECLARE(action_sound_effect_cooldown)

/datum/ai_action/anomaly/short_lighting/Added()
	. = ..()
	COOLDOWN_START(src, action_cooldown, 5 SECONDS)
	COOLDOWN_START(src, action_sound_effect_cooldown, 5 SECONDS)

/datum/ai_action/anomaly/short_lighting/get_weight(datum/human_ai_brain/brain)
	if(!is_type_in_list(src, brain.unique_actions))
		return 0
	return 20

/datum/ai_action/anomaly/short_lighting/trigger_action()
	. = ..()
	if(!COOLDOWN_FINISHED(src, action_cooldown))
		return
	if(brain.in_combat)
		COOLDOWN_START(src, action_cooldown, 2 SECONDS)
	else
		COOLDOWN_START(src, action_cooldown, 5 SECONDS)
	var/mob/tied_mob = brain.tied_human
	var/area/mob_area = get_area(tied_mob)
	if(!mob_area)
		return
	var/list/nearby_lights = list()
	var/list/areas_to_check = list(mob_area)
	if(brain.current_target && get_area(brain.current_target) != mob_area)
		areas_to_check |= get_area(brain.current_target)
	for(var/area/lighting_area as anything in areas_to_check)
		for(var/obj/structure/machinery/light/light as anything in lighting_area.all_lights)
			if(!light.on || get_dist(light, tied_mob) > ability_range)
				continue
			nearby_lights |= light
	// breaks more lights if used in combat, but always at least 1
	for(var/i in 1 to rand(1, (brain.in_combat * 4 + 1)))
		if(!length(nearby_lights))
			break
		var/obj/structure/machinery/light/target_light = pick(nearby_lights)
		if(prob(60) && brain.in_combat)
			target_light.flicker(rand(2, 10), 1, 3)
			playsound(target_light, pick(sound_effect_list), 20)
			addtimer(CALLBACK(target_light, TYPE_PROC_REF(/obj/structure/machinery/light, broken), FALSE, FALSE), rand(2, 4) SECONDS)
		else
			addtimer(CALLBACK(target_light, TYPE_PROC_REF(/obj/structure/machinery/light, flicker)), rand(1, 3) SECONDS)
		nearby_lights -= target_light
	if(brain.current_target && ishuman_strict(brain.current_target) && brain.in_combat)
		var/mob/living/carbon/human/target = brain.current_target
		if(COOLDOWN_FINISHED(src, action_sound_effect_cooldown))
			playsound_client(target.client, pick(action_sound_effect_list), target, 40, TRUE)
			COOLDOWN_START(src, action_sound_effect_cooldown, 10 SECONDS)
		if(prob(20))	// 20% chance to turn off their targets armor light every 2 seconds
			var/obj/item/clothing/suit/storage/marine/target_armor = target.get_item_by_slot(WEAR_JACKET)
			target_armor?.turn_light(target, FALSE)

