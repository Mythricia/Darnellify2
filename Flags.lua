-- Static flags and values
local addonName, Darn = ...
Darn.flags = {}

Darn.flags.FAKE_CLASSIC = false
Darn.flags.DARN_DEBUG = false

Darn.flags.DEFAULT_SAMPLE_COOLDOWN = 1
Darn.flags.BASE_SOUND_DIRECTORY = "Interface\\AddOns\\Darnellify2\\Sounds\\"

Darn.flags.CLIENT_MAJOR_VER = tonumber(GetBuildInfo():sub(1,1))