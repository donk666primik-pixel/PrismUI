local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

_G.PrismUI = _G.PrismUI or {}
local Utils = {}

Utils.Fonts = {
	["Gotham"] = "rbxasset://fonts/families/GothamSSm.json",
	["Roboto"] = "rbxasset://fonts/families/Roboto.json"
}

Utils.FontList = {
	"Gotham",
	"Roboto"
}

Utils.CurrentFontName = "Gotham"
local RegisteredTextObjects = {}

local function getFontFace(fontName, isBold)
	local family = Utils.Fonts[fontName] or Utils.Fonts["Gotham"]
	return Font.new(
		family,
		isBold and Enum.FontWeight.Bold or Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
end

function Utils.SetFont(fontName)
	if not Utils.Fonts[fontName] then return end
	Utils.CurrentFontName = fontName

	for i = #RegisteredTextObjects, 1, -1 do
		local item = RegisteredTextObjects[i]
		if item.Instance and item.Instance.Parent then
			item.Instance.FontFace = getFontFace(fontName, item.IsBold)
		else
			table.remove(RegisteredTextObjects, i)
		end
	end
end

function Utils.Create(className, props, parent)
	local inst = Instance.new(className)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end

	local requestedFont = props and props.Font
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		local isBold = (requestedFont == Enum.Font.GothamBold)
		inst.FontFace = getFontFace(Utils.CurrentFontName, isBold)
		table.insert(RegisteredTextObjects, {
			Instance = inst,
			IsBold = isBold
		})
	end

	for k, v in pairs(props or {}) do
		if k ~= "Font" then
			inst[k] = v
		end
	end

	if parent then
		inst.Parent = parent
	end
	return inst
end

function Utils.AddCorner(parent, radius)
	return Utils.Create("UICorner", {
		CornerRadius = UDim.new(0, radius)
	}, parent)
end

function Utils.Tween(inst, duration, props, style, dir)
	local info = TweenInfo.new(
		duration or 0.18,
		style or Enum.EasingStyle.Quad,
		dir or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(inst, info, props)
	tween:Play()
	return tween
end

function Utils.MakeDraggable(dragHandle, targetFrame)
	local dragging = false
	local dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

_G.PrismUI.Utils = Utils