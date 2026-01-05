/datum/pain/anomaly
	current_pain = null
	max_pain = 1000

	threshold_mild = null
	threshold_discomforting = null
	threshold_moderate = null
	threshold_distressing = null
	threshold_severe = null
	threshold_horrible = null

	feels_pain = FALSE

/datum/pain/anomaly/apply_pain(amount = 0, type = BRUTE)
	return FALSE
