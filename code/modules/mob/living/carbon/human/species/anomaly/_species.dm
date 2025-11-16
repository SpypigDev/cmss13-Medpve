/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species/anomaly
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = SPECIES_ANOMALY
	name_plural = "Anomalies"

	icobase = 'icons/mob/humans/species/r_human.dmi' // Normal icon set.
	deform = 'icons/mob/humans/species/r_def_human.dmi' // Mutated icon set.

	eyes = "eyes_s"   // Icon for eyes.

	//datum/unarmed_attack/unarmed    // For empty hand harm-intent attack
	//datum/unarmed_attack/secondary_unarmed // For empty hand harm-intent attack if the first fails.
	//gluttonous // Can eat some mobs. 1 for monkeys, 2 for people.

	unarmed_type = /datum/unarmed_attack
	secondary_unarmed_type = /datum/unarmed_attack/bite
	pain_type = /datum/pain/human
	stamina_type = /datum/stamina

	speech_sounds = list()
	speech_chance = 0
	has_fine_manipulation = TRUE
	can_emote = TRUE
	insulated = FALSE

	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"
	remains_type = /obj/effect/decal/remains/xeno
	bloodsplatter_type = /obj/effect/temp_visual/dir_setting/bloodsplatter/human
	death_sound = null
	death_message = "seizes up and falls limp, their eyes dead and lifeless..."

	breath_type = "oxygen"
	poison_type = "phoron"
	exhale_type = "carbon_dioxide"

	total_health = 100  //new maxHealth

	cold_level_1 = 260  // Cold damage level 1 below this point.
	cold_level_2 = 240  // Cold damage level 2 below this point.
	cold_level_3 = 120  // Cold damage level 3 below this point.

	heat_level_1 = 360  // Heat damage level 1 above this point.
	heat_level_2 = 400  // Heat damage level 2 above this point.
	heat_level_3 = 1000 // Heat damage level 2 above this point.

	body_temperature = 310.15 //non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	reagent_tag  //Used for metabolizing reagents.

	darksight = 2
	default_lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	flags_sight = 0

	brute_mod = null // Physical damage reduction/malus.
	burn_mod = null  // Burn damage reduction/malus.

	flags = 0    // Various specific features.

	blood_color = BLOOD_COLOR_HUMAN //Red.
	flesh_color = "#FFC896" //Pink.
	base_color   //Used when setting species.
	hair_color   //If the species only has one hair color

	//Used in icon caching.
	race_key = 0
	icon_template = 'icons/mob/humans/template.dmi'


	has_organ = list(
		"heart" = /datum/internal_organ/heart,
		"lungs" = /datum/internal_organ/lungs,
		"liver" = /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" = /datum/internal_organ/brain,
		"eyes" =  /datum/internal_organ/eyes
		)

	/// Factor of reduction of  KnockDown duration.
	knock_down_reduction = 1
	/// Factor of reduction of Stun duration.
	stun_reduction = 1
	/// Factor of reduction of  KnockOut duration.
	knock_out_reduction = 1

	/// If different from 1, a signal is registered on post_spawn().
	weed_slowdown_mult = 1

	acid_blood_dodge_chance = 0

	blood_mask = 'icons/effects/blood.dmi'

	mob_flags = NO_FLAGS // The mob flags to give their mob

	ignores_stripdrag_flag = FALSE

	has_species_tab_items = FALSE

/datum/species/anomaly/New()
	if(unarmed_type)
		unarmed = new unarmed_type()
	if(secondary_unarmed_type)
		secondary_unarmed = new secondary_unarmed_type()

/datum/species/anomaly/larva_impregnated(obj/item/alien_embryo/embryo)
	return

/// Override to add an emote panel to a species
/datum/species/anomaly/open_emote_panel()
	return

/datum/species/anomaly/handle_npc(mob/living/carbon/human/H)
	set waitfor = FALSE
	return

/datum/species/anomaly/attempt_rock_paper_scissors()
	return

/datum/species/anomaly/attempt_high_five()
	return

/datum/species/anomaly/attempt_fist_bump()
	return

//things to change after we're no longer that species
/datum/species/anomaly/post_species_loss(mob/living/carbon/human/H)
	for(var/T in mob_inherent_traits)
		REMOVE_TRAIT(src, T, TRAIT_SOURCE_SPECIES)

/datum/species/anomaly/remove_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		remove_verb(H, inherent_verbs)

/datum/species/anomaly/add_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		add_verb(H, inherent_verbs)

/datum/species/anomaly/handle_post_spawn(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	add_inherent_verbs(H)
	apply_signals(H)

/datum/species/anomaly/apply_signals(mob/living/carbon/human/H)
	return

/datum/species/anomaly/handle_death(mob/living/carbon/human/H)
/*
	if(flags & IS_SYNTHETIC)
		H.h_style = ""
		spawn(100)
			if(!H) return
			H.update_hair()
	return
*/

/datum/species/anomaly/handle_dead_death(mob/living/carbon/human/H, gibbed)

/datum/species/anomaly/handle_cryo(mob/living/carbon/human/H)

//Only used by horrors at the moment. Only triggers if the mob is alive and not dead.
/datum/species/anomaly/handle_unique_behavior(mob/living/carbon/human/H)
	return

// Used to update alien icons for aliens.
/datum/species/anomaly/handle_login_special(mob/living/carbon/human/H)
	return

// As above.
/datum/species/anomaly/handle_logout_special(mob/living/carbon/human/H)
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
