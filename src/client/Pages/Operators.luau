--!strict
-- OPERATORS: fake character select. A row of tall operator cards, role
-- filters, and a detail strip with abilities and Select / Customize.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

type Ability = { Name: string, Text: string }
type Operator = {
	Name: string,
	Role: string,
	Bio: string,
	Locked: boolean,
	Difficulty: number,
	Abilities: { Ability },
}

local ROLE_COLORS: { [string]: Color3 } = {
	Assault = C.Amber,
	Scout = C.Cyan,
	Support = C.Green,
	Defender = C.Rare,
	Recon = C.Epic,
}
local ROLE_ICONS: { [string]: string } = {
	Assault = "assault",
	Scout = "scout",
	Support = "support",
	Defender = "defender",
	Recon = "recon",
}

local OPERATORS: { Operator } = {
	{ Name = "VEX", Role = "Assault", Locked = false, Difficulty = 2,
		Bio = "Former orbital marine. Breaks sieges with relentless forward pressure.",
		Abilities = { { Name = "Overdrive", Text = "Boosts fire rate and sprint speed for 6s." }, { Name = "Breach Charge", Text = "Blasts through light cover." } } },
	{ Name = "NOVA", Role = "Scout", Locked = false, Difficulty = 3,
		Bio = "Signal ghost and route-finder. Always first through the door.",
		Abilities = { { Name = "Blink", Text = "Short-range dash with afterimage." }, { Name = "Pulse Scan", Text = "Reveals nearby enemies briefly." } } },
	{ Name = "ATLAS", Role = "Support", Locked = false, Difficulty = 1,
		Bio = "Field engineer who keeps the squad stocked and standing.",
		Abilities = { { Name = "Supply Drop", Text = "Calls an ammo and armor crate." }, { Name = "Mend Field", Text = "Heals allies inside the zone." } } },
	{ Name = "BULWARK", Role = "Defender", Locked = false, Difficulty = 1,
		Bio = "Walking fortress. Holds the line so others can play hero.",
		Abilities = { { Name = "Aegis Wall", Text = "Deploys a hardlight barrier." }, { Name = "Anchor", Text = "Becomes immovable and gains armor." } } },
	{ Name = "WRAITH", Role = "Recon", Locked = true, Difficulty = 3,
		Bio = "Infiltrator who turns enemy intel against them.",
		Abilities = { { Name = "Cloak", Text = "Near-invisibility while still." }, { Name = "Tap Wire", Text = "Hack a camera to spot through it." } } },
	{ Name = "KADE", Role = "Assault", Locked = true, Difficulty = 2,
		Bio = "Demolitions specialist with a short fuse and a long list.",
		Abilities = { { Name = "Cluster Shot", Text = "Fires a splitting grenade." }, { Name = "Rally", Text = "Grants nearby allies bonus armor." } } },
}

local CARD_W, CARD_H, CARD_GAP = 162, 312, 17

local function lockGlyph(parent: Instance)
	local holder = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.fromOffset(34, 40),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(22, 26),
		BackgroundTransparency = 1,
		Parent = holder,
	}, { UI.corner(11), UI.stroke(C.Text, 0, 4) })
	UI.new("Frame", {
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.fromOffset(34, 24),
		BackgroundColor3 = C.Text,
		Parent = holder,
	}, { UI.corner(5) })
end

