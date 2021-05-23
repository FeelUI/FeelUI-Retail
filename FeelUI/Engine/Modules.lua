-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Lib Globals
local _G = _G

-- WoW Globals
local CreateFrame = CreateFrame
local UIParent = UIParent

-- Locals

-- Functions

-- Register a Module
function UI:RegisterModule(Name)
	if (self.Modules[Name]) then
		return self.Modules[Name]
	end

	local Module = CreateFrame('Frame', Name, UIParent)
	Module.Name = Name
	Module.Initialized = false

	self.Modules[Name] = Module
	self.Modules[#self.Modules + 1] = Module

	return Module
end

-- Call a registered Module
function UI:CallModule(Name)
	if (self.Modules[Name]) then
		return self.Modules[Name]
	end
end

-- Load all Modules
function UI:InitializeModules()
	for Index = 1, #self.Modules do
		if (self.Modules[Index].Initialize and not self.Modules[Index].Initialized) then
			self.Modules[Index]:Initialize()

			self.Modules[Index].Initialized = true
		end
	end
end

-- Init
local OnEvent = function(self, event)
	if (event == 'PLAYER_LOGIN') then
		UI:InitializeModules()

		self:UnregisterEvent(event)
	end
end

local EventFrame = CreateFrame('Frame')
EventFrame:RegisterEvent('PLAYER_LOGIN')
EventFrame:SetScript('OnEvent', OnEvent)
