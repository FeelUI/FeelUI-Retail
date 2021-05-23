-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local min = min
local max = max
local m_abs = _G.math.abs
local m_max = _G.math.max
local m_min = _G.math.min

local clamp = function(v, min, max)
	return m_min(max or 1, m_max(min or 0, v))
end

local attachGainToVerticalBar = function(self, object, prev, max)
	local offset = object:GetHeight() * (1 - clamp(prev / max))

	self:Point('BOTTOMLEFT', object, 'TOPLEFT', 0, -offset)
	self:Point('BOTTOMRIGHT', object, 'TOPRIGHT', 0, -offset)
end

local attachLossToVerticalBar = function(self, object, prev, max)
	local offset = object:GetHeight() * (1 - clamp(prev / max))

	self:Point('TOPLEFT', object, 'TOPLEFT', 0, -offset)
	self:Point('TOPRIGHT', object, 'TOPRIGHT', 0, -offset)
end

local attachGainToHorizontalBar = function(self, object, prev, max)
	local offset = object:GetWidth() * (1 - clamp(prev / max))

	self:Point('TOPLEFT', object, 'TOPRIGHT', -offset, 0)
	self:Point('BOTTOMLEFT', object, 'BOTTOMRIGHT', -offset, 0)
end

local attachLossToHorizontalBar = function(self, object, prev, max)
	local offset = object:GetWidth() * (1 - clamp(prev / max))

	self:Point('TOPRIGHT', object, 'TOPRIGHT', -offset, 0)
	self:Point('BOTTOMRIGHT', object, 'BOTTOMRIGHT', -offset, 0)
end

local update = function(self, cur, max, condition)
	if (max and max ~= 0 and (condition == nil or condition)) then
		local prev = (self._prev or cur) * max / (self._max or max)
		local diff = cur - prev

		if (m_abs(diff) / max < self.threshold) then
			diff = 0
		end

		if (diff > 0) then
			if (self.Gain and self.Gain:GetAlpha() == 0) then
				self.Gain:SetAlpha(1)

				if (self.orientation == 'VERTICAL') then
					attachGainToVerticalBar(self.Gain, self.__owner, prev, max)
				else
					attachGainToHorizontalBar(self.Gain, self.__owner, prev, max)
				end

				self.Gain.FadeOut:Play()
			end
		elseif (diff < 0) then
			if (self.Gain) then
				self.Gain.FadeOut:Stop()
				self.Gain:SetAlpha(0)
			end

			if (self.Loss) then
				if (self.Loss:GetAlpha() <= 0.33) then
					self.Loss:SetAlpha(1)

					if (self.orientation == 'VERTICAL') then
						attachLossToVerticalBar(self.Loss, self.__owner, prev, max)
					else
						attachLossToHorizontalBar(self.Loss, self.__owner, prev, max)
					end

					self.Loss.FadeOut:Restart()
				elseif (self.Loss.FadeOut.Alpha:IsDelaying() or self.Loss:GetAlpha() >= 0.66) then
					self.Loss.FadeOut:Restart()
				end
			end
		end
	else
		if (self.Gain) then
			self.Gain.FadeOut:Stop()
			self.Gain:SetAlpha(0)
		end

		if (self.Loss) then
			self.Loss.FadeOut:Stop()
			self.Loss:SetAlpha(0)
		end
	end

	if (max and max ~= 0) then
		self._prev = cur
		self._max = max
	else
		self._prev = nil
		self._max = nil
	end
end

local updateColors = function(self)
	self.Gain_:SetColorTexture(0, 0.8, 0, 0.5)
	self.Loss_:SetColorTexture(0.8, 0, 0, 0.5)
end

local updatePoints = function(self, orientation)
	orientation = orientation or 'HORIZONTAL'

	if (orientation == 'HORIZONTAL') then
		self.Gain_:ClearAllPoints()
		self.Gain_:Point('TOPRIGHT', self.__owner:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		self.Gain_:Point('BOTTOMRIGHT', self.__owner:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)

		self.Loss_:ClearAllPoints()
		self.Loss_:Point('TOPLEFT', self.__owner:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		self.Loss_:Point('BOTTOMLEFT', self.__owner:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	else
		self.Gain_:ClearAllPoints()
		self.Gain_:Point('TOPLEFT', self.__owner:GetStatusBarTexture(), 'TOPLEFT', 0, 0)
		self.Gain_:Point('TOPRIGHT', self.__owner:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)

		self.Loss_:ClearAllPoints()
		self.Loss_:Point('BOTTOMLEFT', self.__owner:GetStatusBarTexture(), 'TOPLEFT', 0, 0)
		self.Loss_:Point('BOTTOMRIGHT', self.__owner:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	end

	self.orientation = orientation
end

local updateThreshold = function(self, value)
	self.threshold = value or 0.01
end

function UI:CreateGainLossIndicators(object)
	local Texture = Media.Textures.Normal

	local gainTexture = object:CreateTexture(nil, 'OVERLAY', nil, 1)
	gainTexture:SetTexture(Texture)
	gainTexture:SetAlpha(0)

	local ag = gainTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	gainTexture.FadeOut = ag

	local anim = ag:CreateAnimation('Alpha')
	anim:SetOrder(1)
	anim:SetFromAlpha(1)
	anim:SetToAlpha(0)
	anim:SetStartDelay(0.25)
	anim:SetDuration(0.1)
	ag.Alpha = anim

	local lossTexture = object:CreateTexture(nil, 'OVERLAY', nil, 1)
	lossTexture:SetTexture(Texture)
	lossTexture:SetAlpha(0)

	ag = lossTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	lossTexture.FadeOut = ag

	anim = ag:CreateAnimation('Alpha')
	anim:SetOrder(1)
	anim:SetFromAlpha(1)
	anim:SetToAlpha(0)
	anim:SetStartDelay(0.25)
	anim:SetDuration(0.1)
	ag.Alpha = anim

	return {
		__owner = object,
		threshold = 0.01,
		Gain = gainTexture,
		Gain_ = gainTexture,
		Loss = lossTexture,
		Loss_ = lossTexture,
		Update = update,
		UpdateColors = updateColors,
		UpdatePoints = updatePoints,
		UpdateThreshold = updateThreshold,
	}
end
