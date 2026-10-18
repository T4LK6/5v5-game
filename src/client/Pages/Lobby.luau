--!strict
-- LOBBY: the hero page. Keeps the centre of the screen clear for the 3D
-- party scene and frames it with a party strip, an event card and the
-- Play call-to-action.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

local MODES = {
	{ Name = "SQUAD ELIMINATION", Detail = "4-PLAYER SQUADS  ·  RANKED" },
	{ Name = "EXTRACTION RAID", Detail = "PvE  ·  CO-OP  ·  HARD" },
	{ Name = "TRAINING RANGE", Detail = "SOLO  ·  PRACTICE" },
}
local PRIVACY = { "FRIENDS ONLY", "INVITE ONLY", "PUBLIC" }
local REGIONS = { { Name = "EU-WEST", Ping = 24 }, { Name = "NA-EAST", Ping = 88 }, { Name = "ASIA-SE", Ping = 142 } }

-- Little "< VALUE >" cycler used for privacy / region / mode.
local function cycler(parent: Instance, label: string, values: { string }, props: UI.Props, onChange: ((number) -> ())?)
	local p = table.clone(props)
	p.Parent = parent
	local index = 1
	local button: TextButton = UI.button(p, "ghost", "")
	UI.text({
		Text = label,
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = C.TextFaint,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -28, 0, 14),
		Parent = button,
	})
	local value = UI.text({
		Text = values[1],
		Font = F.Heavy,
		TextSize = 15,
		Position = UDim2.fromOffset(14, 22),
		Size = UDim2.new(1, -44, 0, 18),
		Parent = button,
	})
	UI.text({
		Text = ">",
		Font = F.Heavy,
		TextSize = 16,
		TextColor3 = C.Cyan,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -14, 1, 0),
		Parent = button,
	})
	button.Activated:Connect(function()
		index = index % #values + 1
		value.Text = values[index]
		value.Position = UDim2.fromOffset(24, 22)
		UI.tween(value, 0.25, { Position = UDim2.fromOffset(14, 22) })
		if onChange then
			onChange(index)
		end
	end)
	return button
end

local function eventCard(page: Instance, ctx: Types.Ctx)
	local card: TextButton = UI.new("TextButton", {
		Text = "",
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.fromOffset(400, 118),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = page,
	}, { UI.corner(14), UI.stroke(C.Line, 0.85) })
	UI.stagger(card, 1)
	UI.gradient({ Color3.fromRGB(120, 24, 92), Color3.fromRGB(40, 22, 100), Color3.fromRGB(8, 60, 110) }, 15).Parent = card
	UI.hover(card)

	-- Diagonal light streaks.
	for k = 0, 2 do
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -70 + k * 26, 0.5, 0),
			Size = UDim2.fromOffset(10, 200),
			Rotation = 25,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.88 + k * 0.03,
			Parent = card,
		})
	end
	card.ClipsDescendants = true

	UI.chip(card, "LIMITED EVENT", C.Magenta, { Position = UDim2.fromOffset(16, 14), BackgroundTransparency = 0.6 })
	UI.text({
		Text = "NEON FRONTIER",
		Font = F.Display,
		TextSize = 24,
		Position = UDim2.fromOffset(16, 46),
		Size = UDim2.fromOffset(360, 30),
		Parent = card,
	})
	UI.text({
		Text = "Double XP weekend  ·  Ends in 2d 14h",
		Font = F.Medium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(220, 200, 240),
		Position = UDim2.fromOffset(16, 80),
		Size = UDim2.fromOffset(360, 18),
		Parent = card,
	})
	card.Activated:Connect(function()
		ctx.goTo("Missions")
	end)
end

