-- Автовыгрузка старой копии при перезапуске
if _G.PrismUI and _G.PrismUI.ActiveWindow then
	pcall(function()
		_G.PrismUI.ActiveWindow:Unload()
	end)
end

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
	"ui.lua"
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

-- Отдельная безопасная подгрузка configs.lua (не ломает интерфейс при отсутствии файла)
local cfgSource = loadModuleSource("configs.lua")
if cfgSource then
	local cfgFn = loadstring(cfgSource, "@configs.lua")
	if cfgFn then
		pcall(cfgFn)
	end
else
	warn("[PrismUI] configs.lua не найден на GitHub — проверь git push")
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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
_G.PrismUI.ActiveWindow = Window

Configs:Register("UI_Theme", {
	Get = function()
		return Window.Theme.Current.Name
	end,
	Set = function(_, themeName)
		Window.Theme:SetTheme(themeName)
	end
}, "Главные настройки", "Light")

-- 1. Главная страница
local homeTab = Window:AddTab({
	Name = "Главная страница",
	Closable = false,
	LeftTitle = "Главные настройки",
	RightTitle = "Дополнительно"
})

local autoloadName = Configs:GetAutoload()
if autoloadName ~= "" then
	Configs:Load(autoloadName)
end

homeTab.Left:AddThemePicker("Тема", "Переключает цветовую схему интерфейса")

local fontDrop = homeTab.Left:AddDropdown({
	Name = "Шрифт",
	Options = Utils.FontList,
	Default = Utils.CurrentFontName,
	Tip = "Меняет шрифт во всём интерфейсе в реальном времени",
	Callback = function(selectedFont)
		Utils.SetFont(selectedFont)
	end
})
Configs:Register("UI_Font", fontDrop, "Главные настройки", Utils.CurrentFontName)

local hideKeybind = homeTab.Left:AddKeybind({
	Name = "Скрыть UI",
	Default = Enum.KeyCode.RightShift,
	Tip = "Горячая клавиша скрытия и открытия окна",
	Callback = function()
		Window:ToggleVisible()
	end
})
Configs:Register("UI_HideKey", hideKeybind, "Главные настройки", Enum.KeyCode.RightShift)

-- Кнопка [ Конфиги ] Настроить -> открывает отдельную вкладку конфигов
homeTab.Left:AddConfigs(Window)

homeTab.Left:AddButton({
	Name = "Выгрузка",
	ButtonText = "Unload UI",
	Tip = "Полностью закрывает интерфейс и отключает все циклы",
	Callback = function()
		Window:Unload()
	end
})

homeTab.Left:AddText("ПКМ по любой функции открывает меню биндов. Скрипты под игры — на панели слева.")

-- Автозагрузка выбранного конфига при запуске
local autoloadName = Configs:GetAutoload()
Configs:Load(autoloadName)

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
	Configs:Register("SAE_AutoSteal", autoStealToggle, "Steal An Egg", false)

	local rarityDrop = tab.Left:AddDropdown({
		Name = "Редкость",
		Options = { "Любая", "Редкие", "Мифические", "Секретные" },
		Default = "Любая",
		Tip = "Фильтр яиц по редкости",
		Callback = function(choice)
			print("Редкость:", choice)
		end
	})
	Configs:Register("SAE_Rarity", rarityDrop, "Steal An Egg", "Любая")

	local mutationsMulti = tab.Left:AddMultiDropdown({
		Name = "Мутации",
		Options = { "Золотой", "Алмазный", "Радужный", "Гигантский" },
		Default = { "Золотой" },
		Tip = "Выбор нужных мутаций",
		Callback = function(selectedList)
			print("Мутации:", table.concat(selectedList, ", "))
		end
	})
	Configs:Register("SAE_Mutations", mutationsMulti, "Steal An Egg", { "Золотой" })

	local tpBaseBtn = tab.Left:AddButton({
		Name = "База",
		ButtonText = "Телепорт на базу",
		Tip = "Мгновенно возвращает на твою базу с яйцом",
		Callback = function()
			print("ТП на базу")
		end
	})
	Configs:Register("SAE_TpBase", tpBaseBtn, "Steal An Egg")

	local walkSlider = tab.Right:AddSlider({
		Name = "Walkspeed",
		Min = 16,
		Max = 120,
		OffText = "Выкл.",
		Tip = "Скорость передвижения персонажа",
		Callback = function(speed)
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = speed or 16
			end
		end
	})
	Configs:Register("SAE_Walkspeed", walkSlider, "Steal An Egg", nil)

	local jumpSlider = tab.Right:AddSlider({
		Name = "JumpPower",
		Min = 50,
		Max = 200,
		OffText = "Выкл.",
		Tip = "Сила прыжка персонажа",
		Callback = function(jp)
			local char = Players.LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.UseJumpPower = true
				char.Humanoid.JumpPower = jp or 50
			end
		end
	})
	Configs:Register("SAE_JumpPower", jumpSlider, "Steal An Egg", nil)

	local noclipEnabled = false
	local noclipToggle = tab.Right:AddToggle({
		Name = "NoClip",
		Default = false,
		Tip = "Позволяет проходить сквозь стены и двери",
		Callback = function(state)
			noclipEnabled = state
		end
	})
	Configs:Register("SAE_NoClip", noclipToggle, "Steal An Egg", false)

	local noclipConn = RunService.Stepped:Connect(function()
		if not noclipEnabled then return end
		local char = Players.LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
	Window:AddCleanup(noclipConn)

	Window:AddCleanup(function()
		noclipEnabled = false
		local char = Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = 16
			char.Humanoid.JumpPower = 50
		end
	end)

	Configs:Load(Configs:GetAutoload())
	Window:SelectTab(tab)
end

Window:AddGameIcon({
	Image = "rbxassetid://114533623813414",
	LastUpdate = "22.11.2026",
	Callback = openStealAnEgg
})