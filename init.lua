_G.PrismUI = _G.PrismUI or {}

local LOCAL_DIR = "/workspaces/PrismUI/"
local BASE_URL = "https://raw.githubusercontent.com/donk666primik-pixel/PrismUI/main/"

local function fetchUrl(url)
	local ok, res = pcall(function()
		return game.HttpGet(game, url)
	end)
	if ok and type(res) == "string" and res ~= "" then
		return res
	end

	local req = request or http_request or (syn and syn.request) or (http and http.request)
	if req then
		local rOk, response = pcall(function()
			return req({ Url = url, Method = "GET" })
		end)
		if rOk and response and response.Body then
			return response.Body
		end
	end

	return nil
end

local function loadModuleSource(fileName)
	local localPath = LOCAL_DIR .. fileName
	if type(isfile) == "function" and type(readfile) == "function" then
		local ok, exists = pcall(isfile, localPath)
		if ok and exists then
			local rOk, content = pcall(readfile, localPath)
			if rOk and type(content) == "string" and content ~= "" then
				return content
			end
		end
	end

	return fetchUrl(BASE_URL .. fileName .. "?t=" .. tostring(os.time()))
end

local modules = {
	"utils.lua",
	"themes.lua",
	"elements.lua",
	"ui.lua",
	"configs.lua"
}

for _, fileName in ipairs(modules) do
	local source = loadModuleSource(fileName)
	if not source then
		warn("[PrismUI] Не удалось загрузить модуль: " .. fileName)
		return
	end

	local fn, err = loadstring(source, "@" .. fileName)
	if not fn then
		warn("[PrismUI] Ошибка компиляции " .. fileName .. ": " .. tostring(err))
		return
	end

	local runOk, runErr = pcall(fn)
	if not runOk then
		warn("[PrismUI] Ошибка выполнения " .. fileName .. ": " .. tostring(runErr))
		return
	end
end

local Utils = _G.PrismUI.Utils
local LibraryUI = _G.PrismUI.UI
local Configs = _G.PrismUI.Configs

function _G.PrismUI:CreateWindow(options)
	return LibraryUI.CreateWindow(options)
end

local Window = _G.PrismUI:CreateWindow({
	Title = "PrismUI (v1.0)",
	Theme = "Light"
})

-- Регистрируем тему и шрифт в конфиги
Configs:Register("UI_Theme", {
	Get = function()
		return Window.Theme.Current.Name
	end,
	Set = function(_, themeName)
		Window.Theme:SetTheme(themeName)
	end
})

local fontDrop = nil

-- 1. Главная страница
local homeTab = Window:AddTab({
	Name = "Главная страница",
	Closable = false,
	LeftTitle = "Главные настройки",
	RightTitle = "Конфигурации"
})

homeTab.Left:AddThemePicker("Тема", "Переключает цветовую схему интерфейса")

fontDrop = homeTab.Left:AddDropdown({
	Name = "Шрифт",
	Options = Utils.FontList,
	Default = Utils.CurrentFontName,
	Tip = "Меняет шрифт во всём интерфейсе в реальном времени",
	Callback = function(selectedFont)
		Utils.SetFont(selectedFont)
	end
})
Configs:Register("UI_Font", fontDrop)

homeTab.Left:AddKeybind({
	Name = "Скрыть UI",
	Default = Enum.KeyCode.RightShift,
	Tip = "Горячая клавиша скрытия и открытия окна",
	Callback = function()
		Window:ToggleVisible()
	end
})

homeTab.Left:AddText("Выбери игру на панели слева, чтобы открыть скрипт под нужный плейс.")

-- Управление конфигами в правой колонке главной страницы
local selectedConfigName = "default"
local cfgListDrop = nil

local cfgNameBox = homeTab.Right:AddTextBox({
	Name = "Название",
	Default = "default",
	Placeholder = "Имя конфига...",
	Tip = "Введи имя для нового или существующего конфига",
	Callback = function(txt)
		local clean = string.gsub(txt or "", "[^%w_%-]", "")
		if clean ~= "" then
			selectedConfigName = clean
		end
	end
})

