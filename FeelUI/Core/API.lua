-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G
local assert = assert
local error = error
local getmetatable = getmetatable
local pairs = pairs
local pcall = pcall
local select = select
local type = type
local unpack = unpack
local find = string.find

-- WoW Globals
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- Locals
local Dummy = UI.Dummy
local UserClass = UI.UserClass

local STRIP_TEX = 'Texture'
local STRIP_FONT = 'FontString'

local StripTexturesBlizzFrames = {
	'Inset', 'inset', 'InsetFrame', 
	'LeftInset', 'RightInset',
	'NineSlice', 'BG',
	'border', 'Border', 'BorderFrame', 
	'bottomInset', 'BottomInset',
	'bgLeft', 'bgRight',
	'FilligreeOverlay', 'PortraitOverlay', 'ArtOverlayFrame',
	'Portrait', 'portrait',
}

-- Functions
function UI:PointsRestricted(self)
	if (self and not pcall(self.GetPoint, self)) then
		return true
	end
end

-- Kill, Hide, Strip
local Kill = function(self)
	if (self.IsProtected) then
		if (self:IsProtected()) then
			error('Attempted to kill a protected object: <' .. self:GetName() .. '>')
		end
	end

	if (self.UnregisterAllEvents) then
		self:UnregisterAllEvents()
		self:SetParent(UI.HiddenParent)
	else
		self.Show = self.Hide
	end

	if (self.GetScript and self:GetScript('OnUpdate')) then
		self:SetScript('OnUpdate', nil)
	end

	self:Hide()
end

local StripRegion = function(Type, self, Kill, Alpha)
	if (Kill) then
		self:Kill()
	elseif (Alpha) then
		self:SetAlpha(0)
	elseif (Type == STRIP_TEX) then
		self:SetTexture()
	elseif (Type == STRIP_FONT) then
		self:SetText('')
	end
end

local StripType = function(Type, self, Kill, Alpha)
	if (self:IsObjectType(Type)) then
		StripRegion(Type, self, Kill, Alpha)
	else
		if (Type == STRIP_TEX) then
			local FrameName = self.GetName and self:GetName()

			for _, Blizzard in pairs(StripTexturesBlizzFrames) do
				local BlizzFrame = self[Blizzard] or (FrameName and _G[FrameName..Blizzard])

				if (BlizzFrame and BlizzFrame.StripTextures) then
					BlizzFrame:StripTextures(Kill, Alpha)
				end
			end
		end

		if (self.GetNumRegions) then
			for Index = 1, self:GetNumRegions() do
				local Region = select(Index, self:GetRegions())

				if (Region and Region.IsObjectType and Region:IsObjectType(Type)) then
					StripRegion(Type, Region, Kill, Alpha)
				end
			end
		end
	end
end

local StripTextures = function(self, Kill, Alpha)
	StripType(STRIP_TEX, self, Kill, Alpha)
end

local StripTexts = function(self, Kill, Alpha)
	StripType(STRIP_FONT, self, Kill, Alpha)
end

-- Templates
local SetFontTemplate = function(self, FontTemplate, FontSize, FontStyle, ShadowOffsetX, ShadowOffsetY)
	if (self.FontIsStyled) then
		return
	end

	if (FontTemplate == 'Default') then 
		self:SetFont(Media.Fonts.Default, UI:Scale(FontSize or 12), FontStyle or 'OUTLINE')
	elseif (FontTemplate == 'Normal') then
		self:SetFont(Media.Fonts.Normal, UI:Scale(FontSize or 12), FontStyle or 'OUTLINE')
	elseif (FontTemplate == 'Pixel') then
		self:SetFont(Media.Fonts.Asphyxia, UI:Scale(FontSize or 10), FontStyle or 'MONOCHROME, THINOUTLINE')
	end

	self:SetShadowOffset(UI:Scale(ShadowOffsetX or 1), -UI:Scale(ShadowOffsetY or 1))
	self:SetShadowColor(0, 0, 0, 0.5)

	self.FontIsStyled = true
end

-- ActionBars
local StyleButton = function(self, NoHover, NoPushed, NoChecked)
	if (self.SetHighlightTexture and not self.Highlight and not NoHover) then
		local Highlight = self:CreateTexture()
		Highlight:SetInside(self, 1, 1)
		Highlight:SetBlendMode("ADD")
		Highlight:SetColorTexture(unpack(DB.ActionBars.HighlightColor))

		self:SetHighlightTexture(Highlight)
		self.Highlight = Highlight
	end

	if (self.SetPushedTexture and not self.Pushed and not NoPushed) then
		local Pushed = self:CreateTexture()
		Pushed:SetInside(self, 1, 1)
		Pushed:SetBlendMode("ADD")
		Pushed:SetColorTexture(unpack(DB.ActionBars.PushedColor))

		self:SetPushedTexture(Pushed)
		self.Pushed = Pushed
	end

	if (self.SetCheckedTexture and not self.Checked and not NoChecked) then
		local Checked = self:CreateTexture()
		Checked:SetInside(self, 1, 1)
		Checked:SetBlendMode("ADD")
		Checked:SetColorTexture(unpack(DB.ActionBars.CheckedColor))

		self:SetCheckedTexture(Checked)
		self.Checked = Checked
	end

	local Name = self.GetName and self:GetName()
	local Cooldown = Name and _G[Name .. "Cooldown"]
	if (Cooldown) then
		Cooldown:ClearAllPoints()
		Cooldown:SetInside()
		Cooldown:SetDrawEdge(true)
	end
