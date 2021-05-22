-- Lib Globals
local _G = _G
local select = select
local setmetatable = setmetatable
local max = math.max
local min = math.min
local match = string.match

-- WoW Globals
local GetAddOnMetadata = GetAddOnMetadata
local GetCVar = GetCVar
local GetLocale = GetLocale
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetRealmName = GetRealmName
local GetSpecialization = GetSpecialization
local UnitClass = UnitClass
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitRace = UnitRace

-- Locales
local Resolution = select(1, GetPhysicalScreenSize()) .. 'x' .. select(2, GetPhysicalScreenSize())
local Windowed = Display_DisplayModeDropDown:windowedmode()
local Fullscreen = Display_DisplayModeDropDown:fullscreenmode()
local PixelPerfectScale = 768 / match(Resolution, '%d+x(%d+)')

-- Build the engine
local AddOnName, Engine = ...

Engine[1] = {} -- UI
Engine[2] = {} -- DB
Engine[3] = {} -- Media
Engine[4] = {} -- Language

-- Modules
Engine[1].Modules = {}

-- AddOn
Engine[1].Title = GetAddOnMetadata('FeelUI', 'Title')
Engine[1].Version = GetAddOnMetadata('FeelUI', 'Version')

-- Language
local Index = function(self, Value)
	return Value
end

setmetatable(Engine[4], { __index = Index })

-- Globals
Engine[1].Dummy = function() return end
Engine[1].TextureCoords = { 0.08, 0.92, 0.08, 0.92 }

-- Player
Engine[1].UserClass = select(2, UnitClass('player'))
Engine[1].UserFaction = UnitFactionGroup('player')
Engine[1].UserGUID = UnitGUID('player')
Engine[1].UserLevel = UnitLevel('player')
Engine[1].UserLocale = GetLocale()
Engine[1].UserName = UnitName('player')
Engine[1].UserRace = select(2, UnitRace('player'))
Engine[1].UserRealm = GetRealmName()
Engine[1].UserSpec = GetSpecialization()

if (Engine[1].UserLocale == 'enGB') then
	Engine[1].UserLocale = 'enUS'
end

-- Game
Engine[1].WindowedMode = Windowed
Engine[1].FullscreenMode = Fullscreen
Engine[1].Resolution = Resolution or (Windowed and GetCVar('gxWindowedResolution')) or GetCVar('gxFullscreenResolution')
Engine[1].ScreenHeight = select(2, GetPhysicalScreenSize())
Engine[1].ScreenWidth = select(1, GetPhysicalScreenSize())
Engine[1].PerfectScale = min(1.15, max(0.4, 768 / match(Resolution, '%d+x(%d+)')))
Engine[1].Mult = PixelPerfectScale / GetCVar('uiScale')
Engine[1].NoScaleMult = Engine[1].Mult * GetCVar('uiScale')

-- Access Tables
function Engine:Call()
	return self[1], self[2], self[3], self[4]
end

-- Global Access
_G['FeelUI'] = Engine
