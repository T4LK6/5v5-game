--!strict
-- World-anchored party UI: the hero nameplate over slot 1 and the big "+"
-- invite buttons floating over the three empty pads. Billboards live in
-- PlayerGui (adorned to the pads) so they receive mouse input.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.UI)
local C = Theme.Colors
local F = Theme.Fonts

local SlotBillboards = {}

local billboards: { BillboardGui } = {}
local bobbers: { { gui: BillboardGui, base: Vector3, phase: number } } = {}
local spinners: { GuiObject } = {}

local function nameplate(anchor: BasePart, playerGui: PlayerGui)
	local player = Players.LocalPlayer
	local gui: BillboardGui = UI.new("BillboardGui", {
		Name = "HeroNameplate",
		Adornee = anchor,
		Size = UDim2.fromScale(7, 1.9),
		StudsOffsetWorldSpace = Vector3.new(0, 6.7, 0),
		LightInfluence = 0,
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		MaxDistance = 500,
		Parent = playerGui,
	})

	local row = UI.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = gui })

	-- Level hex.
	local badge = UI.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0.02, 0.42),
		Size = UDim2.fromScale(0.15, 0.55),
		BackgroundTransparency = 1,
		Parent = row,
	})
	UI.new("UIAspectRatioConstraint", { AspectRatio = 1, Parent = badge })
	UI.diamond(badge, C.Amber, 10, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.78, 0.78),
	})
	UI.text({
		Text = "42",
		Font = F.Heavy,
		TextScaled = true,
		TextColor3 = C.Void,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 0.5),
		Position = UDim2.fromScale(0, 0.25),
		Parent = badge,
	})

	UI.text({
		Text = string.upper(player.DisplayName),
		Font = F.Heavy,
		TextScaled = true,
		TextColor3 = C.Text,
		Position = UDim2.fromScale(0.2, 0.08),
		Size = UDim2.fromScale(0.8, 0.46),
		Parent = row,
	})
	local status = UI.new("Frame", {
		Position = UDim2.fromScale(0.2, 0.58),
		Size = UDim2.fromScale(0.8, 0.3),
		BackgroundTransparency = 1,
		Parent = row,
	})
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0.035, 0.45),
		BackgroundColor3 = C.Green,
		Parent = status,
	}, { UI.corner(99) })
	UI.text({
		Text = "PARTY LEADER  ·  READY",
		Font = F.Bold,
		TextScaled = true,
		TextColor3 = C.Amber,
		Position = UDim2.fromScale(0.06, 0),
		Size = UDim2.fromScale(0.94, 1),
		Parent = status,
	})

	table.insert(billboards, gui)
end

