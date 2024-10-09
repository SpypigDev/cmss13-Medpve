//Provost Enforcer
/datum/job/special/provost/enforcer
	title = JOB_PROVOST_ENFORCER

//Provost Team Leader
/datum/job/special/provost/tml
	title = JOB_PROVOST_TML

//Provost Advisor
/datum/job/special/provost/advisor
	title = JOB_PROVOST_ADVISOR

//Provost Inspector
/datum/job/special/provost/inspector
	title = JOB_PROVOST_INSPECTOR

//Provost Marshal
/datum/job/special/provost/marshal
	title = JOB_PROVOST_MARSHAL
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADMIN_NOTIFY
	gear_preset = /datum/equipment_preset/uscm_event/provost/marshal
	total_positions = 1
	spawn_positions = 1

/obj/effect/landmark/start/marshal
	name = JOB_PROVOST_MARSHAL
	icon_state = "co_spawn"
	job = /datum/job/special/provost/marshal

//Provost Sector
/datum/job/special/provost/marshal/sector
	title = JOB_PROVOST_SMARSHAL

//Provost Chief Marshal
/datum/job/special/provost/marshal/chief
	title = JOB_PROVOST_CMARSHAL
