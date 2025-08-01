/// Subtype quirk that has some logic for altering the player's tongue.
/datum/quirk/tongue_quirk
	abstract_parent_type = /datum/quirk/tongue_quirk

	// Default these to null, we'll set them on subtypes of tongue quirk directly if we need them. Leave as null if you want set_say_modifiers to not set the respective null var.
	var/ask
	var/exclaim
	var/whisper
	var/yell
	var/say

/datum/quirk/tongue_quirk/add(client/client_source) // Run this on all subtypes as a blanket rule. Overwrite on subtype if need be.
	set_say_modifiers(ask, exclaim, whisper, yell, say)

/datum/quirk/tongue_quirk/remove(client/client_source) // Same as above.
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	set_say_modifiers(initial(quirk_holder.verb_ask), initial(quirk_holder.verb_exclaim), initial(quirk_holder.verb_whisper), initial(quirk_holder.verb_yell), initial(tongue.say_mod))

/// A proc to set the holder's say modifiers, used for ALL tongue_quirks in this file. Use Avian Traits as a basic example, and feline traits as a better example.
/datum/quirk/tongue_quirk/proc/set_say_modifiers(ask, exclaim, whisper, yell, say)
	if(SEND_SIGNAL(quirk_holder, COMSIG_SET_SAY_MODIFIERS)) // If quirk_holder has COMSIG_SET_SAY_MODIFIERS registered to them then early return. Used for custom tongue to prevent overwrites.
		return
	if(ask)
		quirk_holder.verb_ask = ask
	if(exclaim)
		quirk_holder.verb_exclaim = exclaim
	if(whisper)
		quirk_holder.verb_whisper = whisper
	if(yell)
		quirk_holder.verb_yell = yell
	if(say)
		var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
		tongue.say_mod = say

