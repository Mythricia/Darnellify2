--[[
Sound files and their properties are collected here.
The structure of these tables are hopefully fairly self-explanatory.

Things to note:

File paths are relative to the "Sounds" folder. That is, if you want to add a file "Ding.mp3",
and that file resides inside the Sounds folder, you simply put "Ding.mp3" as the file path.

If you have a file in a subfolder: "Sounds\FunnierSounds\TheFunniest.mp3", then you would put
"FunnierSounds\\TheFunniest.mp3" as the file path. Notice the double backslashes: they are mandatory!

Every "event" is a collection, and can contain many different sample variants.
To add another sample to the pool, simply add another line with the new file path. That's it!

An example:
-----------

	library.interface["Mailbox_Open"] = {
		{path = "Interface\\Mail_Open_1.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_2.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_3.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_4.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_5.mp3", cooldown = 5},

		cooldown = 1,
	}


This is the collection for the "Mailbox_Open" event. The name is self-explanatory.
It contains 5 different samples! Each time the event fires, a random sample will play.

Each sample can have it's own Cooldown attribute (measured in seconds).

Additionally, a collection as a whole can have a cooldown; no samples within will replay before it expires.
These cooldowns can be mixed and matched as you desire.

The cooldown can be set to 0.
--]]


-- This table holds all of the sounds
local library = {}


-- Interface Panel events (Windows, panels, etc)
library.interface = {}
library.interface["Mailbox_Open"] = {
	{path = "Interface\\Mail_Open.mp3", cooldown = 2},

	cooldown = 5,
}


-- Mount events.
library.mounts = {}
library.mounts["Dismount"] = {
	{path = "Mounts\\Car_Alarm.mp3", cooldown = 1},
}

--[[
Mount Music works slightly differently. Mounts are divided into categories.
Each category shares a pool of clips that will play, if ANY of the mounts inside the category is used.

Each category contains a "music" table, and a "mounts" array.

The "music" table is a collection of clips, that works exactly like the other collections.
You can add new ones, and a random one will play when you use any of the mounts listed in the "mounts" array.

The "mounts" array, is just a list of spellID's (NOT mountID's!!!) that belong to that category.
You can add new spellID's to the category if you like. The "cooldown" in this case is treated more like a duration.
Recommended you put the "cooldown" to be exactly equal to the clip duration.

You can create brand new caterogies (named anything you want) and add mount spellID's to them, and they'll work automatically.
--]]
library.mounts["Chocobo"] =
{
	music = {
		{path = "Mounts\\Chocobo_1.mp3", cooldown = 30},
	},

	mounts = {
		35027,  --"Swift Purple Hawkstrider"
	}
}



-- Passing the whole library back over to the core Darnellify addon code
local _, addonTable = ...
addonTable.library = library