cfgListDrop = homeTab.Right:AddDropdown({
	Name = "Список",
	Options = Configs:GetList(),
	Default = "default",
	Tip = "Выбор сохранённого конфига из папки PrismUI/configs",
	Callback = function(choice)
		selectedConfigName = choice
		cfgNameBox:Set(choice)
	end
})

homeTab.Right:AddButton({
	Name = "Запись",
	ButtonText = "Сохранить конфиг",
	Tip = "Сохраняет все текущие настройки в JSON-файл",
	Callback = function()
		local ok = Configs:Save(selectedConfigName)
		if ok and cfgListDrop then
			cfgListDrop:Refresh(Configs:GetList())
		end
	end
})

homeTab.Right:AddButton({
	Name = "Чтение",
	ButtonText = "Загрузить конфиг",
	Tip = "Применяет настройки из выбранного конфига",
	Callback = function()
		Configs:Load(selectedConfigName)
	end
})

-- Автозагрузка default-конфига при старте, если он уже существует
Configs:Load("default")

-- 2. Вкладка игры
local stealEggTab = nil

local function openStealAnEgg()
	if stealEggTab and stealEggTab.Container.Parent then
		Window:SelectTab(stealEggTab)
		return
	end

	local tab = Window:AddTab({
		Name = "Steal An Egg",
		Closable = true,
		LeftTitle = "Под игру",
		RightTitle = "Оптимизованные классические"
	})
	stealEggTab = tab

	local autoStealToggle = tab.Left:AddToggle({
		Name = "Auto Steal",
		Default = false,
		Tip = "Автоматически крадет ближайшие яйца в радиусе",
		Callback = function(state)
			print("Auto Steal:", state)
		end
	})
	Configs:Register("SAE_AutoSteal", autoStealToggle)

	local rarityDrop = tab.Left:AddDropdown({
		Name = "Редкость",
		Options = { "Любая", "Редкие", "Мифические", "Секретные" },
		Default = "Любая",
		Tip = "Фильтр яиц по редкости",
		Callback = function(choice)
			print("Редкость:", choice)
		end
	})
	Configs:Register("SAE_Rarity", rarityDrop)

	local mutationsMulti = tab.Left:AddMultiDropdown({
		Name = "Мутации",
		Options = { "Золотой", "Алмазный", "Радужный", "Гигантский" },
		Default = { "Золотой" },
		Tip = "Выбор нужных мутаций",
		Callback = function(selectedList)
			print("Мутации:", table.concat(selectedList, ", "))
		end
	})
	Configs:Register("SAE_Mutations", mutationsMulti)

	tab.Left:AddButton({
		Name = "База",
		ButtonText = "Телепорт на базу",
		Tip = "Мгновенно возвращает на твою базу с яйцом",
		Callback = function()
			print("ТП на базу")
		end
	})

	local walkSlider = tab.Right:AddSlider({
		Name = "Walkspeed",
		Min = 16,
		Max = 120,
		OffText = "Выкл.",
		Tip = "Скорость передвижения персонажа",
		Callback = function(speed)
			local char = game.Players.LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = speed or 16
			end
		end
	})
	Configs:Register("SAE_Walkspeed", walkSlider)

	local jumpSlider = tab.Right:AddSlider({
		Name = "JumpPower",
		Min = 50,
		Max = 200,
		OffText = "Выкл.",
		Tip = "Сила прыжка персонажа",
		Callback = function(jp)
			local char = game.Players.LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.UseJumpPower = true
				char.Humanoid.JumpPower = jp or 50
			end
		end
	})
	Configs:Register("SAE_JumpPower", jumpSlider)

	local noclipToggle = tab.Right:AddToggle({
		Name = "NoClip",
		Default = false,
		Tip = "Позволяет проходить сквозь стены и двери",
		Callback = function(state)
			print("NoClip:", state)
		end
	})
	Configs:Register("SAE_NoClip", noclipToggle)

	-- Подтягиваем значения из выбранного конфига для только что открытой вкладки
	Configs:Load(selectedConfigName)

	Window:SelectTab(tab)
end

Window:AddGameIcon({
	Image = "rbxassetid://114533623813414",
	LastUpdate = "22.11.2026",
	Callback = openStealAnEgg
})