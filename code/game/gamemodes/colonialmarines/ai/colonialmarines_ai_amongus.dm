/datum/game_mode/colonialmarines/ai/amongus
	name = "The Hit Game Among Us!"
	config_tag = "Among Us"
	flags_round_type = MODE_INFESTATION|MODE_NEW_SPAWN|MODE_NO_XENO_EVOLVE
	votable = FALSE

	role_mappings = list(
		/datum/job/special/provost/marshal = JOB_PROVOST_MARSHAL,
		/datum/job/command/commander = JOB_CO,
		/datum/job/civilian/professor = JOB_CMO,
		/datum/job/command/warrant = JOB_CHIEF_POLICE,
		/datum/job/marine/leader/ai = JOB_SQUAD_LEADER,
		/datum/job/marine/medic/ai = JOB_SQUAD_MEDIC,
		/datum/job/marine/tl/ai = JOB_SQUAD_TEAM_LEADER,
		/datum/job/marine/smartgunner/ai = JOB_SQUAD_SMARTGUN,
		/datum/job/marine/standard/ai = JOB_SQUAD_MARINE,
	)

/datum/game_mode/colonialmarines/ai/amongus/post_setup()
	for(var/mob/new_player/np in GLOB.new_player_list)
		np.new_player_panel_proc()
	round_time_lobby = world.time
	return ..()

/datum/game_mode/colonialmarines/ai/amongus/get_roles_list()
	return ROLES_AI_AMONGUS