end

-- Sizing, Points
local WatchPixelSnap = function(self, Snap)
	if ((self and not self:IsForbidden()) and self.PixelSnapDisabled and Snap) then
		self.PixelSnapDisabled = nil
	end
end

local DisablePixelSnap = function(self)
	if ((self and not self:IsForbidden()) and not self.PixelSnapDisabled) then
		if (self.SetSnapToPixelGrid) then
			self:SetSnapToPixelGrid(false)
			self:SetTexelSnappingBias(0)
		elseif (self.GetStatusBarTexture) then
			local Texture = self:GetStatusBarTexture()

			if (Texture and Texture.SetSnapToPixelGrid) then
				Texture:SetSnapToPixelGrid(false)
				Texture:SetTexelSnappingBias(0)
			end
		end

		self.PixelSnapDisabled = true
	end
end

local Size = function(self, Width, Height)
	assert(Width)

	self:SetSize(UI:Scale(Width), UI:Scale(Height or Width))
end

local Width = function(self, Width)
	assert(Width)

	self:SetWidth(UI:Scale(Width))
end

local Height = function(self, Height)
	assert(Height)

	self:SetHeight(UI:Scale(Height))
end

local Point = function(...)
	local Object, Arg1, Arg2, Arg3, Arg4, Arg5 = select(1, ...)

	if not (Object) then
		return
	end

	local Points = { Arg1, Arg2, Arg3, Arg4, Arg5 }

	for Index = 1, #Points do
		if (type(Points[Index]) == 'number') then
			Points[Index] = UI:Scale(Points[Index])
		end
	end

	Object:SetPoint(unpack(Points))
end

local SetInside = function(self, Anchor, OffsetX, OffsetY, Anchor2)
	OffsetX = OffsetX or 0
	OffsetY = OffsetY or 0
	Anchor = Anchor or self:GetParent()

	assert(Anchor)

	if (UI:PointsRestricted(self) or self:GetPoint()) then
		self:ClearAllPoints()
	end

	DisablePixelSnap(self)

	self:Point('TOPLEFT', Anchor, 'TOPLEFT', OffsetX, -OffsetY)
	self:Point('BOTTOMRIGHT', Anchor2 or Anchor, 'BOTTOMRIGHT', -OffsetX, OffsetY)
end

local SetOutside = function(self, Anchor, OffsetX, OffsetY, Anchor2)
	OffsetX = OffsetX or 0
	OffsetY = OffsetY or 0
	Anchor = Anchor or self:GetParent()

	assert(Anchor)

	if (UI:PointsRestricted(self) or self:GetPoint()) then
		self:ClearAllPoints()
	end

	DisablePixelSnap(self)

	self:Point('TOPLEFT', Anchor, 'TOPLEFT', -OffsetX, OffsetY)
	self:Point('BOTTOMRIGHT', Anchor2 or Anchor, 'BOTTOMRIGHT', OffsetX, -OffsetY)
end

local HandlePointXY = function(self, NewX, NewY)
	local Anchor1, Parent, Anchor2, XOffset, YOffset = self:GetPoint()

	self:Point(Anchor1, Parent, Anchor2, NewX or XOffset, NewY or YOffset)
end

