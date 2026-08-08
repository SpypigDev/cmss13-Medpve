/obj/structure/machinery/scp
	name = "\improper Coffee Machine"
	desc = "A generic vending machine."
	icon = 'icons/obj/structures/machinery/vending.dmi'
	icon_state = "294"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	wrenchable = FALSE
	unslashable = TRUE
	unacidable = TRUE
	explo_proof = TRUE


/obj/structure/machinery/scp/attack_remote(mob/user as mob)
	return 0

/obj/structure/machinery/scp/attack_hand(mob/user as mob)
	user.set_interaction(src)
	tgui_interact(user)

/obj/structure/machinery/scp/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "scp", name)
		ui.open()

/obj/structure/machinery/scp/ui_data(mob/user)
	var/list/data = list()
	return data

/obj/structure/machinery/scp/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

