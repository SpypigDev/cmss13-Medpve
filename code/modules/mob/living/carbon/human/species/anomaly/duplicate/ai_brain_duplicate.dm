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
	if(pretending_to_be_human && get_dist(tied_human, alter) < 9)
		for(var/mob/living/viewing_mob in view(view_distance, tied_human))
			if(viewing_mob == tied_human)
				continue

			if(viewing_mob == alter)
				initial_contact_alter()
				break
	..()

/datum/human_ai_brain/duplicate/proc/initial_contact_alter()
	if(tied_human.client || !alter.client)
		return
	if(mimic_timer)
		return
	mimic_timer = addtimer(CALLBACK(src, PROC_REF(engage_alter)), 6 SECONDS, TIMER_STOPPABLE)
	RegisterSignal(alter, COMSIG_HUMAN_SAY, PROC_REF(replicate_speech))
	pretending_to_be_human = FALSE
	hold_position = TRUE

/datum/human_ai_brain/duplicate/proc/replicate_alter(mob/living/carbon/human/alter)
	var/list/alter_equipment_list = list()
	alter_equipment_list |= alter.get_equipped_items()
	tied_human.create_hud()
	for(var/obj/item/item in alter_equipment_list)
		var/obj/item/new_item = new item.type()
		tied_human.equip_to_appropriate_slot(new_item)
	tied_human.name = alter.name
	tied_human.real_name = alter.real_name
	tied_human.gender = alter.gender

/datum/human_ai_brain/duplicate/proc/replicate_speech(message)
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
	enter_combat()
