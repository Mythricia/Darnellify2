local addonName, addonTable = ...
local library = addonTable.library
local settings

-- Static flags and values
local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1))
local BASE_SOUND_DIRECTORY = "Interface\\AddOns\\Darnellify2\\Sounds\\"
local DEFAULT_SAMPLE_COOLDOWN = 1
local DARN_DEBUG = true
local FAKE_CLASSIC = false
local MOUNTED = IsMounted()
local PLAYING_MUSIC = false

-- Color tags
local cTag = "|cFF"
local DarnColors = {
	red 	= cTag.."FF0000",
	green	= cTag.."00FF00",
	blue	= cTag.."0000FF",
	cyan	= cTag.."00FFFF",
	teal	= cTag.."008080",
	orange	= cTag.."FFA500",
	brown	= cTag.."8B4500",
	pink	= cTag.."EE1289",
	purple	= cTag.."9F79EE",
	yellow	= cTag.."FFF569",
	white	= cTag.."FFFFFF",
}
local prettyName = DarnColors.yellow..addonName.."|r"

-- Tables
local eventHandler = {}
local eventList = {}
local cooldownTimers = {}
local messages = {}

-- Forward declarations
local playSample
local playSampleFromCollection
local playMusicFromCollection
local tableContains
local slashProcessor
local darnPrint
local logMessage



-- Misc addon setup
local eventFrame = CreateFrame("Frame", "DarnellifyEventFrame")
eventFrame:UnregisterAllEvents()
eventFrame:RegisterEvent("ADDON_LOADED")


local function initialize()
	eventFrame:UnregisterAllEvents()

	-- TODO: This doesn't do anything
	settings = Darnellify2_Settings or {}

	-- Check mount status. If dismount within 2 seconds of UI load, this will fail
	C_Timer.After(2, function() MOUNTED = IsMounted() end)


	for k, v in pairs(eventList) do
		if type(v) == "string" then
			-- Duplicate prevention
			if not eventFrame:IsEventRegistered(v) then
				eventFrame:RegisterEvent(v)
			end
		end
	end
end

local function parseEvent(frame, event, ...)
	if eventHandler[event] then
		eventHandler[event](...)
	else
		local msg = ("Event registered but not handled: \""..event.."\"")
		if DARN_DEBUG then
			darnPrint(msg)
		end
		logMessage(msg, "WARNING")
	end
end

eventFrame:SetScript("OnEvent", parseEvent)

-- Using a function here to clean up the event hooking syntax later
local function ifModern(passthroughEvent)
	if FAKE_CLASSIC then
		return nil
	else
		return (CLIENT_MAJOR_VER > 1 and passthroughEvent) or nil
	end
end


-- Events we want to register for
eventList =
{
	-- Modern-only events
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),
	ifModern("GUILDBANKFRAME_OPENED"),
	ifModern("GUILDBANKFRAME_CLOSED"),
	ifModern("VOID_STORAGE_OPEN"),
	ifModern("VOID_STORAGE_CLOSE"),
	ifModern("ACHIEVEMENT_EARNED"),

	-- Classic-safe events
	"MAIL_SHOW",
	"MAIL_CLOSED",
	"AUCTION_HOUSE_SHOW",
	"AUCTION_HOUSE_CLOSED",
	"BANKFRAME_OPENED",
	"BANKFRAME_CLOSED",
	"MERCHANT_SHOW",
	"MERCHANT_CLOSED",
	"PLAYER_LEVEL_UP",
	"PLAYER_MOUNT_DISPLAY_CHANGED",
	"UNIT_SPELLCAST_SUCCEEDED",
	"DUEL_REQUESTED",
	"UI_INFO_MESSAGE",
	"UI_ERROR_MESSAGE",
}


-- Event handlers
eventHandler["ADDON_LOADED"] = function(...)
	if ... == addonName then
		initialize()
	end
end


-- Interface events
eventHandler["MAIL_SHOW"] = function()
	playSampleFromCollection(library.interface.Mailbox_Open)
end
eventHandler["MAIL_CLOSED"] = function()
	playSampleFromCollection(library.interface.Mailbox_Close)
end
eventHandler["TRANSMOGRIFY_OPEN"] = function()
	playSampleFromCollection(library.interface.Transmog_Open)
end
eventHandler["TRANSMOGRIFY_CLOSE"] = function()
	playSampleFromCollection(library.interface.Transmog_Close)
end
eventHandler["GUILDBANKFRAME_OPENED"] = function()
	playSampleFromCollection(library.interface.GuildBank_Open)
end
eventHandler["GUILDBANKFRAME_CLOSED"] = function()
	playSampleFromCollection(library.interface.GuildBank_Close)
end
eventHandler["VOID_STORAGE_OPEN"] = function()
	playSampleFromCollection(library.interface.Void_Open)
end
eventHandler["VOID_STORAGE_CLOSE"] = function()
	playSampleFromCollection(library.interface.Void_Close)
end
eventHandler["AUCTION_HOUSE_SHOW"] = function()
	playSampleFromCollection(library.interface.AH_Open)
end
eventHandler["AUCTION_HOUSE_CLOSED"] = function()
	playSampleFromCollection(library.interface.AH_Close)
end
eventHandler["BANKFRAME_OPENED"] = function()
	playSampleFromCollection(library.interface.Bank_Open)
end
eventHandler["BANKFRAME_CLOSED"] = function()	-- THIS FIRES TWICE. For some reason. 🤷
	playSampleFromCollection(library.interface.Bank_Close)
end
eventHandler["MERCHANT_SHOW"] = function()
	playSampleFromCollection(library.interface.Vendor_Open)
end
eventHandler["MERCHANT_CLOSED"] = function()
	playSampleFromCollection(library.interface.Vendor_Close)
end


-- Player events (levelup, duel, achievement, etc)
eventHandler["PLAYER_LEVEL_UP"] = function()
playSampleFromCollection(library.player.Player_LevelUp)
end

eventHandler["DUEL_REQUESTED"] = function() -- player RECIEVED a duel request
	playSampleFromCollection(library.player.DuelRequested)
end


-- Note: Some of the global info message strings (ERR_PVP_TOGGLE_OFF etc) are wrong,
-- and don't actually reflect the real info text that is displays. Add string mapping to fix
-- REMEMBER TO RESOLVE THE KEYS AS STRINGS with [ ]
local InfoMessageMap = {
	[ERR_DUEL_REQUESTED] 	= library.info.DuelRequested, -- player SENT a duel request
	[ERR_DUEL_CANCELLED] 	= library.info.DuelCancelled,
	[ERR_PVP_TOGGLE_ON]		= library.info.PVP_On,
	[ERR_PVP_TOGGLE_OFF]	= library.info.PVP_Off,

	[ERR_FISH_NOT_HOOKED]	= library.info.Fishing_NotHooked,
}

eventHandler["UI_INFO_MESSAGE"] = function(messageType, message)
	local mappedMessage = InfoMessageMap[message]
	if mappedMessage then
		playSampleFromCollection(mappedMessage)
	end
end



-- Note: Like UI_INFO_MESSAGE events, these globals sometimes don't match the actual error messages
-- REMEMBER TO RESOLVE THE KEYS AS STRINGS with [ ]
local ErrorMessageMap = {
	-- generic errors
	[ERR_GENERIC_NO_TARGET] = library.error.GenericNoTarget,
	["There is nothing to attack."] = library.error.GenericNoTarget,
	[ERR_GENERIC_STUNNED]	= library.error.GenericStunned,
	[ERR_CLIENT_LOCKED_OUT] = library.error.GenericLockout,
	
	-- targeting / range errors
	[ERR_BADATTACKPOS] 		= library.error.TooFarAway,
	[ERR_LOOT_TOO_FAR] 		= library.error.TooFarAway,
	[ERR_NO_BANK_HERE] 		= library.error.TooFarAway,
	[ERR_TAXITOOFARAWAY] 	= library.error.TooFarAway,
	[ERR_USE_TOO_FAR] 		= library.error.TooFarAway,
	[ERR_VENDOR_TOO_FAR] 	= library.error.TooFarAway,
	[ERR_AUTOFOLLOW_TOO_FAR] = library.error.TooFarAway,
	[ERR_TOO_FAR_TO_INTERACT]=library.error.GetCloser,
	[ERR_OUT_OF_RANGE]		= library.error.OutOfRange,
	[ERR_SPELL_OUT_OF_RANGE]= library.error.OutOfRange,
	["Target needs to be in front of you."] = library.error.FacingWrongWay,
	-- ^ ^ ^ Blizzards "ERR_BADATTACKFACING" string is outdated and not equal to the actual message
	[ERR_INVALID_ATTACK_TARGET]=library.error.InvalidTarget,
	["Invalid target"] = library.error.InvalidTarget,

	-- control state errors
	[ERR_ATTACK_STUNNED]	= library.error.CantAttack_Stunned,
	[ERR_ATTACK_PACIFIED]	= library.error.CantAttack_Pacified,
	[ERR_ATTACK_FLEEING]	= library.error.CantAttack_Fleeing,
	[ERR_ATTACK_DEAD]		= library.error.CantAttack_Dead,
	[ERR_ATTACK_CONFUSED]	= library.error.CantAttack_Confused,
	[ERR_ATTACK_CHARMED]	= library.error.CantAttack_Charmed,
	-- disoriented = todo / investigate?
	-- frozen = todo / investigate?

	-- resource errors
	[ERR_OUT_OF_RAGE]		= library.error.NotEnough_Rage,
	[ERR_OUT_OF_MANA]		= library.error.NotEnough_Mana,
	[ERR_OUT_OF_HEALTH]		= library.error.NotEnough_Health,
	[ERR_OUT_OF_FOCUS]		= library.error.NotEnough_Focus,
	[ERR_OUT_OF_ENERGY]		= library.error.NotEnough_Energy,
	--[ERR_OUT_OF_MAELSTROM] = todo
	--[ERR_OUT_OF_FURY] = todo

	-- item errors
	[ERR_ITEM_COOLDOWN]		= library.error.Item_Cooldown,
	[ERR_ITEM_LOCKED]		= library.error.Item_Locked,
	[ERR_CANT_USE_ITEM]		= library.error.Item_CannotUse,
	[ERR_OBJECT_IS_BUSY]	= library.error.ObjectBusy,
	[ERR_CHEST_IN_USE]		= library.error.ChestInUse,

	-- interaction errors
	[ERR_ALREADY_TRADING]	= library.error.AlreadyTrading,
	[ERR_CHAT_WHILE_DEAD]	= library.error.CantChatWhileDead,

	-- spell / ability errors
	[SPELL_FAILED_CASTER_AURASTATE]	= library.error.CantDoThatYet,
	[SPELL_FAILED_MOVING]			= library.error.CantWhileMoving,
	[SPELL_FAILED_BAD_TARGETS]		= library.error.InvalidTarget,
	[ERR_SPELL_COOLDOWN]			= library.error.SpellCooldown,
	[ERR_ABILITY_COOLDOWN]			= library.error.AbilityCooldown,

	-- fishing...
	[ERR_FISH_ESCAPED]			= library.error.Fishing_Escaped,
	[SPELL_FAILED_TOO_SHALLOW]	= library.error.Fishing_TooShallow,
	[SPELL_FAILED_NOT_FISHABLE]	= library.error.Fishing_NotFishable,
}

eventHandler["UI_ERROR_MESSAGE"] = function(messageType, message)
	local mappedMessage = ErrorMessageMap[message]
	if mappedMessage then
		playSampleFromCollection(mappedMessage)
	end
end


-- This only deals with trying to keep the MOUNTED flag up to date
eventHandler["PLAYER_MOUNT_DISPLAY_CHANGED"] = function()
	if MOUNTED then
		playSampleFromCollection(library.mounts["Dismount"])

		if PLAYING_MUSIC then
			StopMusic()
			PLAYING_MUSIC = false
		end
	end

	-- Making extra sure MOUNTED remains correct
	C_Timer.After(1, function() MOUNTED = IsMounted() end)
end


-- If we mounted up, play the correct music for the mount, if any
eventHandler["UNIT_SPELLCAST_SUCCEEDED"] = function(target, GUID, spellID)
	if target == "player" then
		for name, category in pairs(library.mounts) do
			if tableContains(category.mounts, spellID) then
				playMusicFromCollection(category.music)
				return
			end
		end
	end
end


-- Sample playback functions
function playSample(sample)
	local cooldown = sample.cooldown or DEFAULT_SAMPLE_COOLDOWN

	if not cooldownTimers[sample] then
		if DARN_DEBUG then darnPrint("Playing sample: "..sample.path) end
		cooldownTimers[sample] = GetTime()
		PlaySoundFile(BASE_SOUND_DIRECTORY .. sample.path)

		-- Schedule the removal of sample cooldown, if it exists (including 0!), default otherwise
		C_Timer.After(cooldown, function()
			cooldownTimers[sample] = nil
		end)
	elseif DARN_DEBUG then
		darnPrint("Sample skipped due to being on cooldown: "
		..sample.path
		.." ("
		..cooldown - string.format("%.2f", GetTime()-cooldownTimers[sample])
		.."s remaining)")
	end
end


