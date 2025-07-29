// Edit /area/station/maintenance to have a mood bonus for rodents. If you have a better way to do this please suggest it. This stops other things from applying positive moods in maintenance (general) although we have nothing that does that.
/area/station/maintenance
	mood_bonus = 5
	mood_message = "It's like a maze!"
	mood_trait = TRAIT_RODENTIAL

/datum/quirk/rodential_aspect
	name = "Rodential Traits"
	desc = "Squeak! You happen to act like a rodent, for whatever reason. "
	gain_text = span_notice("You feel especially rodential today.")
	lose_text = span_notice("You no longer desire to eat a bunch of baking soda and then oil.")
	medical_record_text = "Patient expressed desires to 'dig into' the insulation."
	value = 0
	mob_trait = TRAIT_RODENTIAL
	icon = FA_ICON_MOUSE
	// nova_stars_only = TRUE You can kill yourself with this quirk very easily so I was advised to make it a Nova Star quirk, which is fair.

/// Signal handler, INVOKE_ASYNCs chew_wire if combat mode is on and an accessible wire is present.
/datum/quirk/rodential_aspect/proc/chew_invoker(null, obj/structure/cable/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/structure/cable))
		return

	var/turf/open/floor/floor = get_turf(target)
	if(floor.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
		var/obj/item/held = quirk_holder.get_active_held_item()
		if(!held && !quirk_holder.combat_mode == 0)
			if(!quirk_holder.is_mouth_covered(ITEM_SLOT_MASK) && !quirk_holder.is_mouth_covered(ITEM_SLOT_HEAD))
				INVOKE_ASYNC(src, PROC_REF(chew_wire), target)

/// Chews through a cable with a high chance of electrocution (code stolen directly from mouse.dm just with a do_after thrown ontop)
/datum/quirk/rodential_aspect/proc/chew_wire(obj/structure/cable/target) // Chew wire like the stupid little death prone rodent you are.
	quirk_holder.visible_message(
		span_warning("[quirk_holder] stares at \the [target] with a hungry gaze!"),
		span_notice("You wind your head back, preparing to chew through \the [target]."),
	)
	if(do_after(quirk_holder, 2 SECONDS, target))
		if(target.avail() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE) && prob(85))
			quirk_holder.visible_message(
				span_warning("[quirk_holder] chews through \the [target]. [quirk_holder.p_Theyre()] toast!"),
				span_userdanger("As you bite deeply into [target], you suddenly realize this may have been a bad idea."),
				span_hear("You hear electricity crack."),
			)
			quirk_holder.electrocute_act(quirk_holder.maxHealth * 1.5, target, 1, flags = SHOCK_NOGLOVES, )
		else
			quirk_holder.visible_message(
				span_warning("[quirk_holder] chews through \the [target]."),
				span_notice("You chew through \the [target]."),
			)

		playsound(target, 'sound/effects/sparks/sparks2.ogg', 100, TRUE)
		target.deconstruct()

/datum/quirk/rodential_aspect/add_unique()
	RegisterSignal(quirk_holder, COMSIG_MOB_CLICKON, PROC_REF(chew_invoker)) // This is a slightly unhinged way to do this but it works, was very easy, and feels fairly natural in round.
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	tongue.set_say_modifiers(quirk_holder, say = "squeaks", ask = "sqweeks", whisper = "snuffles", exclaim = "squees", yell = "shrieks")
	tongue.liked_foodtypes = tongue.liked_foodtypes + DAIRY // Rodents don't actually like cheese all that much but the stereotype is set in stone and we already have a rat tongue in the codebase that likes cheese so why not?

/datum/quirk/rodential_aspect/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_CLICKON)
	var/obj/item/organ/tongue/tongue = quirk_holder.get_organ_slot(ORGAN_SLOT_TONGUE)
	tongue.set_say_modifiers(quirk_holder, say = initial(tongue.say_mod))
	tongue.liked_foodtypes = tongue.liked_foodtypes - DAIRY