-- Frame Styles
local SetTemplate = function(self, ExtraShadowBorders)
	if (self.BorderIsCreated) then
		return
	end

	local R, G, B, Alpha = unpack(DB.Colors.Border)

	self.FrameRaised = CreateFrame('Frame', nil, self)
	self.FrameRaised:SetFrameStrata(self:GetFrameStrata())
	self.FrameRaised:SetFrameLevel(self:GetFrameLevel() + 1)
	self.FrameRaised:SetAllPoints()

	self.Border = {}

	for Index = 1, 4 do
		self.Border[Index] = self.FrameRaised:CreateTexture(nil, 'OVERLAY')
		self.Border[Index]:Size(1, 1)
		self.Border[Index]:SetColorTexture(R, G, B, Alpha)
	end

	self.Border[1]:Point('TOPLEFT', self, 'TOPLEFT', 0, 0)
	self.Border[1]:Point('TOPRIGHT', self, 'TOPRIGHT', 0, 0)

	self.Border[2]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, 0)
	self.Border[2]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0)

	self.Border[3]:Point('TOPLEFT', self, 'TOPLEFT', 0, 0)
	self.Border[3]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, 0)

	self.Border[4]:Point('TOPRIGHT', self, 'TOPRIGHT', 0, 0)
	self.Border[4]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0)

	if (ExtraShadowBorders) then
		self.BorderThick = {}

		for Index = 1, 8 do
			self.BorderThick[Index] = self.FrameRaised:CreateTexture(nil, 'OVERLAY')
			self.BorderThick[Index]:Size(1, 1)
			self.BorderThick[Index]:SetColorTexture(0, 0, 0, 1)
		end

		self.BorderThick[1]:Point('TOPLEFT', self, 'TOPLEFT', -1, 1)
		self.BorderThick[1]:Point('TOPRIGHT', self, 'TOPRIGHT', 1, -1)

		self.BorderThick[2]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', -1, -1)
		self.BorderThick[2]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 1, -1)

		self.BorderThick[3]:Point('TOPLEFT', self, 'TOPLEFT', -1, 1)
		self.BorderThick[3]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', 1, -1)

		self.BorderThick[4]:Point('TOPRIGHT', self, 'TOPRIGHT', 1, 1)
		self.BorderThick[4]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -1, -1)

		self.BorderThick[5]:Point('TOPLEFT', self, 'TOPLEFT', 1, -1)
		self.BorderThick[5]:Point('TOPRIGHT', self, 'TOPRIGHT', -1, 1)

		self.BorderThick[6]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', 1, 1)
		self.BorderThick[6]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -1, 1)

		self.BorderThick[7]:Point('TOPLEFT', self, 'TOPLEFT', 1, -1)
		self.BorderThick[7]:Point('BOTTOMLEFT', self, 'BOTTOMLEFT', -1, 1)

		self.BorderThick[8]:Point('TOPRIGHT', self, 'TOPRIGHT', -1, -1)
		self.BorderThick[8]:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 1, 1)
	end

	self.BorderIsCreated = true
end

local SetBackdropTemplate = function(self, InsetLeft, InsetRight, InsetTop, InsetBottom)
	if (self.BackdropIsCreated) then
		return
	end

	local R, G, B, Alpha = unpack(DB.Colors.Backdrop)

	self.BorderBackdrop = self:CreateTexture(nil, 'BACKGROUND', nil, -8)
	self.BorderBackdrop:SetTexture(Media.Textures.Blank)
	self.BorderBackdrop:SetVertexColor(R, G, B, Alpha)

	if (InsetLeft or InsetRight or InsetTop or InsetBottom) then
		self.BorderBackdrop:Point('TOPLEFT', self, 'TOPLEFT', -InsetLeft or 0, InsetTop or 0)
		self.BorderBackdrop:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', InsetRight or 0, -InsetBottom or 0)
	else
		self.BorderBackdrop:Point('TOPLEFT', self, 'TOPLEFT', 0, 0)
		self.BorderBackdrop:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0)
	end

	self.BackdropIsCreated = true
end

local SetColorTemplate = function(self, R, G, B, Alpha)
	if (self and self.Border) then
		for Index = 1, 4 do
			self.Border[Index]:SetColorTexture(R, G, B, Alpha)
		end
	end
end

local SetBackdropColorTemplate = function(self, R, G, B, Alpha)
	if (self and self.BorderBackdrop) then
		self.BorderBackdrop:SetVertexColor(R, G, B, Alpha)
	end
end

local function CreateBackdrop(self, ExtraShadowBorders)
	if (self.Backdrop) then
		return
	end

	self:SetBackdropTemplate()

	self.Backdrop = CreateFrame('Frame', nil, self, 'BackdropTemplate')
	self.Backdrop:SetOutside()
	self.Backdrop:SetTemplate(ExtraShadowBorders)
end

local CreateShadow = function(self)
	if (self.Shadow) then
		return
	end

	local R, G, B, Alpha = unpack(DB.Colors.Shadow)

	self.Shadow = CreateFrame('Frame', nil, self, 'BackdropTemplate')

	if (self.FrameRaised) then
		self.Shadow:SetFrameStrata(self.FrameRaised:GetFrameStrata())
	end

	self.Shadow:SetFrameLevel(0)
	self.Shadow:SetOutside(self, 2, 2)
	self.Shadow:SetBackdrop({ edgeFile = Media.Textures.Shadow, edgeSize = UI:Scale(3) })
	self.Shadow:SetBackdropColor(0, 0, 0, 0)
	self.Shadow:SetBackdropBorderColor(R, G, B, Alpha)
end

local CreateOverlay = function(self, Texture, R, G, B, Alpha)
	if (self.Overlay) then
		return
	end

	local Texture = Media.Textures.Overlay or Texture
	local R, G, B, Alpha = R or 0.05, G or 0.05, B or 0.05, Alpha or 1.0

	self.Overlay = self:CreateTexture(nil, 'OVERLAY')
	self.Overlay:SetInside()
	self.Overlay:SetTexture(Texture)
	self.Overlay:SetVertexColor(R, G, B, Alpha)
end

local CreateShadowOverlay = function(self, Texture, R, G, B, Alpha)
	if (self.ShadowOverlay) then
		return
	end

	local R, G, B, Alpha = R or 1.0, G or 1.0, B or 1.0, Alpha or 1.0

	self.ShadowOverlay = self:CreateTexture(nil, 'OVERLAY')
	self.ShadowOverlay:SetInside()
	self.ShadowOverlay:SetTexture(Media.Textures.ShadowOverlay)
	self.ShadowOverlay:SetVertexColor(R, G, B, Alpha)
