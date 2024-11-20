/datum/game_mode/colonialmarines/ai/masterchef
	name = "Masterchef!"
	config_tag = "Masterchef"
	flags_round_type = MODE_INFESTATION|MODE_NEW_SPAWN|MODE_NO_XENO_EVOLVE
	votable = FALSE

	role_mappings = list(
		/datum/job/command/commander = JOB_CO,
		/datum/job/civilian/chef = JOB_MESS_SERGEANT,
		/datum/job/civilian/reporter = JOB_COMBAT_REPORTER,
		/datum/job/civilian/liaison = JOB_CORPORATE_LIAISON,
		/datum/job/command/executive = JOB_XO,
		/datum/job/command/bridge = JOB_XO,
	)

/datum/game_mode/colonialmarines/ai/masterchef/post_setup()
	for(var/mob/new_player/np in GLOB.new_player_list)
		np.new_player_panel_proc()
	round_time_lobby = world.time
	return ..()

/datum/game_mode/colonialmarines/ai/masterchef/get_roles_list()
	return GLOB.ROLES_AI_MASTERCHEF
