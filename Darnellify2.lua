local addonName, Darnellify = ...
local collections = Darnellify.collections
local settings

local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1)) -- If Major version > 1, it's not WoW Classic
local BASE_SOUND_DIRECTORY = "Interface\\AddOns\\Darnellify2\\Sounds\\"
local DARN_DEBUG = true -- Print ugly debug messages in chatframe

-- Forward declarations
local eventHandler = {}
local eventList = {}
local print


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
	local samples = collections.interface.MAILBOX_OPEN
	local sample = samples[random(1, #samples)].path

	local finalPath = BASE_SOUND_DIRECTORY..sample
	if DARN_DEBUG then print("Playing sample: "..finalPath) end
	PlaySoundFile(finalPath)
end




-- Utilities --
---------------
-- Cheeky debug print to chat
function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("Darnellify2:: \n" .. tostring(msg))
end