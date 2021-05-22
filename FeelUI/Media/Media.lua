-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals

-- WoW Globals

-- Locales
local UserClass = UI.UserClass

local Path = [[Interface\AddOns\FeelUI\Media\]]

-- Textures
Media.Textures = {
	Blank = Path .. [[Textures\Blank]],
	Glow = Path .. [[Textures\Glow]],
	Highlight = Path .. [[Textures\Highlight]],
	Logo = Path .. [[Textures\Logo]],
	Overlay = Path .. [[Textures\Overlay]],
	Shadow = Path .. [[Textures\Shadow]],
	ShadowOverlay = Path .. [[Textures\ShadowOverlay]],
}

Media.Fonts = {
	Aftermathh = Path .. [[Fonts\Aftermathh.ttf]],
	Asphyxia = Path .. [[Fonts\Asphyxia.ttf]],
	Default = Path .. [[Fonts\Default.ttf]],
	Normal = Path .. [[Fonts\Normal.ttf]],
	PixelRu = Path .. [[Fonts\PixelRu.ttf]],
}
