/datum/species/anomaly/duplicate
	///Used for isx(y) checking of species groups
	group = SPECIES_ANOMALY
	name = "Duplicate"
	name_plural = "Duplicates"
	uses_skin_color = TRUE
	special_body_types = TRUE
	unarmed_type = /datum/unarmed_attack/claws/shredding
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	pain_type = /datum/pain/anomaly
	flags = NO_CLONE_LOSS|NO_POISON|NO_NEURO|HAS_UNDERWEAR
	default_ai_brain_type = /datum/human_ai_brain/duplicate
	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"
	flesh_color = BLOOD_COLOR_ZOMBIE
	blood_color = BLOOD_COLOR_ZOMBIE
	bloodsplatter_type = /obj/effect/temp_visual/dir_setting/bloodsplatter/anomaly
	death_sound = 'sound/voice/scream_horror1.ogg'
	death_message = "falls still, one last inhuman screech escaping their stolen lungs..."
	speech_sounds = list('sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
	speech_chance = 100
	brute_mod = 0.5
	burn_mod = 2

//datum/species/anomaly/duplicate/handle_on_fire(humanoidmob)
//	. = ..()
//	INVOKE_ASYNC(humanoidmob, TYPE_PROC_REF(/mob, emote), pick("pain", "scream"))

/datum/emote/living/carbon/human/anomaly/duplicate/roar
	key = "roar"
	message = "releases an inhuman roar!"
	sound = 'sound/voice/xeno_praetorian_screech.ogg'
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE
