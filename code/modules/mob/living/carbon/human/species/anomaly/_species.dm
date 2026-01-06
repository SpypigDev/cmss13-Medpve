/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species/anomaly
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = SPECIES_ANOMALY
	name_plural = "Anomalies"

/datum/species/anomaly/larva_impregnated(obj/item/alien_embryo/embryo)
	return

/// Override to add an emote panel to a species
/datum/species/anomaly/open_emote_panel()
	return

/datum/emote/living/carbon/human/anomaly
	species_type_allowed_typecache = list(/datum/species/anomaly)
	emote_type = EMOTE_AUDIBLE

/datum/species/anomaly/handle_npc(mob/living/carbon/human/H)
	return

/datum/species/anomaly/attempt_rock_paper_scissors()
	return

/datum/species/anomaly/attempt_high_five()
	return

/datum/species/anomaly/attempt_fist_bump()
	return

/datum/species/anomaly/apply_signals(mob/living/carbon/human/H)
	return

//Only used by horrors at the moment. Only triggers if the mob is alive and not dead.
/datum/species/anomaly/handle_unique_behavior(mob/living/carbon/human/H)
	return

// Used for checking on how each species would scream when they are burning
/datum/species/anomaly/handle_on_fire(humanoidmob)
	// call this for each species so each has their own unique scream options when burning alive
	// heebie-jebies made me do all this effort, I HATE YOU
	return

/datum/species/anomaly/handle_head_loss(mob/living/carbon/human/human)
	return

/datum/species/anomaly/handle_paygrades()
	return
