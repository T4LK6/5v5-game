--!strict
-- SETTINGS: fake options menu. Sliders drag, toggles flip and selectors
-- cycle, but nothing is applied or saved.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

type Setting = {
	Label: string,
	Hint: string,
	Kind: "slider" | "toggle" | "option",
	Value: any,
	Min: number?,
	Max: number?,
	Decimals: number?,
	Suffix: string?,
	Options: { string }?,
}
type Category = { Name: string, Icon: string, Settings: { Setting } }

local CATEGORIES: { Category } = {
	{ Name = "Audio", Icon = "support", Settings = {
		{ Label = "Master Volume", Hint = "Overall game loudness", Kind = "slider", Value = 80, Min = 0, Max = 100, Suffix = "%" },
		{ Label = "Music", Hint = "Menu and match soundtrack", Kind = "slider", Value = 55, Min = 0, Max = 100, Suffix = "%" },
		{ Label = "Effects", Hint = "Weapons, footsteps and abilities", Kind = "slider", Value = 90, Min = 0, Max = 100, Suffix = "%" },
		{ Label = "Voice Chat", Hint = "Hear your squad over voice", Kind = "toggle", Value = true },
		{ Label = "Push to Talk", Hint = "Hold V to transmit", Kind = "toggle", Value = false },
		{ Label = "Output Mix", Hint = "Tuned for your audio device", Kind = "option", Value = 2, Options = { "Speakers", "Headphones", "Night Mode" } },
	} },
	{ Name = "Graphics", Icon = "star", Settings = {
		{ Label = "Quality Preset", Hint = "Overall visual fidelity", Kind = "option", Value = 3, Options = { "Low", "Medium", "High", "Ultra" } },
		{ Label = "Field of View", Hint = "Horizontal viewing angle", Kind = "slider", Value = 90, Min = 70, Max = 110, Suffix = "°" },
		{ Label = "Shadows", Hint = "Dynamic shadow quality", Kind = "option", Value = 2, Options = { "Off", "Soft", "Ultra" } },
		{ Label = "Bloom", Hint = "Glow on lights and neon", Kind = "toggle", Value = true },
		{ Label = "Motion Blur", Hint = "Blur during fast camera moves", Kind = "toggle", Value = false },
		{ Label = "Frame Limit", Hint = "Cap rendering frame rate", Kind = "option", Value = 3, Options = { "60", "120", "144", "Unlimited" } },
	} },
	{ Name = "Controls", Icon = "assault", Settings = {
		{ Label = "Mouse Sensitivity", Hint = "Look speed when hip-firing", Kind = "slider", Value = 1.8, Min = 0.1, Max = 5, Decimals = 1, Suffix = "" },
		{ Label = "Aim Sensitivity", Hint = "Multiplier while aiming down sights", Kind = "slider", Value = 0.8, Min = 0.1, Max = 2, Decimals = 2, Suffix = "x" },
		{ Label = "Invert Y Axis", Hint = "Flip vertical look", Kind = "toggle", Value = false },
		{ Label = "Toggle Aim", Hint = "Click to aim instead of hold", Kind = "toggle", Value = false },
		{ Label = "Sprint", Hint = "How sprint input behaves", Kind = "option", Value = 1, Options = { "Hold", "Toggle", "Auto" } },
		{ Label = "Controller Vibration", Hint = "Haptic feedback on gamepads", Kind = "toggle", Value = true },
	} },
	{ Name = "Interface", Icon = "scout", Settings = {
		{ Label = "HUD Scale", Hint = "Size of in-match interface", Kind = "slider", Value = 100, Min = 70, Max = 130, Suffix = "%" },
		{ Label = "Crosshair", Hint = "Reticle style", Kind = "option", Value = 2, Options = { "Dot", "Cross", "Circle", "Chevron" } },
		{ Label = "Crosshair Color", Hint = "Reticle tint", Kind = "option", Value = 1, Options = { "Cyan", "Green", "Yellow", "Magenta" } },
		{ Label = "Damage Numbers", Hint = "Show hit values on enemies", Kind = "toggle", Value = true },
		{ Label = "Show FPS", Hint = "Performance counter in corner", Kind = "toggle", Value = false },
		{ Label = "Minimap", Hint = "Minimap orientation", Kind = "option", Value = 1, Options = { "Rotate", "Fixed" } },
	} },
	{ Name = "Accessibility", Icon = "defender", Settings = {
		{ Label = "Colorblind Mode", Hint = "Adjusts team and UI colors", Kind = "option", Value = 1, Options = { "Off", "Protanopia", "Deuteranopia", "Tritanopia" } },
		{ Label = "Subtitles", Hint = "Captions for dialogue and callouts", Kind = "toggle", Value = true },
		{ Label = "Text Size", Hint = "Menu and subtitle text scale", Kind = "slider", Value = 100, Min = 80, Max = 150, Suffix = "%" },
		{ Label = "Reduce Motion", Hint = "Calmer menu and camera animation", Kind = "toggle", Value = false },
		{ Label = "Screen Shake", Hint = "Intensity of camera shake", Kind = "slider", Value = 60, Min = 0, Max = 100, Suffix = "%" },
		{ Label = "Visual Sound Cues", Hint = "Show footsteps and gunfire on HUD", Kind = "toggle", Value = false },
	} },
}

