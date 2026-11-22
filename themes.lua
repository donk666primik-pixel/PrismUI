_G.PrismUI = _G.PrismUI or {}
local TweenService = game:GetService("TweenService")
local Themes = {}

Themes.Presets = {
	Dark = {
		Name = "Dark",
		Preview = Color3.fromRGB(36, 36, 36),
		PreviewAccent = nil,
		MainBg = Color3.fromRGB(36, 36, 36),
		TopBar = Color3.fromRGB(26, 26, 26),
		TabBg = Color3.fromRGB(46, 46, 46),
		ColumnBg = Color3.fromRGB(28, 28, 28),
		ElementBg = Color3.fromRGB(48, 48, 48),
		TrackBg = Color3.fromRGB(64, 64, 64),
		KnobOff = Color3.fromRGB(172, 104, 104),
		KnobOn = Color3.fromRGB(104, 185, 128),
		SliderKnob = Color3.fromRGB(198, 198, 198),
		Text = Color3.fromRGB(245, 245, 245),
		Accent = Color3.fromRGB(255, 255, 255),
		ScrollTrack = Color3.fromRGB(45, 45, 45),
		ScrollThumb = Color3.fromRGB(95, 95, 95),
		DockSlot = Color3.fromRGB(52, 52, 52)
	},
	Light = {
		Name = "Light",
		Preview = Color3.fromRGB(214, 214, 214),
		PreviewAccent = nil,
		MainBg = Color3.fromRGB(214, 214, 214),
		TopBar = Color3.fromRGB(182, 182, 182),
		TabBg = Color3.fromRGB(205, 205, 205),
		ColumnBg = Color3.fromRGB(182, 182, 182),
		ElementBg = Color3.fromRGB(214, 214, 214),
		TrackBg = Color3.fromRGB(162, 162, 162),
		KnobOff = Color3.fromRGB(172, 104, 104),
		KnobOn = Color3.fromRGB(98, 178, 118),
		SliderKnob = Color3.fromRGB(198, 198, 198),
		Text = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(255, 255, 255),
		ScrollTrack = Color3.fromRGB(165, 165, 165),
		ScrollThumb = Color3.fromRGB(194, 194, 194),
		DockSlot = Color3.fromRGB(255, 255, 255)
	},
	LightPurple = {
		Name = "LightPurple",
		Preview = Color3.fromRGB(214, 214, 214),
		PreviewAccent = Color3.fromRGB(98, 92, 186),
		MainBg = Color3.fromRGB(214, 214, 214),
		TopBar = Color3.fromRGB(182, 182, 182),
		TabBg = Color3.fromRGB(205, 205, 205),
		ColumnBg = Color3.fromRGB(182, 182, 182),
		ElementBg = Color3.fromRGB(214, 214, 214),
		TrackBg = Color3.fromRGB(162, 162, 162),
		KnobOff = Color3.fromRGB(172, 104, 104),
		KnobOn = Color3.fromRGB(98, 92, 186),
		SliderKnob = Color3.fromRGB(130, 124, 220),
		Text = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(98, 92, 186),
		ScrollTrack = Color3.fromRGB(165, 165, 165),
		ScrollThumb = Color3.fromRGB(115, 108, 210),
		DockSlot = Color3.fromRGB(255, 255, 255)
	},
	DarkPurple = {
		Name = "DarkPurple",
		Preview = Color3.fromRGB(36, 36, 36),
		PreviewAccent = Color3.fromRGB(98, 92, 186),
		MainBg = Color3.fromRGB(30, 30, 36),
		TopBar = Color3.fromRGB(22, 22, 28),
		TabBg = Color3.fromRGB(40, 40, 48),
		ColumnBg = Color3.fromRGB(25, 25, 31),
		ElementBg = Color3.fromRGB(44, 44, 54),
		TrackBg = Color3.fromRGB(60, 60, 74),
		KnobOff = Color3.fromRGB(172, 104, 104),
		KnobOn = Color3.fromRGB(115, 108, 224),
		SliderKnob = Color3.fromRGB(135, 128, 240),
		Text = Color3.fromRGB(245, 245, 255),
		Accent = Color3.fromRGB(125, 118, 245),
		ScrollTrack = Color3.fromRGB(42, 42, 52),
		ScrollThumb = Color3.fromRGB(115, 108, 224),
		DockSlot = Color3.fromRGB(46, 46, 56)
	}
}

Themes.Order = { "Dark", "Light", "LightPurple", "DarkPurple" }
local TWEEN_INFO = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Themes.new(initialThemeName)
	local self = {
		Current = Themes.Presets[initialThemeName] or Themes.Presets.Light,
		Bindings = {},
		Listeners = {},
		ActiveTweens = {}
	}

	function self:TweenProperty(instance, property, targetColor)
		if not instance or not instance.Parent or not targetColor then return end
		if not self.ActiveTweens[instance] then
			self.ActiveTweens[instance] = {}
		end
		local prevTween = self.ActiveTweens[instance][property]
		if prevTween then
			prevTween:Cancel()
		end
		local tw = TweenService:Create(instance, TWEEN_INFO, { [property] = targetColor })
		self.ActiveTweens[instance][property] = tw
		tw:Play()
	end

	function self:Bind(instance, property, themeKey)
		instance[property] = self.Current[themeKey]
		table.insert(self.Bindings, {
			Instance = instance,
			Property = property,
			Key = themeKey
		})
	end

	function self:OnChanged(fn)
		table.insert(self.Listeners, fn)
	end

	function self:SetTheme(themeName)
		local target = Themes.Presets[themeName]
		if not target or self.Current == target then return end
		self.Current = target

		for i = #self.Bindings, 1, -1 do
			local b = self.Bindings[i]
			if b.Instance and b.Instance.Parent then
				self:TweenProperty(b.Instance, b.Property, target[b.Key])
			else
				self.ActiveTweens[b.Instance] = nil
				table.remove(self.Bindings, i)
			end
		end

		for _, fn in ipairs(self.Listeners) do
			task.spawn(fn, target, self)
		end
	end

	return self
end

_G.PrismUI.Themes = Themes