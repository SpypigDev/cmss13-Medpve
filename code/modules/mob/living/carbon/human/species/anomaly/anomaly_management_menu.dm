GLOBAL_LIST_EMPTY(anomaly_ai_spawn_presets)

#define ANOMALY_CLASS_KETER "Keter"

// TO DO
//
// menu icons
// spritesheet config
// spawn config panel
// scss design stuff
// custom spawn framework


/datum/anomaly_ai_spawner_menu
	var/static/list/lazy_ui_data = list()

/datum/anomaly_ai_spawner_menu/New()
	if(!length(GLOB.anomaly_ai_spawn_presets))
		for(var/datum/anomaly_ai_spawn_preset/preset_type as anything in subtypesof(/datum/anomaly_ai_spawn_preset))
			if(!preset_type::name || !preset_type::anomaly_type_ref)
				continue

			if(!lazy_ui_data[preset_type::anomaly_class])
				lazy_ui_data[preset_type::anomaly_class] = list()

			var/datum/anomaly_ai_spawn_preset/preset_obj = new preset_type()
			GLOB.anomaly_ai_spawn_presets["[preset_type]"] = preset_obj

			lazy_ui_data[preset_type::anomaly_class] += list(list(
				"name" = preset_obj.name,
				"description" = preset_obj.desc,
				"path" = preset_type,
				"anomaly_type" = preset_obj.anomaly_type_ref,
				"requires_spawn_config" = preset_obj.requires_spawn_config,
			))


/datum/anomaly_ai_spawner_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyAISpawner")
		ui.open()

/datum/anomaly_ai_spawner_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/anomaly_ai_spawner_menu/ui_data(mob/user)
	var/list/data = list()

	return data

/datum/anomaly_ai_spawner_menu/ui_static_data(mob/user)
	var/list/data = list()

	data["presets"] = lazy_ui_data

	return data

/datum/anomaly_ai_spawner_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("create_ai")
			if(!params["path"])
				return

			var/datum/anomaly_ai_spawn_preset/gotten_path = text2path(params["anomaly_type_ref"])
			if(!gotten_path)
				return

			var/mob/living/carbon/human/ai_human = new()
			ai_human.set_species(gotten_path::anomaly_type_ref)
			ai_human.AddComponent(/datum/component/human_ai)
			//arm_equipment(ai_human, gotten_path::path, TRUE)

			ai_human.face_dir(ui.user.dir)
			ai_human.forceMove(get_turf(ui.user))
			ai_human.get_ai_brain().configure_custom_spawn(ai_human)
			return TRUE

/client/proc/open_anomaly_ai_spawner_panel()
	set name = "Manage Anomaly AI"
	set category = "Game Master.HumanAI"

	if(!check_rights(R_DEBUG))
		return

	if(!SSticker.mode)
		to_chat(src, SPAN_WARNING("The round hasn't started yet!"))
		return

	if(anomaly_spawn_menu)
		anomaly_spawn_menu.tgui_interact(mob)
		return

	anomaly_spawn_menu = new /datum/anomaly_ai_spawner_menu(src)
	anomaly_spawn_menu.tgui_interact(mob)

/datum/anomaly_ai_spawn_preset
	/// The GM-visible name of the equipment preset
	var/name = ""
	var/icon_state
	var/anomaly_class = ANOMALY_CLASS_KETER
	/// A short description of what the preset does. Including important equipment or usecases is a good idea
	var/desc = ""
	/// What faction the preset is related to
	var/faction = FACTION_ANOMALY
	var/anomaly_type_ref
	var/requires_spawn_config = FALSE
	var/mob_type = /mob/living/carbon/human

/datum/anomaly_ai_spawn_preset/keter
	anomaly_class = ANOMALY_CLASS_KETER

/datum/anomaly_ai_spawn_preset/keter/duplicate
	name = "Duplicate"
	icon_state = "duplicate"
	desc = "Standard Royal Marine armed with a rifle."
	anomaly_type_ref = /datum/species/anomaly/duplicate
	var/mob/living/carbon/human/alter
	requires_spawn_config = TRUE
