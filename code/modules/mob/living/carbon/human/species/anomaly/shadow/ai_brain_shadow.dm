/datum/human_ai_brain/shadow_men
	micro_action_delay = 0.2 SECONDS
	short_action_delay = 0.5 SECONDS
	medium_action_delay = 2 SECONDS
	long_action_delay = 5 SECONDS
	action_delay_mult = 2 // Doubled from 1, gives hAI a believable time between actions
	unique_actions = list(/datum/ai_action/anomaly/short_lighting)
	grenading_allowed = FALSE
	requires_vision = TRUE
	can_assign_squad = FALSE
	has_nightvision = TRUE

// -------------------
// OPERATION OPTIMIZE!
//
// review flickering lights code
// reduce the calls from short lights ability
// reduce the lighting subsystem in general
// review static lighting modules as marked
// investigate lightweight light interactions that dont use the subsystem
// review the human_ai/fire subsystem proc
// review the shadow men processing proc
// reduce pathfinding usage
// apply optimized pathfinding code
// -------------------




/datum/human_ai_brain/shadow_men/say_in_combat_line(chance)
	return

/datum/human_ai_brain/shadow_men/say_exit_combat_line()
	return

/datum/human_ai_brain/shadow_men/on_squad_member_death()
	return

/datum/human_ai_brain/shadow_men/say_grenade_thrown_line()
	return

/datum/human_ai_brain/shadow_men/say_reload_line()
	return

/datum/human_ai_brain/shadow_men/say_need_healing_line()
	return

//datum/human_ai_brain/shadow_men/enter_combat()	// proc not in use while optimizations underway
//	if(!ishuman(current_target))
//		return ..()
//	var/mob/target_mob = current_target
//	if(target_mob.client && !in_combat)
//		playsound_client(target_mob.client, 'sound/ambience/weymart.ogg', target_mob, 70)
//	..()

/datum/human_ai_brain/shadow_men/configure_custom_spawn(mob/living/carbon/human/target)
	//RegisterSignal(tied_human, COMSIG_MOB_MOVE_OR_LOOK, PROC_REF(calculate_mob_slowdown))
	tied_human.add_filter("motion_blur", 1, list("type" = "motion_blur", "x" = 1))

/// proc not in use while optimizations underway
/datum/human_ai_brain/shadow_men/proc/calculate_mob_slowdown()
	if(tied_human.stat)
		UnregisterSignal(tied_human, COMSIG_MOB_MOVE_OR_LOOK)
		return
	var/turf/mob_turf = get_turf(tied_human)
	var/slowdown_factor = (mob_turf.luminosity * 2) + mob_turf.dynamic_lumcount
	if(!slowdown_factor)
		return FALSE
	if(!tied_human.stamina)
		return
	var/shadow_slowdown = listgetindex(tied_human.stamina.stamina_levels, slowdown_factor)
	tied_human.stamina.activate_stamina_debuff(shadow_slowdown)

