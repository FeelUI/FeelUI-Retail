-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Register Module
local StatusReport = UI:RegisterModule('StatusReport')

-- Lib Globals
local unpack = unpack

-- WoW Globals
local CreateFrame = CreateFrame

local UNKNOWN = UNKNOWN
local NO = NO
local YES = YES

-- Locals
local UserName = UI.UserName
local R, G, B = unpack(UI.GetClassColors)

local EnglishClassNames = {
	DEATHKNIGHT = "Death Knight",
	DEMONHUNTER = "Demon Hunter",
	DRUID = "Druid",
	HUNTER = "Hunter",
	MAGE = "Mage",
	MONK = "Monk",
	PALADIN = "Paladin",
	PRIEST = "Priest",
	ROGUE = "Rogue",
	SHAMAN = "Shaman",
	WARLOCK = "Warlock",
	WARRIOR = "Warrior",
}

local EnglishSpecNames = {
	[250] = "Blood",
	[251] = "Frost",
	[252] = "Unholy",
	[102] = "Balance",
	[103] = "Feral",
	[104] = "Guardian",
	[105] = "Restoration",
	[253] = "Beast Mastery",
	[254] = "Marksmanship",
	[255] = "Survival",
	[62] = "Arcane",
	[63] = "Fire",
	[64] = "Frost",
	[268] = "Brewmaster",
	[270] = "Mistweaver",
	[269] = "Windwalker",
	[65] = "Holy",
	[66] = "Protection",
	[70] = "Retribution",
	[256] = "Discipline",
	[257] = "Holy",
	[258] = "Shadow",
	[259] = "Assasination",
	[260] = "Combat",
	[261] = "Sublety",
	[262] = "Elemental",
	[263] = "Enhancement",
	[264] = "Restoration",
	[265] = "Affliction",
	[266] = "Demonoligy",
	[267] = "Destruction",
	[71] = "Arms",
	[72] = "Fury",
	[73] = "Protection",
	[577] = "Havoc",
	[581] = "Vengeance",
}

-- Functions
local GetSpecName = function()
	return EnglishSpecNames[GetSpecializationInfo(GetSpecialization())] or UNKNOWN
end

function StatusReport:GetClient()
	if (IsWindowsClient()) then
		return "Windows"
	elseif (IsMacClient()) then
		return "Mac"
	else
		return "Linux"
	end
end

function StatusReport:GetNumLoadedAddOns()
	local NumLoaded = 0

	for Index = 1, GetNumAddOns() do
		if (IsAddOnLoaded(Index)) then
			NumLoaded = NumLoaded + 1
		end
	end

	return NumLoaded
end

function StatusReport:IsAddOnEnabled(AddOn)
	return GetAddOnEnableState(UserName, AddOn) == 2
end

function StatusReport:AddonsCheck()
	for Index = 1, GetNumAddOns() do
		local Name = GetAddOnInfo(Index)

		if (Name ~= "FeelUI" or Name ~= 'FeelUI_Options' and StatusReport:IsAddOnEnabled(Name)) then
			return '|cffff3333' .. NO .. '|r'
		end
	end

	return '|cff4beb2c' .. YES .. '|r'
end

function StatusReport:GetDisplayMode()
	local Window, Maximize = GetCVar("gxWindow") == "1", GetCVar("gxMaximize") == "1"

	return (Window and Maximize and "Windowed (Fullscreen)") or (Window and "Windowed") or "Fullscreen"
end


function StatusReport:CreateCategories(Parent, Name, FontSize, ShadowOffsetX, ShadowOffsetY, InsertText, R, G, B, A, Anchor, OffsetX, OffsetY)
	local Text = Parent:CreateFontString(nil, "OVERLAY")
	Text:Point("TOP", Anchor, 'TOP', OffsetX or 0, OffsetY or 0)
	Text:SetFontTemplate("Default", FontSize, ShadowOffsetX or 1, ShadowOffsetY or 1)
	Text:SetText(InsertText)
	Text:SetTextColor(R, G, B, A)

	if (Name) then
		Parent[Name] = Text
	end

	return Text
end

function StatusReport:CreateDividerLeft(Parent, Name, R, G, B, Anchor, OffsetX, OffsetY)
	local Divider = CreateFrame("StatusBar", nil, Parent)
	Divider:Size(146, 2)
	Divider:Point("LEFT", Anchor, 'LEFT', OffsetX or 0, OffsetY or 0)
	Divider:SetStatusBarTexture(Media.Textures.Highlight)
	Divider:SetStatusBarColor(R, G, B, 0.7)
	
	if (Name) then
		Parent[Name] = Divider
	end

	return Divider
