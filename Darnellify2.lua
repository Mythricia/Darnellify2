local addonName, addonTable = ...
local settings

local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1)) -- If Major version > 1, it's not WoW Classic
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

local function initialize(frame)
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
		eventHandler[event](frame, event, ...)
	elseif DARN_DEBUG then
		print("\nEvent registered but not handled: \""..event.."\"")
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

	-- Required
	"ADDON_LOADED",
}


-- Event Handlers --
--------------------
eventHandler["ADDON_LOADED"] = function(frame, event, ...)
	if ... == addonName then
		frame:UnregisterEvent("ADDON_LOADED")
		initialize(frame)
	end
end

eventHandler["MAIL_SHOW"] = function(frame, event, ...)
	PlaySoundFile("Interface\\AddOns\\Darnellify2\\Sounds\\Ding.mp3")
end




-- Utilities --
---------------
-- Cheeky debug print to chat
function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("Darnellify2:: " .. tostring(msg))
end