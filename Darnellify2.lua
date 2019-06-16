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

-- Tables
local eventHandler = {}
local eventList = {}
local cooldownTimers = {}

-- Forward declarations
local playSample
local playSampleFromCollection
local playMusicFromCollection
local tableContains
local print -- overriding for debug purposes


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
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),
	ifModern("ACHIEVEMENT_EARNED"),

	-- Classic-safe events
	"MAIL_SHOW",
	"MAIL_CLOSED",
	"UNIT_SPELLCAST_SUCCEEDED",
	"PLAYER_MOUNT_DISPLAY_CHANGED",
}


-- Event handlers
eventHandler["ADDON_LOADED"] = function(event, ...)
	if ... == addonName then
		initialize()
	end
end


eventHandler["MAIL_SHOW"] = function(event, ...)
	playSampleFromCollection(library.interface.Mailbox_Open)
end


-- This only deals with trying to keep the MOUNTED flag up to date
eventHandler["PLAYER_MOUNT_DISPLAY_CHANGED"] = function(event, ...)
	if MOUNTED then
		print("We were dismounted!")
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
eventHandler["UNIT_SPELLCAST_SUCCEEDED"] = function(event, target, GUID, spellID)
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


function playMusicFromCollection(collection)
	if #collection > 0 then
		local sample = collection[random(1, #collection)]
		if DARN_DEBUG then
			print("Playing MountMusic: " .. sample.path)
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
	end
end


-- Utilities
function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("Darnellify2:: \n" .. tostring(msg))
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