end

-- Skinning
UI.BlizzardRegions = {
	'Left', 'Middle', 'Right', 'Mid', 'Center',
	'LeftDisabled', 'MiddleDisabled', 'RightDisabled',
	'TopLeft', 'TopRight',
	'BottomLeft', 'BottomRight',
	'TopMiddle',
	'MiddleLeft', 'MiddleRight',
	'BottomMiddle', 'MiddleMiddle',
	'TabSpacer', 'TabSpacer1', 'TabSpacer2',
	'_RightSeparator', '_LeftSeparator',
	'Cover', 'Border', 'Background',
	'TopTex', 'TopLeftTex', 'TopRightTex',
	'LeftTex', 'BottomTex', 'BottomLeftTex', 'BottomRightTex', 'RightTex', 'MiddleTex',
}

local HandleBlizzardRegions = function(self, Name, Kill)
	if not (Name) then
		Name = self.GetName and self:GetName()
	end

	for _, Area in pairs(UI.BlizzardRegions) do
		local Object = (Name and _G[Name .. Area]) or self[Area]

		if (Object) then
			if (Kill) then
				Object:Kill()
			else
				Object:SetAlpha(0)
			end
		end
	end
end

local HandleInsetFrame = function(self)
	if (self.Bg) then self.Bg:Hide() end
	if (self.InsetBorderTop) then self.InsetBorderTop:Hide() end
	if (self.InsetBorderTopLeft) then self.InsetBorderTopLeft:Hide() end
	if (self.InsetBorderTopRight) then self.InsetBorderTopRight:Hide() end
	if (self.InsetBorderBottom) then self.InsetBorderBottom:Hide() end
	if (self.InsetBorderBottomLeft) then self.InsetBorderBottomLeft:Hide() end
	if (self.InsetBorderBottomRight) then self.InsetBorderBottomRight:Hide() end
	if (self.InsetBorderLeft) then self.InsetBorderLeft:Hide() end
	if (self.InsetBorderRight) then self.InsetBorderRight:Hide() end
end

local DisableBackdrops = function(self)
	if (self.Bg) then self.Bg:Hide() end
	if (self.Center) then self.Center:Hide() end
	if (self.TopEdge) then self.TopEdge:Hide() end
	if (self.BottomEdge) then self.BottomEdge:Hide() end
	if (self.LeftEdge) then self.LeftEdge:Hide() end
	if (self.RightEdge) then self.RightEdge:Hide() end
	if (self.TopLeftCorner) then self.TopLeftCorner:Hide() end
	if (self.TopRightCorner) then self.TopRightCorner:Hide() end
	if (self.BottomRightCorner) then self.BottomRightCorner:Hide() end
	if (self.BottomLeftCorner) then self.BottomLeftCorner:Hide() end
end

local HandleFrame = function(self)

end

local HandleButton = function(self, Strip)
	if (self.IsSkinned) then
		return 
	end

	local ButtonName = self.GetName and self:GetName()

	if (self.SetNormalTexture) then self:SetNormalTexture('') end
	if (self.SetHighlightTexture) then self:SetHighlightTexture('') end
	if (self.SetPushedTexture) then self:SetPushedTexture('') end
	if (self.SetDisabledTexture) then self:SetDisabledTexture('') end

	if (Strip) then self:StripTexture() end

	self:HandleBlizzardRegions()
	self:CreateBackdrop()

	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]

	self:HookScript('OnEnter', function() 
		self:SetBackdropColorTemplate(Media.Colors.oUF.class[UserClass][1], Media.Colors.oUF.class[UserClass][2], Media.Colors.oUF.class[UserClass][3], 0.4)
		self.Backdrop:SetColorTemplate(Color[1], Color[2], Color[3], 0.5)
	end)

	self:HookScript('OnLeave', function() 
		self:SetBackdropColorTemplate(DB.Colors.Backdrop[1], DB.Colors.Backdrop[2], DB.Colors.Backdrop[3], DB.Colors.Backdrop[4])
		self.Backdrop:SetColorTemplate(DB.Colors.Border[1], DB.Colors.Border[2], DB.Colors.Border[3], DB.Colors.Border[4])
	end)

	self.IsSkinned = true
end

local HandleEquipmentButton = function(self)

end

local HandleCategoriesButtons = function(self, Strip, OffsetX, OffsetY)

end

local HandleVoiceChatButton = function(self, Strip)

end

