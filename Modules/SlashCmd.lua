-- SlashCmd handling
local addonName, Darn = ...

-- Utilities
local colors 		= Darn.utils.colors
local prettyName	= Darn.utils.prettyName
local debugPrint 	= Darn.utils.debugPrint
local tableContains = Darn.utils.tableContains
local isModern		= Darn.utils.isModern
local pairsByKeys	= Darn.utils.pairsByKeys
-- Flags
local flags = Darn.flags
-- Logging
local messages = Darn.logging.messages
local pushMessage = Darn.logging.pushMessage
-- Library
local library = Darn.library
-- Playback
local playSampleFromCollection = Darn.playback.playSampleFromCollection


-- SlashCmd handlers
local slashCommands = {}

slashCommands.events = {
	func = function(cmd, ...)
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
	func = function(cmd, ...)
		flags.DARN_DEBUG = not flags.DARN_DEBUG
		if flags.DARN_DEBUG then
			print(prettyName..": Verbose errors "..colors.green.."enabled")
		else
			print(prettyName..": Verbose errors "..colors.red.."disabled")
		end
	end,

	desc = "Makes Darnellify2 very talkative! (Debugging messages)",

	aliases = {"debug", "shutup", "verbose"},
}


slashCommands.messages = {
	func = function(cmd, ...)
		if cmd == "clear" then
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

	desc = "Show all log messages. Use '/darn messages clear' to clear log",

	aliases = {"log"},
}


-- Print list of event categories in the SampleLibrary
slashCommands.library = {
	func = function(cmd, arg1, arg2)
		local function extractCatColl(a1, a2)
			if not a1 then return end
			local cat, coll
			local patternMatch = "[%:%;%.%,%\\%/]"

			-- See if we're being passed 2 args, or 1 arg with dot notation
			if a1:find(patternMatch) then
				cat	= a1:sub(1, a1:find(patternMatch)-1)
				coll= a1:sub(a1:find(patternMatch)+1, -1)
			else
				cat = a1
				coll= a2
			end

			return cat, coll
		end

		if (cmd == "play") then
			local category, collection = extractCatColl(arg1, arg2)

			if (not category) or (not collection) then
				pushMessage("Invalid arguments for /darn library play <category> <collection>", "ERROR")
				return
			end

			print(prettyName..": Trying to play sample -> "..category.."[\""..collection.."\"]")
			playSampleFromCollection(library[category][collection], (category.."\\"..collection))
		elseif (cmd == "list") then
			print(prettyName..": Dumping sample library:")
			for k, v in pairsByKeys(library) do
				print("\""..k.."\" = ")
				if type(v) == "table" then
					for k2, v2 in pairsByKeys(v) do
						if k == "mounts" then
							print(". . . " .. "["..((v2.music and #v2.music) or #v2).."] " .. k2)
						else
							print(". . . " .. "["..#v2.."] " .. k2)
						end
					end
				end
			end
		elseif (cmd == "mute") then
			local category, collection = extractCatColl(arg1, arg2)

			-- Check that the cat and coll being requested actually exists
			if category and (not library[category]) then
				print(prettyName..": That category does not exist in the library: \""..colors.red..category.."|r\"")
				return
			end
			if collection and (not library[category][collection]) then
				print(prettyName..": That collection does not exist in the library: "..category.."[\""..colors.red..collection.."|r\"]")
				return
			end

			-- Unhide if already hidden
			if category and library[category].___hidden then
				library[category] = library[category].___hidden
				library[category].___hidden = nil
				print(colors.green.."Unmuted category |r\""..category.."\"")
			elseif (category and collection) and library[category][collection].___hidden then
				library[category][collection] = library[category][collection].___hidden
				library[category][collection].___hidden = nil
				print(colors.green.."Unmuted collection |r"..category.."[\""..collection.."\"]")
			else
				-- Put cat or coll into a ___hidden subtable and replace the original with an empty table, effectively hiding it
				if category and collection then
					local coll = library[category][collection]
					library[category][collection] = {}
					library[category][collection].___hidden = coll
					print(colors.red.."Muted collection|r "..category.."[\""..collection.."\"]")
				elseif category then
					local cat = library[category]
					library[category] = {}
					library[category].___hidden = cat
					print(colors.red.."Muted category |r\""..category.."\"")
				end
			end
		end
	end,

	desc = "Interact with the sample library. Try '/darn library [play <category> <collection>, list, mute <category> <collection>]'",

	aliases = {"lib", "sample", "samples"},
}

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

-- Misc SlashCmd code
local function slashProcessor(cmd)
	-- split the recieved slashCmd into a root command plus any extra arguments
	local parts = {}
	local root

	for part in cmd:gmatch("%S+") do
		table.insert(parts, part)
	end

	-- Strip out and store the root command
	if #parts > 0 then
		root = parts[1]:lower()
		table.remove(parts, 1)
	end

	-- Check if the root command exists, and call it. Else print error and list available commands + their description (if any)
	if root then
		local rootCmd = nil

		-- Look if this is an alias of an actual command
		for k, v in pairs(slashCommands) do
			if (k:find(root) == 1) or (tableContains(v.aliases, root)) then
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