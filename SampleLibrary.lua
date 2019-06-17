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

	["Mailbox_Open"] = {
		{path = "Interface\\Mail_Open_1.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_2.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_3.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_4.mp3", cooldown = 5},
		{path = "Interface\\Mail_Open_5.mp3", cooldown = 5},

		cooldown = 1,
		-- TODO: add delay attribute
		-- TODO: We could have a reset attribute, containing a string array of conditional cd resets ("target" etc)
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


-- Interface events (Windows, panels, etc)
library.interface = {
	["Mailbox_Open"] = {
		{path = "Interface\\Mail_Open.mp3"},
	},
	["Mailbox_Close"] = {
		{path = "Interface\\Mail_Close.mp3"},
	},

	["Transmog_Open"] = {
		{path = "Interface\\Transmog_Open.mp3"},
	},
	["Transmog_Close"] = {
		{path = "Interface\\Transmog_Close.mp3"},
	},

	["GuildBank_Open"] = {
		{path = "Interface\\GuildBank_Open.mp3"},
	},
	["GuildBank_Close"] = {
		{path = "Interface\\GuildBank_Close.mp3"},
	},

	["Void_Open"] = {
		{path = "Interface\\VoidStorage_Open.mp3"},
	},
	["Void_Close"] = {
		{path = "Interface\\VoidStorage_Close.mp3"},
	},

	["AH_Open"] = {
		{path = "Interface\\Auction_House_Open.mp3"},
	},
	["AH_Close"] = {
		{path = "Interface\\Auction_House_Close.mp3"},
	},

	["Bank_Open"] = {
		{path = "Interface\\Bank_Open.mp3"},
	},
	["Bank_Close"] = {
		{path = "Interface\\Bank_Close.mp3"},
	},

	["Vendor_Open"] = {
		{path = "Interface\\Merchant_Open.mp3"},
	},
	["Vendor_Close"] = {
		{path = "Interface\\Merchant_Close.mp3"},
	},
}


-- Player events
library.player = {
	["Player_LevelUp"] = {
		{path = "Player\\Player_Level_Up_1.mp3"},
	},

	["DuelRequested"] = {
		{path = "Player\\You_Have_Requested_A_Duel.mp3"},
	},
	["DuelCancelled"] = {
		{path = "Player\\Duel_Cancelled.mp3"},
	}
}


-- Error message events ("Too far away" etc)
library.error = {
	["GenericNoTarget"] = {
		{path = "Error\\You_Have_No_Target.mp3", cooldown = 3},
	},

	["TooFarAway"] = {
		{path = "Error\\You_Are_Too_Far_Away.mp3", cooldown = 3},
	},
	["GetCloser"] = {
		{path = "Error\\You_Need_To_Be_Closer_To_Interact_With_That_Target.mp3", cooldown = 10},
	},
	["OutOfRange"] = {
		{path = "Error\\Out_Of_Range.mp3", cooldown = 5},
	},


	["CantAttack_Stunned"] = {
		{path = "Error\\Cant_Attack_While_Stunned.mp3", cooldown = 3},
	},
	["CantAttack_Pacified"] = {
		{path = "Error\\Cant_Attack_While_Pacified.mp3", cooldown = 3},
	},
	["CantAttack_Fleeing"] = {
		{path = "Error\\Cant_Attack_While_Fleeing.mp3", cooldown = 3},
	},
	["CantAttack_Dead"] = {
		{path = "Error\\Cant_Attack_While_Dead.mp3", cooldown = 3},
	},
	["CantAttack_Confused"] = {
		{path = "Error\\Cant_Attack_While_Confused.mp3", cooldown = 3},
	},
	["CantAttack_Charmed"] = {
		{path = "Error\\Cant_Attack_While_Charmed.mp3", cooldown = 3},
	},


	["NotEnough_Rage"] = {
		{path = "Error\\Not_Enough_Rage.mp3", cooldown = 5},
	},
	["NotEnough_Mana"] = {
		{path = "Error\\Not_Enough_Mana.mp3", cooldown = 5},
	},
	["NotEnough_Health"] = {
		{path = "Error\\Not_Enough_Health.mp3", cooldown = 5},
	},
	["NotEnough_Focus"] = {
		{path = "Error\\Not_Enough_Focus.mp3", cooldown = 5},
	},
	["NotEnough_Energy"] = {
		{path = "Error\\Not_Enough_Energy.mp3", cooldown = 5},
	},
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