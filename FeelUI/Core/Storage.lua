-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Register Module
local Storage = CreateFrame('Frame')

-- Lib Globals
local pairs = pairs
local select = select
local tonumber = tonumber
local type = type
local format = string.format
local gsub = string.gsub
local split = string.split

-- WoW Globals

-- Locals
local UIVersion = UI.Version
local UserName = UI.UserName
local UserRealm = UI.UserRealm
local UserClass = UI.UserClass
local UserLocale = UI.UserLocale

local ValueText

-- Functions
function Storage:CheckStorage()
	if not (FeelDB) then
		FeelDB = {}
	end

	if not (FeelDB['Gold']) then
		FeelDB['Gold'] = {}
	end

	if not (FeelDB[UserRealm]) then
		FeelDB[UserRealm] = {}
	end

	if not (FeelDB[UserRealm][UserName]) then
		FeelDB[UserRealm][UserName] = {}
	end

	if not (FeelDB[UserRealm][UserName]['FramePoints']) then
		FeelDB[UserRealm][UserName]['FramePoints'] = {}
	end
end

function UI:ExportStorage(EditBox)
	local Data = FeelDB[UserRealm][UserName]
	local String = 'FeelUIExport:' .. UIVersion .. ':' .. UserLocale .. ':' .. UserClass

	for OptionCategroy, OptionTable in pairs(Data) do
		if (type(OptionTable) == 'table') then
			for Setting, Value in pairs(OptionTable) do
				if (type(Value) ~= 'table') then

					if (Data[OptionCategroy][Setting] == false) then
						ValueText = 'false'
					elseif (Data[OptionCategroy][Setting] == true) then
						ValueText = 'true'
					else
						ValueText = Data[OptionCategroy][Setting]
					end

					String = String .. '^' .. OptionCategroy .. '~' .. Setting .. '~' .. ValueText
				else
					String = String .. '^' .. OptionCategroy .. '~' .. Setting .. '~' .. Data[OptionCategroy][Setting][1] .. '~' .. Data[OptionCategroy][Setting][2] .. '~' .. Data[OptionCategroy][Setting][3] .. '~' .. Data[OptionCategroy][Setting][4]
				end
			end
		else

		end
	end

	EditBox:SetText(String)
	EditBox:HighlightText()
end

function UI:ImportStorage(String)
	local Data = FeelDB[UserRealm][UserName]
	local Lines = { split('^', String) }
	local UIName, Version, Locale, Class = split(':', Lines[1])
	local SameVersion, SameLocale, SameClass

	if (UIName ~= 'FeelUIExport') then
		print('STATIC_POPUP_PROFILE_IMPORT_INCORRECT_IMPORT_STRING')
	else
		print('STATIC_POPUP_PROFILE_IMPORT_CORRECT_IMPORT_STRING')

		local ImportString = ''

		if (Version ~= UIVersion) then
			ImportString = ImportString .. format('\nImport Version %s(Current Version %s)', Version, UIVersion)
		else
			SameVersion = true
		end

		if (Locale ~= UserLocale) then
			ImportString = ImportString .. format('\nGame Client %s(Current Client %s)', Locale, UserLocale)
		else
			SameLocale = true
		end

		if (Class ~= UserClass) then
			ImportString = ImportString .. format('\nClass %s(Current Class %s)', Class, UserClass)
		else
			SameClass = true
		end

		if not (SameVersion and SameLocale and SameClass) then
			ImportString = ImportString .. '\nMay not import completely.'
		end

		for Index, Key in pairs(Lines) do
			if (Index ~= 1) then
				local OptionCategroy, Setting, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8, Arg9 = split('~', Key)
				local Count = select(2, gsub(Key, '~', '~')) + 1

				if (Count == 3) then
					if (Data[OptionCategroy][Setting] ~= nil) then
						if (Arg1 == 'true') then
							Data[OptionCategroy][Setting] = true
						elseif (Arg1 == 'false') then
							Data[OptionCategroy][Setting] = false
						elseif (tonumber(Arg1)) then
							Data[OptionCategroy][Setting] = tonumber(Arg1)
						else
							Data[OptionCategroy][Setting] = Arg1
						end
					end
				else
					if (OptionCategroy == 'Colors') then
						Data[OptionCategroy][Setting] = {}
						Data[OptionCategroy][Setting] = {
							tonumber(Arg1),
							tonumber(Arg2),
							tonumber(Arg3),
							tonumber(Arg4)
						}
					end
				end
			end
		end
	end
end

function Storage:OnEvent(event, ...)
	local AddOn = ...

	if (AddOn ~= 'FeelUI') then
		return
	end

	self:CheckStorage()

	self:UnregisterEvent('ADDON_LOADED')
end

-- Init
Storage:RegisterEvent('ADDON_LOADED')
Storage:SetScript('OnEvent', Storage.OnEvent)
