/datum/species/anomaly/shadow_men
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = "Shadow Man"
	name_plural = "Shadow Men"
	icobase = 'icons/mob/humans/species/r_anomaly.dmi' // Normal icon set.
	deform = 'icons/mob/humans/species/r_anomaly.dmi' // Mutated icon set.
	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite
	pain_type = /datum/pain/anomaly
	stamina_type = /datum/stamina
	flags = NO_CLONE_LOSS|NO_POISON|NO_NEURO|NO_SLIP|NO_BLOOD|NO_BREATHE|NO_SHRAPNEL
	default_ai_brain_type = /datum/human_ai_brain/shadow_men
	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"
	flesh_color = null
	blood_color = null
	blood_mask = null
	base_color = COLOR_BLACK
	hair_color = COLOR_BLACK
	death_sound = 'sound/voice/4_xeno_roars.ogg'
	death_message = "falls still, one last inhuman screech escaping their stolen lungs..."
	has_fine_manipulation = FALSE
	insulated = TRUE
	brute_mod = 0.5
	burn_mod = 2
	mob_inherent_traits = list(TRAIT_FOREIGN_BIO, TRAIT_UNSTRIPPABLE, TRAIT_FORCED_STANDING, TRAIT_HARDCORE)
	knock_down_reduction = -1
	stun_reduction = -1
	knock_out_reduction = -1
	weed_slowdown_mult = 0
	acid_blood_dodge_chance = 100

	has_organ = list(
		"heart" = /datum/internal_organ/heart,
		"eyes" =  /datum/internal_organ/eyes
		)


