-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals

-- WoW Globals

-- Locals
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
	Normal = Path .. [[Textures\Normal]],
	Normal2 = Path .. [[Textures\Normal2]],
	Normal3 = Path .. [[Textures\Normal3]],
	Normal4 = Path .. [[Textures\Normal4]],
	Melli = Path .. [[Textures\Melli]],
	Melli2 = Path .. [[Textures\Melli6px]],
	Smooth = Path .. [[Textures\SmoothV2]],
	Smooth2 = Path .. [[Textures\SmoothV2_6px]],
}

Media.Fonts = {
	Aftermathh = Path .. [[Fonts\Aftermathh.ttf]],
	Asphyxia = Path .. [[Fonts\Asphyxia.ttf]],
	Default = Path .. [[Fonts\Default.ttf]],
	Normal = Path .. [[Fonts\Normal.ttf]],
	PixelRu = Path .. [[Fonts\PixelRu.ttf]],
}