local function partyStrip(page: Instance, ctx: Types.Ctx)
	local strip = UI.panel({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -6),
		Size = UDim2.fromOffset(640, 156),
		Parent = page,
	}, 16)
	UI.stagger(strip, 2)

	UI.text({
		Text = "SQUAD",
		Font = F.Display,
		TextSize = 16,
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.fromOffset(100, 20),
		Parent = strip,
	})
	local count = UI.chip(strip, "1 / 4", C.Amber, { Position = UDim2.fromOffset(106, 14) })
	count.BackgroundTransparency = 0.8
	UI.text({
		Text = "Invite friends to fill your squad",
		Font = F.Medium,
		TextSize = 13,
		TextColor3 = C.TextFaint,
		Position = UDim2.fromOffset(176, 16),
		Size = UDim2.fromOffset(260, 22),
		Parent = strip,
	})

	-- Four mini slots.
	for i = 1, 4 do
		local x = 20 + (i - 1) * 66
		if i == 1 then
			UI.headshot(strip, 54, C.Amber, { Position = UDim2.fromOffset(x, 56) })
			UI.new("Frame", {
				Position = UDim2.fromOffset(x + 40, 96),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = C.Green,
				Parent = strip,
			}, { UI.corner(6), UI.stroke(C.Panel, 0, 2) })
		else
			local slot: TextButton = UI.new("TextButton", {
				Text = "+",
				Font = F.Heavy,
				TextSize = 26,
				TextColor3 = C.Cyan,
				Position = UDim2.fromOffset(x, 56),
				Size = UDim2.fromOffset(54, 54),
				BackgroundColor3 = C.Cyan,
				BackgroundTransparency = 0.9,
				Parent = strip,
			}, { UI.corner(27) })
			local stroke = UI.stroke(C.Cyan, 0.5, 1.5)
			stroke.Parent = slot
			UI.hover(slot, function()
				UI.tween(slot, 0.2, { BackgroundTransparency = 0.7 })
				UI.tween(stroke, 0.2, { Transparency = 0 })
			end, function()
				UI.tween(slot, 0.2, { BackgroundTransparency = 0.9 })
				UI.tween(stroke, 0.2, { Transparency = 0.5 })
			end)
			slot.Activated:Connect(function()
				ctx.invite(i)
			end)
		end
	end
	UI.text({
		Text = "YOU",
		Font = F.Heavy,
		TextSize = 11,
		TextColor3 = C.Amber,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(20, 116),
		Size = UDim2.fromOffset(54, 14),
		Parent = strip,
	})

	-- Party controls.
	local controls = UI.new("Frame", {
		Position = UDim2.fromOffset(292, 54),
		Size = UDim2.fromOffset(330, 80),
		BackgroundTransparency = 1,
		Parent = strip,
	})
	local invite = UI.button({
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(330, 34),
		TextSize = 14,
		Parent = controls,
	}, "accent", "INVITE FRIENDS")
	invite.Activated:Connect(function()
		ctx.invite(2)
	end)

	cycler(controls, "PRIVACY", PRIVACY, {
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.fromOffset(160, 46),
	}, function(i)
		ctx.toast("Party privacy updated", "Your squad is now " .. string.lower(PRIVACY[i]) .. ".")
	end)
	local regionNames = {}
	for _, r in REGIONS do
		table.insert(regionNames, string.format("%s  %dms", r.Name, r.Ping))
	end
	cycler(controls, "REGION", regionNames, {
		Position = UDim2.fromOffset(170, 40),
		Size = UDim2.fromOffset(160, 46),
	})
end