/datum/quirk/tongue_quirk/avian_aspect // We don't actually need to make an add for this. Tongue Quirk will do it for us.
	name = "Avian Traits"
	desc = "You're a birdbrain, or you've got a bird's brain. This will replace most other tongue-based speech quirks."
	gain_text = span_notice("BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
	lose_text = span_notice("You feel less inclined to sit on eggs.")
	mob_trait = TRAIT_AVIAN
	icon = FA_ICON_KIWI_BIRD
	value = 0
	medical_record_text = "Patient exhibits avian-adjacent mannerisms."
	// As this is a subtype of tongue_quirk, we will set these variables for our post_add to use.
	ask = "peeps"
	exclaim = "squawks"
	whisper = "murmurs"
	yell = "shrieks"
	say = "chirps"

/datum/quirk/tongue_quirk/canine_aspect // We don't actually need to make an add for this. Tongue Quirk will do it for us.
	name = "Canidae Traits"
	desc = "Bark. You seem to act like a canine for whatever reason. This will replace most other tongue-based speech quirks."
	gain_text = span_notice("B-.. Bacon strips...")
	lose_text = span_notice("You feel less abandonment issues.")
	mob_trait = TRAIT_CANINE
	icon = FA_ICON_DOG
	value = 0
	medical_record_text = "Patient seems to behave like a canine, barking and growling like a dog when agitated."
	// As this is a subtype of tongue_quirk, we will set these variables for tongue_quirk's add to use.
	ask = "arfs"
	exclaim = "wans"
	whisper = "whimpers"
	yell = "barks"
	say = "woofs"

/datum/quirk/tongue_quirk/feline_aspect
	name = "Feline Traits"
	desc = "You happen to act like a feline, for whatever reason. This will replace most other tongue-based speech quirks."
	gain_text = span_notice("Nya could go for some catnip right about now...")
	lose_text = span_notice("You feel less attracted to lasers.")
	medical_record_text = "Patient seems to possess behavior much like a feline."
	mob_trait = TRAIT_FELINE
	icon = FA_ICON_CAT
	// As this is a subtype of tongue_quirk, we will set these variables for tongue_quirk's add to use.
	ask = "mrrps"
	exclaim = "mrrowls"
	whisper = "purrs"
	yell = "yowls"
	say = "meows"

/datum/quirk/tongue_quirk/feline_aspect/add(client/client_source)
	. = ..()
	ADD_TRAIT(quirk_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

/datum/quirk/tongue_quirk/feline_aspect/remove(client/client_source)
	. = ..()
	REMOVE_TRAIT(quirk_holder, TRAIT_WATER_HATER, QUIRK_TRAIT)

// Put more complex quirks below this comment, ideally.

/datum/quirk/tongue_quirk/rodential_aspect
	name = "Rodential Traits"
	desc = "Squeak! You happen to act like a rodent, for whatever reason. "
	gain_text = span_notice("You feel especially rodential today.")
	lose_text = span_notice("You feel a lot less rodential.")
	medical_record_text = "Patient expressed desires to 'dig into' the insulation."
	value = 0
	mob_trait = TRAIT_RODENTIAL
	icon = FA_ICON_MOUSE
	// nova_stars_only = TRUE You can kill yourself with this quirk very easily so I was advised to make it a Nova Star quirk, which is fair, but you can also just, do the same with wirecutters. We'll see how people act with it first.
	ask = "sqweeks"
	exclaim = "squees"
	whisper = "snuffles"
	yell = "shrieks"
	say = "squeaks"

// Edit /area/station/maintenance to have a mood bonus for rodents. If you have a better way to do this please suggest it. This stops other things from applying positive moods in maintenance (general) although we have nothing that does that.
/area/station/maintenance
	mood_bonus = 5
	mood_message = "It's like a maze!"
	mood_trait = TRAIT_RODENTIAL

/// Signal handler, INVOKE_ASYNCs chew_wire if combat mode is on and an accessible wire is present.
/datum/quirk/tongue_quirk/rodential_aspect/proc/chew_invoker(null, obj/structure/cable/target)
	SIGNAL_HANDLER

	if(get_dist(quirk_holder, target) > 1)
		return
	if(!istype(target, /obj/structure/cable))
		return

	var/turf/open/floor/floor = get_turf(target)
	if(floor.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
		var/obj/item/held = quirk_holder.get_active_held_item()
		if(!held && !quirk_holder.combat_mode == 0)
			if(!quirk_holder.is_mouth_covered(ITEM_SLOT_MASK) && !quirk_holder.is_mouth_covered(ITEM_SLOT_HEAD))
				INVOKE_ASYNC(src, PROC_REF(chew_wire), target)

/// Chews through a cable with a high chance of electrocution (code stolen directly from mouse.dm just with a do_after thrown ontop)
/datum/quirk/tongue_quirk/rodential_aspect/proc/chew_wire(obj/structure/cable/target) // Chew wire like the stupid little death prone rodent you are.
	if(do_after(quirk_holder, 2 SECONDS, target, interaction_key = "rodential_aspect_chew_wire_proc", max_interact_count = 1))
		var/shock_damage = target.powernet.get_electrocute_damage()
		if(target.avail() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE) && prob(85) && shock_damage > 0)
			quirk_holder.visible_message(
				span_warning("[quirk_holder] chews through \the [target]. [quirk_holder.p_Theyre()] toast!"),
				span_userdanger("As you bite deeply into [target], you suddenly realize this may have been a bad idea."),
				span_hear("You hear electricity crack."),
			)
			quirk_holder.electrocute_act(shock_damage, target, 1, flags = SHOCK_NOGLOVES, )
		else
			quirk_holder.visible_message(
				span_warning("[quirk_holder] chews through \the [target]."),
				span_notice("You chew through \the [target]."),
			)

		playsound(target, 'sound/effects/sparks/sparks2.ogg', 100, TRUE)
		target.deconstruct()

/datum/quirk/tongue_quirk/rodential_aspect/add(client/client_source)
	. = ..()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	RegisterSignal(quirk_holder, COMSIG_MOB_CLICKON, PROC_REF(chew_invoker)) // This is a slightly unhinged way to do this but it works, was very easy, and feels fairly natural in round.
	tongue.liked_foodtypes = tongue.liked_foodtypes + DAIRY // Rodents don't actually like cheese all that much but the stereotype is set in stone and we already have a rat tongue in the codebase that likes cheese so why not?

/datum/quirk/rodential_aspect/remove(client/client_source)
	. = ..()
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	UnregisterSignal(quirk_holder, COMSIG_MOB_CLICKON)
	tongue.liked_foodtypes = tongue.liked_foodtypes - DAIRY

/datum/quirk/tongue_quirk/custom_tongue
	name = "Custom Tongue"
	desc = "Your tongue is not standard. It has a shape and texture that is unique to you, affecting the way you speak."
	gain_text = span_notice("Your tongue feels normal.")
	lose_text = span_notice("Your tongue feels... Different.")
	medical_record_text = "Patient speaks a little funny."
	value = 0
	icon = FA_ICON_FACE_GRIN_TONGUE

// Parent preference for convenience. Everything that runs on this (Such as the serialize code) will apply to the remainder of our preferences.
/datum/preference/text/custom_tongue
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "custom_tongue"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	maximum_value_length = 64 // We may want to lower this for sanity.

/datum/preference/text/custom_tongue/serialize(input)
	var/regex/unwanted_characters = regex(@"[^a-z]") // Prevent people from inputting slop into my text fields. No, you CAN'T have an eggplant emoji for when you whisper.
	if(unwanted_characters.Find(input))
		return null // No fun allowed.
	return htmlrendertext(input)

/datum/preference/text/custom_tongue/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Custom Tongue" in preferences.all_quirks

/datum/preference/text/custom_tongue/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/text/custom_tongue/ask
	savefile_key = "custom_tongue_ask"

/datum/preference/text/custom_tongue/exclaim
	savefile_key = "custom_tongue_exclaim"

/datum/preference/text/custom_tongue/whisper
	savefile_key = "custom_tongue_whisper"

/datum/preference/text/custom_tongue/yell
	savefile_key = "custom_tongue_yell"

/datum/preference/text/custom_tongue/say
	savefile_key = "custom_tongue_say"

/datum/quirk_constant_data/custom_tongue
	associated_typepath = /datum/quirk/tongue_quirk/custom_tongue
	customization_options = list(
		/datum/preference/text/custom_tongue/ask,
		/datum/preference/text/custom_tongue/exclaim,
		/datum/preference/text/custom_tongue/whisper,
		/datum/preference/text/custom_tongue/yell,
		/datum/preference/text/custom_tongue/say
	)

/// Used to set the quirk holder's say modifiers based on the client preferences. Runs on quirk add and on COMSIG_SET_SAY_MODIFIERS signal (sent in /obj/item/organ/tongue/proc/set_say_modifiers())
/datum/quirk/tongue_quirk/custom_tongue/proc/set_custom_tongue() // This proc will run at most three times depending on the client prefs.
	SIGNAL_HANDLER

	var/client/client_source = quirk_holder.client

	var/new_ask = client_source?.prefs.read_preference(/datum/preference/text/custom_tongue/ask)
	if (new_ask)
		quirk_holder.verb_ask = LOWER_TEXT(new_ask)

	var/new_exclaim = client_source?.prefs.read_preference(/datum/preference/text/custom_tongue/exclaim)
	if (new_exclaim)
		quirk_holder.verb_exclaim = LOWER_TEXT(new_exclaim)

	var/new_whisper = client_source?.prefs.read_preference(/datum/preference/text/custom_tongue/whisper)
	if (new_whisper)
		quirk_holder.verb_whisper = LOWER_TEXT(new_whisper)

	var/new_yell = client_source?.prefs.read_preference(/datum/preference/text/custom_tongue/yell)
	if (new_yell)
		quirk_holder.verb_yell = LOWER_TEXT(new_yell)

	var/new_say = client_source?.prefs.read_preference(/datum/preference/text/custom_tongue/say)
	if (new_say)
		var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
		tongue.say_mod = LOWER_TEXT(new_say)

	return TRUE

/datum/quirk/tongue_quirk/custom_tongue/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_SET_SAY_MODIFIERS, PROC_REF(set_custom_tongue)) // Only register the signal, the post_add will trigger the proc.
	. = ..()

/datum/quirk/tongue_quirk/custom_tongue/remove(client/client_source)
	UnregisterSignal(quirk_holder, COMSIG_SET_SAY_MODIFIERS)
	. = ..()
