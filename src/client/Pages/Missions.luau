--!strict
-- MISSIONS: fake task board. Season pass track on top, Daily and Weekly
-- columns with progress bars and claimable rewards.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

type Mission = { Title: string, Text: string, Progress: number, Goal: number, Xp: number, Coins: number, Icon: string }

local DAILY: { Mission } = {
	{ Title = "Squad Up", Text = "Play 3 matches with a full squad", Progress = 3, Goal = 3, Xp = 500, Coins = 150, Icon = "support" },
	{ Title = "Sharpshooter", Text = "Land 50 headshots", Progress = 34, Goal = 50, Xp = 750, Coins = 200, Icon = "assault" },
	{ Title = "Field Medic", Text = "Revive 5 teammates", Progress = 5, Goal = 5, Xp = 400, Coins = 100, Icon = "defender" },
	{ Title = "Spearhead", Text = "Win a match as VEX", Progress = 0, Goal = 1, Xp = 600, Coins = 250, Icon = "star" },
}

local WEEKLY: { Mission } = {
	{ Title = "Season Grinder", Text = "Win 15 matches", Progress = 9, Goal = 15, Xp = 4000, Coins = 1200, Icon = "trophy" },
	{ Title = "Arsenal", Text = "Get 100 eliminations with rifles", Progress = 100, Goal = 100, Xp = 3000, Coins = 800, Icon = "rifle" },
	{ Title = "Versatile", Text = "Play 10 matches across 3 operators", Progress = 6, Goal = 10, Xp = 2500, Coins = 600, Icon = "recon" },
	{ Title = "Drop Zone", Text = "Extract 8 times in Extraction Raid", Progress = 2, Goal = 8, Xp = 3500, Coins = 1000, Icon = "scout" },
}

local function missionCard(parent: Instance, mission: Mission, order: number, accent: Color3, ctx: Types.Ctx)
	local done = mission.Progress >= mission.Goal
	local card = UI.panel({
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 100),
		BackgroundTransparency = if done then 0.02 else 0.12,
		Parent = parent,
	}, 14)
	local stroke = card:FindFirstChildOfClass("UIStroke") :: UIStroke
	if done then
		stroke.Color = C.Amber
		stroke.Transparency = 0.45
	end

	local iconBox = UI.new("Frame", {
		Position = UDim2.fromOffset(18, 20),
		Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = card,
	}, { UI.corner(12) })
	UI.gradient({ accent:Lerp(C.Void, 0.5), accent:Lerp(C.Void, 0.82) }, 135).Parent = iconBox
	Icons.draw(mission.Icon, iconBox, accent, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.72, 0.72),
	})

	UI.text({
		Text = string.upper(mission.Title),
		Font = F.Heavy,
		TextSize = 17,
		Position = UDim2.fromOffset(96, 18),
		Size = UDim2.fromOffset(340, 20),
		Parent = card,
	})
	UI.text({
		Text = mission.Text,
		Font = F.Medium,
		TextSize = 14,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(96, 40),
		Size = UDim2.fromOffset(340, 18),
		Parent = card,
	})
	local _, fill = UI.progress(card, 0, if done then C.Amber else accent, {
		Position = UDim2.fromOffset(96, 68),
		Size = UDim2.fromOffset(300, 8),
	})
	UI.tween(fill, 0.9 + order * 0.1, { Size = UDim2.fromScale(mission.Progress / mission.Goal, 1) })
	UI.text({
		Text = string.format("%d / %d", mission.Progress, mission.Goal),
		Font = F.Heavy,
		TextSize = 13,
		TextColor3 = if done then C.Amber else C.Text,
		Position = UDim2.fromOffset(406, 62),
		Size = UDim2.fromOffset(80, 18),
		Parent = card,
	})

	-- Rewards.
	local rewards = UI.new("Frame", {
		Position = UDim2.fromOffset(470, 22),
		Size = UDim2.fromOffset(120, 56),
		BackgroundTransparency = 1,
		Parent = card,
	})
	UI.diamond(rewards, C.Epic, 14, { Position = UDim2.fromOffset(3, 7) })
	UI.text({
		Text = UI.formatNumber(mission.Xp) .. " XP",
		Font = F.Heavy,
		TextSize = 14,
		Position = UDim2.fromOffset(28, 2),
		Size = UDim2.fromOffset(100, 24),
		Parent = rewards,
	})
	UI.coin(rewards, C.Amber, 18, { Position = UDim2.fromOffset(1, 33) })
	UI.text({
		Text = UI.formatNumber(mission.Coins),
		Font = F.Heavy,
		TextSize = 14,
		Position = UDim2.fromOffset(28, 30),
		Size = UDim2.fromOffset(100, 24),
		Parent = rewards,
	})

	local claim = UI.button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(150, 48),
		TextSize = 15,
		Parent = card,
	}, if done then "primary" else "ghost", if done then "CLAIM" else "IN PROGRESS")
	if not done then
		claim.TextColor3 = C.TextFaint
	end

	local claimed = false
	claim.Activated:Connect(function()
		if not done then
			ctx.toast(mission.Title, string.format("%d more to go.", mission.Goal - mission.Progress), accent)
			return
		end
		if claimed then
			return
		end
		claimed = true
		claim.Text = "CLAIMED"
		local gradient = claim:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = ColorSequence.new(C.Green, Color3.fromRGB(20, 170, 110))
		end
		UI.tween(stroke, 0.3, { Color = C.Green, Transparency = 0.5 })
		ctx.toast("Reward claimed", string.format("+%s XP  ·  +%s Credits", UI.formatNumber(mission.Xp), UI.formatNumber(mission.Coins)), C.Green)
	end)
