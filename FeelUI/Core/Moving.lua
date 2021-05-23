-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Register Module
local Moving = UI:RegisterModule('Moving')
Moving:RegisterEvent('PLAYER_ENTERING_WORLD')
Moving:RegisterEvent('PLAYER_REGEN_DISABLED')

Moving.Frames = {}
Moving.Defaults = {}

-- Lib Globals
local _G = _G
local pairs = pairs
local select = select
local unpack = unpack
local tinsert = table.insert
local floor = math.floor

-- WoW Globals
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local InCombatLockdown = InCombatLockdown
local UIParent = UIParent

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local UNKNOWN = UNKNOWN

-- Locals
local UserName = UI.UserName
local UserRealm = UI.UserRealm

-- Functions
function Moving:SaveDefaults(frame, Anchor1, Parent, Anchor2, X, Y)
	if not (Anchor1) then
		return
	end

	if not (Parent) then
		Parent = UIParent
	end

	local Data = Moving.Defaults
	local Frame = frame:GetName()

	Data[Frame] = { Anchor1, Parent:GetName(), Anchor2, X, Y }
end

function Moving:RestoreDefaults(button)
	local FrameName = self.Parent:GetName()
	local Data = Moving.Defaults[FrameName]
	local SavedVariables = FeelDB[UserRealm][UserName].FramePoints

	if ((button == 'RightButton') and (Data)) then
		local Anchor1, ParentName, Anchor2, X, Y = unpack(Data)
		local Frame = _G[FrameName]
		local Parent = _G[ParentName]
		local Name = Frame.MoverName or Frame:GetName() or UNKNOWN

		if not (Parent) then
			Parent = UIParent
		end

		Frame:ClearAllPoints()
		Frame:Point(Anchor1, Parent, Anchor2, X, Y)

		Frame.DragInfo:ClearAllPoints()
		Frame.DragInfo:SetAllPoints(Frame)

		Frame.DragInfo.Text:SetText(Name)

		SavedVariables[FrameName] = nil
		SavedVariables[FrameName] = { Anchor1, Parent:GetName(), Anchor2, UI:Round(X), UI:Round(Y) }
	end
end

function Moving:RegisterFrame(Frame, FrameName)
	local Anchor1, Parent, Anchor2, X, Y = Frame:GetPoint()

	tinsert(self.Frames, Frame)

	if (FrameName) then
		Frame.MoverName = FrameName
	end

	self:SaveDefaults(Frame, Anchor1, Parent, Anchor2, X, Y)
end

function Moving:OnDragFollowMe()
	local Anchor1, Parent, Anchor2, X, Y = self:GetPoint()
	local Name = self.Parent.MoverName or self.Parent:GetName() or UNKNOWN

	if not (Parent) then
		Parent = UIParent
	end

	self.Parent:ClearAllPoints()
	self.Parent:Point(Anchor1, Parent, Anchor2, UI:Round(X), UI:Round(Y))
end

function Moving:OnDragStart()
	GameTooltip_Hide()

	self:SetScript('OnUpdate', Moving.OnDragFollowMe)
	self:StartMoving()
end

function Moving:OnDragStop()
	self:StopMovingOrSizing()
	self:SetScript('OnUpdate', nil)

	local Data = FeelDB[UserRealm][UserName].FramePoints
	local Anchor1, Parent, Anchor2, X, Y = self:GetPoint()
	local FrameName = self.Parent:GetName()
	local Frame = self.Parent

	if not (Parent) then
		Parent = UIParent
	end

	Frame:ClearAllPoints()
	Frame:Point(Anchor1, Parent, Anchor2, X, Y)

	Data[FrameName] = { Anchor1, Parent:GetName(), Anchor2, UI:Round(X), UI:Round(Y) }

	Moving:OnEnter()
end

function Moving:OnEnter()
	GameTooltip:SetOwner(self)
	GameTooltip:SetAnchorType('ANCHOR_CURSOR')
	GameTooltip:AddLine(Language['Hint:'])
	GameTooltip:AddLine(Language['Hold left click to drag'])
	GameTooltip:AddLine(Language['Right click to reset default'])
	GameTooltip:Show()
end

function Moving:OnLeave()
	GameTooltip_Hide()
end

