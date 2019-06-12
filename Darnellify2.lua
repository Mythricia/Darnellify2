local addonName, addonTable = ...
local settings

-- Forward declarations
local parseEvent
local eventHandler = {}

-- Find out which version we're playing.
-- If Major version > 1, it's not WoW Classic
local CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1))

-- Using a function here to clean up the event hooking syntax later
local function ifModern(passthroughEvent)
	return (CLIENT_MAJOR_VER > 1 and passthroughEvent) or nil
end


-- EVENT LISTINGS --
--------------------

local eventList =
{
	-- Modern-only events
	ifModern("TRANSMOGRIFY_OPEN"),
	ifModern("TRANSMOGRIFY_CLOSE"),

	-- Classic-safe events
	"MAIL_SHOW",
	"MAIL_CLOSED",
}



-- Misc addon setup --
----------------------

local eventFrame = CreateFrame("Frame", "DarnellifyEventFrame")
eventFrame:UnregisterAllEvents()


local function initialize(self, event, name)
	if name == addonName then
		
		-- Do some user settings stuff here at some point
		settings = Darnellify2_Settings or {}
		
		eventFrame:UnregisterAllEvents()
		eventFrame:SetScript("OnEvent", parseEvent)
		
		for k, v in pairs(eventList) do
			if type(k) == "string" then
				eventFrame:RegisterEvent(k)
			end
		end
	end
end

-- Just wait for addon load for now
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", initialize)


function parseEvent(self, event, ...)
	if eventList[event] ~= nil then
		DEFAULT_CHAT_FRAME:AddMessage("Handled Event: " .. event)
		eventHandler[event](event, ...)
	end
end


-- Event Handlers --
--------------------

eventHandler["MAIL_SHOW"] = function(event, ...)
	PlaySoundFile("Interface\\AddOns\\Darnellify2\\Sounds\\Ding.mp3")
end