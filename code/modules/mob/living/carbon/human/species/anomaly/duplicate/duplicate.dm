/datum/species/anomaly/duplicate
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = "Duplicate"
	name_plural = "Duplicates"

	eyes = "eyes_s"   // Icon for eyes.

	//datum/unarmed_attack/unarmed    // For empty hand harm-intent attack
	//datum/unarmed_attack/secondary_unarmed // For empty hand harm-intent attack if the first fails.
	//gluttonous // Can eat some mobs. 1 for monkeys, 2 for people.

	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite
	pain_type = /datum/pain/human
	stamina_type = null

	insulated = TRUE

	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"

	bloodsplatter_type = /obj/effect/temp_visual/dir_setting/bloodsplatter/anomaly
	death_sound = 'sound/voice/scream_horror1.ogg'
	death_message = "seizes up and falls limp, their eyes dead and lifeless..."

	total_health = 100  //new maxHealth

	default_lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	flags_sight = 0

	brute_mod = 0.5
	burn_mod = 2

	flags = 0    // Various specific features.

	blood_color = BLOOD_COLOR_ZOMBIE
	flesh_color = "#110e0b"

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
