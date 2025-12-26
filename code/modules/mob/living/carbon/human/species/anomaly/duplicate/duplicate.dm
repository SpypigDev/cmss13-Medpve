/datum/species/anomaly/duplicate
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = "Duplicate"
	name_plural = "Duplicates"

	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite
	pain_type = /datum/pain/human

	default_ai_brain_type = /datum/human_ai_brain/duplicate

	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"

	bloodsplatter_type = /obj/effect/temp_visual/dir_setting/bloodsplatter/anomaly
	death_sound = 'sound/voice/scream_horror1.ogg'
	death_message = "falls still, one last inhuman screech escaping their stolen lungs..."

	brute_mod = 0.5
	burn_mod = 2
