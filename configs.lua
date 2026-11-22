local HttpService = game:GetService("HttpService")

_G.PrismUI = _G.PrismUI or {}
local Configs = {}
Configs.Items = {}

local FOLDER_ROOT = "PrismUI"
local FOLDER_CONFIGS = "PrismUI/configs"
local AUTOLOAD_FILE = "PrismUI/autoload.txt"

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

function Configs:Register(flagName, elementObj)
	if not flagName or not elementObj then return end
	self.Items[flagName] = elementObj
end

function Configs:SetAutoload(configName)
	if type(writefile) ~= "function" then return false end
	ensureFolders()
	if not configName or configName == "" then
		if type(isfile) == "function" and type(delfile) == "function" and isfile(AUTOLOAD_FILE) then
			delfile(AUTOLOAD_FILE)
		end
		return true
	end
	writefile(AUTOLOAD_FILE, tostring(configName))
	return true
end

function Configs:GetAutoload()
	if type(isfile) == "function" and type(readfile) == "function" then
		if isfile(AUTOLOAD_FILE) then
			local content = readfile(AUTOLOAD_FILE)
			if type(content) == "string" and content ~= "" then
				return string.gsub(content, "%s+", "")
			end
		end
	end
	return "default"
end

function Configs:Save(configName)
	if type(writefile) ~= "function" then
		warn("[PrismUI] Экзекутор не поддерживает writefile")
		return false
	end

	ensureFolders()
	local data = {
		Values = {},
		Binds = {}
	}

	for flagName, el in pairs(self.Items) do
		if el.Get then
			local val = el.Get()
			if typeof(val) == "EnumItem" then
				data.Values[flagName] = { __enum = tostring(val.EnumType), name = val.Name }
			else
				data.Values[flagName] = val
			end
		end

		if el.GetBind then
			local bindData = el.GetBind()
			if bindData then
				data.Binds[flagName] = bindData
			end
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
		return false
	end

	local path = FOLDER_CONFIGS .. "/" .. configName .. ".json"
	if not isfile(path) then
		return false
	end

	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
	if not ok or type(decoded) ~= "table" then
		return false
	end

	local valuesMap = decoded.Values or decoded
	local bindsMap = decoded.Binds or {}

	for flagName, savedVal in pairs(valuesMap) do
		local el = self.Items[flagName]
		if el and el.Set then
			if type(savedVal) == "table" and savedVal.__enum == "KeyCode" then
				local keyEnum = Enum.KeyCode[savedVal.name]
				if keyEnum then
					el:Set(keyEnum)
				end
			else
				el:Set(savedVal)
			end
		end
	end

	for flagName, el in pairs(self.Items) do
		if el and el.SetBind then
			el:SetBind(bindsMap[flagName])
		end
	end

	return true
end

function Configs:Delete(configName)
	if type(isfile) ~= "function" or type(delfile) ~= "function" then
		return false
	end

	local path = FOLDER_CONFIGS .. "/" .. configName .. ".json"
	if isfile(path) then
		delfile(path)
		if self:GetAutoload() == configName then
			self:SetAutoload("default")
		end
		return true
	end
	return false
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