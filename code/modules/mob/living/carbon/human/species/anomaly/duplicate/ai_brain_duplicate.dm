GLOBAL_LIST_EMPTY(human_ai_brains)

/datum/human_ai_brain/duplicate
	/// The human that this brain ties into
	var/mob/living/carbon/human/tied_human
	/// The original mob the duplicant has copied
	var/mob/living/carbon/human/alter

	var/micro_action_delay = 0.2 SECONDS
	var/short_action_delay = 0.5 SECONDS
	var/medium_action_delay = 2 SECONDS
	var/long_action_delay = 5 SECONDS
	/// Global multiplier for all AI action delays
	var/action_delay_mult = 2 // Doubled from 1, gives hAI a believable time between actions
	/// Factions that the AI won't engage in hostilities with. Controlled by the AI's faction
	var/list/friendly_factions = list()
	/// Factions that the AI will not become hostile to unless attacked
	var/list/neutral_factions = list()
	/// If TRUE, the AI will throw grenades at enemies who enter cover
	var/grenading_allowed = FALSE
	/// If TRUE, we care about the target being in view after shooting at them. If not, then we only do a line check instead
	var/requires_vision = TRUE

	COOLDOWN_DECLARE(replicate_speech)

/datum/human_ai_brain/duplicate/New(mob/living/carbon/human/tied_human)
	. = ..()
	src.tied_human = tied_human
	RegisterSignal(tied_human, COMSIG_PARENT_QDELETING, PROC_REF(on_human_delete))
	RegisterSignal(tied_human, COMSIG_HUMAN_EQUIPPED_ITEM, PROC_REF(on_item_equip))
	RegisterSignal(tied_human, COMSIG_HUMAN_UNEQUIPPED_ITEM, PROC_REF(on_item_unequip))
	RegisterSignal(tied_human, COMSIG_MOB_PICKUP_ITEM, PROC_REF(on_item_pickup))
	RegisterSignal(tied_human, COMSIG_MOB_DROP_ITEM, PROC_REF(on_item_drop))
	RegisterSignal(tied_human, COMSIG_MOB_DEATH, PROC_REF(reset_ai))
	RegisterSignal(tied_human, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(tied_human, COMSIG_HUMAN_BULLET_ACT, PROC_REF(on_shot))
	RegisterSignal(tied_human, COMSIG_HUMAN_HANDCUFFED, PROC_REF(on_handcuffed))
	RegisterSignal(tied_human, COMSIG_HUMAN_GET_AI_BRAIN, PROC_REF(get_ai_brain))
	RegisterSignal(tied_human, COMSIG_HUMAN_SET_SPECIES, PROC_REF(on_species_change))
	GLOB.human_ai_brains += src
	setup_detection_radius()
	appraise_inventory()
	tied_human.a_intent_change(INTENT_DISARM)

/datum/human_ai_brain/duplicate/Destroy(force, ...)
	GLOB.human_ai_brains -= src
	tied_human = null

	reset_ai()

	return ..()

/datum/human_ai_brain/duplicate/process(delta_time)
	if(tied_human.is_mob_incapacitated())
		for(var/action in ongoing_actions)
			qdel(action)
		ongoing_actions.Cut()
		lose_target()
		return

	if(tied_human.resting)
		tied_human.set_resting(FALSE, TRUE)

	if(tied_human.buckled)
		tied_human.set_buckled(FALSE) // AI never buckle themselves into chairs at the moment, change if this becomes the case

	if(!current_target)
		set_target(get_target())

	if(current_target)
		enter_combat()

	item_search(range(2, tied_human))

	// List all allowed action types for AI to consider
	var/list/allowed_actions = action_whitelist || (GLOB.AI_actions.Copy() - action_blacklist)
	for(var/datum/ongoing_action as anything in ongoing_actions)
		if(is_type_in_list(ongoing_action, allowed_actions))
			allowed_actions -= ongoing_action.type

	// Create assoc list of selected AI actions and their weight
	var/list/possible_actions = list()
	for(var/action_type in shuffle(allowed_actions))
		var/datum/ai_action/glob_ref = GLOB.AI_actions[action_type]
		var/weight = glob_ref.get_weight(src)
		if(weight) // No weight means we shouldn't consider this action at all
			possible_actions[action_type] = weight

	// Sorts all allowed actions by their weight
	var/list/sorted_actions = sortTim(possible_actions, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	// Choose what actions to start in current process() iteration
	for(var/action_type as anything in sorted_actions)
		var/datum/ai_action/possible_action = GLOB.AI_actions[action_type]

		var/list/conflicting_actions = possible_action.get_conflicts(src)
		for(var/datum/ai_action/ongoing_action as anything in ongoing_actions)
			if(ongoing_action.type in conflicting_actions)
				possible_action = null
				break

		if(!possible_action)
			continue

		ongoing_actions += new action_type(src)
#if defined(TESTING) && defined(HUMAN_AI_TESTING)
		message_admins("action of type [action_type] was added to [tied_human.real_name]")
#endif

	for(var/datum/ai_action/action as anything in ongoing_actions)
		var/retval = action.trigger_action()
		switch(retval)
			if(ONGOING_ACTION_UNFINISHED_BLOCK)
				return
			if(ONGOING_ACTION_COMPLETED)
				qdel(action)

/datum/human_ai_brain/duplicate/proc/on_move(atom/oldloc, direction, forced)
	setup_detection_radius()

	if(in_cover && (get_dist(tied_human, current_cover) > gun_data?.minimum_range))
		end_cover()

	update_target_pos()

/datum/human_ai_brain/duplicate/proc/initial_contact_alter()
	SIGNAL_HANDLER

	if(tied_human.client)
		return

	if(in_combat)
		return

	RegisterSignal(alter, COMSIG_HUMAN_SAY, PROC_REF(replicate_speech))
	hold_position = TRUE

/datum/human_ai_brain/duplicate/proc/replicate_speech(message)
	if(!COOLDOWN_FINISHED(replicate_speech))
		return
	COOLDOWN_START(src, replicate_speech, 1 SECONDS)

	tied_human.say(message)

/datum/human_ai_brain/duplicate/proc/engage_alter()
	UnregisterSignal(alter, COMSIG_HUMAN_SAY)
	//emote

	holster_primary()
	holster_melee()
	tied_human.has_fine_manipulation = FALSE
	tied_human.a_intent_change(INTENT_HARM)
	hold_position = FALSE

	if(current_cover)
		end_cover()

	current_target = alter
	quick_approach = get_turf(alter)
	enter_combat()

/datum/human_ai_brain/proc/can_target(mob/living/carbon/target)
	if(!istype(target))
		return FALSE

	if(target.stat == DEAD)
		return FALSE

	if(!shoot_to_kill && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	if(faction_check(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CLOAKED) && get_dist(tied_human, target) > cloak_visible_range)
		return FALSE

	if(!friendly_check(target))
		return FALSE

	return TRUE

/// Given a target, checks if there are any (not laying down) friendlies in a line between the AI and the target
/datum/human_ai_brain/proc/friendly_check(atom/target)
	var/list/turf_list = get_line(get_turf(tied_human), get_turf(target))
	turf_list.Cut(1, 2) // starting turf
	for(var/turf/tile in turf_list)
		if(istype(tile, /turf/closed))
			return TRUE

		for(var/mob/living/carbon/human/possible_friendly in tile)
			if(possible_friendly.body_position == LYING_DOWN)
				continue

			if(faction_check(possible_friendly))
				return FALSE
	return TRUE

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER
