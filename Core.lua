local addonName, Darn = ...
local library = Darn.library
local settings

-- Importing static flags and values
local flags = Darn.flags
local MOUNTED					= IsMounted()
-- Importing utilities
local colors 		= Darn.utils.colors
local prettyName	= Darn.utils.prettyName
local tableContains = Darn.utils.tableContains
local isModern		= Darn.utils.isModern
-- Logging
local pushMessage = Darn.logging.pushMessage
-- Playback
local playSampleFromCollection	= Darn.playback.playSampleFromCollection
local playMusicFromCollection	= Darn.playback.playMusicFromCollection

-- Internal tables
local eventHandler = {}
local eventList = {}
local cooldownTimers = {}

-- Locally scope functions
local C_Timer = C_Timer
local GetTime = GetTime



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
		pushMessage(msg, "WARNING")
	end
end

eventFrame:SetScript("OnEvent", parseEvent)

-- Events we want to register for
eventList =
{
	-- Modern-only events
	isModern("TRANSMOGRIFY_OPEN"),
	isModern("TRANSMOGRIFY_CLOSE"),
	isModern("GUILDBANKFRAME_OPENED"),
	isModern("GUILDBANKFRAME_CLOSED"),
	isModern("VOID_STORAGE_OPEN"),
	isModern("VOID_STORAGE_CLOSE"),
	isModern("ACHIEVEMENT_EARNED"),

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
	"ACHIEVEMENT_EARNED",
	"PLAYER_MOUNT_DISPLAY_CHANGED",
	"UNIT_SPELLCAST_SUCCEEDED",
	"DUEL_REQUESTED",
	"UI_INFO_MESSAGE",
	"UI_ERROR_MESSAGE",

	"COMBAT_LOG_EVENT_UNFILTERED",
}
Darn.eventList = eventList


-- Hooking DoEmote to play our own samples
hooksecurefunc("DoEmote", function(emote, message)
	if library.emotes[emote] then
		playSampleFromCollection(library.emotes[emote], "DoEmote["..emote.."]")
	end
end)


-- Addon load
eventHandler["ADDON_LOADED"] = function(...)
	if ... == addonName then
		initialize()
	end
end

-- Interface events
eventHandler["MAIL_SHOW"] = function()
	playSampleFromCollection(library.interface.Mailbox_Open, "Mailbox_Open")
end
eventHandler["MAIL_CLOSED"] = function()
	playSampleFromCollection(library.interface.Mailbox_Close, "Mailbox_Close")
end
eventHandler["TRANSMOGRIFY_OPEN"] = function()
	playSampleFromCollection(library.interface.Transmog_Open, "Transmog_Open")
end
eventHandler["TRANSMOGRIFY_CLOSE"] = function()
	playSampleFromCollection(library.interface.Transmog_Close, "Transmog_Close")
end
eventHandler["GUILDBANKFRAME_OPENED"] = function()
	playSampleFromCollection(library.interface.GuildBank_Open, "GuildBank_Open")
end
eventHandler["GUILDBANKFRAME_CLOSED"] = function()
	playSampleFromCollection(library.interface.GuildBank_Close, "GuildBank_Close")
end
eventHandler["VOID_STORAGE_OPEN"] = function()
	playSampleFromCollection(library.interface.Void_Open, "Void_Open")
end
eventHandler["VOID_STORAGE_CLOSE"] = function()
	playSampleFromCollection(library.interface.Void_Close, "Void_Close")
end
eventHandler["AUCTION_HOUSE_SHOW"] = function()
	playSampleFromCollection(library.interface.AH_Open, "AH_Open")
end
eventHandler["AUCTION_HOUSE_CLOSED"] = function()
	playSampleFromCollection(library.interface.AH_Close, "AH_Close")
end
eventHandler["BANKFRAME_OPENED"] = function()
	playSampleFromCollection(library.interface.Bank_Open, "Bank_Open")
end
eventHandler["BANKFRAME_CLOSED"] = function()	-- THIS FIRES TWICE. For some reason. 🤷
	playSampleFromCollection(library.interface.Bank_Close, "Bank_Close")
