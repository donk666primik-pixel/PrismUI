local Players = game:GetService("Players")

_G.PrismUI = _G.PrismUI or {}
while not (_G.PrismUI.Utils and _G.PrismUI.Themes and _G.PrismUI.Elements) do
	task.wait()
end

local Utils = _G.PrismUI.Utils
local Themes = _G.PrismUI.Themes
local Elements = _G.PrismUI.Elements
local UI = {}

function UI.CreateWindow(options)
	options = options or {}
	local titleText = options.Title or "PrismUI v1.0"
	local themeManager = Themes.new(options.Theme or "Light")

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local old = playerGui:FindFirstChild("PrismUI_GUI")
	if old then old:Destroy() end

	local screenGui = Utils.Create("ScreenGui", {
		Name = "PrismUI_GUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, playerGui)

	local root = Utils.Create("Frame", {
		Name = "RootContainer",
		Size = UDim2.new(0, 880, 0, 520),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1
	}, screenGui)

	-- ==========================================
	-- ЛЕВЫЙ ДОК (ЦЕНТРИРОВАН + ТУЛТИП ДАТЫ ОБНОВЛЕНИЯ СЛЕВА)
	-- ==========================================
	local dockScrollTrack = Utils.Create("Frame", {
		Name = "DockScrollTrack",
		Size = UDim2.new(0, 8, 0, 320),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = themeManager.Current.TopBar,
		Visible = false
	}, root)
	Utils.AddCorner(dockScrollTrack, 4)
	themeManager:Bind(dockScrollTrack, "BackgroundColor3", "TopBar")

	local dockScrollThumb = Utils.Create("Frame", {
		Name = "DockScrollThumb",
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = themeManager.Current.ScrollThumb
	}, dockScrollTrack)
	Utils.AddCorner(dockScrollThumb, 4)
	themeManager:Bind(dockScrollThumb, "BackgroundColor3", "ScrollThumb")

	local leftDock = Utils.Create("Frame", {
		Name = "LeftDock",
		Size = UDim2.new(0, 74, 0, 66),
		Position = UDim2.new(0, 40, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = themeManager.Current.MainBg,
		Visible = false,
		ZIndex = 1
	}, root)
	Utils.AddCorner(leftDock, 20)
	themeManager:Bind(leftDock, "BackgroundColor3", "MainBg")

	local dockScroll = Utils.Create("ScrollingFrame", {
		Name = "DockScroll",
		Size = UDim2.new(0, 56, 1, -24),
		Position = UDim2.new(0, 0, 0, 12),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 2
	}, leftDock)

	Utils.Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, dockScroll)

	local dockUpdateTooltip = Utils.Create("Frame", {
		Name = "DockUpdateTooltip",
		Size = UDim2.new(0, 0, 0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = themeManager.Current.MainBg,
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 60
	}, root)
	Utils.AddCorner(dockUpdateTooltip, 8)
	themeManager:Bind(dockUpdateTooltip, "BackgroundColor3", "MainBg")

	Utils.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10)
	}, dockUpdateTooltip)

	local dockUpdateLabel = Utils.Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextSize = 11,
		TextTransparency = 1,
		TextColor3 = themeManager.Current.Text,
		ZIndex = 61
	}, dockUpdateTooltip)
	themeManager:Bind(dockUpdateLabel, "TextColor3", "Text")

	local function updateDockLayout(slotCount)
		if slotCount <= 0 then
			leftDock.Visible = false
			dockScrollTrack.Visible = false
			return
		end

		local wasHidden = not leftDock.Visible
		leftDock.Visible = true
		local neededHeight = math.clamp(slotCount * 48 - 6 + 24, 66, 456)

		if wasHidden then
			leftDock.Size = UDim2.new(0, 74, 0, neededHeight)
			Utils.Tween(leftDock, 0.28, { Position = UDim2.new(0, 14, 0.5, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			Utils.Tween(leftDock, 0.2, { Size = UDim2.new(0, 74, 0, neededHeight) })
		end

		dockScrollTrack.Visible = (slotCount > 9)
	end

	dockScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local maxCanvas = math.max(1, dockScroll.AbsoluteCanvasSize.Y - dockScroll.AbsoluteWindowSize.Y)
		local ratio = math.clamp(dockScroll.CanvasPosition.Y / maxCanvas, 0, 1)
		local maxThumbY = dockScrollTrack.AbsoluteSize.Y - dockScrollThumb.AbsoluteSize.Y
		dockScrollThumb.Position = UDim2.new(0, 0, 0, math.floor(maxThumbY * ratio))
	end)

	-- ==========================================
	-- ГЛАВНОЕ ОКНО И ШАПКА
	-- ==========================================
	local mainWindow = Utils.Create("Frame", {
		Name = "MainWindow",
		Size = UDim2.new(0, 804, 0, 520),
		Position = UDim2.new(0, 68, 0, 0),
		BackgroundColor3 = themeManager.Current.MainBg,
		ZIndex = 3
	}, root)
	Utils.AddCorner(mainWindow, 22)
	themeManager:Bind(mainWindow, "BackgroundColor3", "MainBg")

	local topBar = Utils.Create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = themeManager.Current.TopBar,
		ZIndex = 4
	}, mainWindow)
	Utils.AddCorner(topBar, 22)
	themeManager:Bind(topBar, "BackgroundColor3", "TopBar")

	Utils.MakeDraggable(topBar, root)

	local titleLabel = Utils.Create("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(0, 210, 0, 36),
		Position = UDim2.new(1, -224, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = titleText,
		TextSize = 15,
		TextColor3 = themeManager.Current.Text,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 6
	}, topBar)
	themeManager:Bind(titleLabel, "TextColor3", "Text")

	local tabsHolder = Utils.Create("Frame", {
		Name = "TabsHolder",
		Size = UDim2.new(1, -240, 0, 42),
		Position = UDim2.new(0, 12, 0, 8),
		BackgroundTransparency = 1,
		ZIndex = 5
	}, topBar)

	Utils.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, tabsHolder)

	local topBarMask = Utils.Create("Frame", {
		Name = "TopBarBottomMask",
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = themeManager.Current.MainBg,
		ZIndex = 7
	}, mainWindow)
	themeManager:Bind(topBarMask, "BackgroundColor3", "MainBg")

	local contentArea = Utils.Create("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -24, 1, -60),
		Position = UDim2.new(0, 12, 0, 48),
		BackgroundTransparency = 1,
		ZIndex = 8
	}, mainWindow)

	-- ==========================================
	-- УПРАВЛЕНИЕ ВКЛАДКАМИ И КОЛОНКАМИ
	-- ==========================================
	local Window = {
		Theme = themeManager,
		Tabs = {},
		ActiveTab = nil,
		DockSlotCount = 0,
		IsVisible = true,
		IsAnimating = true
	}

	local rootScale = Utils.Create("UIScale", { Scale = 0 }, root)
	local openStartTween = Utils.Tween(rootScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	openStartTween.Completed:Connect(function()
		Window.IsAnimating = false
	end)

	function Window:SelectTab(tabObj)
		if self.ActiveTab == tabObj then return end

		for _, t in ipairs(self.Tabs) do
			t.Container.Visible = false
			Utils.Tween(t.Underline, 0.16, { Size = UDim2.new(0, 0, 0, 2) })
		end

		self.ActiveTab = tabObj
		tabObj.Container.Visible = true
		tabObj.Container.Position = UDim2.new(0, 0, 0, 6)
		Utils.Tween(tabObj.Container, 0.2, { Position = UDim2.new(0, 0, 0, 0) })

		tabObj.Underline.Visible = true
		Utils.Tween(tabObj.Underline, 0.22, { Size = UDim2.new(1, 0, 0, 2) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end

	function Window:ToggleVisible()
		if self.IsAnimating then
			return
		end

		self.IsAnimating = true
		self.IsVisible = not self.IsVisible

		if self.IsVisible then
			screenGui.Enabled = true
			rootScale.Scale = 0
			local tw = Utils.Tween(rootScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			tw.Completed:Connect(function()
				self.IsAnimating = false
			end)
		else
			dockUpdateTooltip.Visible = false
			local tw = Utils.Tween(rootScale, 0.5, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			tw.Completed:Connect(function()
				if not self.IsVisible then
					screenGui.Enabled = false
				end
				self.IsAnimating = false
			end)
		end
	end

	function Window:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Вкладка"
		local closable = tabConfig.Closable ~= false

		local tabBtn = Utils.Create("TextButton", {
			Name = "Tab_" .. tabName,
			Size = UDim2.new(0, 0, 0, 42),
			BackgroundColor3 = themeManager.Current.TabBg,
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true,
			LayoutOrder = #self.Tabs + 1,
			ZIndex = 5
		}, tabsHolder)
		Utils.AddCorner(tabBtn, 16)
		themeManager:Bind(tabBtn, "BackgroundColor3", "TabBg")

		Utils.Tween(tabBtn, 0.22, { Size = UDim2.new(0, 170, 0, 42) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local underline = Utils.Create("Frame", {
			Name = "ActiveLine",
			Size = UDim2.new(0, 0, 0, 2),
			Position = UDim2.new(0.5, 0, 0, 26),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = themeManager.Current.Accent,
			Visible = false,
			ZIndex = 6
		}, tabBtn)
		themeManager:Bind(underline, "BackgroundColor3", "Accent")

		local labelOffset = closable and 34 or 12
		local labelWidth = closable and -46 or -24

		local tabLabel = Utils.Create("TextLabel", {
			Size = UDim2.new(1, labelWidth, 0, 28),
			Position = UDim2.new(0, labelOffset, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = tabName,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = themeManager.Current.Text,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 6
		}, tabBtn)
		themeManager:Bind(tabLabel, "TextColor3", "Text")

		local tabContainer = Utils.Create("Frame", {
			Name = "TabContainer_" .. tabName,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 8
		}, contentArea)

		local function buildColumn(sideName, xPos, headerText)
			local col = Utils.Create("Frame", {
				Name = sideName,
				Size = UDim2.new(0.495, 0, 1, 0),
				Position = xPos,
				BackgroundColor3 = themeManager.Current.ColumnBg,
				ClipsDescendants = true,
				ZIndex = 8
			}, tabContainer)
			Utils.AddCorner(col, 18)
			themeManager:Bind(col, "BackgroundColor3", "ColumnBg")

			local cleanHeader = string.gsub(headerText, "\n", " ")

			local badge = Utils.Create("Frame", {
				Name = "HeaderBadge",
				Size = UDim2.new(0, 0, 0, 36),
				AutomaticSize = Enum.AutomaticSize.X,
				Position = UDim2.new(0, 12, 0, -6),
				BackgroundColor3 = themeManager.Current.MainBg,
				ZIndex = 9
			}, col)
			Utils.AddCorner(badge, 9)
			themeManager:Bind(badge, "BackgroundColor3", "MainBg")

			Utils.Create("UIPadding", {
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
				PaddingTop = UDim.new(0, 6)
			}, badge)

			local badgeLabel = Utils.Create("TextLabel", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Text = cleanHeader,
				TextSize = 11,
				TextWrapped = false,
				TextColor3 = themeManager.Current.Text,
				ZIndex = 10
			}, badge)
			themeManager:Bind(badgeLabel, "TextColor3", "Text")

			local listScroll = Utils.Create("ScrollingFrame", {
				Name = "ElementsScroll",
				Size = UDim2.new(1, -24, 1, -46),
				Position = UDim2.new(0, 8, 0, 40),
				BackgroundTransparency = 1,
				ScrollBarThickness = 0,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ZIndex = 9
			}, col)

			Utils.Create("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, listScroll)

			local colScrollTrack = Utils.Create("Frame", {
				Name = "ColScrollTrack",
				Size = UDim2.new(0, 8, 1, -90),
				Position = UDim2.new(1, -13, 0, 68),
				BackgroundColor3 = themeManager.Current.ScrollTrack,
				Visible = false,
				ZIndex = 9
			}, col)
			Utils.AddCorner(colScrollTrack, 4)
			themeManager:Bind(colScrollTrack, "BackgroundColor3", "ScrollTrack")

			local colScrollThumb = Utils.Create("Frame", {
				Name = "ColScrollThumb",
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = themeManager.Current.ScrollThumb,
				ZIndex = 10
			}, colScrollTrack)
			Utils.AddCorner(colScrollThumb, 4)
			themeManager:Bind(colScrollThumb, "BackgroundColor3", "ScrollThumb")

			local function syncColumnScrollbar()
				local contentH = listScroll.AbsoluteCanvasSize.Y
				local windowH = listScroll.AbsoluteWindowSize.Y
				if contentH > windowH + 2 then
					colScrollTrack.Visible = true
					local maxCanvas = math.max(1, contentH - windowH)
					local ratio = math.clamp(listScroll.CanvasPosition.Y / maxCanvas, 0, 1)
					local thumbH = math.clamp(math.floor(colScrollTrack.AbsoluteSize.Y * (windowH / contentH)), 22, colScrollTrack.AbsoluteSize.Y)
					colScrollThumb.Size = UDim2.new(1, 0, 0, thumbH)
					local maxThumbY = colScrollTrack.AbsoluteSize.Y - thumbH
					colScrollThumb.Position = UDim2.new(0, 0, 0, math.floor(maxThumbY * ratio))
				else
					colScrollTrack.Visible = false
				end
			end

			listScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(syncColumnScrollbar)
			listScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(syncColumnScrollbar)
			listScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(syncColumnScrollbar)

			return Elements.AttachToColumn(listScroll, themeManager, root)
		end

		local Tab = {
			Name = tabName,
			Button = tabBtn,
			Underline = underline,
			Container = tabContainer,
			Left = buildColumn("LeftColumn", UDim2.new(0, 0, 0, 0), tabConfig.LeftTitle or "Под игру"),
			Right = buildColumn("RightColumn", UDim2.new(0.505, 0, 0, 0), tabConfig.RightTitle or "Оптимизованные классические")
		}

		if closable then
			local closeBtn = Utils.Create("TextButton", {
				Name = "CloseBtn",
				Size = UDim2.new(0, 22, 0, 22),
				Position = UDim2.new(0, 10, 0, 3),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 7
			}, tabBtn)

			local crossScale = Utils.Create("UIScale", { Scale = 1 }, closeBtn)

			for _, rot in ipairs({ 45, -45 }) do
				local line = Utils.Create("Frame", {
					Size = UDim2.new(0, 18, 0, 2),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Rotation = rot,
					BackgroundColor3 = themeManager.Current.Text,
					ZIndex = 7
				}, closeBtn)
				Utils.AddCorner(line, 1)
				themeManager:Bind(line, "BackgroundColor3", "Text")
			end

			closeBtn.MouseEnter:Connect(function()
				Utils.Tween(crossScale, 0.14, { Scale = 1.18 })
			end)

			closeBtn.MouseLeave:Connect(function()
				Utils.Tween(crossScale, 0.14, { Scale = 1 })
			end)

			closeBtn.MouseButton1Click:Connect(function()
				for idx, t in ipairs(Window.Tabs) do
					if t == Tab then
						table.remove(Window.Tabs, idx)
						break
					end
				end

				tabContainer:Destroy()
				if Window.ActiveTab == Tab and #Window.Tabs > 0 then
					Window:SelectTab(Window.Tabs[1])
				end

				local closeTween = Utils.Tween(tabBtn, 0.16, { Size = UDim2.new(0, 0, 0, 42) })
				closeTween.Completed:Connect(function()
					if tabBtn and tabBtn.Parent then
						tabBtn:Destroy()
					end
				end)
			end)
		end

		tabBtn.MouseButton1Click:Connect(function()
			Window:SelectTab(Tab)
		end)

		table.insert(self.Tabs, Tab)
		if #self.Tabs == 1 then
			Window:SelectTab(Tab)
		end

		return Tab
	end

	function Window:AddGameIcon(iconConfig)
		iconConfig = iconConfig or {}
		self.DockSlotCount += 1

		local imageStr = ""
		if type(iconConfig.Image) == "number" then
			imageStr = "rbxassetid://" .. tostring(iconConfig.Image)
		elseif type(iconConfig.Image) == "string" then
			imageStr = iconConfig.Image
		end

		local slotBtn = Utils.Create("ImageButton", {
			Name = "GameSlot_" .. self.DockSlotCount,
			Size = UDim2.new(0, 42, 0, 42),
			BackgroundColor3 = themeManager.Current.DockSlot,
			Image = imageStr,
			ScaleType = Enum.ScaleType.Crop,
			AutoButtonColor = false,
			LayoutOrder = self.DockSlotCount,
			ZIndex = 2
		}, dockScroll)
		Utils.AddCorner(slotBtn, 10)
		themeManager:Bind(slotBtn, "BackgroundColor3", "DockSlot")

		local slotScale = Utils.Create("UIScale", { Scale = 0 }, slotBtn)
		Utils.Tween(slotScale, 0.26, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		local lastUpdateDate = iconConfig.LastUpdate
		local hovered = false

		slotBtn.MouseEnter:Connect(function()
			hovered = true
			Utils.Tween(slotScale, 0.15, { Scale = 1.08 })

			if lastUpdateDate and lastUpdateDate ~= "" then
				dockUpdateLabel.Text = "Последнее обновление: " .. tostring(lastUpdateDate)
				local relY = (slotBtn.AbsolutePosition.Y - root.AbsolutePosition.Y) + (slotBtn.AbsoluteSize.Y * 0.5)
				local leftEdgeX = (leftDock.AbsolutePosition.X - root.AbsolutePosition.X) - (dockScrollTrack.Visible and 18 or 8)

				dockUpdateTooltip.Position = UDim2.new(0, leftEdgeX + 8, 0, relY)
				dockUpdateTooltip.Visible = true
				Utils.Tween(dockUpdateTooltip, 0.16, {
					Position = UDim2.new(0, leftEdgeX, 0, relY),
					BackgroundTransparency = 0
				})
				Utils.Tween(dockUpdateLabel, 0.16, { TextTransparency = 0 })
			end
		end)

		slotBtn.MouseLeave:Connect(function()
			hovered = false
			Utils.Tween(slotScale, 0.15, { Scale = 1 })

			if lastUpdateDate and lastUpdateDate ~= "" then
				Utils.Tween(dockUpdateLabel, 0.12, { TextTransparency = 1 })
				local tw = Utils.Tween(dockUpdateTooltip, 0.12, { BackgroundTransparency = 1 })
				tw.Completed:Connect(function()
					if not hovered and dockUpdateTooltip.BackgroundTransparency >= 0.99 then
						dockUpdateTooltip.Visible = false
					end
				end)
			end
		end)

		if iconConfig.Callback then
			slotBtn.MouseButton1Click:Connect(function()
				Utils.Tween(slotScale, 0.08, { Scale = 0.9 })
				task.delay(0.08, function()
					if slotBtn and slotBtn.Parent then
						Utils.Tween(slotScale, 0.2, { Scale = 1.05 }, Enum.EasingStyle.Back)
					end
				end)
				iconConfig.Callback()
			end)
		end

		-- Возвращаем обновление высоты и видимости левого дока!
		updateDockLayout(self.DockSlotCount)
		return slotBtn
	end

	return Window
end

_G.PrismUI.UI = UI