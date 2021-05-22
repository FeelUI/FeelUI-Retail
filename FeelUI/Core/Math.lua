-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local tonumber = tonumber
local format = string.format
local match = string.match

-- WoW Globals

-- Locales

-- Functions

-- Round Numbers
function UI:Round(String, Decimals)
	if not (Decimals) then
		Decimals = 0
	end

	return format(format('%%.%df', Decimals), String)
end

--RGB to Hex
function UI:RGBToHex(R, G, B, Header, Ending)
	R = R <= 1 and R >= 0 and R or 1
	G = G <= 1 and G >= 0 and G or 1
	B = B <= 1 and B >= 0 and B or 1

	return format('%s%02x%02x%02x%s', Header or '|cff', R * 255, G * 255, B * 255, Ending or '')
end

--Hex to RGB
function UI:HexToRGB(String)
	local A, R, G, B = match(String, '^|?c?(%x%x)(%x%x)(%x%x)(%x?%x?)|?r?$')

	if not (A) then
		return 0, 0, 0, 0
	end

	if (B == '') then
		R, G, B, A = A, R, G, 'ff'
	end

	return tonumber(R, 16), tonumber(G, 16), tonumber(B, 16), tonumber(A, 16)
end