end

function StatusReport:CreateDividerRight(Parent, Name, R, G, B, Anchor, OffsetX, OffsetY)
	local Divider = CreateFrame("StatusBar", nil, Parent)
	Divider:Size(146, 2)
	Divider:Point("RIGHT", Anchor, 'RIGHT', OffsetX or 0, OffsetY or 0)
	Divider:SetStatusBarTexture(Media.Textures.Highlight)
	Divider:SetStatusBarColor(R, G, B, 0.7)
	
	if (Name) then
		Parent[Name] = Divider
	end

	return Divider
end

function StatusReport:CloseOnMouseUp()
	StatusReport:Toggle()
end

function StatusReport:UpdateStatusFrameSpec()
	self.Frame.Spec:SetFormattedText("|cffffffffSpec:|r %s", GetSpecName())
end

function StatusReport:UpdateStatusFrameZone()
	self.Frame.Zone:SetFormattedText("Current Zone: |cff4beb2c%s", GetRealZoneText() or UNKNOWN)
end

function StatusReport:Toggle()
	if (InCombatLockdown()) then
		return
	end

	if (self.Frame:IsShown()) then
		self.Frame.FadeOut:Play()
	else
		self.Frame:Show()
		self.Frame.FadeIn:Play()
	end
end

function StatusReport:PLAYER_REGEN_DISABLED()
	if (self.Frame:IsShown()) then
		self.Frame:SetAlpha(0)
		self.Frame:Hide()
		self.Frame.CombatClosed = true
	end
end

function StatusReport:PLAYER_REGEN_ENABLED()
	if (self.Frame.CombatClosed) then
		self.Frame:Show()
		self.Frame:SetAlpha(1)
		self.Frame.CombatClosed = false
	end
end

function StatusReport:OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA") then
		self:UpdateStatusFrameZone()
	end
	
	if (event == "PLAYER_ENTERING_WORLD" or event == "ACTIVE_TALENT_GROUP_CHANGED") then
		self:UpdateStatusFrameSpec()
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		self:PLAYER_REGEN_DISABLED()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:PLAYER_REGEN_ENABLED()
	end
end

