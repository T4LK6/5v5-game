--!strict
-- PROFILE: fake player card, career stats and recent match history.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

local STATS = {
	{ "MATCHES", "1,284", "+38 this week" },
	{ "WINS", "712", "+21 this week" },
	{ "WIN RATE", "55.4%", "+2.1%" },
	{ "MVP", "143", "Top 8%" },
	{ "ACCURACY", "31.7%", "+0.8%" },
	{ "K / D", "1.86", "+0.12" },
}

local MATCHES = {
	{ Win = true, Mode = "Squad Elimination", Operator = "VEX", Kda = "18 / 6 / 7", Xp = "+640 XP", Ago = "12m ago", Mvp = true },
	{ Win = true, Mode = "Squad Elimination", Operator = "VEX", Kda = "14 / 9 / 4", Xp = "+520 XP", Ago = "41m ago", Mvp = false },
	{ Win = false, Mode = "Extraction Raid", Operator = "ATLAS", Kda = "6 / 4 / 15", Xp = "+310 XP", Ago = "2h ago", Mvp = false },
	{ Win = true, Mode = "Squad Elimination", Operator = "NOVA", Kda = "21 / 8 / 3", Xp = "+700 XP", Ago = "Yesterday", Mvp = true },
	{ Win = false, Mode = "Squad Elimination", Operator = "BULWARK", Kda = "9 / 11 / 10", Xp = "+280 XP", Ago = "Yesterday", Mvp = false },
}