function playSampleFromCollection(collection)
	if collection and (#collection > 0) then
		local sample = collection[random(1, #collection)]
		if not cooldownTimers[collection] then
			playSample(sample)

			-- If collection has a cooldown value, apply it and schedule the expiration
			if collection.cooldown then
				cooldownTimers[collection] = GetTime()
				C_Timer.After(collection.cooldown, function()
					cooldownTimers[collection] = nil
				end)
			end
		elseif DARN_DEBUG then
			darnPrint("Sample skipped due to collection being on cooldown: "
			..sample.path
			.." ("
			..collection.cooldown - string.format("%.2f", GetTime()-cooldownTimers[collection])
			.."s remaining)")
		end
	else
		local msg = ("Tried to play from an empty sample collection!")
		if DARN_DEBUG then
			darnPrint(msg)
		end
		logMessage(msg, "ERROR")
	end
end


function playMusicFromCollection(collection)
	if collection and (#collection > 0) then
		local sample = collection[random(1, #collection)]
		if DARN_DEBUG then
			darnPrint("Playing MountMusic: " .. sample.path)
		end

		PlayMusic(BASE_SOUND_DIRECTORY .. sample.path)

		-- We need to schedule music to stop,
		-- but only if the starting timestamp matches (we can only cancel ourselves)
		PLAYING_MUSIC = sample

		local startTime = GetTime()
		cooldownTimers[sample] = startTime

		C_Timer.After(sample.cooldown, function()
			if PLAYING_MUSIC == sample and (cooldownTimers[sample] and cooldownTimers[sample] == startTime) then
				StopMusic()
				PLAYING_MUSIC = false
			end
		end)
	else
		local msg = ("Tried to play from an empty Mount collection!")
		if DARN_DEBUG then
			darnPrint(msg)
		end
		logMessage(msg, "ERROR")
	end
end


-- Utilities
function darnPrint(msg)
	DEFAULT_CHAT_FRAME:AddMessage(prettyName..":: \n" .. tostring(msg))
end

-- Check if table contains KEY
function tableContains(t, val)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if v == val then
                return true
            end
        end
    end
    return false
end

-- Push a new message to messages
function logMessage(msg, msgType)
	local entry = {
		type = msgType or "GENERIC",
		msg = msg,
		time = date("%H:%M:%S"),
	}

	table.insert(messages, entry)
end



-- SlashCmd handlers
local slashCommands = {}

slashCommands.events = {
	func = function(...)
		print(" ")
		print(prettyName.." hooked events: ")
		local modern = ifModern("dummy") and "False" or "True"
		print("(WoW Classic mode: "..modern..")")
		for k, v in pairs( eventList ) do
			print( DarnColors.green .. v )
		end
	end,

	desc = "Lists all registered Events"
}


slashCommands.spam = {
	func = function(...)
		DARN_DEBUG = not DARN_DEBUG
		if DARN_DEBUG then
			print(prettyName..": Verbose errors "..DarnColors.red.."enabled")
		else
			print(prettyName..": Verbose errors "..DarnColors.green.."disabled")
		end
	end,

	desc = "Makes Darnellify2 very talkative! (Debugging messages)"
}

slashCommands.messages = {
	func = function(...)
		if (...) == "clear" then
			messages = {}
			print(prettyName..": Messages cleared!")
			return
		end

		if #messages > 0 then
			print(prettyName..": Dumping "..#messages.." log messages: ")
			for k, v in ipairs(messages) do
				if v.type == "WARNING" then
					print("["..k.."] ("..v.time..") "..DarnColors.yellow..v.msg)
				elseif v.type == "ERROR" then
					print("["..k.."] ("..v.time..") "..DarnColors.red..v.msg)
				else
					print("["..k.."] ("..v.time..") "..v.msg)
				end
			end
		else
			print(prettyName..": No log messages!")
		end
	end,

	desc = "Show all log messages. Append 'clear' to clear log, 'export' to copy the log to clipboard."
}


-- Misc SlashCmd code
function slashProcessor(cmd)
	-- split the recieved slashCmd into a root command plus any extra arguments
	local parts = {}
	local root

	for part in string.lower(cmd):gmatch("%S+") do
		table.insert(parts, part)
	end

	-- Strip out and store the root command
	root = parts[1]
	table.remove(parts, 1)

	-- Utility function to print all available commands
	local function printCmdList()
		local slashListSeparator = "      `- "
		if select("#", slashCommands) > 0 then
			print(DarnColors.yellow..addonName.." commands:")

			for k, v in pairs(slashCommands) do
				print(k)
				if v.desc then
					print(DarnColors.cyan..slashListSeparator..DarnColors.orange..v.desc)
				else
					print(slashListSeparator..DarnColors.red.."No Description")
				end
			end
		end
	end


		-- Check if the root command exists, and call it. Else print error and list available commands + their description (if any)
	if slashCommands[root] then
		slashCommands[root].func(unpack(parts))
	elseif root == nil then
		print(prettyName..": ["..#messages.."] messages stored.")
		printCmdList()
	else
		print(DarnColors.yellow.."Darnellify".."r| unrecognized command: "..DarnColors.red..root)
		print("List available commands with "..DarnColors.cyan.."/darn|r or "..DarnColors.cyan.."/darnellify")
	end
end


SLASH_Darnellify1 = "/Darnell"
SLASH_Darnellify2 = "/Darnellify"
SLASH_Darnellify3 = "/Darn"
SLASH_Darnellify4 = "/Fony"
SLASH_Darnellify5 = "/MikeB"

SlashCmdList["Darnellify"] = slashProcessor
