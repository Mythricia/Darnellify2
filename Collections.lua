--[[
Sound files and their properties are collected here.

File paths are relative to the "Sounds" folder. That is, if you want to add a file "Ding.mp3",
and that file resides inside the Sounds folder, you simply put "Ding.mp3" as the file path.

If you have a file in a subfolder: "Sounds\FunnierSounds\TheFunniest.mp3", then you would put
"FunnierSounds\\TheFunniest.mp3" as the file path. Notice the double backslashes: they are mandatory!
]]


-- This table holds all of the sounds
local collections = {}


-- Interface Panel Sounds
collections.interface = {}

collections.interface["MAILBOX_OPEN"] = {
	{path = "Ding.mp3", cooldown = 2},
	{path = "Crit_1.mp3", cooldown = 3},
}



-- Passing the whole collection back over to the core Darnellify addon code
local _, Darnellify = ...
Darnellify.collections = collections