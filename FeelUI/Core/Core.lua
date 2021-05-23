-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local print = print
local format = string.format

-- WoW Globals

-- Locals

-- Print
function UI:Print(Color, ...)
	local String = ...

	if not(String) then
		return
	end

	print(format('|cff%sFeelUI|r: ' .. String, Color))
end

-- Pulse Function
function UI:CreatePulse(Frame)
	local Speed = 0.05
	local Mult = 1
	local Alpha = 0.8
	local Last = 0

	Frame:SetScript("OnUpdate", function(self, Elapsed)
		Last = Last + Elapsed

		if (Last > Speed) then
			Last = 0
			self:SetAlpha(Alpha)
		end

		Alpha = Alpha - Elapsed * Mult

		if (Alpha < 0 and Mult > 0) then
			Mult = Mult * -1
			Alpha = 0
		elseif (Alpha > 1 and Mult < 0) then
			Mult = Mult * -1
		end
	end)
end
