-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()
UI.Commands = {}

-- Lib Globals
local _G = _G
local type = type

-- WoW Globals
local C_UI_Reload = C_UI.Reload

-- Locals

-- Functions

-- Init
function UI:RegisterChatCommand(Command, Func)
	local Name = 'FeelUI' .. Command:upper()

	if (type(Func) == 'string') then
		SlashCmdList[Name] = function()
			if (Func == 'Status') then
				local StatusReport = UI:CallModule('StatusReport')
				StatusReport:Toggle()
			end
		end
	else
		SlashCmdList[Command] = Func
	end

	_G['SLASH_' .. Name .. '1'] = '/' .. Command:lower()

	UI.Commands[Command] = Name
end

SLASH_RELOADUI1 = '/rl'
SLASH_RELOADUI2 = '/reloadui'
SLASH_RELOADUI3 = '/frl'
SlashCmdList.RELOADUI = C_UI_Reload

UI:RegisterChatCommand('feel', 'GUI')
UI:RegisterChatCommand('feelui', 'GUI')
UI:RegisterChatCommand('fstatus', 'Status')
UI:RegisterChatCommand('resetui', 'Reset')
UI:RegisterChatCommand('moveui', 'MoveUI')