end
eventHandler["MERCHANT_SHOW"] = function()
	playSampleFromCollection(library.interface.Vendor_Open, "Vendor_Open")
end
eventHandler["MERCHANT_CLOSED"] = function()
	playSampleFromCollection(library.interface.Vendor_Close, "Vendor_Close")
end


-- Player events (levelup, duel, achievement, etc)
eventHandler["PLAYER_LEVEL_UP"] = function()
playSampleFromCollection(library.player.Player_LevelUp, "Player_LevelUp")
end
eventHandler["ACHIEVEMENT_EARNED"] = function()
	playSampleFromCollection(library.player.Player_LevelUp, "Player_LevelUp")
end

eventHandler["DUEL_REQUESTED"] = function() -- player RECIEVED a duel request
	playSampleFromCollection(library.player.DuelRequested, "DuelRequested")
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
		playSampleFromCollection(mappedMessage, "UI_INFO_MESSAGE["..messageType.."]")
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
		playSampleFromCollection(mappedMessage, "UI_ERROR_MESSAGE["..messageType.."]")
	end
end


-- This only deals with trying to keep the MOUNTED flag up to date
eventHandler["PLAYER_MOUNT_DISPLAY_CHANGED"] = function()
	if MOUNTED then
		playSampleFromCollection(library.mounts["Dismount"], "Dismount")

		if flags.PLAYING_MUSIC then
			StopMusic()
			flags.PLAYING_MUSIC = false
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
				playMusicFromCollection(category.music, "mounts[\""..name.."\"]")
				return
			end
		end
	end
end


-- Combat related events handled here, such as crit, crit-kill, fall death, etc
-- NOTE: This event no longer carries a payload by itself, must use CombatLogGetCurrentEventInfo() to fetch them
eventHandler["COMBAT_LOG_EVENT_UNFILTERED"] = function()
	local logParams = {CombatLogGetCurrentEventInfo()}
	local playerName = UnitName("player")

	-- [1] = timeStamp,
	-- [2] = eventType,
	-- [3] = hideCaster,
	-- [4] = sourceGUID,
	-- [5] = sourceName,
	-- [6] = sourceFlags,
	-- [7] = sourceRaidFlags,
	-- [8] = destGUID,
	-- [9] = destName,
	-- [10]= destFlags,
	-- [11]= destRaidFlags,
	-- remaining params depend on eventType, see: https://wow.gamepedia.com/COMBAT_LOG_EVENT

    local eventType = logParams[2]
    local sourceName = logParams[5]
	local destName = logParams[9]

	-- Only care about overkill and critical currently, map params accordingly
	local critical
	local overkill

	if ((eventType == "SPELL_DAMAGE")
	or (eventType == "SPELL_PERIODIC_DAMAGE")
	or (eventType == "RANGE_DAMAGE")) and sourceName == playerName then
		critical = logParams[21]
		overkill = logParams[16]

		if (critical and (overkill == -1)) then
			playSampleFromCollection(library.combat.CriticalHit, "CriticalHit")
		elseif (critical and (overkill > 0) and (UnitHealthMax("target") > 1)) then
			playSampleFromCollection(library.combat.CriticalKill, "CriticalKill")
		end
	elseif (eventType == "SWING_DAMAGE") and sourceName == playerName then
		critical = logParams[18]
		overkill = logParams[13]

		if (critical and (overkill == -1)) then
			playSampleFromCollection(library.combat.CriticalHit, "CriticalHit")
		elseif (critical and (overkill > 0) and (UnitHealthMax("target") > 1)) then
			playSampleFromCollection(library.combat.CriticalKill, "CriticalKill")
		end
	end

	-- Check for death from environmental damage (fall, drown, lava, etc)
	if (eventType == "ENVIRONMENTAL_DAMAGE") and destName == playerName then
		local amount = logParams[13]
		local curHP = UnitHealth("player")
		local deadOrGhost = UnitIsDeadOrGhost("player")

		if (curHP < 2) or deadOrGhost then
			playSampleFromCollection(library.combat.EnvironmentDeath, "EnvironmentDeath")
		end
		return
	end
end