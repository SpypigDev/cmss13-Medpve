#define MEETING_READY 0
#define MEETING_ACTIVE 1
GLOBAL_VAR_INIT(meeting_state, MEETING_READY)

/obj/structure/machinery/emergency_meeting
	name = "Emergency Meeting"
	icon_state = "big_red_button_tablev"
	unslashable = TRUE
	unacidable = TRUE
	COOLDOWN_DECLARE(meeting_lockdown)

/obj/structure/machinery/emergency_meeting/ex_act(severity)
	return FALSE

/obj/structure/machinery/emergency_meeting/attack_remote(mob/user as mob)
	return FALSE

/obj/structure/machinery/emergency_meeting/attack_alien(mob/user as mob)
	return FALSE

/obj/structure/machinery/emergency_meeting/attackby(obj/item/attacking_item, mob/user)
	return attack_hand(user)

/obj/structure/machinery/emergency_meeting/attack_hand(mob/living/user)
	if(isxeno(user))
		return FALSE
	if(!allowed(user))
		to_chat(user, SPAN_DANGER("Access Denied"))
		flick(initial(icon_state) + "-denied", src)
		return FALSE

	if(!COOLDOWN_FINISHED(src, meeting_lockdown))
		to_chat(user, SPAN_BOLDWARNING("Emergency Meeting procedures are on cooldown! They will be ready in [COOLDOWN_SECONDSLEFT(src, meeting_lockdown)] seconds!"))
		return FALSE

	add_fingerprint(user)
	emergency_meeting(user)
	COOLDOWN_START(src, meeting_lockdown, 1 MINUTES)

/obj/structure/machinery/door/poddoor/almayer/meeting
	name = "Meeting Room Containment Airlock"
	density = FALSE

/obj/structure/machinery/door/poddoor/almayer/meeting/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MEETING, PROC_REF(close))
	RegisterSignal(SSdcs, COMSIG_GLOB_MEETING_LIFT, PROC_REF(open))

/obj/structure/machinery/door/poddoor/almayer/meeting/white
	icon_state = "w_almayer_pdoor1"
	base_icon_state = "w_almayer_pdoor"

/client/proc/admin_meeting_alert()
	set name = "Declare Emergency Meeting"
	set category = "Admin.Ship"

	if(!admin_holder ||!check_rights(R_EVENT))
		return FALSE

	var/prompt = tgui_alert(src, "Are you sure you want to trigger an Emergency Meeting?", "Choose.", list("Yes", "No"), 20 SECONDS)
	if(prompt != "Yes")
		return FALSE

	prompt = tgui_alert(src, "Do you want to use a custom announcement?", "Choose.", list("Yes", "No"), 20 SECONDS)
	if(prompt == "Yes")
		var/whattoannounce = tgui_input_text(src, "Please enter announcement text.", "what?")
		emergency_meeting(usr, whattoannounce, TRUE)
	else
		emergency_meeting(usr, admin = TRUE)
	return TRUE

/proc/emergency_meeting(mob/user, message, admin = FALSE)
	if(IsAdminAdvancedProcCall())
		return PROC_BLOCKED

	var/log = "[key_name(user)] triggered emergency meeting!"
	var/ares_log = "[user.name] triggered Emergency Meeting"
	if(!message)
		message = "ATTENTION! \n\nEMERGENCY MEETING REQUESTED. \n\nREPORT TO THE CONFERENCE ROOM."
	else
		log = "[key_name(user)] triggered an Emergency meeting! (Using a custom announcement)."
	if(admin)
		log += " (Admin Triggered)."
		ares_log = "[MAIN_AI_SYSTEM] triggered an Emergency Meeting."

	switch(GLOB.meeting_state)
		if(MEETING_READY)
			GLOB.meeting_state = MEETING_ACTIVE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MEETING)
		if(MEETING_ACTIVE)
			GLOB.meeting_state = MEETING_READY
			message = "ATTENTION! \n\nEMERGENCY MEETING ENDED."
			log = "[key_name(user)] ended emergency meeting!"
			ares_log = "[user.name] ended an Emergency Meeting."
			if(admin)
				log += " (Admin Triggered)."
				ares_log = "[MAIN_AI_SYSTEM] ended an Emergency Meeting."

			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MEETING_LIFT)

	shipwide_ai_announcement(message, MAIN_AI_SYSTEM, 'sound/effects/biohazard.ogg')
	message_admins(log)
	log_ares_security("Emergency Meeting", ares_log)

#undef MEETING_READY
#undef MEETING_ACTIVE
