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

	return fetchUrl(BASE_URL .. fileName)
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

local Utils = _G.PrismUI.Utils
local LibraryUI = _G.PrismUI.UI

function _G.PrismUI:CreateWindow(options)
	return LibraryUI.CreateWindow(options)
end

local Window = _G.PrismUI:CreateWindow({
	Title = "AllTheFeatures (ATF)",
	Theme = "Light"
})

-- 1. Главная страница
local homeTab = Window:AddTab({
	Name = "Главная страница",
	Closable = false,
	LeftTitle = "Главные настройки",
	RightTitle = "Infinite Yield"
})

homeTab.Left:AddThemePicker("Тема", "Переключает цветовую схему интерфейса")

homeTab.Left:AddDropdown({
	Name = "Шрифт",
	Options = Utils.FontList,
	Default = Utils.CurrentFontName,
	Tip = "Меняет шрифт во всём интерфейсе в реальном времени",
	Callback = function(selectedFont)
		Utils.SetFont(selectedFont)
	end
})

homeTab.Left:AddKeybind({
	Name = "Скрыть UI",
	Default = Enum.KeyCode.RightShift,
	Tip = "Горячая клавиша скрытия и открытия окна",
	Callback = function()
		Window:ToggleVisible()
	end
})

homeTab.Left:AddText("Выбери игру на панели слева, чтобы открыть скрипт под нужный плейс.")

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

	tab.Left:AddToggle({
		Name = "Auto Steal",
		Default = false,
		Tip = "Автоматически крадет ближайшие яйца в радиусе",
		Callback = function(state)
			print("Auto Steal:", state)
		end
	})

	tab.Left:AddDropdown({
		Name = "Редкость",
		Options = { "Любая", "Редкие", "Мифические", "Секретные" },
		Default = "Любая",
		Tip = "Фильтр яиц по редкости",
		Callback = function(choice)
			print("Редкость:", choice)
		end
	})

	tab.Left:AddMultiDropdown({
		Name = "Мутации",
		Options = { "Золотой", "Алмазный", "Радужный", "Гигантский" },
		Default = { "Золотой" },
		Tip = "Выбор нужных мутаций",
		Callback = function(selectedList)
			print("Мутации:", table.concat(selectedList, ", "))
		end
	})

	tab.Left:AddButton({
		Name = "База",
		ButtonText = "Телепорт на базу",
		Tip = "Мгновенно возвращает на твою базу с яйцом",
		Callback = function()
			print("ТП на базу")
		end
	})

	tab.Right:AddSlider({
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

	tab.Right:AddSlider({
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

	tab.Right:AddToggle({
		Name = "NoClip",
		Default = false,
		Tip = "Позволяет проходить сквозь стены и двери",
		Callback = function(state)
			print("NoClip:", state)
		end
	})

	Window:SelectTab(tab)
end

Window:AddGameIcon({
	Image = "rbxassetid://0",
	LastUpdate = "22.11.2026",
	Callback = openStealAnEgg
})