local function inviteButton(index: number, anchor: BasePart, playerGui: PlayerGui, onInvite: (number) -> ())
	local gui: BillboardGui = UI.new("BillboardGui", {
		Name = "Invite" .. index,
		Adornee = anchor,
		Size = UDim2.fromScale(3.6, 4.8),
		StudsOffsetWorldSpace = Vector3.new(0, 3.7, 0),
		LightInfluence = 0,
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		MaxDistance = 500,
		Active = true,
		Parent = playerGui,
	})

	local button: TextButton = UI.new("TextButton", {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local orb = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.37),
		Size = UDim2.fromScale(0.82, 0.62),
		BackgroundTransparency = 1,
		Parent = button,
	})
	UI.new("UIAspectRatioConstraint", { AspectRatio = 1, Parent = orb })
	local scale = UI.new("UIScale", { Parent = orb })

	-- Expanding pulse ring.
	local pulse = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = orb,
	}, { UI.corner(999) })
	local pulseStroke = UI.stroke(C.Cyan, 0, 2)
	pulseStroke.Parent = pulse

	-- Glass disc.
	local disc = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.86),
		BackgroundColor3 = Color3.fromRGB(8, 30, 52),
		BackgroundTransparency = 0.25,
		Parent = orb,
	}, { UI.corner(999) })
	UI.gradient({ Color3.fromRGB(120, 200, 255), Color3.fromRGB(30, 60, 110) }, 90).Parent = disc
	local discStroke = UI.stroke(C.Cyan, 0.05, 3)
	discStroke.Parent = disc

	-- Rotating tick ring.
	local ticks = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.08, 1.08),
		BackgroundTransparency = 1,
		Parent = orb,
	})
	for k = 0, 3 do
		local holder = UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Rotation = k * 90,
			BackgroundTransparency = 1,
			Parent = ticks,
		})
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.16, 0.03),
			BackgroundColor3 = C.Cyan,
			Parent = holder,
		}, { UI.corner(99) })
	end
	table.insert(spinners, ticks)

	-- The plus.
	local plus = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.44, 0.44),
		BackgroundTransparency = 1,
		Parent = disc,
	})
	local bars = {}
	for _, size in { UDim2.fromScale(1, 0.17), UDim2.fromScale(0.17, 1) } do
		local bar = UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = size,
			BackgroundColor3 = C.Text,
			Parent = plus,
		}, { UI.corner(99) })
		table.insert(bars, bar)
	end

	local caption = UI.text({
		Text = "INVITE",
		Font = F.Heavy,
		TextScaled = true,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromScale(0, 0.72),
		Size = UDim2.fromScale(1, 0.12),
		Parent = button,
	})
	UI.text({
		Text = string.format("SLOT %02d  ·  OPEN", index),
		Font = F.Bold,
		TextScaled = true,
		TextColor3 = C.Cyan,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromScale(0, 0.85),
		Size = UDim2.fromScale(1, 0.075),
		Parent = button,
	})

	-- Looping pulse.
	task.spawn(function()
		task.wait(index * 0.35)
		while gui.Parent do
			pulse.Size = UDim2.fromScale(0.86, 0.86)
			pulseStroke.Transparency = 0.1
			UI.tween(pulse, 1.6, { Size = UDim2.fromScale(1.35, 1.35) }, Enum.EasingStyle.Sine)
			UI.tween(pulseStroke, 1.6, { Transparency = 1 }, Enum.EasingStyle.Sine)
			task.wait(2.2)
		end
	end)

	button.MouseEnter:Connect(function()
		UI.tween(scale, 0.2, { Scale = 1.12 }, Enum.EasingStyle.Back)
		UI.tween(disc, 0.2, { BackgroundTransparency = 0.05 })
		UI.tween(discStroke, 0.2, { Color = C.Amber })
		UI.tween(caption, 0.2, { TextColor3 = C.Amber })
		for _, bar in bars do
			UI.tween(bar, 0.2, { BackgroundColor3 = C.Amber })
		end
	end)
	button.MouseLeave:Connect(function()
		UI.tween(scale, 0.25, { Scale = 1 })
		UI.tween(disc, 0.25, { BackgroundTransparency = 0.25 })
		UI.tween(discStroke, 0.25, { Color = C.Cyan })
		UI.tween(caption, 0.25, { TextColor3 = C.Text })
		for _, bar in bars do
			UI.tween(bar, 0.25, { BackgroundColor3 = C.Text })
		end
	end)
	button.MouseButton1Down:Connect(function()
		UI.tween(scale, 0.08, { Scale = 0.94 })
	end)
	button.Activated:Connect(function()
		UI.tween(scale, 0.3, { Scale = 1.12 }, Enum.EasingStyle.Back)
		onInvite(index)
	end)

	table.insert(billboards, gui)
	table.insert(bobbers, { gui = gui, base = gui.StudsOffsetWorldSpace, phase = index * 1.3 })
end

function SlotBillboards.build(onInvite: (number) -> ())
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
	local lobby = workspace:WaitForChild("HelixLobby")

	for index = 1, #Theme.Lobby.Slots do
		local folder = lobby:WaitForChild("Slot" .. index)
		local anchor = folder:WaitForChild("Anchor") :: BasePart
		if index == 1 then
			nameplate(anchor, playerGui)
		else
			inviteButton(index, anchor, playerGui, onInvite)
		end
	end

	RunService.RenderStepped:Connect(function()
		local t = os.clock()
		for _, b in bobbers do
			b.gui.StudsOffsetWorldSpace = b.base + Vector3.new(0, math.sin(t * 1.4 + b.phase) * 0.18, 0)
		end
		for _, spinner in spinners do
			spinner.Rotation = (t * 28) % 360
		end
	end)
end

function SlotBillboards.setVisible(visible: boolean)
	for _, gui in billboards do
		gui.Enabled = visible
	end
end

return SlotBillboards