function StatusReport:CreateStatus()
	-- Main Frame
	local Frame = CreateFrame("Frame", nil, UIParent)
	Frame:Raise()
	Frame:Point("CENTER",_G.UIParent, 0, 112)
	Frame:Size(342, 442)
	Frame:CreateBackdrop()
	Frame.Backdrop:CreateShadow()
	Frame:SetAlpha(0)
	Frame:Hide()

	-- ANIMATION
	Frame.Fade = CreateAnimationGroup(Frame)

	Frame.FadeIn = Frame.Fade:CreateAnimation("Fade")
	Frame.FadeIn:SetDuration(1)
	Frame.FadeIn:SetChange(1)
	Frame.FadeIn:SetEasing("in-sinusoidal")

	Frame.FadeOut = Frame.Fade:CreateAnimation("Fade")
	Frame.FadeOut:SetDuration(1)
	Frame.FadeOut:SetChange(0)
	Frame.FadeOut:SetEasing("out-sinusoidal")
	Frame.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)

	GameMenuFrame:HookScript("OnShow", function()
		if StatusReport.Frame:IsShown() then
			StatusReport:Toggle()
		end
	end)

	-- Invisible Frame
	local InvisFrame = CreateFrame("Frame", nil, Frame)
	InvisFrame:SetFrameLevel(Frame:GetFrameLevel() + 10)
	InvisFrame:SetInside()

	-- Logo
	local Logo = InvisFrame:CreateTexture(nil, "OVERLAY")
	Logo:Size(162, 162)
	Logo:Point("TOP", Frame, 0, 82)
	Logo:SetTexture(Media.Textures.Logo)

	-- Texts
	self:CreateCategories(InvisFrame, "AddonInfoText", 18, 1, 1, "AddOn Info", 1, 0.82, 0, 1, Frame, 0, -22)
	self:CreateCategories(InvisFrame, "WoWInfoText", 18, 1, 1, "WoW Info", 1, 0.82, 0, 1, Frame, 0, -150)
	self:CreateCategories(InvisFrame, "CharacterInfoText", 18, 1, 1, "Character Info", 1, 0.82, 0, 1, Frame, 0, -280)

	-- Dividers
	StatusReport:CreateDividerLeft(Frame, "AddonInfoDividerLeft", 0, 0.66, 1, InvisFrame.AddonInfoText, 72, -2)
	StatusReport:CreateDividerRight(Frame, "AddonInfoDividerRight", 0, 0.66, 1, InvisFrame.AddonInfoText, -72, -2)
	StatusReport:CreateDividerLeft(Frame, "WoWInfoDividerLeft", 0, 0.66, 1, InvisFrame.WoWInfoText, 68, -2)
	StatusReport:CreateDividerRight(Frame, "WoWInfoDividerRight", 0, 0.66, 1, InvisFrame.WoWInfoText, -68, -2)
	StatusReport:CreateDividerLeft(Frame, "CharacterInfoDividerLeft", 0, 0.66, 1, InvisFrame.CharacterInfoText, 88, -2)
	StatusReport:CreateDividerRight(Frame, "CharacterInfoDividerRight", 0, 0.66, 1, InvisFrame.CharacterInfoText, -88, -2)

	-- Addon Info
	self:CreateCategories(Frame, "TotalAddOns", 16, 1, 1, "Total AddOns: |CFF4BEB2C" .. GetNumAddOns(), 1, 1, 1, 1, InvisFrame.AddonInfoText, 0, -26)
	self:CreateCategories(Frame, "LoadedAddOns", 16, 1, 1, "Loaded AddOns: |CFF4BEB2C" .. self:GetNumLoadedAddOns(), 1, 1, 1, 1, Frame.TotalAddOns, 0, -20)
	self:CreateCategories(Frame, "OtherAddOnsEnabled", 16, 1, 1, "|CFF00AAFFFeelUI|r Only Loaded: " .. self.AddonsCheck(), 1, 1, 1, 1, Frame.LoadedAddOns, 0, -20)
	self:CreateCategories(Frame, "Version", 16, 1, 1, "|CFF00AAFFFeelUI|r Version: |CFF4BEB2C".. UI.Version, 1, 1, 1, 1, Frame.OtherAddOnsEnabled, 0, -20)
	self:CreateCategories(Frame, "UIScale", 16, 1, 1, "UI Scale: |CFF4BEB2C" .. GetCVar('uiScale'), 1, 1, 1, 1, Frame.Version, 0, -20)

	-- WOW INFO
	self:CreateCategories(Frame, "WoWPatch", 16, 1, 1, "WoW Patch: |CFF4BEB2C" .. UI.WoWPatch .. " (Build: " .. UI.WoWBuild .. ")", 1, 1, 1, 1, InvisFrame.WoWInfoText, 0, -26)
	self:CreateCategories(Frame, "Language", 16, 1, 1, "Language: |CFF4BEB2C" .. UI.UserLocale, 1, 1, 1, 1, Frame.WoWPatch, 0, -20)
	self:CreateCategories(Frame, "DisplayMode", 16, 1, 1, "Display Mode: |CFF4BEB2C" .. self:GetDisplayMode(), 1, 1, 1, 1, Frame.Language, 0, -20)
	self:CreateCategories(Frame, "Resolution", 16, 1, 1, "Resolution: |CFF4BEB2C" .. UI.Resolution, 1, 1, 1, 1, Frame.DisplayMode, 0, -20)
	self:CreateCategories(Frame, "OS", 16, 1, 1, "Operating System: |CFF4BEB2C" .. self:GetClient(), 1, 1, 1, 1, Frame.Resolution, 0, -20)

	-- CHARACTER INFO
	self:CreateCategories(Frame, "Faction", 16, 1, 1, "Faction: |CFF4BEB2C" .. UI.UserFaction, 1, 1, 1, 1, InvisFrame.CharacterInfoText, 0, -26)	
	self:CreateCategories(Frame, "Race", 16, 1, 1, "Race: |CFF4BEB2C" .. UI.UserRace, 1, 1, 1, 1, Frame.Faction, 0, -20)
	self:CreateCategories(Frame, "Class", 16, 1, 1, "|cffffffffClass:|r " .. EnglishClassNames[UI.UserClass], R, G, B, 1, Frame.Race, 0, -20)
	self:CreateCategories(Frame, "Spec", 16, 1, 1, nil, R, G, B, 1, Frame.Class, 0, -20)
	self:CreateCategories(Frame, "Level", 16, 1, 1, "|cffffffffLevel:|r ".. UI.UserLevel, 1, 0.82, 0, 1, Frame.Spec, 0, -20)
	self:CreateCategories(Frame, "Zone", 16, 1, 1, nil, 1, 1, 1, 1, Frame.Level, 0, -20)

	self.Frame = Frame
	self.InvisFrame = InvisFrame
end

-- Init
function StatusReport:Initialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:SetScript("OnEvent", self.OnEvent)

	self:CreateStatus()
end