local HandleCloseButton = function(self, Point)
	if (self.IsSkinned) then 
		return 
	end

	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]

	self:StripTextures()

	self.Display = CreateFrame('Frame', nil, self)
	self.Display:Point('CENTER', self, 'CENTER', 0, 0)
	self.Display:Size(16, 16)
	self.Display:CreateBackdrop()

	self:SetFrameLevel(self:GetFrameLevel() + 1)
	self.Display:SetFrameLevel(self:GetFrameLevel() - 1)

	self.Display.Normal = self.Display:CreateTexture(nil, 'OVERLAY')
	self.Display.Normal:SetTexture(Media.Textures.Overlay)
	self.Display.Normal:SetVertexColor(R, G, B, 0.5)
	self.Display.Normal:SetInside(self.Display)
	self:SetNormalTexture(self.Display.Normal)

	self.Display.Hover = self.Display:CreateTexture(nil, 'OVERLAY')
	self.Display.Hover:SetTexture(Media.Textures.Overlay)
	self.Display.Hover:SetVertexColor(R, G, B, 1)
	self.Display.Hover:SetInside(self.Display)
	self:SetHighlightTexture(self.Display.Hover)

	self.Display.Pushed = self.Display:CreateTexture(nil, 'OVERLAY')
	self.Display.Pushed:SetTexture(Media.Textures.Overlay)
	self.Display.Pushed:SetVertexColor(1, 1, 1, 0.3)
	self.Display.Pushed:SetInside(self.Display)
	self:SetPushedTexture(self.Display.Pushed)

	self.SetNormalTexture = Dummy
	self.SetPushedTexture = Dummy
	self.SetHighlightTexture = Dummy

	if (Point) then
		self:ClearAllPoints()
		self:Point('TOPRIGHT', Point, 'TOPRIGHT', 2, 2)
	end

	self.IsSkinned = true
end

local HandleBNETCloseButton = function(self, Strip, OffsetX, OffsetY, CloseSize)

end

local HandleArrowButton = function(self, Width, Height)
	if (self.IsSkinned) then 
		return 
	end

	local Texture = Media.Textures.Overlay
	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]
	local NormalTexture = self:GetNormalTexture()
	local PushedTexture = self:GetPushedTexture()
	local DisabledTexture = self:GetDisabledTexture()
	local HighlightTexture = self:GetHighlightTexture()

	self:StripTextures()

	self:Size(Width or 18, Height or 18)
	self:CreateBackdrop()

	self:SetNormalTexture(Texture)
	self:SetPushedTexture(Texture)
	self:SetDisabledTexture(Texture)
	self:SetHighlightTexture(Texture)

	if (NormalTexture) then
		NormalTexture:SetVertexColor(R, G, B, 0.8)
		NormalTexture:SetInside(self)
	end

	if (PushedTexture) then
		PushedTexture:SetVertexColor(1, 1, 1, 0.3)
		PushedTexture:SetInside(self)
	end

	if (DisabledTexture) then
		DisabledTexture:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		DisabledTexture:SetInside(self)
	end

	if (HighlightTexture) then
		HighlightTexture:SetVertexColor(R, G, B, 1)
		HighlightTexture:SetInside(self)
	end

	self.IsSkinned = true
end

local HandlePlusMinusButton = function(self)

end

local HandleQuestMinimizeButton = function(self, Width, Height)

end

local HandleNavButtonDropDown = function(self, Width, Height)

end

local HandleSplitButton = function(self, Width, Height)

end

local HandleWorldMapOverlayButtons = function(self, Width, Height)

end

local HandleDropDown = function(self, Width, Position)
	if (self.IsSkinned) then 
		return 
	end

	local FrameName = self.GetName and self:GetName()
	local Button = self.Button or FrameName and (_G[FrameName .. 'Button'] or _G[FrameName .. '_Button'])
	local Text = FrameName and _G[FrameName .. 'Text'] or self.Text
	local Icon = self.Icon

	self:StripTextures()
	self:Width(Width or 158)

	Text:ClearAllPoints()
	Text:Point('RIGHT', Button, 'LEFT', 0, 0)
	Text:SetFontTemplate('Normal')

	Button:ClearAllPoints()

	if (Position) then
		Button:Point('TOPRIGHT', self.Right, -20, -21)
	else
		Button:Point('RIGHT', self, 'RIGHT', -10, 4)
	end

	Button:Size(16, 16)
	Button.SetPoint = Dummy
	Button.SetSize = Dummy
	Button:HandleArrowButton()

	if (Icon) then
		Icon:Point('LEFT', 22, 6)
	end

	self.Backdrop = CreateFrame('Frame', nil, self)
	self.Backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
	self.Backdrop:Point('TOPLEFT', self, 'TOPLEFT', 20, -1)
	self.Backdrop:Point('BOTTOMRIGHT', Button, 'BOTTOMRIGHT', 3, -3)
	self.Backdrop:CreateBackdrop()

	self.IsSkinned = true
end

local Tabs = { 'LeftDisabled', 'MiddleDisabled', 'RightDisabled', 'Left', 'Middle', 'Right' }

local HandleTab = function(self)

end

