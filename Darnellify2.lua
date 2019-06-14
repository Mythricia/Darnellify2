local addonName, addonTable = ...
local library = addonTable.library
local settings

-- "static" flags and values
local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1)) -- If Major version > 1, it's not WoW Classic
local BASE_SOUND_DIRECTORY = "Interface\\AddOns\\Darnellify2\\Sounds\\"
local DEFAULT_SAMPLE_COOLDOWN = 1
local DARN_DEBUG = true -- Print ugly debug messages in chatframe
local FAKE_CLASSIC = false -- if true, isModern will always return false
local MOUNTED = IsMounted()  -- This IS valid on UI reload
local PLAYING_MUSIC = false

-- Forward declarations
local eventHandler = {}
local eventList = {}
local cooldownTimers = {}		-- Track single samples on cooldown
local playSample
local playSampleFromCollection
local playMusicSample
local print -- overriding this since it doesn't do anything ingame anyway


-- Misc addon setup --
----------------------
local eventFrame = CreateFrame("Frame", "DarnellifyEventFrame")
eventFrame:UnregisterAllEvents()

-- Just wait for addon load for now
eventFrame:RegisterEvent("ADDON_LOADED")

local function initialize()
	eventFrame:UnregisterAllEvents()	

	-- Do some user settings stuff here at some point
	settings = Darnellify2_Settings or {}

	-- Check mount status. If dismount within 2 seconds of UI load, this will fail.. Oh well
	C_Timer.After(2, function() MOUNTED = IsMounted() end)

	-- Register the actual events we care about now that we're loaded
	for k, v in pairs(eventList) do
		if type(v) == "string" then
			eventFrame:RegisterEvent(v)
		end
	end
end

local function parseEvent(frame, event, ...)
	if eventHandler[event] then
		eventHandler[event](event, ...)
	elseif DARN_DEBUG then
		print("Event registered but not handled: \""..event.."\"")
	end
end

eventFrame:SetScript("OnEvent", parseEvent)

-- Using a function here to clean up the event hooking syntax later
local function ifModern(passthroughEvent)
	if FAKE_CLASSIC then
		return false
	else
		return (CLIENT_MAJOR_VER > 1 and passthroughEvent) or nil
	end
end


-- EVENT LISTINGS --
--------------------
eventList =
{
	-- Modern-only events
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),
	ifModern("GUILDBANKFRAME_OPENED"),
	ifModern("GUILDBANKFRAME_CLOSED"),
	ifModern("VOID_STORAGE_OPEN"),
	ifModern("VOID_STORAGE_CLOSE"),
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),
	ifModern("ACHIEVEMENT_EARNED"),
	
	-- Classic-safe events
	"MAIL_SHOW",
	"MAIL_CLOSED",
	"UNIT_SPELLCAST_SUCCEEDED", -- Used for mount-up detection
	"PLAYER_MOUNT_DISPLAY_CHANGED", -- Used for dismount detection
}


-- Event Handlers --
--------------------
eventHandler["ADDON_LOADED"] = function(event, ...)
	if ... == addonName then
		initialize()
	end
end

eventHandler["MAIL_SHOW"] = function(event, ...)
	playSampleFromCollection(library.interface.MAILBOX_OPEN)
end

-- This only deals with trying to keep the MOUNTED flag up to date
eventHandler["PLAYER_MOUNT_DISPLAY_CHANGED"] = function(event, ...)
	if MOUNTED then -- We were already mounted, thus, this must be a dismount
		print("We were dismounted!")
		playSample(library.mounts["Dismount"])
		if PLAYING_MUSIC then
			StopMusic()
			PLAYING_MUSIC = false
		end
	end

	C_Timer.After(1, function() MOUNTED = IsMounted() end) -- Making extra sure MOUNTED remains correct
end

eventHandler["UNIT_SPELLCAST_SUCCEEDED"] = function(event, target, GUID, spellID)
	if target == "player" then
		if library.mounts["MountUp"][spellID] then
			playMusicSample(library.mounts["MountUp"][spellID])
		end
	end
end

-- Sample players --
--------------------
-- This is just a proxy for PlaySoundFile() for now, but makes it easier to extend later
function playSample(sample)
	if not cooldownTimers[sample] then
		if DARN_DEBUG then print("Playing sample: "..sample.path) end
		cooldownTimers[sample] = GetTime()
		PlaySoundFile(BASE_SOUND_DIRECTORY .. sample.path)

		-- Schedule the removal of sample cooldown
		C_Timer.After(sample.cooldown or DEFAULT_SAMPLE_COOLDOWN, function()
			cooldownTimers[sample] = nil
		end)
	elseif DARN_DEBUG then
		print("Sample skipped due to being on cooldown: "
		..sample.path
		.." ("
		..sample.cooldown - string.format("%.2f", GetTime()-cooldownTimers[sample])
		.."s remaining)")
	end
end

-- Play a random sample from a collection, via playSample()
function playSampleFromCollection(collection)
	if #collection > 0 then
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
			print("Sample skipped due to collection being on cooldown: "
			..sample.path
			.." ("
			..collection.cooldown - string.format("%.2f", GetTime()-cooldownTimers[collection])
			.."s remaining)")
		end
	elseif DARN_DEBUG then
		print("Tried to play from an empty collection!")
	end
end


function playMusicSample(sample)
	PlayMusic(BASE_SOUND_DIRECTORY .. sample.path)

	-- We need to schedule music to stop,
	-- but we want to avoid stopping music if another track has since started.
	PLAYING_MUSIC = sample

	local startTime = GetTime()
	cooldownTimers[sample] = startTime

	C_Timer.After(sample.cooldown, function()
		if PLAYING_MUSIC == sample and (cooldownTimers[sample] and cooldownTimers[sample] == startTime) then
			StopMusic()
			PLAYING_MUSIC = false
		end
	end)
end


-- Utilities --
---------------
-- Cheeky debug print to chat
function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("Darnellify2:: \n" .. tostring(msg))
end