local function playCluster(page: Instance, ctx: Types.Ctx)
	local cluster = UI.new("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, -6),
		Size = UDim2.fromOffset(420, 200),
		BackgroundTransparency = 1,
		Parent = page,
	})
	UI.stagger(cluster, 3)

	-- Mode selector.
	local mode = UI.panel({
		Size = UDim2.fromOffset(420, 84),
		Parent = cluster,
	}, 14)
	UI.text({
		Text = "GAME MODE",
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = C.TextFaint,
		Position = UDim2.fromOffset(20, 14),
		Size = UDim2.fromOffset(200, 14),
		Parent = mode,
	})
	local modeName = UI.text({
		Text = MODES[1].Name,
		Font = F.Display,
		TextSize = 18,
		Position = UDim2.fromOffset(20, 30),
		Size = UDim2.fromOffset(300, 24),
		Parent = mode,
	})
	local modeDetail = UI.text({
		Text = MODES[1].Detail,
		Font = F.Bold,
		TextSize = 12,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(20, 56),
		Size = UDim2.fromOffset(300, 16),
		Parent = mode,
	})
	local modeIndex = 1
	local function stepMode(dir: number)
		modeIndex = (modeIndex - 1 + dir) % #MODES + 1
		modeName.Text = MODES[modeIndex].Name
		modeDetail.Text = MODES[modeIndex].Detail
		modeName.Position = UDim2.fromOffset(20 + dir * 16, 30)
		UI.tween(modeName, 0.3, { Position = UDim2.fromOffset(20, 30) })
	end
	for k, dir in { -1, 1 } do
		local arrow = UI.button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, k == 1 and -60 or -16, 0.5, 0),
			Size = UDim2.fromOffset(38, 38),
			TextSize = 18,
			TextColor3 = C.Cyan,
			Parent = mode,
		}, "dark", dir < 0 and "<" or ">")
		arrow.Activated:Connect(function()
			stepMode(dir)
		end)
	end

	-- PLAY.
	local play: TextButton = UI.button({
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.fromOffset(420, 100),
		CornerRadius = 16,
		ClipsDescendants = true,
		Parent = cluster,
	}, "primary", "")
	local gradient = play:FindFirstChildOfClass("UIGradient") :: UIGradient
	local playLabel = UI.text({
		Text = "PLAY",
		Font = F.Display,
		TextSize = 40,
		TextColor3 = C.Void,
		Position = UDim2.fromOffset(30, 16),
		Size = UDim2.fromOffset(300, 46),
		Parent = play,
	})
	local playSub = UI.text({
		Text = "SQUAD 1/4  ·  READY TO DEPLOY",
		Font = F.Heavy,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(70, 34, 0),
		Position = UDim2.fromOffset(32, 64),
		Size = UDim2.fromOffset(330, 18),
		Parent = play,
	})
	-- Chevrons on the right.
	local chevrons = UI.new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -30, 0.5, 0),
		Size = UDim2.fromOffset(60, 40),
		BackgroundTransparency = 1,
		Parent = play,
	})
	for k = 0, 2 do
		local holder = UI.new("Frame", {
			Position = UDim2.fromOffset(k * 18, 0),
			Size = UDim2.fromOffset(20, 40),
			BackgroundTransparency = 1,
			Parent = chevrons,
		})
		for _, sign in { -1, 1 } do
			UI.new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, sign * 7),
				Size = UDim2.fromOffset(18, 5),
				Rotation = sign * 45,
				BackgroundColor3 = C.Void,
				BackgroundTransparency = 0.15 + k * 0.25,
				Parent = holder,
			}, { UI.corner(2) })
		end
	end
	-- Shine sweep.
	local shine = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, -80, 0.5, 0),
		Size = UDim2.fromOffset(60, 220),
		Rotation = 20,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.55,
		Parent = play,
	}, { UI.gradient({ Color3.new(1, 1, 1) }, 0, NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1),
	})) })
	task.spawn(function()
		while play.Parent do
			shine.Position = UDim2.new(0, -80, 0.5, 0)
			UI.tween(shine, 0.9, { Position = UDim2.new(1, 80, 0.5, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			task.wait(3.5)
		end
	end)

	-- Fake matchmaking state.
	local searching = false
	local started = 0
	local connection: RBXScriptConnection? = nil
	play.Activated:Connect(function()
		searching = not searching
		if searching then
			started = os.clock()
			gradient.Color = ColorSequence.new(C.Cyan, C.CyanDeep)
			playLabel.Text = "SEARCHING"
			playLabel.TextSize = 32
			connection = RunService.Heartbeat:Connect(function()
				local elapsed = math.floor(os.clock() - started)
				playSub.Text = string.format("%02d:%02d  ·  CLICK TO CANCEL", elapsed // 60, elapsed % 60)
			end)
			ctx.toast("Matchmaking (demo)", "Visual only — no real queue in this prototype.", C.Cyan)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			gradient.Color = ColorSequence.new(C.Amber, C.AmberDeep)
			playLabel.Text = "PLAY"
			playLabel.TextSize = 40
			playSub.Text = "SQUAD 1/4  ·  READY TO DEPLOY"
		end
		playSub.TextColor3 = if searching then Color3.fromRGB(0, 40, 70) else Color3.fromRGB(70, 34, 0)
	end)
end

return function(page: Frame, ctx: Types.Ctx)
	eventCard(page, ctx)
	partyStrip(page, ctx)
	playCluster(page, ctx)
end
