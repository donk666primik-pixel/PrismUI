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
	},
	Neverlose = {
		Name = "Neverlose",
		Preview = Color3.fromRGB(16, 24, 38),
		PreviewAccent = Color3.fromRGB(0, 175, 255),
		MainBg = Color3.fromRGB(14, 21, 34),
		TopBar = Color3.fromRGB(10, 15, 25),
		TabBg = Color3.fromRGB(20, 31, 50),
		ColumnBg = Color3.fromRGB(11, 17, 28),
		ElementBg = Color3.fromRGB(22, 34, 54),
		TrackBg = Color3.fromRGB(32, 49, 76),
		KnobOff = Color3.fromRGB(168, 72, 84),
		KnobOn = Color3.fromRGB(0, 175, 255),
		SliderKnob = Color3.fromRGB(45, 195, 255),
		Text = Color3.fromRGB(238, 246, 255),
		Accent = Color3.fromRGB(0, 175, 255),
		ScrollTrack = Color3.fromRGB(18, 27, 44),
		ScrollThumb = Color3.fromRGB(0, 155, 230),
		DockSlot = Color3.fromRGB(24, 37, 58)
	},
	Fatality = {
		Name = "Fatality",
		Preview = Color3.fromRGB(28, 20, 36),
		PreviewAccent = Color3.fromRGB(235, 45, 105),
		MainBg = Color3.fromRGB(26, 18, 34),
		TopBar = Color3.fromRGB(19, 13, 25),
		TabBg = Color3.fromRGB(38, 26, 48),
		ColumnBg = Color3.fromRGB(21, 15, 28),
		ElementBg = Color3.fromRGB(42, 29, 54),
		TrackBg = Color3.fromRGB(58, 40, 74),
		KnobOff = Color3.fromRGB(140, 65, 85),
		KnobOn = Color3.fromRGB(235, 45, 105),
		SliderKnob = Color3.fromRGB(250, 75, 130),
		Text = Color3.fromRGB(250, 240, 248),
		Accent = Color3.fromRGB(235, 45, 105),
		ScrollTrack = Color3.fromRGB(34, 23, 44),
		ScrollThumb = Color3.fromRGB(215, 40, 95),
		DockSlot = Color3.fromRGB(44, 30, 56)
	},
	Skeet = {
		Name = "Skeet",
		Preview = Color3.fromRGB(22, 24, 22),
		PreviewAccent = Color3.fromRGB(154, 214, 48),
		MainBg = Color3.fromRGB(22, 24, 22),
		TopBar = Color3.fromRGB(15, 17, 15),
		TabBg = Color3.fromRGB(32, 35, 32),
		ColumnBg = Color3.fromRGB(18, 20, 18),
		ElementBg = Color3.fromRGB(35, 38, 35),
		TrackBg = Color3.fromRGB(48, 52, 48),
		KnobOff = Color3.fromRGB(165, 82, 82),
		KnobOn = Color3.fromRGB(154, 214, 48),
		SliderKnob = Color3.fromRGB(172, 230, 68),
		Text = Color3.fromRGB(240, 245, 238),
		Accent = Color3.fromRGB(154, 214, 48),
		ScrollTrack = Color3.fromRGB(28, 31, 28),
		ScrollThumb = Color3.fromRGB(138, 194, 42),
		DockSlot = Color3.fromRGB(36, 40, 36)
	},
	Nord = {
		Name = "Nord",
		Preview = Color3.fromRGB(46, 52, 64),
		PreviewAccent = Color3.fromRGB(136, 192, 208),
		MainBg = Color3.fromRGB(46, 52, 64),
		TopBar = Color3.fromRGB(36, 41, 51),
		TabBg = Color3.fromRGB(59, 66, 82),
		ColumnBg = Color3.fromRGB(40, 45, 56),
		ElementBg = Color3.fromRGB(67, 76, 94),
		TrackBg = Color3.fromRGB(76, 86, 106),
		KnobOff = Color3.fromRGB(191, 97, 106),
		KnobOn = Color3.fromRGB(136, 192, 208),
		SliderKnob = Color3.fromRGB(143, 188, 187),
		Text = Color3.fromRGB(236, 239, 244),
		Accent = Color3.fromRGB(136, 192, 208),
		ScrollTrack = Color3.fromRGB(52, 59, 73),
		ScrollThumb = Color3.fromRGB(129, 161, 193),
		DockSlot = Color3.fromRGB(67, 76, 94)
	},
	Dracula = {
		Name = "Dracula",
		Preview = Color3.fromRGB(40, 42, 54),
		PreviewAccent = Color3.fromRGB(255, 121, 198),
		MainBg = Color3.fromRGB(40, 42, 54),
		TopBar = Color3.fromRGB(30, 32, 42),
		TabBg = Color3.fromRGB(52, 55, 70),
		ColumnBg = Color3.fromRGB(34, 36, 47),
		ElementBg = Color3.fromRGB(58, 61, 78),
		TrackBg = Color3.fromRGB(68, 71, 90),
		KnobOff = Color3.fromRGB(255, 85, 85),
		KnobOn = Color3.fromRGB(255, 121, 198),
		SliderKnob = Color3.fromRGB(189, 147, 249),
		Text = Color3.fromRGB(248, 248, 242),
		Accent = Color3.fromRGB(255, 121, 198),
		ScrollTrack = Color3.fromRGB(46, 49, 63),
		ScrollThumb = Color3.fromRGB(189, 147, 249),
		DockSlot = Color3.fromRGB(58, 61, 78)
	},
	Crimson = {
		Name = "Crimson",
		Preview = Color3.fromRGB(28, 18, 18),
		PreviewAccent = Color3.fromRGB(220, 52, 52),
		MainBg = Color3.fromRGB(28, 18, 18),
		TopBar = Color3.fromRGB(20, 12, 12),
		TabBg = Color3.fromRGB(42, 26, 26),
		ColumnBg = Color3.fromRGB(23, 14, 14),
		ElementBg = Color3.fromRGB(46, 28, 28),
		TrackBg = Color3.fromRGB(64, 38, 38),
		KnobOff = Color3.fromRGB(120, 62, 62),
		KnobOn = Color3.fromRGB(220, 52, 52),
		SliderKnob = Color3.fromRGB(240, 78, 78),
		Text = Color3.fromRGB(252, 238, 238),
		Accent = Color3.fromRGB(220, 52, 52),
		ScrollTrack = Color3.fromRGB(36, 22, 22),
		ScrollThumb = Color3.fromRGB(200, 48, 48),
		DockSlot = Color3.fromRGB(48, 30, 30)
	},
	Amber = {
		Name = "Amber",
		Preview = Color3.fromRGB(30, 26, 20),
		PreviewAccent = Color3.fromRGB(245, 166, 35),
		MainBg = Color3.fromRGB(30, 26, 20),
		TopBar = Color3.fromRGB(22, 19, 14),
		TabBg = Color3.fromRGB(44, 38, 29),
		ColumnBg = Color3.fromRGB(25, 21, 16),
		ElementBg = Color3.fromRGB(48, 41, 31),
		TrackBg = Color3.fromRGB(66, 56, 42),
		KnobOff = Color3.fromRGB(168, 86, 74),
		KnobOn = Color3.fromRGB(245, 166, 35),
		SliderKnob = Color3.fromRGB(255, 185, 65),
		Text = Color3.fromRGB(252, 246, 235),
		Accent = Color3.fromRGB(245, 166, 35),
		ScrollTrack = Color3.fromRGB(38, 33, 25),
		ScrollThumb = Color3.fromRGB(225, 150, 30),
		DockSlot = Color3.fromRGB(50, 43, 33)
	},
	Emerald = {
		Name = "Emerald",
		Preview = Color3.fromRGB(18, 29, 24),
		PreviewAccent = Color3.fromRGB(46, 204, 113),
		MainBg = Color3.fromRGB(18, 29, 24),
		TopBar = Color3.fromRGB(13, 21, 17),
		TabBg = Color3.fromRGB(26, 43, 35),
		ColumnBg = Color3.fromRGB(15, 24, 20),
		ElementBg = Color3.fromRGB(29, 48, 39),
		TrackBg = Color3.fromRGB(40, 66, 54),
		KnobOff = Color3.fromRGB(172, 82, 82),
		KnobOn = Color3.fromRGB(46, 204, 113),
		SliderKnob = Color3.fromRGB(72, 224, 136),
		Text = Color3.fromRGB(236, 252, 243),
		Accent = Color3.fromRGB(46, 204, 113),
		ScrollTrack = Color3.fromRGB(22, 36, 30),
		ScrollThumb = Color3.fromRGB(40, 185, 102),
		DockSlot = Color3.fromRGB(31, 52, 42)
	}
}

Themes.Order = {
	"Dark",
	"Light",
	"LightPurple",
	"DarkPurple",
	"Neverlose",
	"Fatality",
	"Skeet",
	"Nord",
	"Dracula",
	"Crimson",
	"Amber",
	"Emerald"
}

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