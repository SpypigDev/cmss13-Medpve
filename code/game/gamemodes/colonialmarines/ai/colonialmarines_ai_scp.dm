/datum/game_mode/colonialmarines/ai/scp
	name = "Containment Breach"
	config_tag = "Containment Breach"
	required_players = 0

	flags_round_type = MODE_ANOMALY_HUNT|MODE_NEW_SPAWN|MODE_NO_XENO_EVOLVE

	squad_limit = list(
		/datum/squad/marine/forecon/containment
	)

	objectives = list()
	initial_objectives = 0

	game_started = FALSE

	role_mappings = list(
		/datum/job/command/bridge/ai = JOB_SO,
		/datum/job/marine/tl/ai/forecon = JOB_SQUAD_TEAM_LEADER_FORECON,
		/datum/job/marine/specialist = JOB_SQUAD_SPECIALIST,
		/datum/job/marine/medic/ai/forecon = JOB_SQUAD_MEDIC_FORECON,
		/datum/job/marine/engineer/ai = JOB_SQUAD_ENGI,
		/datum/job/marine/smartgunner/ai/forecon = JOB_SQUAD_SMARTGUN_FORECON,
		/datum/job/marine/standard/ai/forecon = JOB_SQUAD_MARINE_FORECON,
	)

	static_comms_amount = 0
	requires_comms = FALSE
	toggleable_flags = MODE_NO_JOIN_AS_XENO|MODE_HARDCORE_PERMA|MODE_DISABLE_FS_PORTRAIT

/datum/game_mode/colonialmarines/ai/scp/pre_setup()
	// rework to activate entity spawning
	//RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, PROC_REF(handle_xeno_spawn))

	GLOB.platoon_to_jobs[/datum/squad/marine/forecon/containment] = list(
		/datum/job/command/bridge/ai = JOB_SO,\
		/datum/job/marine/tl/ai/forecon = JOB_SQUAD_TEAM_LEADER_FORECON,\
		/datum/job/marine/specialist = JOB_SQUAD_SPECIALIST,\
		/datum/job/marine/medic/ai/forecon = JOB_SQUAD_MEDIC_FORECON,\
		/datum/job/marine/engineer/ai = JOB_SQUAD_ENGI,
		/datum/job/marine/smartgunner/ai/forecon = JOB_SQUAD_SMARTGUN_FORECON,\
		/datum/job/marine/standard/ai/forecon = JOB_SQUAD_MARINE_FORECON)

	GLOB.platoon_to_role_list[/datum/squad/marine/forecon/containment] = GLOB.ROLES_AI_CONTAINMENT

	. = ..()

// rework to allow entity spawns
/datum/game_mode/colonialmarines/ai/scp/handle_xeno_spawn(datum/source, mob/living/carbon/xenomorph/spawning_xeno, ai_hard_off = FALSE)
	if(ai_hard_off)
		return

	spawning_xeno.make_ai()