function Moving:CreateDragInfo()
	self.DragInfo = CreateFrame('Frame', nil, self)
	self.DragInfo:SetAllPoints(self)
	self.DragInfo:CreateBackdrop()
	self.DragInfo.Backdrop:SetBackdropBorderColor(1, 0, 0)

	self.DragInfo:SetFrameLevel(100)
	self.DragInfo:SetFrameStrata('HIGH')
	self.DragInfo:SetMovable(true)
	self.DragInfo:RegisterForDrag('LeftButton')
	self.DragInfo:SetClampedToScreen(true)

	self.DragInfo.Text = self.DragInfo:CreateFontString(nil, 'OVERLAY')
	self.DragInfo.Text:SetFontTemplate('Default')
	self.DragInfo.Text:Point('CENTER', self.DragInfo, 'CENTER', 0, 0)
	self.DragInfo.Text:SetText(self.MoverName or self:GetName() or UNKNOWN)

	self.DragInfo:Hide()

	self.DragInfo:SetScript('OnMouseUp', Moving.RestoreDefaults)
	self.DragInfo:SetScript('OnEnter', Moving.OnEnter)
	self.DragInfo:SetScript('OnLeave', Moving.OnLeave)

	self.DragInfo.Parent = self.DragInfo:GetParent()
end

function Moving:StartOrStopMoving()
	if (InCombatLockdown()) then
		UI:Print('Red', ERR_NOT_IN_COMBAT)

		return
	end

	if not (self.IsEnabled) then
		self.IsEnabled = true
	else
		self.IsEnabled = false
	end

	for Index = 1, #self.Frames do
		local Frame = Moving.Frames[Index]

		if (self.IsEnabled) then
			if not (Frame.DragInfo) then
				self.CreateDragInfo(Frame)
			end

			Frame.DragInfo:SetParent(UIParent)
			Frame.DragInfo:SetScript('OnDragStart', self.OnDragStart)
			Frame.DragInfo:SetScript('OnDragStop', self.OnDragStop)
			Frame.DragInfo:SetScript('OnEnter', self.OnEnter)
			Frame.DragInfo:SetScript('OnLeave', self.OnLeave)
			Frame.DragInfo:Show()

			if (Frame.DragInfo:GetFrameLevel() ~= 100) then
				Frame.DragInfo:SetFrameLevel(100)
			end

			if (Frame.DragInfo:GetFrameStrata() ~= 'HIGH') then
				Frame.DragInfo:SetFrameStrata('HIGH')
			end
		else
			if (Frame.DragInfo) then
				Frame.DragInfo:SetParent(Frame.DragInfo.Parent)
				Frame.DragInfo:SetScript('OnDragStart', nil)
				Frame.DragInfo:SetScript('OnDragStop', nil)
				Frame.DragInfo:SetScript('OnEnter', nil)
				Frame.DragInfo:SetScript('OnLeave', nil)
				Frame.DragInfo:Hide()
			end
		end
	end
end

function Moving:ResetAllFrames()
	if (InCombatLockdown()) then
		UI:Print('Red', ERR_NOT_IN_COMBAT)

		return
	end

	FeelDB[UserRealm][UserName].FramePoints = nil
	FeelDB[UserRealm][UserName].FramePoints = {}
end

function Moving:IsRegisteredFrame(frame)
	local Match = false

	for Index = 1, #self.Frames do
		if (self.Frames[Index] == frame) then
			Match = true
		end
	end

	return Match
end

Moving:SetScript('OnEvent', function(self, event)
	if (event == 'PLAYER_ENTERING_WORLD') then

		local Data = FeelDB[UserRealm][UserName].FramePoints

		for Frame, Position in pairs(Data) do
			local Frame = _G[Frame]
			local IsRegistered = self:IsRegisteredFrame(Frame)

			if (Frame and IsRegistered) then
				local Anchor1, Parent, Anchor2, X, Y = Frame:GetPoint()

				self:SaveDefaults(Frame, Anchor1, Parent, Anchor2, X, Y)

				Anchor1, Parent, Anchor2, X, Y = unpack(Position)

				Frame:ClearAllPoints()
				Frame:Point(Anchor1, _G[Parent], Anchor2, X, Y)
			end
		end
	elseif (event == 'PLAYER_REGEN_DISABLED') then
		if (self.IsEnabled) then
			self:StartOrStopMoving()
		end
	end
end)
