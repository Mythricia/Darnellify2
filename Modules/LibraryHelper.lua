-- Library helpers / manipulation
local addonName, Darn = ...
Darn.libhelper = {}

-- Get the sample library
local library = Darn.library


local function getLibraryCategories()
	local catergories = {}

	for k, v in pairs(library) do
		table.insert(catergories, k)
	end

	return catergories
end