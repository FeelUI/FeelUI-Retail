-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals

-- WoW Globals

-- Locales

-- Functions

-- Init

DB.FramePoints = {}

DB.General = {
	AutoScale = true,
	AutoUIScale = UI.PerfectScale,
	UIScale = 0.64,
	IsInstalled = false,
	WelcomeMessage = true,
}

DB.Colors = {
	-- General
	Backdrop = { 0.05, 0.05, 0.05, 0.70 },
	Border = { 0, 0, 0, 1 },
	Shadow = { 0.05, 0.05, 0.05, 0.8 },
	PrimaryText = { 1.0, 1.0, 1.0, 1.0 },
	SecondaryText = { 0.4, 0.4, 0.5, 1.0 },
}

DB.Skins = {
	Enable = true,
}