local function playerCard(parent: Instance, ctx: Types.Ctx)
	local player = Players.LocalPlayer
	local card = UI.panel({
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(420, 640),
		ClipsDescendants = true,
		Parent = parent,
	}, 18)
	UI.stagger(card, 1)

	-- Banner.
	local banner = UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = true,
		Parent = card,
	})
	UI.gradient({ Color3.fromRGB(255, 140, 30), Color3.fromRGB(150, 40, 120), Color3.fromRGB(20, 40, 110) }, 20).Parent = banner
	for k = 0, 6 do
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(60 + k * 60, 75),
			Size = UDim2.fromOffset(18, 300),
			Rotation = 30,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.9,
			Parent = banner,
		})
	end
	UI.chip(banner, "NEON VANGUARD", C.Text, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		BackgroundTransparency = 0.75,
	})

	UI.headshot(card, 112, C.Amber, { Position = UDim2.fromOffset(24, 92) })
	-- Big level badge.
	local badge = UI.new("Frame", {
		Position = UDim2.fromOffset(110, 168),
		Size = UDim2.fromOffset(44, 44),
		BackgroundTransparency = 1,
		Parent = card,
	})
	local diamond = UI.diamond(badge, C.Amber, 12, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(34, 34),
	})
	UI.stroke(C.Panel, 0, 3).Parent = diamond
	UI.text({
		Text = "42",
		Font = F.Heavy,
		TextSize = 16,
		TextColor3 = C.Void,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = badge,
	})

	UI.text({
		Text = player.DisplayName,
		Font = F.Display,
		TextSize = 24,
		Position = UDim2.fromOffset(24, 220),
		Size = UDim2.new(1, -48, 0, 30),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	UI.text({
		Text = "@" .. player.Name .. "  ·  Member since Season 01",
		Font = F.Medium,
		TextSize = 14,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(24, 252),
		Size = UDim2.new(1, -48, 0, 18),
		Parent = card,
	})

	-- Rank block.
	local rank = UI.new("Frame", {
		Position = UDim2.fromOffset(24, 290),
		Size = UDim2.new(1, -48, 0, 92),
		BackgroundColor3 = C.PanelRaised,
		BackgroundTransparency = 0.25,
		Parent = card,
	}, { UI.corner(12), UI.stroke(C.Cyan, 0.7) })
	local emblem = UI.new("Frame", {
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(60, 60),
		BackgroundTransparency = 1,
		Parent = rank,
	})
	UI.diamond(emblem, C.Cyan, 10, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(40, 40),
	})
	UI.diamond(emblem, Color3.new(1, 1, 1), 6, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
	})
	UI.text({
		Text = "COMPETITIVE RANK",
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = C.TextFaint,
		Position = UDim2.fromOffset(92, 18),
		Size = UDim2.fromOffset(200, 14),
		Parent = rank,
	})
	UI.text({
		Text = "DIAMOND II",
		Font = F.Display,
		TextSize = 20,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(92, 34),
		Size = UDim2.fromOffset(220, 26),
		Parent = rank,
	})
	UI.text({
		Text = "2,418 RR  ·  Top 4.2%",
		Font = F.Bold,
		TextSize = 13,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(92, 62),
		Size = UDim2.fromOffset(220, 16),
		Parent = rank,
	})

	-- XP.
	UI.text({
		Text = "LEVEL 42",
		Font = F.Heavy,
		TextSize = 14,
		Position = UDim2.fromOffset(24, 404),
		Size = UDim2.fromOffset(160, 18),
		Parent = card,
	})
	UI.text({
		Text = "6,850 / 10,000 XP",
		Font = F.Bold,
		TextSize = 13,
		TextColor3 = C.TextDim,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(0, 24, 0, 404),
		Size = UDim2.new(1, -48, 0, 18),
		Parent = card,
	})
	local _, fill = UI.progress(card, 0, C.Amber, {
		Position = UDim2.fromOffset(24, 430),
		Size = UDim2.new(1, -48, 0, 10),
	})
	UI.tween(fill, 1.1, { Size = UDim2.fromScale(0.685, 1) })

	-- Badges.
	UI.header(card, "Showcase Badges", { Position = UDim2.fromOffset(24, 464), Size = UDim2.new(1, -48, 0, 22) })
	local badgeDefs = {
		{ Icon = "trophy", Color = C.Legendary, Name = "Season 01 Champion" },
		{ Icon = "assault", Color = C.Red, Name = "100 Clutch Wins" },
		{ Icon = "support", Color = C.Green, Name = "Lifesaver" },
		{ Icon = "scout", Color = C.Cyan, Name = "First Blood x500" },
		{ Icon = "star", Color = C.Epic, Name = "Founder" },
	}
	for k, def in badgeDefs do
		local b: TextButton = UI.new("TextButton", {
			Text = "",
			Position = UDim2.fromOffset(24 + (k - 1) * 74, 500),
			Size = UDim2.fromOffset(62, 62),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = card,
		}, { UI.corner(14), UI.stroke(def.Color, 0.5, 1.5) })
		UI.gradient({ def.Color:Lerp(C.Void, 0.55), C.Void }, 135).Parent = b
		Icons.draw(def.Icon, b, def.Color, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.66, 0.66),
		})
		UI.hover(b)
		b.Activated:Connect(function()
			ctx.toast(def.Name, "Showcase badge", def.Color)
		end)
	end

	local edit = UI.button({
		Position = UDim2.fromOffset(24, 580),
		Size = UDim2.new(1, -48, 0, 40),
		TextSize = 14,
		Parent = card,
	}, "ghost", "EDIT PLAYER CARD")
	edit.Activated:Connect(function()
		ctx.toast("Player card", "Customization is visual-only in this prototype.")
	end)
end

