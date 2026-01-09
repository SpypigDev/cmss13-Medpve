/datum/human_ai_brain/duplicate
	/// The original mob the duplicant has copied
	var/mob/living/carbon/human/alter
	var/pretending_to_be_human = TRUE
	var/mimic_timer

	micro_action_delay = 0.2 SECONDS
	short_action_delay = 0.5 SECONDS
	medium_action_delay = 2 SECONDS
	long_action_delay = 5 SECONDS
	/// Global multiplier for all AI action delays
	action_delay_mult = 2 // Doubled from 1, gives hAI a believable time between actions
	/// Factions that the AI won't engage in hostilities with. Controlled by the AI's faction
	friendly_factions = list()
	/// Factions that the AI will not become hostile to unless attacked
	neutral_factions = list()
	/// If TRUE, the AI will throw grenades at enemies who enter cover
	grenading_allowed = FALSE
	/// If TRUE, we care about the target being in view after shooting at them. If not, then we only do a line check instead
	requires_vision = TRUE

	COOLDOWN_DECLARE(replicate_speech)

	enter_combat_lines = list(
		"*scream",
		"*warcry",
	)

	in_combat_line_chance = 100

/datum/human_ai_brain/duplicate/say_in_combat_line(chance)
	if(!length(enter_combat_lines) || !prob(chance) || (tied_human.health < HEALTH_THRESHOLD_CRIT))
		return
	tied_human.say(pick(enter_combat_lines))

/datum/human_ai_brain/duplicate/say_exit_combat_line()
	return

/datum/human_ai_brain/duplicate/on_squad_member_death()
	return

/datum/human_ai_brain/duplicate/say_grenade_thrown_line()
	return

/datum/human_ai_brain/duplicate/say_reload_line()
	return

/datum/human_ai_brain/duplicate/say_need_healing_line()
	return

/datum/human_ai_brain/duplicate/configure_custom_spawn(mob/living/carbon/human/target)
	var/datum/squad/alter_target_squad = tgui_input_list(usr, "Select a squad for [tied_human] to join", "Select a squad", GLOB.RoleAuthority.squads)
	var/list/alters_list = list()
	if (!alter_target_squad)
		return
	if(!alter_target_squad.active || alter_target_squad.name == "Root")
		return FALSE

	for(var/mob/living/carbon/human/marine_human as anything in alter_target_squad.marines_list)
		alters_list |= marine_human
	var/target_alter = tgui_input_list(usr, "Select a player for [tied_human] to imitate", "Select a player for [tied_human] to imitate", alters_list)

	if(!target_alter)
		return
	if(QDELETED(tied_human))
		return
	alter = target_alter
	neutral_factions |= alter.faction
	replicate_alter(alter)

	COOLDOWN_START(src, replicate_speech, 1 SECONDS)

/datum/human_ai_brain/duplicate/process(delta_time)
	if(hold_position)
		return
	if(!alter)
		return
	if(tied_human.is_mob_incapacitated())
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		lose_target()
		return
	var/distance_to_alter = get_dist(tied_human, alter)
	if(pretending_to_be_human && distance_to_alter < 9)
		for(var/mob/living/viewing_mob in view(view_distance, tied_human))
			if(viewing_mob == tied_human)
				continue

			if(viewing_mob == alter)
				initial_contact_alter()
				break
	if(distance_to_alter < 36)
		quick_approach = get_turf(alter)
	..()

/datum/human_ai_brain/duplicate/proc/initial_contact_alter()
	if(tied_human.client || !alter.client)
		return
	if(mimic_timer)
		return
	mimic_timer = addtimer(CALLBACK(src, PROC_REF(engage_alter)), 6 SECONDS, TIMER_STOPPABLE)
	addtimer(CALLBACK(src, PROC_REF(turn_off_armor_lights)), 4 SECONDS)
	RegisterSignal(alter, COMSIG_HUMAN_SAY, PROC_REF(replicate_speech))
	pretending_to_be_human = FALSE
	hold_position = TRUE

/datum/human_ai_brain/duplicate/proc/turn_off_armor_lights()
	var/obj/item/clothing/suit/storage/marine/armor = tied_human.get_item_by_slot(WEAR_JACKET)
	if(armor)
		armor.turn_light(tied_human, FALSE)

/datum/human_ai_brain/duplicate/proc/replicate_alter(mob/living/carbon/human/alter)
	var/list/alter_equipment_list = list()
	alter_equipment_list |= alter.get_equipped_items()
	tied_human.create_hud()
	for(var/obj/item/item in alter_equipment_list)
		var/obj/item/new_item = new item.type()
		tied_human.equip_to_appropriate_slot(new_item)
	var/obj/item/clothing/suit/storage/marine/armor = tied_human.get_item_by_slot(WEAR_JACKET)
	if(armor)
		armor.turn_light(tied_human, TRUE)
	tied_human.body_size = alter.body_size
	tied_human.body_type = alter.body_type
	tied_human.skin_color = alter.skin_color

	tied_human.gender = alter.gender
	tied_human.r_hair = alter.r_hair
	tied_human.g_hair = alter.g_hair
	tied_human.b_hair = alter.b_hair
	tied_human.r_facial = alter.r_facial
	tied_human.g_facial = alter.g_facial
	tied_human.b_facial = alter.b_facial
	tied_human.h_style = alter.h_style
	tied_human.f_style = alter.f_style

	tied_human.change_real_name(tied_human, alter.real_name)

	tied_human.regenerate_icons()

/datum/human_ai_brain/duplicate/proc/replicate_speech(source, message)
	if(!COOLDOWN_FINISHED(src, replicate_speech))
		return
	COOLDOWN_START(src, replicate_speech, 1 SECONDS)

	tied_human.say(message)

/datum/human_ai_brain/duplicate/proc/engage_alter()
	UnregisterSignal(alter, COMSIG_HUMAN_SAY)
	//emote
	mimic_timer = null
	holster_primary()
	holster_melee()
	//tied_human.has_fine_manipulation = FALSE
	tied_human.a_intent_change(INTENT_HARM)
	hold_position = FALSE
	friendly_factions -= alter.faction
	neutral_factions -= alter.faction
	current_target = alter
	quick_approach = get_turf(alter)
	tied_human.r_eyes = 255
	tied_human.g_eyes = 0
	tied_human.b_eyes = 0
	tied_human.update_body()
	enter_combat()