local HandleEditBox = function(self)
	if (self.IsSkinned) then 
		return 
	end

	local EditBoxName = self.GetName and self:GetName()

	self:HandleBlizzardRegions()

	self.Backdrop = CreateFrame('Frame', nil, self)
	self.Backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
	self.Backdrop:Point('TOPLEFT', self, 'TOPLEFT', -3, -1)
	self.Backdrop:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -11, 0)
	self.Backdrop:CreateBackdrop()

	if (EditBoxName) then
		if (find(EditBoxName, 'Silver') or find(EditBoxName, 'Copper')) then
			self.Backdrop:Point('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -11, 0)
		end
	end

	self.IsSkinned = true
end

local HandleCheckBox = function(self)
	if (self.IsSkinned) then 
		return 
	end

	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]

	StripTextures(self)

	self.Display = CreateFrame('Frame', nil, self)
	self.Display:Size(16, 16)
	self.Display:CreateBackdrop()
	self.Display:Point('CENTER')

	self:SetFrameLevel(self:GetFrameLevel() + 1)
	self.Display:SetFrameLevel(self:GetFrameLevel() - 1)

	local Checked = self.Display:CreateTexture(nil, 'OVERLAY')
	Checked:SetTexture(Media.Textures.Overlay)
	Checked:SetVertexColor(R, G, B)
	Checked:SetInside(self.Display)
	self:SetCheckedTexture(Checked)

	local Disabled = self.Display:CreateTexture(nil, 'OVERLAY')
	Disabled:SetTexture(Media.Textures.Overlay)
	Disabled:SetVertexColor(0.77, 0.12, 0.23)
	Disabled:SetInside(self.Display)
	self:SetDisabledTexture(Disabled)

	local Hover = self.Display:CreateTexture(nil, 'OVERLAY')
	Hover:SetTexture(Media.Textures.Overlay)
	Hover:SetVertexColor(1.0, 1.0, 1.0, 0.3)
	Hover:SetInside(self.Display)
	self:SetHighlightTexture(Hover)

	self.SetNormalTexture = Dummy
	self.SetPushedTexture = Dummy
	self.SetHighlightTexture = Dummy

	local Name = self:GetName()
	local Text = self['Text'] or Name and _G[Name .. 'Text']

	if (Text) then
		Text:ClearAllPoints()
		Text:SetFontTemplate('Normal')
		Text:Point('LEFT', self, 'RIGHT', 0, -1)
		Text:Width(100)
	end

	self.IsSkinned = true
end

local GrabScrollBarElement = function(self, element)
	local FrameName = self:GetDebugName()

	return self[element] or FrameName and (_G[FrameName .. element] or find(FrameName, element)) or nil
end

local HandleScrollFrame = function(self)
	if (self.IsSkinned) then 
		return 
	end

	local Parent = self:GetParent()
	local ScrollUpButton = GrabScrollBarElement(self, 'ScrollUpButton') or GrabScrollBarElement(self, 'UpButton') or GrabScrollBarElement(self, 'ScrollUp') or GrabScrollBarElement(Parent, 'scrollUp')
	local ScrollDownButton = GrabScrollBarElement(self, 'ScrollDownButton') or GrabScrollBarElement(self, 'DownButton') or GrabScrollBarElement(self, 'ScrollDown') or GrabScrollBarElement(Parent, 'scrollDown')
	local Thumb = GrabScrollBarElement(self, 'ThumbTexture') or GrabScrollBarElement(self, 'thumbTexture') or self.GetThumbTexture and self:GetThumbTexture()

	self:StripTextures()
	self:Size(16, self:GetHeight())

	self.BackdropOverlay = CreateFrame('Frame', nil, self)
	self.BackdropOverlay:SetFrameLevel(self:GetFrameLevel() - 1)
	self.BackdropOverlay:Size(self:GetWidth(), self:GetHeight())
	self.BackdropOverlay:Point('TOP', ScrollUpButton, 'BOTTOM', 0, 16)
	self.BackdropOverlay:Point('BOTTOM', ScrollDownButton, 'TOP', 0, -16)
	self.BackdropOverlay:CreateBackdrop()

	if (ScrollUpButton) then
		ScrollUpButton:ClearAllPoints()
		ScrollUpButton:Point('TOP', self, 0, 18)
		ScrollUpButton:HandleArrowButton(16, 16)
	end

	if (ScrollDownButton) then
		ScrollDownButton:ClearAllPoints()
		ScrollDownButton:Point('BOTTOM', self, 0, -18)
		ScrollDownButton:HandleArrowButton(16, 16)
	end

	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]

	if (Thumb) then
		Thumb:Size(12, 16)
		Thumb:SetTexture(Media.Textures.Overlay)
		Thumb:SetVertexColor(R, G, B, 0.80)

		self.HighlightTexture = self:CreateTexture(nil, 'OVERLAY')
		self.HighlightTexture:SetInside(Thumb)
		self.HighlightTexture:SetTexture(Media.Textures.Highlight)
		self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		self.HighlightTexture:Hide()

		self:HookScript('OnEnter', function(self)
			self.HighlightTexture:SetVertexColor(1.0, 1.0, 1.0, 0.3)
			self.HighlightTexture:Show()
		end)

		self:HookScript('OnLeave', function(self)
			self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
			self.HighlightTexture:Hide()
		end)
	end

	self.IsSkinned = true
