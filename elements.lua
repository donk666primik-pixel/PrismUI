local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

_G.PrismUI = _G.PrismUI or {}
while not (_G.PrismUI.Utils and _G.PrismUI.Themes) do
	task.wait()
end

local Utils = _G.PrismUI.Utils
local Themes = _G.PrismUI.Themes
local Elements = {}

local function startBreathing(targetInst, propName, fromVal, toVal)
	local info = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	targetInst[propName] = fromVal
	local tween = TweenService:Create(targetInst, info, { [propName] = toVal })
	tween:Play()
	return tween
end

function Elements.AttachToColumn(columnContainer, themeManager, overlayRoot)
	local api = {}

	local function createHeaderLabel(row, textStr, tipText, fixedWidth)
		local labelBox = Utils.Create("Frame", {
			Size = UDim2.new(0, fixedWidth or 84, 0, 26),
			BackgroundColor3 = themeManager.Current.ElementBg,
			ZIndex = 9
		}, row)
		Utils.AddCorner(labelBox, 8)
		themeManager:Bind(labelBox, "BackgroundColor3", "ElementBg")

		local hasTip = (tipText ~= nil and tipText ~= "")
		local labelText = Utils.Create("TextLabel", {
			Size = UDim2.new(1, hasTip and -22 or -6, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = textStr,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = themeManager.Current.Text,
			TextXAlignment = hasTip and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
			ZIndex = 10
		}, labelBox)
		themeManager:Bind(labelText, "TextColor3", "Text")

		if hasTip then
			local tipBtn = Utils.Create("TextButton", {
				Name = "TipBtn",
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(1, -17, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = themeManager.Current.TrackBg,
				Font = Enum.Font.GothamBold,
				Text = "?",
				TextSize = 10,
				TextColor3 = themeManager.Current.Text,
				AutoButtonColor = false,
				ZIndex = 11
			}, labelBox)
			Utils.AddCorner(tipBtn, 7)
			themeManager:Bind(tipBtn, "BackgroundColor3", "TrackBg")
			themeManager:Bind(tipBtn, "TextColor3", "Text")

			local tooltip = Utils.Create("Frame", {
				Name = "TooltipPopup",
				Size = UDim2.new(0, 175, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = themeManager.Current.MainBg,
				BackgroundTransparency = 1,
				Visible = false,
				ZIndex = 50
			}, overlayRoot or row)
			Utils.AddCorner(tooltip, 8)
			themeManager:Bind(tooltip, "BackgroundColor3", "MainBg")

			Utils.Create("UIPadding", {
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8)
			}, tooltip)

			local tipLabel = Utils.Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Text = tipText,
				TextSize = 11,
				TextWrapped = true,
				TextTransparency = 1,
				TextColor3 = themeManager.Current.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 51
			}, tooltip)
			themeManager:Bind(tipLabel, "TextColor3", "Text")

			local function showTip()
				if overlayRoot then
					local absPos = tipBtn.AbsolutePosition - overlayRoot.AbsolutePosition
					tooltip.Position = UDim2.new(0, absPos.X + 14, 0, absPos.Y - 4)
					tooltip.Visible = true
					Utils.Tween(tooltip, 0.16, {
						Position = UDim2.new(0, absPos.X + 20, 0, absPos.Y - 4),
						BackgroundTransparency = 0
					})
				else
					tooltip.Position = UDim2.new(0, (fixedWidth or 84) + 6, 0, 0)
					tooltip.Visible = true
					Utils.Tween(tooltip, 0.16, { BackgroundTransparency = 0 })
				end
				Utils.Tween(tipLabel, 0.16, { TextTransparency = 0 })
				Utils.Tween(tipBtn, 0.15, { BackgroundColor3 = themeManager.Current.KnobOn })
			end

			local function hideTip()
				Utils.Tween(tipBtn, 0.15, { BackgroundColor3 = themeManager.Current.TrackBg })
				Utils.Tween(tipLabel, 0.12, { TextTransparency = 1 })
				local tw = Utils.Tween(tooltip, 0.12, { BackgroundTransparency = 1 })
				tw.Completed:Connect(function()
					if tooltip.BackgroundTransparency >= 0.99 then
						tooltip.Visible = false
					end
				end)
			end

			tipBtn.MouseEnter:Connect(showTip)
			tipBtn.MouseLeave:Connect(hideTip)
			tipBtn.MouseButton1Click:Connect(function()
				if tooltip.Visible then hideTip() else showTip() end
			end)
		end

		return labelBox
	end

	-- 1. Toggle
	function api:AddToggle(config)
		config = config or {}
		local state = config.Default or false
		local callback = config.Callback or function() end

		local row = Utils.Create("Frame", {
			Name = "ToggleRow_" .. (config.Name or "Item"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, config.Name or "Toggle", config.Tip, 84)

		local track = Utils.Create("TextButton", {
			Size = UDim2.new(0, 40, 0, 20),
			Position = UDim2.new(0, 90, 0, 3),
			BackgroundColor3 = themeManager.Current.TrackBg,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 9
		}, row)
		Utils.AddCorner(track, 10)
		themeManager:Bind(track, "BackgroundColor3", "TrackBg")

		local knob = Utils.Create("Frame", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = state and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = state and themeManager.Current.KnobOn or themeManager.Current.KnobOff,
			ZIndex = 10
		}, track)
		Utils.AddCorner(knob, 10)

		local function updateVisual()
			Utils.Tween(knob, 0.22, {
				Position = state and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = state and themeManager.Current.KnobOn or themeManager.Current.KnobOff
			}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end

		themeManager:OnChanged(function(target)
			themeManager:TweenProperty(knob, "BackgroundColor3", state and target.KnobOn or target.KnobOff)
		end)

		track.MouseButton1Click:Connect(function()
			state = not state
			updateVisual()
			callback(state)
		end)

		return {
			Set = function(_, newState)
				state = newState
				updateVisual()
				callback(state)
			end,
			Get = function() return state end
		}
	end

	-- 2. Slider
	function api:AddSlider(config)
		config = config or {}
		local minVal = config.Min or 16
		local maxVal = config.Max or 100
		local currentVal = config.Default or minVal
		local offText = config.OffText or "Выкл."
		local callback = config.Callback or function() end

		local row = Utils.Create("Frame", {
			Name = "SliderRow_" .. (config.Name or "Item"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, config.Name or "Slider", config.Tip, 84)

		local track = Utils.Create("TextButton", {
			Size = UDim2.new(0, 100, 0, 20),
			Position = UDim2.new(0, 90, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = themeManager.Current.TrackBg,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 9
		}, row)
		Utils.AddCorner(track, 12)
		themeManager:Bind(track, "BackgroundColor3", "TrackBg")

		local knob = Utils.Create("Frame", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = themeManager.Current.SliderKnob,
			ZIndex = 10
		}, track)
		Utils.AddCorner(knob, 12)
		themeManager:Bind(knob, "BackgroundColor3", "SliderKnob")

		local knobStroke = Utils.Create("UIStroke", {
			Color = themeManager.Current.Accent,
			Thickness = 2,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, knob)
		themeManager:Bind(knobStroke, "Color", "Accent")

		local valueLabel = Utils.Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = offText,
			TextSize = 11,
			TextColor3 = themeManager.Current.Text,
			ZIndex = 11
		}, track)
		themeManager:Bind(valueLabel, "TextColor3", "Text")

		local dragging = false
		local breathTween = nil

		local function setHoldVisual(isHolding)
			if isHolding then
				Utils.Tween(track, 0.16, { Size = UDim2.new(0, 104, 0, 24) }, Enum.EasingStyle.Back)
				Utils.Tween(knob, 0.16, { Size = UDim2.new(0, 24, 0, 24) }, Enum.EasingStyle.Back)
				if not breathTween then
					breathTween = startBreathing(knobStroke, "Transparency", 0.15, 0.75)
				end
			else
				Utils.Tween(track, 0.18, { Size = UDim2.new(0, 100, 0, 20) })
				Utils.Tween(knob, 0.18, { Size = UDim2.new(0, 20, 0, 20) })
				if breathTween then
					breathTween:Cancel()
					breathTween = nil
				end
				Utils.Tween(knobStroke, 0.15, { Transparency = 1 })
			end
		end

		local function setFromPercent(alpha, smooth)
			alpha = math.clamp(alpha, 0, 1)
			local knobW = dragging and 24 or 20
			local trackW = dragging and 104 or 100
			local maxOffset = math.max(1, trackW - knobW)
			local targetPos = UDim2.new(0, math.floor(maxOffset * alpha), 0.5, 0)

			if smooth then
				Utils.Tween(knob, 0.14, { Position = targetPos })
			else
				knob.Position = targetPos
			end

			if alpha <= 0.02 then
				currentVal = minVal
				valueLabel.Text = offText
				callback(nil)
			else
				currentVal = math.floor(minVal + (maxVal - minVal) * alpha)
				valueLabel.Text = tostring(currentVal)
				callback(currentVal)
			end
		end

		local function updateFromInput(input)
			local knobW = dragging and 24 or 20
			local maxOffset = math.max(1, track.AbsoluteSize.X - knobW)
			local relX = input.Position.X - track.AbsolutePosition.X - (knobW * 0.5)
			setFromPercent(relX / maxOffset, false)
		end

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setHoldVisual(true)
				updateFromInput(input)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				setHoldVisual(false)
			end
		end)

		return {
			Set = function(_, val)
				if not val or val <= minVal then
					setFromPercent(0, true)
				else
					setFromPercent((val - minVal) / (maxVal - minVal), true)
				end
			end,
			Get = function() return currentVal end
		}
	end

	-- 3. Button
	function api:AddButton(config)
		config = config or {}
		local callback = config.Callback or function() end

		local row = Utils.Create("Frame", {
			Name = "ButtonRow_" .. (config.Name or "Btn"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, config.Name or "Action", config.Tip, 84)

		local actionBtn = Utils.Create("TextButton", {
			Size = UDim2.new(0, 100, 0, 24),
			Position = UDim2.new(0, 90, 0, 1),
			BackgroundColor3 = themeManager.Current.ElementBg,
			Font = Enum.Font.GothamBold,
			Text = config.ButtonText or "Выполнить",
			TextSize = 11,
			TextColor3 = themeManager.Current.Text,
			AutoButtonColor = false,
			ZIndex = 10
		}, row)
		Utils.AddCorner(actionBtn, 8)
		themeManager:Bind(actionBtn, "BackgroundColor3", "ElementBg")
		themeManager:Bind(actionBtn, "TextColor3", "Text")

		local btnScale = Utils.Create("UIScale", { Scale = 1 }, actionBtn)

		actionBtn.MouseEnter:Connect(function()
			Utils.Tween(btnScale, 0.14, { Scale = 1.03 })
		end)

		actionBtn.MouseLeave:Connect(function()
			Utils.Tween(btnScale, 0.14, { Scale = 1 })
		end)

		actionBtn.MouseButton1Click:Connect(function()
			Utils.Tween(btnScale, 0.08, { Scale = 0.94 })
			Utils.Tween(actionBtn, 0.1, { BackgroundColor3 = themeManager.Current.KnobOn })
			task.delay(0.12, function()
				if actionBtn and actionBtn.Parent then
					Utils.Tween(btnScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
					Utils.Tween(actionBtn, 0.18, { BackgroundColor3 = themeManager.Current.ElementBg })
				end
			end)
			callback()
		end)

		return actionBtn
	end

	-- 4. Dropdown
	function api:AddDropdown(config)
		config = config or {}
		local options = config.Options or {}
		local selected = config.Default or options[1] or "Выбрать"
		local callback = config.Callback or function() end
		local isOpen = false
		local breathTween = nil
		local optionButtons = {}

		local wrapper = Utils.Create("Frame", {
			Name = "Dropdown_" .. (config.Name or "Drop"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 9
		}, columnContainer)

		local topRow = Utils.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, wrapper)

		createHeaderLabel(topRow, config.Name or "Выбор", config.Tip, 84)

		local dropBtn = Utils.Create("TextButton", {
			Size = UDim2.new(0, 125, 0, 24),
			Position = UDim2.new(0, 90, 0, 1),
			BackgroundColor3 = themeManager.Current.ElementBg,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 10
		}, topRow)
		Utils.AddCorner(dropBtn, 8)
		themeManager:Bind(dropBtn, "BackgroundColor3", "ElementBg")

		local dropStroke = Utils.Create("UIStroke", {
			Color = themeManager.Current.Accent,
			Thickness = 1.5,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, dropBtn)
		themeManager:Bind(dropStroke, "Color", "Accent")

		local dropText = Utils.Create("TextLabel", {
			Size = UDim2.new(1, -22, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = tostring(selected),
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = themeManager.Current.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 11
		}, dropBtn)
		themeManager:Bind(dropText, "TextColor3", "Text")

		local arrowLabel = Utils.Create("TextLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -18, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "▼",
			TextSize = 9,
			TextColor3 = themeManager.Current.Text,
			ZIndex = 11
		}, dropBtn)
		themeManager:Bind(arrowLabel, "TextColor3", "Text")

		local listBox = Utils.Create("Frame", {
			Size = UDim2.new(0, 125, 0, 0),
			Position = UDim2.new(0, 90, 0, 28),
			BackgroundColor3 = themeManager.Current.TrackBg,
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 12
		}, wrapper)
		Utils.AddCorner(listBox, 8)
		themeManager:Bind(listBox, "BackgroundColor3", "TrackBg")

		Utils.Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, listBox)

		Utils.Create("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3)
		}, listBox)

		local function getListHeight()
			if #options == 0 then return 0 end
			return #options * 22 + 4
		end

		local function setDropdownOpen(openState)
			isOpen = openState
			Utils.Tween(arrowLabel, 0.2, { Rotation = isOpen and 180 or 0 })

			if isOpen then
				local listH = getListHeight()
				listBox.Visible = true
				Utils.Tween(listBox, 0.22, { Size = UDim2.new(0, 125, 0, listH) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Utils.Tween(wrapper, 0.22, { Size = UDim2.new(1, 0, 0, 28 + listH) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				if not breathTween then
					breathTween = startBreathing(dropStroke, "Transparency", 0.2, 0.78)
				end
			else
				if breathTween then
					breathTween:Cancel()
					breathTween = nil
				end
				Utils.Tween(dropStroke, 0.15, { Transparency = 1 })
				Utils.Tween(wrapper, 0.18, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local tw = Utils.Tween(listBox, 0.18, { Size = UDim2.new(0, 125, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				tw.Completed:Connect(function()
					if not isOpen and listBox and listBox.Parent then
						listBox.Visible = false
					end
				end)
			end
		end

		local function updateOptionColors(smooth)
			for _, item in ipairs(optionButtons) do
				if item.Btn and item.Btn.Parent then
					local isSel = (item.Opt == selected)
					local targetBg = isSel and themeManager.Current.KnobOn or themeManager.Current.ElementBg
					if smooth then
						themeManager:TweenProperty(item.Btn, "BackgroundColor3", targetBg)
						themeManager:TweenProperty(item.Btn, "TextColor3", themeManager.Current.Text)
					else
						item.Btn.BackgroundColor3 = targetBg
						item.Btn.TextColor3 = themeManager.Current.Text
					end
				end
			end
		end

		local function rebuildOptions()
			for _, child in ipairs(listBox:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			optionButtons = {}

			for _, opt in ipairs(options) do
				local optBtn = Utils.Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundColor3 = (opt == selected) and themeManager.Current.KnobOn or themeManager.Current.ElementBg,
					Font = Enum.Font.GothamMedium,
					Text = tostring(opt),
					TextSize = 11,
					TextColor3 = themeManager.Current.Text,
					AutoButtonColor = false,
					ZIndex = 13
				}, listBox)
				Utils.AddCorner(optBtn, 6)

				table.insert(optionButtons, { Btn = optBtn, Opt = opt })

				optBtn.MouseEnter:Connect(function()
					if opt ~= selected then
						Utils.Tween(optBtn, 0.12, { BackgroundColor3 = themeManager.Current.TabBg })
					end
				end)

				optBtn.MouseLeave:Connect(function()
					if opt ~= selected then
						Utils.Tween(optBtn, 0.12, { BackgroundColor3 = themeManager.Current.ElementBg })
					end
				end)

				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					dropText.Text = tostring(selected)
					updateOptionColors(true)
					setDropdownOpen(false)
					callback(selected)
				end)
			end
		end

		rebuildOptions()
		themeManager:OnChanged(function()
			updateOptionColors(true)
		end)

		dropBtn.MouseButton1Click:Connect(function()
			setDropdownOpen(not isOpen)
		end)

		return {
			Set = function(_, val)
				selected = val
				dropText.Text = tostring(selected)
				updateOptionColors(true)
				callback(selected)
			end,
			Refresh = function(_, newOpts)
				options = newOpts
				rebuildOptions()
				if isOpen then
					local listH = getListHeight()
					Utils.Tween(listBox, 0.18, { Size = UDim2.new(0, 125, 0, listH) })
					Utils.Tween(wrapper, 0.18, { Size = UDim2.new(1, 0, 0, 28 + listH) })
				end
			end,
			Get = function() return selected end
		}
	end

	-- 5. MultiDropdown
	function api:AddMultiDropdown(config)
		config = config or {}
		local options = config.Options or {}
		local selectedMap = {}
		if config.Default then
			for _, v in ipairs(config.Default) do
				selectedMap[v] = true
			end
		end
		local callback = config.Callback or function() end
		local isOpen = false
		local breathTween = nil
		local optionButtons = {}

		local wrapper = Utils.Create("Frame", {
			Name = "MultiDropdown_" .. (config.Name or "Multi"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 9
		}, columnContainer)

		local topRow = Utils.Create("Frame", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, wrapper)

		createHeaderLabel(topRow, config.Name or "Список", config.Tip, 84)

		local function getSelectedArray()
			local arr = {}
			for _, opt in ipairs(options) do
				if selectedMap[opt] then
					table.insert(arr, opt)
				end
			end
			return arr
		end

		local function formatHeaderText()
			local arr = getSelectedArray()
			if #arr == 0 then
				return "Ничего"
			elseif #arr <= 2 then
				return table.concat(arr, ", ")
			else
				return string.format("Выбрано: %d", #arr)
			end
		end

		local dropBtn = Utils.Create("TextButton", {
			Size = UDim2.new(0, 125, 0, 24),
			Position = UDim2.new(0, 90, 0, 1),
			BackgroundColor3 = themeManager.Current.ElementBg,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 10
		}, topRow)
		Utils.AddCorner(dropBtn, 8)
		themeManager:Bind(dropBtn, "BackgroundColor3", "ElementBg")

		local dropStroke = Utils.Create("UIStroke", {
			Color = themeManager.Current.Accent,
			Thickness = 1.5,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, dropBtn)
		themeManager:Bind(dropStroke, "Color", "Accent")

		local dropText = Utils.Create("TextLabel", {
			Size = UDim2.new(1, -22, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = formatHeaderText(),
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = themeManager.Current.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 11
		}, dropBtn)
		themeManager:Bind(dropText, "TextColor3", "Text")

		local arrowLabel = Utils.Create("TextLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -18, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "▼",
			TextSize = 9,
			TextColor3 = themeManager.Current.Text,
			ZIndex = 11
		}, dropBtn)
		themeManager:Bind(arrowLabel, "TextColor3", "Text")

		local listBox = Utils.Create("Frame", {
			Size = UDim2.new(0, 125, 0, 0),
			Position = UDim2.new(0, 90, 0, 28),
			BackgroundColor3 = themeManager.Current.TrackBg,
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 12
		}, wrapper)
		Utils.AddCorner(listBox, 8)
		themeManager:Bind(listBox, "BackgroundColor3", "TrackBg")

		Utils.Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, listBox)

		Utils.Create("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3)
		}, listBox)

		local function getListHeight()
			if #options == 0 then return 0 end
			return #options * 22 + 4
		end

		local function setDropdownOpen(openState)
			isOpen = openState
			Utils.Tween(arrowLabel, 0.2, { Rotation = isOpen and 180 or 0 })

			if isOpen then
				local listH = getListHeight()
				listBox.Visible = true
				Utils.Tween(listBox, 0.22, { Size = UDim2.new(0, 125, 0, listH) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Utils.Tween(wrapper, 0.22, { Size = UDim2.new(1, 0, 0, 28 + listH) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				if not breathTween then
					breathTween = startBreathing(dropStroke, "Transparency", 0.2, 0.78)
				end
			else
				if breathTween then
					breathTween:Cancel()
					breathTween = nil
				end
				Utils.Tween(dropStroke, 0.15, { Transparency = 1 })
				Utils.Tween(wrapper, 0.18, { Size = UDim2.new(1, 0, 0, 26) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local tw = Utils.Tween(listBox, 0.18, { Size = UDim2.new(0, 125, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				tw.Completed:Connect(function()
					if not isOpen and listBox and listBox.Parent then
						listBox.Visible = false
					end
				end)
			end
		end

		local function updateMultiColors()
			for _, item in ipairs(optionButtons) do
				if item.Btn and item.Btn.Parent then
					local active = selectedMap[item.Opt] == true
					local targetBg = active and themeManager.Current.KnobOn or themeManager.Current.ElementBg
					themeManager:TweenProperty(item.Btn, "BackgroundColor3", targetBg)
					themeManager:TweenProperty(item.Btn, "TextColor3", themeManager.Current.Text)
				end
			end
		end

		local function rebuildMulti()
			for _, child in ipairs(listBox:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			optionButtons = {}

			for _, opt in ipairs(options) do
				local active = selectedMap[opt] == true
				local optBtn = Utils.Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundColor3 = active and themeManager.Current.KnobOn or themeManager.Current.ElementBg,
					Font = Enum.Font.GothamMedium,
					Text = tostring(opt),
					TextSize = 11,
					TextColor3 = themeManager.Current.Text,
					AutoButtonColor = false,
					ZIndex = 13
				}, listBox)
				Utils.AddCorner(optBtn, 6)

				table.insert(optionButtons, { Btn = optBtn, Opt = opt })

				optBtn.MouseButton1Click:Connect(function()
					selectedMap[opt] = not selectedMap[opt]
					local nowActive = selectedMap[opt] == true
					dropText.Text = formatHeaderText()
					Utils.Tween(optBtn, 0.15, {
						BackgroundColor3 = nowActive and themeManager.Current.KnobOn or themeManager.Current.ElementBg
					})
					callback(getSelectedArray(), selectedMap)
				end)
			end
		end

		rebuildMulti()
		themeManager:OnChanged(function()
			updateMultiColors()
		end)

		dropBtn.MouseButton1Click:Connect(function()
			setDropdownOpen(not isOpen)
		end)

		return {
			Get = getSelectedArray,
			GetMap = function() return selectedMap end
		}
	end

	-- 6. Text
	function api:AddText(textStr)
		local box = Utils.Create("Frame", {
			Name = "TextBlock",
			Size = UDim2.new(1, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = themeManager.Current.ElementBg,
			ZIndex = 9
		}, columnContainer)
		Utils.AddCorner(box, 8)
		themeManager:Bind(box, "BackgroundColor3", "ElementBg")

		Utils.Create("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}, box)

		local label = Utils.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = textStr or "",
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = themeManager.Current.Text,
			ZIndex = 10
		}, box)
		themeManager:Bind(label, "TextColor3", "Text")

		return {
			SetText = function(_, newText)
				label.Text = newText
			end
		}
	end

	-- 7. Keybind
	function api:AddKeybind(config)
		config = config or {}
		local currentKey = config.Default or Enum.KeyCode.RightShift
		local callback = config.Callback or function() end
		local listening = false
		local dotsSession = 0
		local breathTween = nil

		local row = Utils.Create("Frame", {
			Name = "KeybindRow_" .. (config.Name or "Bind"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, config.Name or "Бинд", config.Tip, 84)

		local bindBtn = Utils.Create("TextButton", {
			Size = UDim2.new(0, 80, 0, 24),
			Position = UDim2.new(0, 90, 0, 1),
			BackgroundColor3 = themeManager.Current.ElementBg,
			Font = Enum.Font.GothamBold,
			Text = currentKey.Name,
			TextSize = 11,
			TextColor3 = themeManager.Current.Text,
			AutoButtonColor = false,
			ZIndex = 10
		}, row)
		Utils.AddCorner(bindBtn, 8)
		themeManager:Bind(bindBtn, "BackgroundColor3", "ElementBg")
		themeManager:Bind(bindBtn, "TextColor3", "Text")

		local bindStroke = Utils.Create("UIStroke", {
			Color = themeManager.Current.Accent,
			Thickness = 1.5,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, bindBtn)
		themeManager:Bind(bindStroke, "Color", "Accent")

		bindBtn.MouseButton1Click:Connect(function()
			if listening then return end
			listening = true
			dotsSession = dotsSession + 1
			local mySession = dotsSession

			Utils.Tween(bindBtn, 0.14, { BackgroundColor3 = themeManager.Current.KnobOn })
			if not breathTween then
				breathTween = startBreathing(bindStroke, "Transparency", 0.15, 0.8)
			end

			task.spawn(function()
				local frames = { ".", "..", "..." }
				local idx = 1
				while listening and dotsSession == mySession do
					bindBtn.Text = frames[idx]
					idx = (idx % #frames) + 1
					task.wait(0.28)
				end
			end)
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if listening then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					dotsSession = dotsSession + 1
					currentKey = input.KeyCode
					bindBtn.Text = currentKey.Name

					if breathTween then
						breathTween:Cancel()
						breathTween = nil
					end
					Utils.Tween(bindStroke, 0.15, { Transparency = 1 })
					Utils.Tween(bindBtn, 0.14, { BackgroundColor3 = themeManager.Current.ElementBg })
				end
			elseif not gameProcessed and input.KeyCode == currentKey then
				callback(currentKey)
			end
		end)

		return {
			Get = function() return currentKey end
		}
	end

	-- 8. TextBox
	function api:AddTextBox(config)
		config = config or {}
		local callback = config.Callback or function() end

		local row = Utils.Create("Frame", {
			Name = "TextBoxRow_" .. (config.Name or "Input"),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, config.Name or "Ввод", config.Tip, 84)

		local inputBox = Utils.Create("TextBox", {
			Size = UDim2.new(0, 125, 0, 24),
			Position = UDim2.new(0, 90, 0, 1),
			BackgroundColor3 = themeManager.Current.TrackBg,
			Font = Enum.Font.GothamMedium,
			PlaceholderText = config.Placeholder or "Значение...",
			PlaceholderColor3 = Color3.fromRGB(135, 135, 135),
			Text = config.Default or "",
			TextSize = 11,
			TextColor3 = themeManager.Current.Text,
			ClearTextOnFocus = false,
			ZIndex = 10
		}, row)
		Utils.AddCorner(inputBox, 8)
		themeManager:Bind(inputBox, "BackgroundColor3", "TrackBg")
		themeManager:Bind(inputBox, "TextColor3", "Text")

		local stroke = Utils.Create("UIStroke", {
			Color = themeManager.Current.Accent,
			Thickness = 1.5,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, inputBox)
		themeManager:Bind(stroke, "Color", "Accent")

		inputBox.Focused:Connect(function()
			Utils.Tween(stroke, 0.16, { Transparency = 0 })
		end)

		inputBox.FocusLost:Connect(function(enterPressed)
			Utils.Tween(stroke, 0.16, { Transparency = 1 })
			callback(inputBox.Text, enterPressed)
		end)

		return {
			Get = function() return inputBox.Text end,
			Set = function(_, txt) inputBox.Text = txt end
		}
	end

	-- 9. ThemePicker (с плавной подсветкой активного кружка темы)
	function api:AddThemePicker(labelTextStr, tipText)
		local row = Utils.Create("Frame", {
			Name = "ThemePickerRow",
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			ZIndex = 9
		}, columnContainer)

		createHeaderLabel(row, labelTextStr or "Тема", tipText, 64)

		local swatchStrokes = {}

		local function syncActiveSwatch(activeName)
			for key, stroke in pairs(swatchStrokes) do
				local isActive = (key == activeName)
				Utils.Tween(stroke, 0.25, {
					Transparency = isActive and 0 or 1,
					Thickness = isActive and 2 or 1
				})
			end
		end

		for idx, themeKey in ipairs(Themes.Order) do
			local preset = Themes.Presets[themeKey]
			local xPos = 70 + (idx - 1) * 30

			local swatchHolder = Utils.Create("Frame", {
				Size = UDim2.new(0, 26, 0, 26),
				Position = UDim2.new(0, xPos, 0, 0),
				BackgroundTransparency = 1,
				ZIndex = 9
			}, row)

			local swatchScale = Utils.Create("UIScale", { Scale = 1 }, swatchHolder)

			if preset.PreviewAccent then
				local accentShadow = Utils.Create("Frame", {
					Size = UDim2.new(0, 26, 0, 26),
					Position = UDim2.new(0, 0, 0, 1),
					BackgroundColor3 = preset.PreviewAccent,
					ZIndex = 9
				}, swatchHolder)
				Utils.AddCorner(accentShadow, 8)
			end

			local btn = Utils.Create("TextButton", {
				Size = UDim2.new(0, 26, 0, 25),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = preset.Preview,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 10
			}, swatchHolder)
			Utils.AddCorner(btn, 8)

			local activeStroke = Utils.Create("UIStroke", {
				Color = preset.PreviewAccent or themeManager.Current.Accent,
				Thickness = (themeManager.Current.Name == themeKey) and 2 or 1,
				Transparency = (themeManager.Current.Name == themeKey) and 0 or 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}, btn)
			if not preset.PreviewAccent then
				themeManager:Bind(activeStroke, "Color", "Accent")
			end
			swatchStrokes[themeKey] = activeStroke

			btn.MouseEnter:Connect(function()
				Utils.Tween(swatchScale, 0.14, { Scale = 1.08 })
			end)

			btn.MouseLeave:Connect(function()
				Utils.Tween(swatchScale, 0.14, { Scale = 1 })
			end)

			btn.MouseButton1Click:Connect(function()
				Utils.Tween(swatchScale, 0.08, { Scale = 0.9 })
				task.delay(0.08, function()
					if swatchHolder and swatchHolder.Parent then
						Utils.Tween(swatchScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
					end
				end)
				themeManager:SetTheme(themeKey)
			end)
		end

		themeManager:OnChanged(function(target)
			syncActiveSwatch(target.Name)
		end)
	end

	return api
end

_G.PrismUI.Elements = Elements