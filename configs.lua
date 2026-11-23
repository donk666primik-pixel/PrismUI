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

local function valuesEqual(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) == "table" then
		if #a ~= #b then return false end
		for k, v in pairs(a) do
			if not valuesEqual(v, b[k]) then
				return false
			end
		end
		for k, v in pairs(b) do
			if not valuesEqual(v, a[k]) then
				return false
			end
		end
		return true
	end
	return a == b
end

-- Регистрация элемента: flagName, elementObj, sectionName (для вкладки "Изменения"), defaultVal
function Configs:Register(flagName, elementObj, sectionName, defaultVal)
	if not flagName or not elementObj then return end
	local initial = defaultVal
	if initial == nil and elementObj.Get then
		initial = elementObj.Get()
	end
	self.Items[flagName] = {
		Element = elementObj,
		Section = sectionName or "Главные настройки",
		Default = initial
	}
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

	for flagName, entry in pairs(self.Items) do
		local el = entry.Element
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
		local entry = self.Items[flagName]
		local el = entry and entry.Element
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

	for flagName, entry in pairs(self.Items) do
		local el = entry.Element
		if el and el.SetBind then
			el:SetBind(bindsMap[flagName])
		end
	end

	return true
end

function Configs:Delete(configName)
	if type(isfile) ~= "function" or type(delfile) == "function" then
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

-- Подсчёт количества изменённых настроек по разделам для правой панели вкладки "Конфиги"
function Configs:GetChangesSummary(compareConfigName)
	local savedValues = nil
	local savedBinds = nil

	if compareConfigName and type(isfile) == "function" and type(readfile) == "function" then
		local path = FOLDER_CONFIGS .. "/" .. compareConfigName .. ".json"
		if isfile(path) then
			local ok, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
			if ok and type(decoded) == "table" then
				savedValues = decoded.Values or decoded
				savedBinds = decoded.Binds or {}
			end
		end
	end

	local counts = {}
	local order = {}

	for flagName, entry in pairs(self.Items) do
		local sec = entry.Section or "Главные настройки"
		if counts[sec] == nil then
			counts[sec] = 0
			table.insert(order, sec)
		end

		local el = entry.Element
		local curVal = el.Get and el.Get() or nil
		if typeof(curVal) == "EnumItem" then
			curVal = curVal.Name
		end

		local baseVal = entry.Default
		if typeof(baseVal) == "EnumItem" then
			baseVal = baseVal.Name
		end

		if savedValues and savedValues[flagName] ~= nil then
			local sv = savedValues[flagName]
			if type(sv) == "table" and sv.__enum == "KeyCode" then
				baseVal = sv.name
			else
				baseVal = sv
			end
		end

		local valChanged = not valuesEqual(curVal, baseVal)
		local curBind = el.GetBind and el.GetBind() or nil
		local savedBind = savedBinds and savedBinds[flagName] or nil
		local bindChanged = not valuesEqual(curBind, savedBind)

		if valChanged or bindChanged then
			counts[sec] = counts[sec] + 1
		end
	end

	local lines = {}
	for _, sec in ipairs(order) do
		if counts[sec] > 0 then
			table.insert(lines, string.format("%s: %d изменений", sec, counts[sec]))
		end
	end

	if #lines == 0 then
		table.insert(lines, "Изменений нет")
	end

	return lines
end

_G.PrismUI.Configs = Configs