local function statsGrid(parent: Instance)
	local holder = UI.new("Frame", {
		Position = UDim2.fromOffset(440, 96),
		Size = UDim2.fromOffset(620, 290),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	UI.stagger(holder, 2)
	UI.header(holder, "Career  ·  All Modes")
	local grid = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 1, -32),
		BackgroundTransparency = 1,
		Parent = holder,
	}, { UI.grid(UDim2.fromOffset(198, 118), 13) })
	for k, stat in STATS do
		local tile = UI.panel({ LayoutOrder = k, Parent = grid }, 14)
		UI.text({
			Text = stat[1],
			Font = F.Bold,
			TextSize = 12,
			TextColor3 = C.TextFaint,
			Position = UDim2.fromOffset(18, 18),
			Size = UDim2.new(1, -36, 0, 14),
			Parent = tile,
		})
		UI.text({
			Text = stat[2],
			Font = F.Display,
			TextSize = 30,
			TextColor3 = if k == 4 then C.Amber else C.Text,
			Position = UDim2.fromOffset(16, 38),
			Size = UDim2.new(1, -32, 0, 40),
			Parent = tile,
		})
		UI.text({
			Text = stat[3],
			Font = F.Bold,
			TextSize = 12,
			TextColor3 = C.Green,
			Position = UDim2.fromOffset(18, 84),
			Size = UDim2.new(1, -36, 0, 14),
			Parent = tile,
		})
	end
end

local function matchHistory(parent: Instance)
	local holder = UI.new("Frame", {
		Position = UDim2.fromOffset(440, 406),
		Size = UDim2.fromOffset(620, 330),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	UI.stagger(holder, 3)
	UI.header(holder, "Recent Matches")
	local list = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 1, -32),
		BackgroundTransparency = 1,
		Parent = holder,
	}, { UI.list(Enum.FillDirection.Vertical, 8) })

	for k, match in MATCHES do
		local color = if match.Win then C.Green else C.Red
		local row = UI.panel({
			LayoutOrder = k,
			Size = UDim2.new(1, 0, 0, 52),
			Parent = list,
		}, 10)
		row.ClipsDescendants = true
		UI.new("Frame", {
			Size = UDim2.new(0, 180, 1, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.75,
			Parent = row,
		}, { UI.gradient({ color }, 0, NumberSequence.new(0, 1)) })
		UI.new("Frame", {
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = color,
			Parent = row,
		})
		UI.text({
			Text = if match.Win then "VICTORY" else "DEFEAT",
			Font = F.Heavy,
			TextSize = 15,
			TextColor3 = color,
			Position = UDim2.fromOffset(18, 8),
			Size = UDim2.fromOffset(120, 18),
			Parent = row,
		})
		UI.text({
			Text = match.Mode,
			Font = F.Medium,
			TextSize = 12,
			TextColor3 = C.TextDim,
			Position = UDim2.fromOffset(18, 28),
			Size = UDim2.fromOffset(160, 16),
			Parent = row,
		})
		UI.text({
			Text = match.Operator,
			Font = F.Display,
			TextSize = 14,
			Position = UDim2.fromOffset(196, 0),
			Size = UDim2.fromOffset(110, 52),
			Parent = row,
		})
		UI.text({
			Text = match.Kda,
			Font = F.Heavy,
			TextSize = 15,
			Position = UDim2.fromOffset(310, 0),
			Size = UDim2.fromOffset(110, 52),
			Parent = row,
		})
		if match.Mvp then
			UI.chip(row, "MVP", C.Amber, {
				Position = UDim2.fromOffset(420, 14),
				BackgroundTransparency = 0.7,
			})
		end
		UI.text({
			Text = match.Xp,
			Font = F.Heavy,
			TextSize = 13,
			TextColor3 = C.Epic,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -170, 0, 8),
			Size = UDim2.fromOffset(150, 18),
			Parent = row,
		})
		UI.text({
			Text = match.Ago,
			Font = F.Medium,
			TextSize = 12,
			TextColor3 = C.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -170, 0, 28),
			Size = UDim2.fromOffset(150, 16),
			Parent = row,
		})
	end
end

return function(content: Frame, ctx: Types.Ctx)
	UI.stagger(UI.text({
		Text = "PROFILE",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(400, 42),
		Parent = content,
	}), 0)
	UI.stagger(UI.text({
		Text = "SEASON 01  ·  CAREER OVERVIEW",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(400, 18),
		Parent = content,
	}), 0)

	playerCard(content, ctx)
	statsGrid(content)
	matchHistory(content)
end