end

local function column(parent: Instance, x: number, title: string, reset: string, missions: { Mission }, accent: Color3, order: number, ctx: Types.Ctx)
	local col = UI.new("Frame", {
		Position = UDim2.fromOffset(x, 270),
		Size = UDim2.fromOffset(790, 470),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	UI.stagger(col, order)
	local header = UI.header(col, title)
	;(header:FindFirstChildOfClass("Frame") :: Frame).BackgroundColor3 = accent
	UI.text({
		Text = reset,
		Font = F.Bold,
		TextSize = 13,
		TextColor3 = C.TextFaint,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 22),
		Parent = col,
	})
	local list = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 1, -34),
		BackgroundTransparency = 1,
		Parent = col,
	}, { UI.list(Enum.FillDirection.Vertical, 12) })
	for k, mission in missions do
		missionCard(list, mission, k, accent, ctx)
	end
end

local function seasonTrack(parent: Instance, ctx: Types.Ctx)
	local strip = UI.panel({
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(1600, 150),
		Parent = parent,
	}, 18)
	UI.stagger(strip, 1)

	UI.text({
		Text = "SEASON PASS",
		Font = F.Bold,
		TextSize = 12,
		TextColor3 = C.Amber,
		Position = UDim2.fromOffset(28, 24),
		Size = UDim2.fromOffset(200, 14),
		Parent = strip,
	})
	UI.text({
		Text = "TIER 12",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(26, 42),
		Size = UDim2.fromOffset(240, 42),
		Parent = strip,
	})
	UI.text({
		Text = "6,850 / 10,000 XP TO TIER 13",
		Font = F.Bold,
		TextSize = 13,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(28, 92),
		Size = UDim2.fromOffset(240, 16),
		Parent = strip,
	})
	UI.progress(strip, 0.685, C.Amber, { Position = UDim2.fromOffset(28, 116), Size = UDim2.fromOffset(220, 6) })

	-- Tier nodes 8..17.
	local track = UI.new("Frame", {
		Position = UDim2.fromOffset(300, 30),
		Size = UDim2.fromOffset(1020, 90),
		BackgroundTransparency = 1,
		Parent = strip,
	})
	UI.new("Frame", {
		Position = UDim2.new(0, 30, 0, 34),
		Size = UDim2.new(1, -60, 0, 4),
		BackgroundColor3 = C.PanelHover,
		Parent = track,
	}, { UI.corner(2) })
	UI.new("Frame", {
		Position = UDim2.new(0, 30, 0, 34),
		Size = UDim2.new(0, (1020 - 60) * (4.685 / 9), 0, 4),
		BackgroundColor3 = C.Amber,
		Parent = track,
	}, { UI.corner(2) })
	local icons = { "star", "rifle", "skin", "star", "accessory", "knife", "star", "gadget", "trophy", "skin" }
	for k = 0, 9 do
		local tier = 8 + k
		local reached = tier <= 12
		local x = 30 + k * (1020 - 60) / 9
		local node = UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, 36),
			Size = UDim2.fromOffset(if tier == 12 then 60 else 50, if tier == 12 then 60 else 50),
			BackgroundColor3 = if reached then C.Amber else C.PanelRaised,
			BackgroundTransparency = if reached then 0.75 else 0.1,
			Parent = track,
		}, { UI.corner(12), UI.stroke(if reached then C.Amber else C.Line, if reached then 0.1 else 0.85, if tier == 12 then 2 else 1) })
		Icons.draw(icons[k + 1], node, if reached then C.Amber else C.TextFaint, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.68, 0.68),
		})
		UI.text({
			Text = tostring(tier),
			Font = F.Heavy,
			TextSize = 12,
			TextColor3 = if reached then C.Text else C.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Center,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromOffset(x, 70),
			Size = UDim2.fromOffset(40, 14),
			Parent = track,
		})
	end

	local premium = UI.button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(220, 56),
		TextSize = 15,
		Parent = strip,
	}, "primary", "GET PREMIUM PASS")
	premium.Activated:Connect(function()
		ctx.goTo("Shop")
	end)
end

return function(content: Frame, ctx: Types.Ctx)
	UI.stagger(UI.text({
		Text = "MISSIONS",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(400, 42),
		Parent = content,
	}), 0)
	UI.stagger(UI.text({
		Text = "COMPLETE MISSIONS TO EARN XP AND REWARDS",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(600, 18),
		Parent = content,
	}), 0)

	seasonTrack(content, ctx)
	column(content, 0, "Daily", "RESETS IN 07:42:13", DAILY, C.Cyan, 2, ctx)
	column(content, 810, "Weekly", "RESETS IN 3D 07H", WEEKLY, C.Epic, 3, ctx)
end
