/*
	*Blood brother is a team orientated antagonist that is meant to complete traitor style objectives using just their team members and game knowledge.
	*blood brother should never be without a team.
	*/
/datum/antagonist/brother
	name = "Brother"
	roundend_category = "Brother"
	job_rank = ROLE_BROTHER
	var/datum/team/brother_team/team //the owning team is stored here.
/*
	* This proc is called when a new brother team is created.
	*/
/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	owner.objectives += team.objectives
	owner.special_role = ROLE_BROTHER
	update_brother_icons_added()
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	owner.objectives -= team.objectives
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer a blood brother!</span>")
	owner.special_role = null
	update_brother_icons_removed()
	return ..()

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<b>Your designated meeting area:</b> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/list/brothers = team.members - owner
	var/brother_text = english_list(brothers)
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role] of [brother_text].</span>")
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together!")
	owner.announce_objectives()
	antag_memory += "<b>Your brothers are</b>: [brother_text].<br>"
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/brother/proc/update_brother_icons_added(datum/mind/brother_mind)
	if(locate(/datum/objective/hijack) in owner.objectives)
		var/datum/atom_hud/antag/hijackhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		hijackhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudhijackbrother")
	else
		var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
		traitorhud.join_hud(owner.current, null)
		set_antag_hud(owner.current, "hudbrother")

/datum/antagonist/brother/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current, null)
	set_antag_hud(owner.current, null)