end

local HandleSliderFrame = function(self)
	if (self.IsSkinned) then
		return
	end

	self:StripTextures()
	self:SetBackdrop(nil)
	self:CreateBackdrop()

	local Color = Media.Colors.oUF.class[UserClass]
	local R, G, B = Color[1], Color[2], Color[3]

	local Thumb = self:GetThumbTexture()
	Thumb:Size(14, 10)
	Thumb:SetTexture(Media.Textures.Overlay)
	Thumb:SetVertexColor(R, G, B, 0.8)

	local Orientation = self:GetOrientation()

	if (Orientation == 'VERTICAL') then
		self:Width(14)
	else
		self:Height(14)

		for Index = 1, self:GetNumRegions() do
			local Region = select(Index, self:GetRegions())

			if (Region and Region:IsObjectType('FontString')) then
				local Point, Anchor, AnchorPoint, X, Y = Region:GetPoint()
	
				if (find(AnchorPoint, 'BOTTOM')) then
					Region:Point(Point, Anchor, AnchorPoint, X, Y -4)
				end
			end
		end
	end

	self.HighlightTexture = self:CreateTexture(nil, 'OVERLAY')
	self.HighlightTexture:SetInside(Thumb, 0, 0)
	self.HighlightTexture:SetTexture(Media.Textures.Overlay)
	self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
	self.HighlightTexture:Hide()

	self:HookScript('OnEnter', function(self)
		self.HighlightTexture:SetVertexColor(1.0, 1.0, 1.0, 0.3)
		self.HighlightTexture:Show()
	end)

	self:HookScript('OnLeave', function(self)
		self.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		self.HighlightTexture:Hide()
	end)

	self:HookScript('OnEnable', function()
		Thumb:SetVertexColor(R, G, B, 0.8)

		if (self.EditBox) then
			self.EditBox:EnableMouse(true)
		end
	end)

	self:HookScript('OnDisable', function()
		Thumb:SetVertexColor(0.77, 0.12, 0.23)

		if (self.EditBox) then
			self.EditBox:EnableMouse(false)
		end
	end)

	if (self.Text) then
		self.Text:SetFontTemplate('Normal', 12)
	end

	if (self.Low) then
		self.Low:SetFontTemplate('Normal', 10)
	end

	if (self.High) then
		self.High:SetFontTemplate('Normal', 10)
	end

	self.IsSkinned = true
end

local HandleRotateButton = function(self, Width, Height)

end

local HandleIconSelectionFrame = function(self, NumIcons, ButtonNameTemplate, FrameNameOverride)

end

local HandleQuestLogHighlight = function(self, Strip, OffsetX, OffsetY)

end

