-- SlashCmd handling
local addonName, Darn = ...

-- Importing utilities
local colors 		= Darn.utils.colors
local prettyName	= Darn.utils.prettyName
local debugPrint 	= Darn.utils.debugPrint
local tableContains = Darn.utils.tableContains
local isModern		= Darn.utils.isModern

-- Importing flags (whole table)
local flags = Darn.flags

-- Logging message table
local messages = Darn.logging.messages

-- SlashCmd handlers
local slashCommands = {}

slashCommands.events = {
	func = function(...)
		print(" ")
		print(prettyName.." hooked events ("..#Darn.eventList.."): ")
		local modern = isModern("dummy") and "False" or "True"
		print("(WoW Classic mode: "..modern..")")
		for k, v in pairs( Darn.eventList ) do
			print( colors.green .. v )
		end
	end,

	desc = "Lists all registered Events"
}


slashCommands.spam = {
	func = function(...)
		flags.DARN_DEBUG = not flags.DARN_DEBUG
		if flags.DARN_DEBUG then
			print(prettyName..": Verbose errors "..colors.green.."enabled")
		else
			print(prettyName..": Verbose errors "..colors.red.."disabled")
		end
	end,

	desc = "Makes Darnellify2 very talkative! (Debugging messages)",

	aliases = {"debug", "shutup", "verbose"}
}


slashCommands.messages = {
	func = function(...)
		if ... == "clear" then
			messages = {}
			print(prettyName..": Messages cleared!")
			return
		end

		if #messages > 0 then
			print(prettyName..": Dumping "..#messages.." log messages: ")
			for k, v in ipairs(messages) do
				if v.type == "WARNING" then
					print("["..k.."] ("..v.time..") "..colors.yellow..v.msg)
				elseif v.type == "ERROR" then
					print("["..k.."] ("..v.time..") "..colors.red..v.msg)
				else
					print("["..k.."] ("..v.time..") "..v.msg)
				end
			end
			print(prettyName..": clear message log with '/darn messages clear'")
		else
			print(prettyName..": No log messages!")
		end
	end,

	desc = "Show all log messages. Use '/darn messages clear' to clear log"
}


-- Misc SlashCmd code
local function slashProcessor(cmd)
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
			print(colors.yellow..addonName.." commands:")

			for k, v in pairs(slashCommands) do
				local triggers = k

				-- append any aliases defined
				if v.aliases and (#v.aliases > 0) then
					for _, alias in ipairs(v.aliases) do
						triggers = triggers .. ", " .. alias
					end
				end

				print(triggers)
				if v.desc then
					print(colors.cyan..slashListSeparator..colors.orange..v.desc)
				else
					print(slashListSeparator..colors.red.."No Description")
				end
			end
		end
	end


	-- Check if the root command exists, and call it. Else print error and list available commands + their description (if any)
	if root then
		local rootCmd = nil

		-- Look if this is an alias of an actual command
		for k, v in pairs(slashCommands) do
			if (k == root) or (tableContains(v.aliases, root)) then
				rootCmd = k
				break
			end
		end

		if rootCmd then
			slashCommands[rootCmd].func(unpack(parts))
		else
			print(prettyName.." unrecognized command: "..colors.red..root)
			print("List available commands with "..colors.cyan.."/darn|r or "..colors.cyan.."/darnellify")
		end
	else
		print(prettyName..": ["..#messages.."] messages stored.")
		printCmdList()
	end
end


SLASH_Darnellify1 = "/Darnell"
SLASH_Darnellify2 = "/Darnellify"
SLASH_Darnellify3 = "/Darn"
SLASH_Darnellify4 = "/Fony"
SLASH_Darnellify5 = "/MikeB"

SlashCmdList["Darnellify"] = slashProcessor