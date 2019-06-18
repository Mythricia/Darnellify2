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
		-- TODO: add chance attribute
		-- TODO: add delay attribute
		-- TODO: add reset attribute? containing a list of conditions that would instantly reset the CD
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
}

-- Info messages ("PVP combat toggled on" etc)
library.info = {
	["PVP_On"] = {
		{path = "Info\\PvP_On.mp3", cooldown = 5},
	},
	["PVP_Off"] = {
		{path = "Info\\PvP_Off.mp3", cooldown = 5},
	},


	["DuelRequested"] = {
		{path = "info\\You_Have_Requested_A_Duel.mp3"},
	},
	["DuelCancelled"] = {
		{path = "info\\Duel_Cancelled.mp3"},
	},


	["Fishing_NotHooked"] = {
		{path = "Error\\No_Fish_Are_Hooked.mp3"},
	},
}

-- Error message events ("Too far away" etc)
library.error = {
	-- generic errors
	["GenericNoTarget"] = {
		{path = "Error\\You_Have_No_Target.mp3", cooldown = 3},
	},
	["GenericStunned"] = -- "Can't do that while stunned", different from "Can't attack while stunned"
	{
		{path = "Error\\You_Are_Stunned.mp3", cooldown = 3},
	},
	["GenericLockout"] = {
		{path = "Error\\You_Cant_Do_That_Right_Now.mp3", cooldown = 5},
	},

	-- range / targeting errors
	["TooFarAway"] = {
		{path = "Error\\You_Are_Too_Far_Away.mp3", cooldown = 3},
	},
	["GetCloser"] = {
		{path = "Error\\You_Need_To_Be_Closer_To_Interact_With_That_Target.mp3", cooldown = 10},
	},
	["OutOfRange"] = {
		{path = "Error\\Out_Of_Range.mp3", cooldown = 5},
	},
	["FacingWrongWay"] = {
		{path = "Error\\You_Are_Facing_The_Wrong_Way.mp3", cooldown = 2},
	},
	["InvalidTarget"] = {
		{path = "Error\\Invalid_Target.mp3"},
	},

	-- loss of control errors
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

	-- lacking resources errors
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

	-- item errors
	["Item_Cooldown"] = {
		{path = "Error\\Item_Is_Not_Ready_Yet.mp3", cooldown = 5},
	},
	["Item_Locked"] = {
		{path = "Error\\Item_Is_Locked.mp3", cooldown = 5},
	},
	["Item_CannotUse"] = {
		{path = "Error\\You_Cant_Use_That_Item.mp3", cooldown = 5},
	},
	["ObjectBusy"] = {
		{path = "Error\\That_Object_Is_Busy.mp3", cooldown = 5},
	},
	["ChestInUse"] = {
		{path = "Error\\That_Is_Already_Being_Used.mp3", cooldown = 5},
	},

	-- player interaction errors
	["AlreadyTrading"] = {
		{path = "Error\\You_Are_Already_Trading.mp3", cooldown = 5},
	},
	["CantChatWhileDead"] = {
		{path = "Error\\You_Cant_Chat_When_YouRe_Dead.mp3", cooldown = 5},
	},

	-- spell / ability errors
	["CantWhileMoving"] = {
		{path = "Error\\Cant_Do_That_While_Moving.mp3", cooldown = 5},
	},
	["CantDoThatYet"] = {
		{path = "Error\\You_Cant_Do_That_Yet.mp3", cooldown = 5},
	},
	["SpellCooldown"] = {
		{path = "Error\\Spell_Is_Not_Ready_Yet.mp3", cooldown = 5},
	},
	["AbilityCooldown"] = {
		{path = "Error\\Ability_Is_Not_Ready_Yet.mp3", cooldown = 5},
	},

	-- fishing...
	["Fishing_Escaped"] = {
		{path = "Error\\Your_Fish_Got_Away.mp3"},
	},
	["Fishing_TooShallow"] = {
		{path = "Error\\Water_Too_Shallow.mp3", cooldown = 3},
	},
	["Fishing_NotFishable"] = {
		{path = "Error\\Your_Cast_Didnt_Land_In_Fishable_Water.mp3", cooldown = 12},
	},
}

-- combat events, such as critical strikes, overkills, environmental damage etc
library.combat = {
	["EnvironmentDeath"] = {
		{path = "Combat\\Insult_1.mp3"},
		{path = "Combat\\Insult_2.mp3"},
		{path = "Combat\\Insult_3.mp3"},

		cooldown = 5,
	},

	["CriticalHit"] = {
		{path = "Combat\\Crit_1.mp3", cooldown = 3},
		{path = "Combat\\Crit_2.mp3", cooldown = 3},
		{path = "Combat\\Crit_3.mp3", cooldown = 3},

		cooldown = 1,
	},

	["CriticalKill"] = { -- if it's both a killing blow AND a critical strike
		{path = "Combat\\Crit_4.mp3", cooldown = 3},
		{path = "Combat\\Crit_5.mp3", cooldown = 3},
		{path = "Combat\\Crit_6.mp3", cooldown = 3},

		cooldown = 1,
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


-- Emotes!
library.emotes = {
	["DANCE"] = {
		{path = "Emotes\\Dance_1.mp3"},
		{path = "Emotes\\Dance_2.mp3"},
		{path = "Emotes\\Dance_3.mp3"},

		cooldown = 10
	},

	["BEG"] = {
		{path = "Emotes\\Beg_1.mp3"},
		{path = "Emotes\\Beg_2.mp3"},
		{path = "Emotes\\Beg_3.mp3"},

		cooldown = 10
	},

	["COWER"] = {
		{path = "Emotes\\Cower_1.mp3"},
		{path = "Emotes\\Cower_2.mp3"},
		{path = "Emotes\\Cower_3.mp3"},

		cooldown = 10
	},

	["SILLY"] = {
		{path = "Silly_1.mp3"},
		{path = "Emotes\\Silly_2.mp3"},
		{path = "Emotes\\Silly_3.mp3"},

		cooldown = 10
	},

	["FLIRT"] = {
		{path = "Emotes\\Flirt_1.mp3"},
		{path = "Emotes\\Flirt_2.mp3"},
		{path = "Emotes\\Flirt_3.mp3"},

		cooldown = 10
	},

	["HELLO"] = {
		{path = "Emotes\\Hello_1.mp3", cooldown = 5},
	},
}

-- These are duplicate emotes. They simply point to an existing collection above.
-- Separated to look cleaner. Can easily be added above if desired (delete these duplicates though).
library.emotes["JOKE"] 	= library.emotes.SILLY

library.emotes["GREET"] = library.emotes.HELLO
library.emotes["HAIL"] 	= library.emotes.HELLO
library.emotes["HI"] 	= library.emotes.HELLO
library.emotes["WAVE"] 	= library.emotes.HELLO



-- Passing the whole library back over to the core Darnellify addon code
local _, addonTable = ...
addonTable.library = library