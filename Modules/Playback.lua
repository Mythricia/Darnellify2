-- Sample playback functions
local addonName, Darn = ...
Darn.playback = {}

-- Importing static flags and values
local flags = Darn.flags
-- Importing utilities
local debugPrint = Darn.utils.debugPrint
local shuffle = Darn.utils.shuffle
-- Logging
local pushMessage = Darn.logging.pushMessage
-- Locally scope functions
local C_Timer = C_Timer
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile
local PlaySound = PlaySound
local PlayMusic = PlayMusic
local StopMusic = StopMusic
local random = random

-- Internal table to keep track of what's on cooldown
local cooldownTimers = {}

-- "override" param can be passed to override the objects self-specified cooldown (used for Samples currently)
local function scheduleReset(object, tag, cooldownOverride)
	local cooldown = cooldownOverride or object.cooldown

	if not cooldown then
		local msg = "Tried to schedule a cooldown that could not be resolved: " .. (tag or "?UNKNOWN?")
		pushMessage(msg, "ERROR")
		return
	end

	C_Timer.After(cooldown, function()
		cooldownTimers[object] = nil
	end)
end


local function playSampleFromCollection(collection, tag)
	if collection and (#collection > 0) then
		local collectionSize = #collection

		-- If Collection is not on cooldown, look through a shuffle of the collection,
		-- until we find a sample that is off-cooldown
		if not cooldownTimers[collection] then
			local sample
			local shuffled = shuffle(collection)

			for k, randSample in pairs(shuffled) do
				if not cooldownTimers[randSample] then
					sample = randSample
					break
				end
			end

			-- If we found a sample, play it, schedule cooldown, etc
			if sample then
				PlaySoundFile(flags.BASE_SOUND_DIRECTORY .. sample.path)

				-- Put sample on cooldown. The GetTime() value is currently unused
				cooldownTimers[sample] = GetTime()

				-- Schedule the removal of sample cooldown, if it exists (including 0!), default otherwise
				local cooldown = sample.cooldown or flags.DEFAULT_SAMPLE_COOLDOWN
				scheduleReset(sample, tag, cooldown)

				-- Debug print
				if flags.DARN_DEBUG then debugPrint("Playing sample: "..sample.path) end

				-- If Collection itself has a cooldown value, apply it and schedule that expiration too
				if collection.cooldown then
					cooldownTimers[collection] = GetTime()
					scheduleReset(collection, tag)
				end
			-- Was unable to find a free sample to play, complain about it
			elseif flags.DARN_DEBUG then
				local numStr = (collectionSize > 1) and ("all ["..collectionSize.."] samples") or "the only sample"
				debugPrint("Playback skipped, "..numStr.." in the collection on cooldown: \""..tag.."\"")
			end
		-- Collection itself was on cooldown, skip
		elseif flags.DARN_DEBUG then
			debugPrint("Playback skipped due to Collection being on cooldown: \""
			..(tag or "?UNKNOWN?")
			.."\" ("
			..collection.cooldown - string.format("%.2f", GetTime()-cooldownTimers[collection])
			.."s remaining)")
		end
	-- Empty collection, skip and complain
	elseif collection then
		local msg = ("Tried to play from an empty sample collection! -> "..(tag or "?UNDEFINED?"))
		pushMessage(msg, "ERROR")
	else
		local msg = ("Tried to play from non-existent collection! -> " .. (tag or "?UNDEFINED?"))
		pushMessage(msg, "ERROR")
	end
end

-- Only used for mount themes currently
local function playMusicFromCollection(collection, tag)
	if collection and (#collection > 0) then
		local collectionSize = #collection

		local sample = collection[random(1, collectionSize)]
		if flags.DARN_DEBUG then
			debugPrint("Playing MountMusic: " .. sample.path)
		end

		PlayMusic(flags.BASE_SOUND_DIRECTORY .. sample.path)

		-- We need to schedule music to stop,
		-- but only if the starting timestamp matches (we can only cancel ourselves)
		flags.PLAYING_MUSIC = sample

		local startTime = GetTime()
		cooldownTimers[sample] = startTime

		C_Timer.After(sample.cooldown, function()
			if flags.PLAYING_MUSIC == sample and (cooldownTimers[sample] and cooldownTimers[sample] == startTime) then
				StopMusic()
				flags.PLAYING_MUSIC = false
			end
		end)
	elseif collection then
		local msg = ("Tried to play from an empty Mount collection! -> "..(tag or "?UNDEFINED?"))
		pushMessage(msg, "ERROR")
	else
		local msg = ("Tried to play from non-existent Mount collection! -> " .. (tag or "?UNDEFINED?"))
		pushMessage(msg, "ERROR")
	end
end



Darn.playback.playSampleFromCollection = playSampleFromCollection
Darn.playback.playMusicFromCollection = playMusicFromCollection