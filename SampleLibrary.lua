--[[
Sound files and their properties are collected here.

File paths are relative to the "Sounds" folder. That is, if you want to add a file "Ding.mp3",
and that file resides inside the Sounds folder, you simply put "Ding.mp3" as the file path.

If you have a file in a subfolder: "Sounds\FunnierSounds\TheFunniest.mp3", then you would put
"FunnierSounds\\TheFunniest.mp3" as the file path. Notice the double backslashes: they are mandatory!
]]


-- This table holds all of the sounds
local library = {}


-- Interface Panel events
library.interface = {}
library.interface["MAILBOX_OPEN"] = {
	{path = "Ding.mp3", cooldown = 2},
	{path = "Crit_1.mp3", cooldown = 3},

	-- collection-wide options below
	cooldown = 5	-- Only one sample will play per cooldown. Remove line for 0 collection cooldown
}


-- Mount events.
-- MountUp Music works slightly differently, it does a lookup by the mount "spellID"
library.mounts = {}
library.mounts["Dismount"] = {path = "Mount\\Car_Alarm.mp3", cooldown = 1}

library.mounts["MountUp"] =
{
	[35027] = {path = "Mount\\Chocobo_1.mp3", cooldown = 10},	--"Swift Purple Hawkstrider"
	[35020] = {path = "Mount\\My_Little_Pony_1.mp3", cooldown = 30} --"Blue Hawkstrider"
}



-- Passing the whole library back over to the core Darnellify addon code
local _, addonTable = ...
addonTable.library = library