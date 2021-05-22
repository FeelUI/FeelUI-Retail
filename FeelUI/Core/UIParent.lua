-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals

-- WoW Globals
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Locales

-- Functions

-- Init
UI.UIParent = CreateFrame('Frame', 'FeelUIParent', UIParent, 'SecureHandlerStateTemplate')
UI.UIParent:SetAllPoints(UIParent)
UI.UIParent:SetFrameLevel(UIParent:GetFrameLevel())

UI.HiddenParent = CreateFrame('Frame', nil, UIParent)
UI.HiddenParent:SetAllPoints()
UI.HiddenParent:Hide()

UI.HiddenPetFrame = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
UI.HiddenPetFrame:SetAllPoints()
UI.HiddenPetFrame:SetFrameStrata('LOW')

RegisterStateDriver(UI.HiddenPetFrame, 'visibility', '[petbattle] hide; show')