return function(page: Frame, ctx: Types.Ctx)
	local selected = 1
	local filter = "All"

	UI.stagger(UI.text({
		Text = "OPERATORS",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(500, 42),
		Parent = page,
	}), 0)
	UI.stagger(UI.text({
		Text = "6 OPERATIVES  ·  4 UNLOCKED",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(400, 18),
		Parent = page,
	}), 0)

	-- Role filter chips.
	local filters = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(1060, 34),
		BackgroundTransparency = 1,
		Parent = page,
	}, { UI.list(Enum.FillDirection.Horizontal, 8) })
	UI.stagger(filters, 1)

	local row = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 146),
		Size = UDim2.fromOffset(1060, CARD_H),
		BackgroundTransparency = 1,
		Parent = page,
	})
	UI.stagger(row, 2)

	local detail = UI.panel({
		Position = UDim2.fromOffset(0, 146 + CARD_H + 20),
		Size = UDim2.fromOffset(1060, 236),
		Parent = page,
	}, 16)
	UI.stagger(detail, 3)

	type CardRef = { button: TextButton, stroke: UIStroke, avatar: ImageLabel, scale: UIScale, op: Operator, shade: Frame }
	local cards: { CardRef } = {}
	local filterButtons: { [string]: TextButton } = {}

	local detailContent = UI.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = detail })

	local function renderDetail()
		detailContent:ClearAllChildren()
		local op = OPERATORS[selected]
		local color = ROLE_COLORS[op.Role]

		-- Left: identity.
		local iconBox = UI.new("Frame", {
			Position = UDim2.fromOffset(24, 24),
			Size = UDim2.fromOffset(60, 60),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.8,
			Parent = detailContent,
		}, { UI.corner(12), UI.stroke(color, 0.3, 1.5) })
		Icons.draw(ROLE_ICONS[op.Role], iconBox, color, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
		})
		UI.text({
			Text = op.Name,
			Font = F.Display,
			TextSize = 32,
			Position = UDim2.fromOffset(100, 22),
			Size = UDim2.fromOffset(300, 40),
			Parent = detailContent,
		})
		UI.chip(detailContent, string.upper(op.Role), color, { Position = UDim2.fromOffset(100, 64) })
		UI.text({
			Text = op.Bio,
			Font = F.Medium,
			TextSize = 15,
			TextColor3 = C.TextDim,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(24, 104),
			Size = UDim2.fromOffset(360, 60),
			Parent = detailContent,
		})
		-- Difficulty pips.
		UI.text({
			Text = "DIFFICULTY",
			Font = F.Bold,
			TextSize = 12,
			TextColor3 = C.TextFaint,
			Position = UDim2.fromOffset(24, 184),
			Size = UDim2.fromOffset(100, 14),
			Parent = detailContent,
		})
		for k = 1, 3 do
			UI.new("Frame", {
				Position = UDim2.fromOffset(110 + (k - 1) * 30, 186),
				Size = UDim2.fromOffset(24, 8),
				BackgroundColor3 = if k <= op.Difficulty then color else C.PanelHover,
				Parent = detailContent,
			}, { UI.corner(4) })
		end

		-- Middle: abilities.
		for a, ability in op.Abilities do
			local y = 24 + (a - 1) * 96
			local box = UI.new("Frame", {
				Position = UDim2.fromOffset(420, y),
				Size = UDim2.fromOffset(360, 84),
				BackgroundColor3 = C.PanelRaised,
				BackgroundTransparency = 0.2,
				Parent = detailContent,
			}, { UI.corner(12), UI.stroke(C.Line, 0.9) })
			local key = UI.new("Frame", {
				Position = UDim2.fromOffset(14, 14),
				Size = UDim2.fromOffset(56, 56),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = box,
			}, { UI.corner(10) })
			UI.gradient({ color, color:Lerp(C.Void, 0.5) }, 135).Parent = key
			UI.text({
				Text = a == 1 and "Q" or "E",
				Font = F.Display,
				TextSize = 22,
				TextColor3 = C.Void,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
				Parent = key,
			})
			UI.text({
				Text = string.upper(ability.Name),
				Font = F.Heavy,
				TextSize = 16,
				Position = UDim2.fromOffset(84, 16),
				Size = UDim2.fromOffset(260, 20),
				Parent = box,
			})
			UI.text({
				Text = ability.Text,
				Font = F.Medium,
				TextSize = 14,
				TextColor3 = C.TextDim,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Position = UDim2.fromOffset(84, 40),
				Size = UDim2.fromOffset(262, 36),
				Parent = box,
			})
		end

		-- Right: actions.
		local selectText = if op.Locked then "UNLOCK  ·  1,200" else "SELECT"
		local select = UI.button({
			Position = UDim2.fromOffset(806, 24),
			Size = UDim2.fromOffset(230, 60),
			TextSize = 18,
			Parent = detailContent,
		}, "primary", selectText)
		select.Activated:Connect(function()
			if op.Locked then
				ctx.goTo("Shop")
			else
				ctx.toast(op.Name .. " deployed", "Operator selected for your next match.", color)
			end
		end)
		local customize = UI.button({
			Position = UDim2.fromOffset(806, 96),
			Size = UDim2.fromOffset(230, 48),
			TextSize = 15,
			Parent = detailContent,
		}, "ghost", "CUSTOMIZE")
		customize.Activated:Connect(function()
			ctx.goTo("Loadout")
		end)
		UI.text({
			Text = if op.Locked then "Unlock with Credits or the Season Pass." else "Mastery 3  ·  148 matches played",
			Font = F.Medium,
			TextSize = 13,
			TextColor3 = C.TextFaint,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(806, 160),
			Size = UDim2.fromOffset(230, 16),
			Parent = detailContent,
		})
	end

	local function refreshCards()
		for i, ref in cards do
			local isSelected = i == selected
			local matches = filter == "All" or ref.op.Role == filter
			local color = ROLE_COLORS[ref.op.Role]
			UI.tween(ref.stroke, 0.25, {
				Color = if isSelected then color else C.Line,
				Transparency = if isSelected then 0 else 0.86,
				Thickness = if isSelected then 2.5 else 1,
			})
			UI.tween(ref.scale, 0.3, { Scale = if isSelected then 1.04 else 1 }, Enum.EasingStyle.Back)
			UI.tween(ref.avatar, 0.3, {
				ImageColor3 = if ref.op.Locked
					then Color3.fromRGB(14, 16, 24)
					elseif isSelected then Color3.new(1, 1, 1)
					else color:Lerp(C.Void, 0.55),
			})
			UI.tween(ref.shade, 0.25, { BackgroundTransparency = if matches then 1 else 0.35 })
		end
		for name, button in filterButtons do
			local active = name == filter
			UI.tween(button, 0.2, {
				BackgroundColor3 = if active then C.Cyan else C.Panel,
				TextColor3 = if active then C.Void else C.TextDim,
			})
		end
	end

	for i, op in OPERATORS do
		local color = ROLE_COLORS[op.Role]
		local card: TextButton = UI.new("TextButton", {
			Text = "",
			Position = UDim2.fromOffset((i - 1) * (CARD_W + CARD_GAP), 0),
			Size = UDim2.fromOffset(CARD_W, CARD_H),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ClipsDescendants = true,
			Parent = row,
		}, { UI.corner(14) })
		UI.gradient({ color:Lerp(C.Void, 0.62), C.Deep, C.Void }, 90).Parent = card
		local stroke = UI.stroke(C.Line, 0.86)
		stroke.Parent = card
		local scale = UI.new("UIScale", { Parent = card })

		-- Big faint role glyph behind the figure.
		local glyph = Icons.draw(ROLE_ICONS[op.Role], card, color, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.36),
			Size = UDim2.fromScale(1.1, 1.1),
			Rotation = -12,
		})
		for _, child in glyph:GetDescendants() do
			if child:IsA("Frame") and child.BackgroundTransparency < 1 then
				child.BackgroundTransparency = 0.88
			elseif child:IsA("UIStroke") then
				child.Transparency = 0.88
			end
		end

		local avatar = UI.new("ImageLabel", {
			Image = UI.avatarUrl("body"),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -58),
			Size = UDim2.fromOffset(200, 220),
			ScaleType = Enum.ScaleType.Crop,
			ImageColor3 = color:Lerp(C.Void, 0.55),
			Parent = card,
		})

		-- Footer.
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 74),
			BackgroundColor3 = C.Void,
			Parent = card,
		}, { UI.gradient({ C.Void }, 90, NumberSequence.new(0.6, 0)) })
		UI.text({
			Text = op.Name,
			Font = F.Display,
			TextSize = 18,
			Position = UDim2.new(0, 14, 1, -52),
			Size = UDim2.new(1, -28, 0, 22),
			Parent = card,
		})
		UI.text({
			Text = string.upper(op.Role),
			Font = F.Heavy,
			TextSize = 12,
			TextColor3 = color,
			Position = UDim2.new(0, 14, 1, -28),
			Size = UDim2.new(1, -28, 0, 14),
			Parent = card,
		})
		local roleBadge = UI.new("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = C.Void,
			BackgroundTransparency = 0.3,
			Parent = card,
		}, { UI.corner(8) })
		Icons.draw(ROLE_ICONS[op.Role], roleBadge, color, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.72, 0.72),
		})

		if op.Locked then
			lockGlyph(card)
			UI.chip(card, "1,200", C.Amber, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 14),
				BackgroundTransparency = 0.7,
			})
		elseif i == 1 then
			UI.chip(card, "MAIN", C.Green, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 14),
				BackgroundTransparency = 0.7,
			})
		end

		local shade = UI.new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = C.Void,
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = card,
		})

		card.MouseEnter:Connect(function()
			if i ~= selected then
				UI.tween(scale, 0.2, { Scale = 1.02 })
			end
		end)
		card.MouseLeave:Connect(function()
			if i ~= selected then
				UI.tween(scale, 0.2, { Scale = 1 })
			end
		end)
		card.Activated:Connect(function()
			selected = i
			refreshCards()
			renderDetail()
		end)

		cards[i] = { button = card, stroke = stroke, avatar = avatar, scale = scale, op = op, shade = shade }
	end

	for k, name in { "All", "Assault", "Scout", "Support", "Defender", "Recon" } do
		local chip: TextButton = UI.new("TextButton", {
			LayoutOrder = k,
			Text = string.upper(name),
			Font = F.Heavy,
			TextSize = 13,
			TextColor3 = C.TextDim,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 34),
			BackgroundColor3 = C.Panel,
			BackgroundTransparency = 0.1,
			Parent = filters,
		}, { UI.corner(17), UI.padding(0, 18), UI.stroke(C.Line, 0.85) })
		UI.hover(chip)
		filterButtons[name] = chip
		chip.Activated:Connect(function()
			filter = name
			refreshCards()
		end)
	end

	refreshCards()
	renderDetail()
end
