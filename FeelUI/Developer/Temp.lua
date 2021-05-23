-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Register Module
local DEV = UI:RegisterModule('DEV')
DEV.Enable = false

-- Lib Globals

-- WoW Globals

-- Locals

-- Functions

-- Init
function DEV:Initialize()
	if not (self.Enable) then
		return
	end

	print('DEV_FILE_LOADED')
end
