-- Call Interface
local UI, DB, Media, Language = select(2, ...):Call()

-- Register Module
local Loading = UI:RegisterModule('Loading')

-- Lib Globals
local type = type
local pairs = pairs

-- WoW Globals

-- Locales
local UserName = UI.UserName
local UserRealm = UI.UserRealm

-- Functions
function Loading:LoadStorage()
	local Storage = FeelDB[UserRealm][UserName]

	for Group, Options in pairs(Storage) do
		if (DB[Group]) then
			local Count = 0

			for Option, Value in pairs(Options) do
				if (DB[Group][Option] ~= nil) then
					if (DB[Group][Option] == Value) then
						Storage[Group][Option] = nil
					else
						Count = Count + 1

						if (type(DB[Group][Option]) == 'table') then
							if (DB[Group][Option][Options]) then
								DB[Group][Option][Value] = Value
							else
								DB[Group][Option] = Value
							end
						else
							DB[Group][Option] = Value
						end
					end
				end
			end
		else
			Storage[Group] = nil
		end
	end
end

function Loading:PurgeStorage()
	if not (FeelDB) then
		return
	end

	FeelDB = nil
	FeelDB = {}
	FeelDB[UserRealm] = {}
	FeelDB[UserRealm][UserName] = {}
	FeelDB[UserRealm][UserName]['FramePoints'] = {}
end

function Loading:CharacterSettings()
	local Storage = FeelDB[UserRealm][UserName]

	for Option, Value in pairs(DB) do
		if (type(Value) ~= 'table') then
			if (Storage[Option] == nil) then
				Storage[Option] = Value
			end
		else
			if (Storage[Option] == nil) then
				Storage[Option] = {}
			end

			for List, Key in pairs(Value) do
				if (Storage[Option][List] == nil) then
					Storage[Option][List] = Key
				end
			end
		end
	end
end

-- Init
function Loading:Initialize()
	self:LoadStorage()
	self:CharacterSettings()
end
