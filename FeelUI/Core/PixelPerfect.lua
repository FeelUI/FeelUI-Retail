-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local select = select
local match = string.match
local floor = math.floor

-- WoW Globals
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local SetCVar = SetCVar
local UIParent = UIParent

-- Locales
local GetPhysicalScreenSize = GetPhysicalScreenSize
local Resolution = select(1, GetPhysicalScreenSize()) .. 'x' .. select(2, GetPhysicalScreenSize())
local PixelPerfectScale = 768 / match(Resolution, '%d+x(%d+)')

local trunc = function(s)
	return s >= 0 and s-s%01 or s-s%-1
end

local round = function(s)
	return s >= 0 and s-s%-1 or s-s%01
end

-- Functions
function UI:Scale(Value)
	local Mult = PixelPerfectScale / GetCVar('uiScale')

	return (Mult == 1 or Value == 0) and Value or ((Mult < 1 and trunc(Value / Mult) or round(Value / Mult)) * Mult)
end

-- Init
local OnEvent = function(self, event, ...)
	if (event == 'PLAYER_LOGIN') then
		if not (DB.General.AutoScale) then
			return
		end

		local CurrentScale = floor((DB.General.AutoUIScale * 100) + .5)
		local SavedScale = floor((GetCVar('uiScale') * 100) + .5)

		SetCVar('useUiScale', 0)

		if (SavedScale ~= CurrentScale) then
			SetCVar('uiScale', DB.General.AutoUIScale)
		end

		if (DB.General.AutoUIScale < 0.64) then
			UIParent:SetScale(DB.General.AutoUIScale)
		end
	end
end

local EventFrame = CreateFrame('Frame')
EventFrame:RegisterEvent('PLAYER_LOGIN')
EventFrame:SetScript('OnEvent', OnEvent)