-- Merge Functions
local MergeAPI = function(Object)
	local MetaTable = getmetatable(Object).__index

	-- PixelPerfect
	if not (Object.DisabledPixelSnap and (MetaTable.SetSnapToPixelGrid or MetaTable.SetStatusBarTexture or MetaTable.SetColorTexture or MetaTable.SetVertexColor or MetaTable.CreateTexture or MetaTable.SetTexCoord or MetaTable.SetTexture)) then
		if (MetaTable.SetSnapToPixelGrid) then hooksecurefunc(MetaTable, 'SetSnapToPixelGrid', WatchPixelSnap) end
		if (MetaTable.SetStatusBarTexture) then hooksecurefunc(MetaTable, 'SetStatusBarTexture', DisablePixelSnap) end
		if (MetaTable.SetColorTexture) then hooksecurefunc(MetaTable, 'SetColorTexture', DisablePixelSnap) end
		if (MetaTable.SetVertexColor) then hooksecurefunc(MetaTable, 'SetVertexColor', DisablePixelSnap) end
		if (MetaTable.CreateTexture) then hooksecurefunc(MetaTable, 'CreateTexture', DisablePixelSnap) end
		if (MetaTable.SetTexCoord) then hooksecurefunc(MetaTable, 'SetTexCoord', DisablePixelSnap) end
		if (MetaTable.SetTexture) then hooksecurefunc(MetaTable, 'SetTexture', DisablePixelSnap) end

		MetaTable.DisabledPixelSnap = true
	end

	-- Kill, Hide, Strip
	if not (Object.Kill) then MetaTable.Kill = Kill end
	if not (Object.StripTextures) then MetaTable.StripTextures = StripTextures end
	if not (Object.StripTexts) then MetaTable.StripTexts = StripTexts end

	-- Templates
	if not (Object.SetFontTemplate) then MetaTable.SetFontTemplate = SetFontTemplate end

	-- ActionBars
	if not (Object.StyleButton) then MetaTable.StyleButton = StyleButton end

	-- Sizing, Points
	if not (Object.Size) then MetaTable.Size = Size end
	if not (Object.Width) then MetaTable.Width = Width end
	if not (Object.Height) then MetaTable.Height = Height end
	if not (Object.Point) then MetaTable.Point = Point end
	if not (Object.SetInside) then MetaTable.SetInside = SetInside end
	if not (Object.SetOutside) then MetaTable.SetOutside = SetOutside end
	if not (Object.HandlePointXY) then MetaTable.HandlePointXY = HandlePointXY end

	-- Frame Styles
	if not (Object.SetTemplate) then MetaTable.SetTemplate = SetTemplate end
	if not (Object.SetBackdropTemplate) then MetaTable.SetBackdropTemplate = SetBackdropTemplate end
	if not (Object.SetColorTemplate) then MetaTable.SetColorTemplate = SetColorTemplate end
	if not (Object.SetBackdropColorTemplate) then MetaTable.SetBackdropColorTemplate = SetBackdropColorTemplate end
	if not (Object.CreateBackdrop) then MetaTable.CreateBackdrop = CreateBackdrop end
	if not (Object.CreateShadow) then MetaTable.CreateShadow = CreateShadow end
	if not (Object.CreateOverlay) then MetaTable.CreateOverlay = CreateOverlay end
	if not (Object.CreateShadowOverlay) then MetaTable.CreateShadowOverlay = CreateShadowOverlay end

	-- Skinning
	if not (Object.HandleBlizzardRegions) then MetaTable.HandleBlizzardRegions = HandleBlizzardRegions end
	if not (Object.HandleInsetFrame) then MetaTable.HandleInsetFrame = HandleInsetFrame end
	if not (Object.HandleFrame) then MetaTable.HandleFrame = HandleFrame end
	if not (Object.DisableBackdrops) then MetaTable.DisableBackdrops = DisableBackdrops end
	if not (Object.HandleButton) then MetaTable.HandleButton = HandleButton end
	if not (Object.HandleEquipmentButton) then MetaTable.HandleEquipmentButton = HandleEquipmentButton end
	if not (Object.HandleCategoriesButtons) then MetaTable.HandleCategoriesButtons = HandleCategoriesButtons end
	if not (Object.HandleVoiceChatButton) then MetaTable.HandleVoiceChatButton = HandleVoiceChatButton end
	if not (Object.HandleCloseButton) then MetaTable.HandleCloseButton = HandleCloseButton end
	if not (Object.HandleBNETCloseButton) then MetaTable.HandleBNETCloseButton = HandleBNETCloseButton end
	if not (Object.HandleArrowButton) then MetaTable.HandleArrowButton = HandleArrowButton end
	if not (Object.HandlePlusMinusButton) then MetaTable.HandlePlusMinusButton = HandlePlusMinusButton end
	if not (Object.HandleQuestMinimizeButton) then MetaTable.HandleQuestMinimizeButton = HandleQuestMinimizeButton end
	if not (Object.HandleNavButtonDropDown) then MetaTable.HandleNavButtonDropDown = HandleNavButtonDropDown end
	if not (Object.HandleSplitButton) then MetaTable.HandleSplitButton = HandleSplitButton end
	if not (Object.HandleWorldMapOverlayButtons) then MetaTable.HandleWorldMapOverlayButtons = HandleWorldMapOverlayButtons end
	if not (Object.HandleTab) then MetaTable.HandleTab = HandleTab end
	if not (Object.HandleEditBox) then MetaTable.HandleEditBox = HandleEditBox end
	if not (Object.HandleDropDown) then MetaTable.HandleDropDown = HandleDropDown end
	if not (Object.HandleCheckBox) then MetaTable.HandleCheckBox = HandleCheckBox end
	if not (Object.HandleScrollFrame) then MetaTable.HandleScrollFrame = HandleScrollFrame end
	if not (Object.HandleSliderFrame) then MetaTable.HandleSliderFrame = HandleSliderFrame end
	if not (Object.HandleRotateButton) then MetaTable.HandleRotateButton = HandleRotateButton end
	if not (Object.HandleIconSelectionFrame) then MetaTable.HandleIconSelectionFrame = HandleIconSelectionFrame end
	if not (Object.HandleQuestLogHighlight) then MetaTable.HandleQuestLogHighlight = HandleQuestLogHighlight end
end

-- Init
local OnEvent = function(self, event, ...)
	if (event == 'ADDON_LOADED') then
		local AddOn = ...

		if (AddOn == 'FeelUI') then
			local Handled = { Frame = true }
			local Object = CreateFrame('Frame')
			local MergeAPI = MergeAPI

			MergeAPI(Object)
			MergeAPI(Object:CreateTexture())
			MergeAPI(Object:CreateFontString())
			MergeAPI(Object:CreateMaskTexture())

			Object = EnumerateFrames()

			while Object do
				if not (Object:IsForbidden() and not Handled[Object:GetObjectType()]) then
					MergeAPI(Object)

					Handled[Object:GetObjectType()] = true
				end

				Object = EnumerateFrames(Object)
			end

			MergeAPI(_G.GameFontNormal)
			MergeAPI(CreateFrame('ScrollFrame'))
		end
	end
end

local EventFrame = CreateFrame('Frame')
EventFrame:RegisterEvent('ADDON_LOADED')
EventFrame:SetScript('OnEvent', OnEvent)
