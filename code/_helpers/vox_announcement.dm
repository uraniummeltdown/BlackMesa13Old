//VOX ANNOUNCEMENT SYSTEM -- GENERIC PROCS
//PORTED FROM /TG/ BY FLATGUB OVER THE COURSE OF TWO PAINFUL DAYS.

var/announcing_vox = 0 // Stores the time of the last announcement
var/const/VOX_CHANNEL = 200
var/const/VOX_DELAY = 10

/////////////////////////////
/// VOX ANNOUNCEMENT HELP ///
/////////////////////////////
// proc used to show an example of all available words and allows the user to preview words

proc/vox_announcement_help()

	var/dat = "Here is a list of words you can type into the 'VOX Announcement' button to create sentences to vocally announce to everyone in the facility.<BR> \
	<LI>You can only say 30 words for every announcement.</LI>\
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI></UL>\
	<font class='bad'>WARNING:</font><BR>Misuse of the announcement system will get you job banned.<HR>"

	var/index = 0
	for(var/word in vox_words)
		index++
		dat += "[capitalize(word)]"
		if(index != vox_words.len)
			dat += " / "

	var/datum/browser/popup = new(usr, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()

////////////////////////////
/// SAY_VOX_ANNOUNCEMENT ///
////////////////////////////
// proc provided with a message, check for invalid words and schedule announcements. The main method.
// message - text to speak

/proc/say_vox_announcement(message)
	var/typingtime = 10

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!vox_words[word])
			incorrect_words += word

	if(incorrect_words.len)
		usr << "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>"
		return


	log_game("[key_name(usr)] made a vocal announcement with the following message: [message].")

	//Force assets to be loaded into cache before playing, incase of unloaded files
	for(var/word in words)
		usr << browse_rsc(vox_words[word])

	usr << "You enter the announcement"

	spawn(typingtime)
		for(var/word in words)
			play_vox_word(word, null)

		//Just incase VOX *DOES* fail, all players get a text version of the announcement
		for(var/mob/M in player_list)
			if(M.client)
				M << "<b><font size = 2><font color = red>AI announcement</b>:</font color> [message]</font size>"



/////////////////////
/// PLAY VOX WORD ///
/////////////////////
// Proc which takes a word and plays the appropriate audio file to the appropriate people. The backbone of this operation.
/proc/play_vox_word(word, mob/only_listener)

	word = lowertext(word)

	if(vox_words[word])

		var/sound_file = vox_words[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = VOX_CHANNEL)
		voice.status = SOUND_STREAM

 		// If there is no single listener, broadcast to everyone
		if(!only_listener)
			// Play voice for all players
			for(var/mob/M in player_list)
				if(M.client && !M.ear_deaf) //People must be clients and people must not be deaf to hear our fabulous annoucements
					M << voice
		else
			only_listener << voice
		return 1
	return 0