local CONTROL_X = -460 -- controls are right-aligned inside each row

local function formatValue(setting: Setting, value: number): string
	local decimals = setting.Decimals or 0
	return string.format("%." .. decimals .. "f", value) .. (setting.Suffix or "")
end

local function slider(row: Frame, setting: Setting)
	local min, max = setting.Min or 0, setting.Max or 100
	local track: TextButton = UI.new("TextButton", {
		Text = "",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, CONTROL_X, 0.5, 0),
		Size = UDim2.fromOffset(320, 26),
		BackgroundTransparency = 1,
		Parent = row,
	})
	local bar = UI.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = C.Void,
		BackgroundTransparency = 0.1,
		Parent = track,
	}, { UI.corner(3) })
	local fill = UI.new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = bar,
	}, { UI.corner(3), UI.gradient({ C.CyanDeep, C.Cyan }, 0) })
	local knob = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = C.Text,
		Parent = track,
	}, { UI.corner(9), UI.stroke(C.Cyan, 0, 3) })
	local knobScale = UI.new("UIScale", { Parent = knob })
	local valueLabel = UI.text({
		Text = "",
		Font = F.Heavy,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -24, 0.5, 0),
		Size = UDim2.fromOffset(90, 20),
		Parent = row,
	})

	local function set(alpha: number)
		alpha = math.clamp(alpha, 0, 1)
		local value = min + (max - min) * alpha
		setting.Value = value
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = formatValue(setting, value)
	end
	set(((setting.Value :: number) - min) / (max - min))

	local dragging = false
	local function fromInput(x: number)
		set((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UI.tween(knobScale, 0.15, { Scale = 1.3 })
			fromInput(input.Position.X)
		end
	end)
	local moved = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input.Position.X)
		end
	end)
	local released = UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			UI.tween(knobScale, 0.2, { Scale = 1 })
		end
	end)
	-- Rows are rebuilt on category switch; drop the global listeners with them.
	track.Destroying:Connect(function()
		moved:Disconnect()
		released:Disconnect()
	end)
end

local function toggle(row: Frame, setting: Setting)
	local pill: TextButton = UI.new("TextButton", {
		Text = "",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -24, 0.5, 0),
		Size = UDim2.fromOffset(60, 32),
		BackgroundColor3 = C.PanelHover,
		Parent = row,
	}, { UI.corner(16) })
	local stroke = UI.stroke(C.Line, 0.8)
	stroke.Parent = pill
	local knob = UI.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = C.TextDim,
		Parent = pill,
	}, { UI.corner(12) })
	local stateLabel = UI.text({
		Text = "",
		Font = F.Heavy,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -96, 0.5, 0),
		Size = UDim2.fromOffset(60, 20),
		Parent = row,
	})

	local function paint(animate: boolean)
		local on = setting.Value == true
		local t = if animate then 0.22 else 0
		UI.tween(knob, t, {
			Position = if on then UDim2.new(1, -28, 0.5, 0) else UDim2.new(0, 4, 0.5, 0),
			BackgroundColor3 = if on then C.Void else C.TextDim,
		}, Enum.EasingStyle.Back)
		UI.tween(pill, t, { BackgroundColor3 = if on then C.Cyan else C.PanelHover })
		UI.tween(stroke, t, { Transparency = if on then 1 else 0.8 })
		stateLabel.Text = if on then "ON" else "OFF"
		stateLabel.TextColor3 = if on then C.Cyan else C.TextFaint
	end
	paint(false)
	pill.Activated:Connect(function()
		setting.Value = not setting.Value
		paint(true)
	end)
