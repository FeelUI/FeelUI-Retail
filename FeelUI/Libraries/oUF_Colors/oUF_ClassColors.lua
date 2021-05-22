-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals

-- WoW Globals

-- Locales
local UserClass = UI.UserClass

UI.GetClassColors = Media.Colors.oUF.class[UserClass]
