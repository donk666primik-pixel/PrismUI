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
			pcall(makefolder, FOLDER_ROOT)
		end
		if not isfolder(FOLDER_CONFIGS) then
			pcall(makefolder, FOLDER_CONFIGS)
		end
	end
end

local function cleanConfigName(rawName)
	if type(rawName) ~= "string" then return "" end
	local stripped = string.gsub(rawName, "%s*%[Autoload%]%s*$", "")
	return string.gsub(stripped, "[^%w_%-]", "")
end

local function valuesEqual(a, b)
	if a == nil and b == nil then
		return true
	end
	if type(a) ~= type(b) then
		return false
	end
	if type(a) == "table" then
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
	local name = cleanConfigName(configName)
	if name == "" then
		if type(delfile) == "function" then
			pcall(delfile, AUTOLOAD_FILE)
		else
			pcall(writefile, AUTOLOAD_FILE, "")
		end
		return true
	end
	pcall(writefile, AUTOLOAD_FILE, name)
	return true
end

function Configs:GetAutoload()
	if type(isfile) == "function" and type(readfile) == "function" then
		local ok, exists = pcall(isfile, AUTOLOAD_FILE)
		if ok and exists then
			local rOk, content = pcall(readfile, AUTOLOAD_FILE)
			if rOk and type(content) == "string" and content ~= "" then
				return cleanConfigName(content)
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

	local name = cleanConfigName(configName)
	if name == "" then return false end

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

	local wOk = pcall(writefile, FOLDER_CONFIGS .. "/" .. name .. ".json", encoded)
	return wOk
end

function Configs:Load(configName)
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return false
	end

	local name = cleanConfigName(configName)
	if name == "" then return false end

	local path = FOLDER_CONFIGS .. "/" .. name .. ".json"
	local okExists, exists = pcall(isfile, path)
	if not okExists or not exists then
		return false
	end

	local okRead, raw = pcall(readfile, path)
	if not okRead or raw == "" then return false end

	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
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
	local name = cleanConfigName(configName)
	if name == "" then return false end

	ensureFolders()
	local targetPath = FOLDER_CONFIGS .. "/" .. name .. ".json"
	local foundExactPath = nil

	-- Ищем точный путь файла так, как его видит сам экзекутор в listfiles
	if type(listfiles) == "function" then
		local ok, files = pcall(listfiles, FOLDER_CONFIGS)
		if ok and type(files) == "table" then
			for _, filePath in ipairs(files) do
				local normalized = string.gsub(tostring(filePath), "\\", "/")
				local fileName = string.match(normalized, "([^/]+)%.json$")
				if fileName == name then
					foundExactPath = tostring(filePath)
					break
				end
			end
		end
	end

	local pathsToTry = {}
	if foundExactPath then
		table.insert(pathsToTry, foundExactPath)
	end
	table.insert(pathsToTry, targetPath)
	table.insert(pathsToTry, FOLDER_CONFIGS .. "\\" .. name .. ".json")

	local deleted = false
	if type(delfile) == "function" then
		for _, p in ipairs(pathsToTry) do
			local ok = pcall(delfile, p)
			if ok then
				deleted = true
			end
		end
	end

	-- Если экзекутор не поддерживает delfile или файл заблокирован — обнуляем его содержимое
	if not deleted and type(writefile) == "function" then
		for _, p in ipairs(pathsToTry) do
			if pcall(writefile, p, "") then
				deleted = true
				break
			end
		end
	end

	if self:GetAutoload() == name then
		self:SetAutoload("")
	end

	return deleted
end

function Configs:GetList()
	if type(listfiles) ~= "function" then
		return {}
	end
	ensureFolders()
	local names = {}
	local seen = {}
	local ok, files = pcall(listfiles, FOLDER_CONFIGS)
	if ok and type(files) == "table" then
		for _, filePath in ipairs(files) do
			local normalized = string.gsub(tostring(filePath), "\\", "/")
			local name = string.match(normalized, "([^/]+)%.json$")
			if name and name ~= "" and not seen[name] then
				local valid = true
				if type(readfile) == "function" then
					local rOk, content = pcall(readfile, filePath)
					if rOk and (content == "" or content == nil) then
						valid = false
					end
				end
				if valid then
					seen[name] = true
					table.insert(names, name)
				end
			end
		end
	end
	table.sort(names)
	return names
end

function Configs:GetChangesSummary(compareConfigName)
	local name = cleanConfigName(compareConfigName)
	if name == "" then
		return { "Конфиг не выбран" }
	end

	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return { "Нет доступа к файлам конфигов" }
	end

	local path = FOLDER_CONFIGS .. "/" .. name .. ".json"
	local okEx, exists = pcall(isfile, path)
	if not okEx or not exists then
		return { string.format("Конфиг «%s» ещё не сохранён", name) }
	end

	local okRead, raw = pcall(readfile, path)
	if not okRead or raw == "" then
		return { string.format("Конфиг «%s» не найден", name) }
	end

	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok or type(decoded) ~= "table" then
		return { "Ошибка чтения файла конфига" }
	end

	local savedValues = decoded.Values or {}
	local savedBinds = decoded.Binds or {}

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

		local cfgVal = savedValues[flagName]
		if type(cfgVal) == "table" and cfgVal.__enum == "KeyCode" then
			cfgVal = cfgVal.name
		end

		local valDiffers = not valuesEqual(curVal, cfgVal)

		local curBind = el.GetBind and el.GetBind() or nil
		local cfgBind = savedBinds[flagName]
		local bindDiffers = not valuesEqual(curBind, cfgBind)

		if valDiffers or bindDiffers then
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
		table.insert(lines, "Изменений нет (совпадает с конфигом)")
	end

	return lines
end

_G.PrismUI.Configs = Configs