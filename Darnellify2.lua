local addonName, Darnellify = ...
local collections = Darnellify.collections
local settings

local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1)) -- If Major version > 1, it's not WoW Classic
local BASE_SOUND_DIRECTORY = "Interface\\AddOns\\Darnellify2\\Sounds\\"
local DEFAULT_SAMPLE_COOLDOWN = 1
local DARN_DEBUG = true -- Print ugly debug messages in chatframe

-- Forward declarations
local eventHandler = {}
local eventList = {}
local sampleCooldowns = {}	-- This table keeps track of samples that are still on cooldown
local playSampleFromCollection
local playSample
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
	return (CLIENT_MAJOR_VER > 1 and passthroughEvent) or nil
end


-- EVENT LISTINGS --
--------------------
eventList =
{
	-- Modern-only events
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),

	-- Classic-safe events
	"MAIL_SHOW",
	"MAIL_CLOSED",
}


-- Event Handlers --
--------------------
eventHandler["ADDON_LOADED"] = function(event, ...)
	if ... == addonName then
		initialize()
	end
end

eventHandler["MAIL_SHOW"] = function(event, ...)
	playSampleFromCollection(collections.interface.MAILBOX_OPEN)
end




-- Sample players --
--------------------
-- This is just a proxy for PlaySoundFile() for now, but makes it easier to extend later
function playSample(sample)
	if DARN_DEBUG then print("Playing sample: "..sample.path) end

	if not sampleCooldowns[sample] then
		sampleCooldowns[sample] = true
		PlaySoundFile(BASE_SOUND_DIRECTORY .. sample.path)

		-- Schedule the removal of the cooldown
		C_Timer.After(sample.cooldown or DEFAULT_SAMPLE_COOLDOWN, function()
			sampleCooldowns[sample] = nil
		end)
	elseif DARN_DEBUG then
		print("Sample skipped due to being on cooldown: "..sample.path)
	end
end

-- Play a random sample from a collection, via playSample()
function playSampleFromCollection(collection)
	local sample = collection[random(1, #collection)]
	playSample(sample)
end


-- Utilities --
---------------
-- Cheeky debug print to chat
function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("Darnellify2:: \n" .. tostring(msg))
end