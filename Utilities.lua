-- Darnellify2 utilities
local addonName, Darn = ...
Darn.utils = {}

-- Color tags
local cTag = "|cFF"
local colors = {
	red 	= cTag.."FF0000",
	green	= cTag.."00FF00",
	blue	= cTag.."0000FF",
	cyan	= cTag.."00FFFF",
	teal	= cTag.."008080",
	orange	= cTag.."FFA500",
	brown	= cTag.."8B4500",
	pink	= cTag.."EE1289",
	purple	= cTag.."9F79EE",
	yellow	= cTag.."FFF569",
	white	= cTag.."FFFFFF",
}
local prettyName = colors.yellow..addonName.."|r"

-- Debug print
local function debugPrint(msg)
	DEFAULT_CHAT_FRAME:AddMessage(prettyName..":: " .. tostring(msg))
end

-- Check if table contains KEY
local function tableContains(t, val)
    if type(t) == "table" then
        for k, v in pairs(t) do
            if v == val then
                return true
            end
        end
    end
    return false
end

-- Fisher-Yates shuffle. Importantly this returns a NEW table, rather than modify the input.
local function shuffle( tInput )
	local tReturn = {}
	local j

    for i = #tInput, 1, -1 do
        j = fastrandom(i) -- using WoW's fastrandom() here since this might be a tight loop
        tInput[i], tInput[j] = tInput[j], tInput[i]
        table.insert(tReturn, tInput[i])
    end
    return tReturn
end

-- Helper function  to clean up event hooking syntax
local function isModern(passthroughEvent)
	if Darn.flags.FAKE_CLASSIC then
		return nil
	else
		return (Darn.flags.CLIENT_MAJOR_VER > 1 and passthroughEvent) or nil
	end
end

-- Exporting to addonTable
Darn.utils.colors = colors
Darn.utils.prettyName = prettyName
Darn.utils.debugPrint = debugPrint
Darn.utils.tableContains = tableContains
Darn.utils.shuffle = shuffle
Darn.utils.isModern = isModern