end

local function option(row: Frame, setting: Setting)
	local options = setting.Options or { "-" }
	local holder = UI.new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -24, 0.5, 0),
		Size = UDim2.fromOffset(300, 44),
		BackgroundColor3 = C.Void,
		BackgroundTransparency = 0.4,
		Parent = row,
	}, { UI.corner(10), UI.stroke(C.Line, 0.88) })
	local label = UI.text({
		Text = "",
		Font = F.Heavy,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(44, 4),
		Size = UDim2.new(1, -88, 0, 26),
		Parent = holder,
	})
	local pips = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -7),
		Size = UDim2.fromOffset(#options * 22, 3),
		BackgroundTransparency = 1,
		Parent = holder,
	}, { UI.list(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center) })
	local pipFrames: { Frame } = {}
	for k = 1, #options do
		pipFrames[k] = UI.new("Frame", {
			LayoutOrder = k,
			Size = UDim2.fromOffset(18, 3),
			BackgroundColor3 = C.PanelHover,
			Parent = pips,
		}, { UI.corner(2) })
	end

	local function paint(dir: number)
		local index = setting.Value :: number
		label.Text = options[index]
		if dir ~= 0 then
			label.Position = UDim2.fromOffset(44 + dir * 14, 4)
			UI.tween(label, 0.25, { Position = UDim2.fromOffset(44, 4) })
		end
		for k, pip in pipFrames do
			UI.tween(pip, 0.2, { BackgroundColor3 = if k == index then C.Cyan else C.PanelHover })
		end
	end
	paint(0)

	for _, dir in { -1, 1 } do
		local arrow: TextButton = UI.new("TextButton", {
			Text = if dir < 0 then "<" else ">",
			Font = F.Heavy,
			TextSize = 18,
			TextColor3 = C.Cyan,
			AnchorPoint = Vector2.new(if dir < 0 then 0 else 1, 0.5),
			Position = UDim2.new(if dir < 0 then 0 else 1, if dir < 0 then 4 else -4, 0.5, 0),
			Size = UDim2.fromOffset(36, 36),
			BackgroundColor3 = C.PanelRaised,
			BackgroundTransparency = 0.4,
			Parent = holder,
		}, { UI.corner(8) })
		UI.hover(arrow)
		arrow.Activated:Connect(function()
			setting.Value = ((setting.Value :: number) - 1 + dir) % #options + 1
			paint(dir)
		end)
	end
end

