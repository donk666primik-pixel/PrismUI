local HttpService = game:GetService("HttpService")

_G.PrismUI = _G.PrismUI or {}
local Configs = {}
Configs.Items = {}

local FOLDER_ROOT = "PrismUI"
local FOLDER_CONFIGS = "PrismUI/configs"

local function ensureFolders()
	if type(isfolder) == "function" and type(makefolder) == "function" then
		if not isfolder(FOLDER_ROOT) then
			makefolder(FOLDER_ROOT)
		end
		if not isfolder(FOLDER_CONFIGS) then
			makefolder(FOLDER_CONFIGS)
		end
	end
end

-- Регистрация любого элемента (Toggle, Slider, Dropdown, Keybind, TextBox)
function Configs:Register(flagName, elementObj, valueType)
	if not flagName or not elementObj then return end
	self.Items[flagName] = {
		Element = elementObj,
		Type = valueType or "default"
	}
end

function Configs:Save(configName)
	if type(writefile) ~= "function" then
		warn("[PrismUI] Экзекутор не поддерживает writefile")
		return false
	end

	ensureFolders()
	local data = {}

	for flagName, entry in pairs(self.Items) do
		local val = entry.Element.Get()
		if typeof(val) == "EnumItem" then
			data[flagName] = { __enum = tostring(val.EnumType), name = val.Name }
		else
			data[flagName] = val
		end
	end

	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok then
		warn("[PrismUI] Ошибка кодирования конфига: " .. tostring(encoded))
		return false
	end

	writefile(FOLDER_CONFIGS .. "/" .. configName .. ".json", encoded)
	return true
end

function Configs:Load(configName)
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		warn("[PrismUI] Экзекутор не поддерживает readfile")
		return false
	end

	local path = FOLDER_CONFIGS .. "/" .. configName .. ".json"
	if not isfile(path) then
		return false
	end

	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
	if not ok or type(decoded) ~= "table" then
		warn("[PrismUI] Повреждённый файл конфига: " .. configName)
		return false
	end

	for flagName, savedVal in pairs(decoded) do
		local entry = self.Items[flagName]
		if entry and entry.Element and entry.Element.Set then
			if type(savedVal) == "table" and savedVal.__enum == "KeyCode" then
				local keyEnum = Enum.KeyCode[savedVal.name]
				if keyEnum then
					entry.Element:Set(keyEnum)
				end
			else
				entry.Element:Set(savedVal)
			end
		end
	end

	return true
end

function Configs:GetList()
	if type(listfiles) ~= "function" then
		return { "default" }
	end
	ensureFolders()
	local names = {}
	for _, filePath in ipairs(listfiles(FOLDER_CONFIGS)) do
		local name = string.match(filePath, "([^/\\]+)%.json$")
		if name then
			table.insert(names, name)
		end
	end
	if #names == 0 then
		table.insert(names, "default")
	end
	return names
end

_G.PrismUI.Configs = Configs