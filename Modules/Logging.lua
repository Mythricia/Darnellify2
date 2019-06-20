-- Message logging
local addonName, Darn = ...
Darn.logging = {}

-- Utilities
local colors 		= Darn.utils.colors
local prettyName	= Darn.utils.prettyName
-- Flags
local flags = Darn.flags
local debugPrint = Darn.utils.debugPrint

-- Locals
local messages = {}

-- Push a new message to messages
local function pushMessage(msg, msgType)
	local entry = {
		type = msgType or "GENERIC",
		msg = msg,
		time = date("%H:%M:%S"),
	}

	table.insert(messages, entry)
	if flags.DARN_DEBUG then
		debugPrint(msg)
	else
		print(prettyName..": Logged "..msgType.." message. See "..colors.orange.."/darn messages|r. ["..#messages.."]")
	end
end

-- Error hooking to capture Darnellify2 related errors to the messages log
local default_errorHandler = geterrorhandler()
local function darnError(errorMessage)
	local parts = {strsplit("\\:", errorMessage)}

	if (#parts > 0) and (parts[3] == addonName) then
		local addon = parts[3]
		local file = parts[4]
		local line = parts[5]
		local err = parts[6]:sub(2)

		local errStr = format("Lua error!|r In file <"..
		colors.cyan..
		"%s|r> @ line ["..
		colors.pink..
		"%d|r]: "..
		colors.orange..
		"%q|r", file, line, err)

		pushMessage(errStr, "ERROR")
		return
	end

	-- pass the errors on to the default handler
	default_errorHandler(errorMessage)
end

seterrorhandler(darnError)


-- Exporting
Darn.logging.pushMessage = pushMessage
Darn.logging.messages = messages