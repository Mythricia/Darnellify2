-- Sample playback functions
local addonName, Darn = ...
Darn.playback = {}

-- Importing static flags and values
local flags = Darn.flags
-- Importing utilities
local debugPrint 	= Darn.utils.debugPrint
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


-- Sample playback functions
local function playSample(sample)
	local cooldown = sample.cooldown or flags.DEFAULT_SAMPLE_COOLDOWN

	if not cooldownTimers[sample] then
		if flags.DARN_DEBUG then debugPrint("Playing sample: "..sample.path) end
		cooldownTimers[sample] = GetTime()
		PlaySoundFile(flags.BASE_SOUND_DIRECTORY .. sample.path)

		-- Schedule the removal of sample cooldown, if it exists (including 0!), default otherwise
		C_Timer.After(cooldown, function()
			cooldownTimers[sample] = nil
		end)
	elseif flags.DARN_DEBUG then
		-- try to extract file name to give a hint
		local nameStart = #sample.path - sample.path:reverse():find("\\") + 1
		local fileName = sample.path:sub(nameStart+1) or "UNKNOWN"

		debugPrint("Sample skipped due to being on cooldown: \""
		..fileName
		.."\" ("
		..cooldown - string.format("%.2f", GetTime()-cooldownTimers[sample])
		.."s remaining)")
	end
end


local function playSampleFromCollection(collection, tag)
	if collection and (#collection > 0) then
		local sample = collection[random(1, #collection)]
		if not cooldownTimers[collection] then
			playSample(sample)

			-- If collection has a cooldown value, apply it and schedule the expiration
			if collection.cooldown then
				cooldownTimers[collection] = GetTime()
				C_Timer.After(collection.cooldown, function()
					cooldownTimers[collection] = nil
				end)
			end
		elseif flags.DARN_DEBUG then
			debugPrint("Sample skipped due to collection being on cooldown: \""
			..(tag or "?UNKNOWN?")
			.."\" ("
			..collection.cooldown - string.format("%.2f", GetTime()-cooldownTimers[collection])
			.."s remaining)")
		end
	else
		local msg = ("Tried to play from an empty sample collection! -> "..(tag or "?UNDEFINED?"))
		if flags.DARN_DEBUG then
			debugPrint(msg)
		end
		pushMessage(msg, "ERROR")
	end
end


local function playMusicFromCollection(collection, tag)
	if collection and (#collection > 0) then
		local sample = collection[random(1, #collection)]
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
	else
		local msg = ("Tried to play from an empty Mount collection! -> "..(tag or "UNDEFINED"))
		if flags.DARN_DEBUG then
			debugPrint(msg)
		end
		pushMessage(msg, "ERROR")
	end
end



Darn.playback.playSampleFromCollection = playSampleFromCollection
Darn.playback.playMusicFromCollection = playMusicFromCollection