return function(content: Frame, ctx: Types.Ctx)
	local categoryIndex = 1

	UI.stagger(UI.text({
		Text = "SETTINGS",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(400, 42),
		Parent = content,
	}), 0)
	UI.stagger(UI.text({
		Text = "PREVIEW BUILD  ·  CHANGES ARE NOT SAVED",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(600, 18),
		Parent = content,
	}), 0)

	local nav = UI.panel({
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(300, 640),
		Parent = content,
	}, 16)
	UI.stagger(nav, 1)
	local navList = UI.new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = nav,
	}, { UI.list(Enum.FillDirection.Vertical, 6), UI.padding(14) })

	local panel = UI.panel({
		Position = UDim2.fromOffset(320, 96),
		Size = UDim2.fromOffset(1280, 640),
		ClipsDescendants = true,
		Parent = content,
	}, 16)
	UI.stagger(panel, 2)
	local panelTitle = UI.text({
		Text = "",
		Font = F.Display,
		TextSize = 22,
		Position = UDim2.fromOffset(32, 24),
		Size = UDim2.fromOffset(600, 30),
		Parent = panel,
	})
	local rows = UI.new("Frame", {
		Position = UDim2.fromOffset(20, 76),
		Size = UDim2.new(1, -40, 1, -160),
		BackgroundTransparency = 1,
		Parent = panel,
	})

	-- Footer actions.
	local reset = UI.button({
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -252, 1, -24),
		Size = UDim2.fromOffset(200, 48),
		TextSize = 14,
		Parent = panel,
	}, "ghost", "RESET TO DEFAULT")
	reset.Activated:Connect(function()
		ctx.toast("Defaults restored", "Preview only — nothing was changed.")
	end)
	local apply = UI.button({
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -32, 1, -24),
		Size = UDim2.fromOffset(200, 48),
		TextSize = 15,
		Parent = panel,
	}, "primary", "APPLY")
	apply.Activated:Connect(function()
		ctx.toast("Settings applied", "Not persisted in this prototype.", C.Green)
	end)

	type NavRef = { button: TextButton, bar: Frame, label: TextLabel }
	local navButtons: { NavRef } = {}

	local function renderRows()
		rows:ClearAllChildren()
		local category = CATEGORIES[categoryIndex]
		panelTitle.Text = string.upper(category.Name)

		local list = UI.new("Frame", {
			Position = UDim2.fromOffset(40, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = rows,
		}, { UI.list(Enum.FillDirection.Vertical, 6) })
		UI.tween(list, 0.4, { Position = UDim2.fromOffset(0, 0) })

		for k, setting in category.Settings do
			local row: Frame = UI.new("Frame", {
				LayoutOrder = k,
				Size = UDim2.new(1, 0, 0, 68),
				BackgroundColor3 = C.PanelRaised,
				BackgroundTransparency = if k % 2 == 1 then 0.55 else 1,
				Parent = list,
			}, { UI.corner(10) })
			UI.text({
				Text = setting.Label,
				Font = F.Heavy,
				TextSize = 17,
				Position = UDim2.fromOffset(20, 14),
				Size = UDim2.fromOffset(500, 20),
				Parent = row,
			})
			UI.text({
				Text = setting.Hint,
				Font = F.Medium,
				TextSize = 13,
				TextColor3 = C.TextFaint,
				Position = UDim2.fromOffset(20, 36),
				Size = UDim2.fromOffset(500, 16),
				Parent = row,
			})
			if setting.Kind == "slider" then
				slider(row, setting)
			elseif setting.Kind == "toggle" then
				toggle(row, setting)
			else
				option(row, setting)
			end
		end

		for i, ref in navButtons do
			local active = i == categoryIndex
			UI.tween(ref.button, 0.2, { BackgroundTransparency = if active then 0.2 else 1 })
			UI.tween(ref.bar, 0.2, { BackgroundTransparency = if active then 0 else 1 })
			UI.tween(ref.label, 0.2, { TextColor3 = if active then C.Text else C.TextDim })
		end
	end

	for i, category in CATEGORIES do
		local button: TextButton = UI.new("TextButton", {
			Text = "",
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 56),
			BackgroundColor3 = C.PanelHover,
			BackgroundTransparency = 1,
			Parent = navList,
		}, { UI.corner(10) })
		local bar = UI.new("Frame", {
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.fromOffset(3, 28),
			BackgroundColor3 = C.Cyan,
			BackgroundTransparency = 1,
			Parent = button,
		}, { UI.corner(2) })
		Icons.draw(category.Icon, button, C.Cyan, {
			Position = UDim2.fromOffset(18, 16),
			Size = UDim2.fromOffset(24, 24),
		})
		local label = UI.text({
			Text = string.upper(category.Name),
			Font = F.Heavy,
			TextSize = 15,
			TextColor3 = C.TextDim,
			Position = UDim2.fromOffset(56, 0),
			Size = UDim2.new(1, -60, 1, 0),
			Parent = button,
		})
		button.MouseEnter:Connect(function()
			if i ~= categoryIndex then
				UI.tween(button, 0.15, { BackgroundTransparency = 0.6 })
			end
		end)
		button.MouseLeave:Connect(function()
			if i ~= categoryIndex then
				UI.tween(button, 0.15, { BackgroundTransparency = 1 })
			end
		end)
		button.Activated:Connect(function()
			categoryIndex = i
			renderRows()
		end)
		navButtons[i] = { button = button, bar = bar, label = label }
	end

	renderRows()
end
