-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

local Skinning = UI:RegisterModule('Skinning')
Skinning:RegisterEvent('ADDON_LOADED')

-- Lib Globals
local pairs = pairs
local type = type

-- WoW Globals
local IsAddOnLoaded = IsAddOnLoaded

-- Locales

-- Functions

-- Skinning
UI.SkinFuncs = {}
UI.SkinFuncs['FeelUI'] = {}

function Skinning:OnEvent(Event, AddOn)
	if (IsAddOnLoaded('Skinner') or IsAddOnLoaded('Aurora') or not DB.Skins.Enable) then
		self:UnregisterEvent('ADDON_LOADED')

		return
	end

	for _AddOn, SkinFunc in pairs(UI.SkinFuncs) do
		if (type(SkinFunc) == 'function') then
			if (_AddOn == AddOn) then
				if (SkinFunc) then
					SkinFunc()
				end
			end
		elseif (type(SkinFunc) == 'table') then
			if (_AddOn == AddOn) then
				for _, SkinFunc in pairs(UI.SkinFuncs[_AddOn]) do
					if (SkinFunc) then
						SkinFunc()
					end
				end
			end
		end
	end
end

Skinning:SetScript('OnEvent', Skinning.OnEvent)
