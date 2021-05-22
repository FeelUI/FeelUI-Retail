-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Import oUF
local Framework = select(2, ...)
local oUF = oUF or Framework.oUF

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
-- Colors
Media.Colors = {}

-- oUF Colors
oUF.colors.disconnected = {
	0.1, 0.1, 0.1
}

oUF.colors.runes = {
	[1] = { 0.69, 0.31, 0.31 },
	[2] = { 0.41, 0.80, 1.00 },
	[3] = { 0.65, 0.63, 0.35 },
	[5] = { 0.55, 0.57, 0.61 },
}

oUF.colors.reaction = {
	[1] = { 0.87, 0.37, 0.37 },
	[2] = { 0.87, 0.37, 0.37 },
	[3] = { 0.87, 0.37, 0.37 },
	[4] = { 0.85, 0.77, 0.36 },
	[5] = { 0.29, 0.67, 0.30 },
	[6] = { 0.29, 0.67, 0.30 },
	[7] = { 0.29, 0.67, 0.30 },
	[8] = { 0.29, 0.67, 0.30 },
}

oUF.colors.power = {
	['MANA'] = { 0.31, 0.45, 0.63 },
	['INSANITY'] = { 0.40, 0.00, 0.80 },
	['MAELSTROM'] = { 0.00, 0.50, 1.00 },
	['LUNAR_POWER'] = { 0.93, 0.51, 0.93 },
	['HOLY_POWER'] = { 0.95, 0.90, 0.60 },
	['RAGE'] = { 0.69, 0.31, 0.31 },
	['FOCUS'] = { 0.71, 0.43, 0.27 },
	['ENERGY'] = { 0.65, 0.63, 0.35 },
	['CHI'] = { 0.71, 1.00, 0.92 },
	['RUNES'] = { 0.55, 0.57, 0.61 },
	['SOUL_SHARDS'] = { 0.50, 0.32, 0.55 },
	['FURY'] = { 0.78, 0.26, 0.99 },
	['PAIN'] = { 1.00, 0.61, 0.00 },
	['RUNIC_POWER'] = { 0.00, 0.82, 1.00 },
	['AMMOSLOT'] = { 0.80, 0.60, 0.00 },
	['FUEL'] = { 0.00, 0.55, 0.50 },
	['POWER_TYPE_STEAM'] = { 0.55, 0.57, 0.61 },
	['POWER_TYPE_PYRITE'] = { 0.60, 0.09, 0.17 },
	['ALTPOWER'] = { 0.00, 1.00, 1.00 },
	['ANIMA'] = { 0.83, 0.83, 0.83 },
}

oUF.colors.class = {
	['DEATHKNIGHT'] = { 0.77, 0.12, 0.24 },
	['DRUID'] = { 1.00, 0.49, 0.03 },
	['HUNTER'] = { 0.67, 0.84, 0.45 },
	['MAGE'] = { 0.41, 0.80, 1.00 },
	['PALADIN'] = { 0.96, 0.55, 0.73 },
	['PRIEST'] = { 0.83, 0.83, 0.83 },
	['ROGUE'] = { 1.00, 0.95, 0.32 },
	['SHAMAN'] = { 0.01, 0.44, 0.87 },
	['WARLOCK'] = { 0.58, 0.51, 0.79 },
	['WARRIOR'] = { 0.78, 0.61, 0.43 },
	['MONK'] = { 0.00, 1.00, 0.59 },
	['DEMONHUNTER'] = { 0.64, 0.19, 0.79 },
}

oUF.colors.totems = {
	[1] = oUF.colors.class[UserClass],
	[2] = oUF.colors.class[UserClass],
	[3] = oUF.colors.class[UserClass],
	[4] = oUF.colors.class[UserClass],
}

-- Merge to Assets
Media.Colors.oUF = oUF.colors
