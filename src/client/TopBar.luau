--!strict
-- Top navigation: logo, the seven menu tabs with a sliding underline,
-- currencies, level badge and the player chip.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.UI)
local C = Theme.Colors
local F = Theme.Fonts

local TopBar = {}

local BAR_HEIGHT = 76
local TAB_WIDTH = 106
local TABS_X = 292

export type TabDef = { Name: string, Badge: string? }

export type TopBarApi = {
	setSelected: (index: number) -> (),
}

local function logo(parent: Instance)
	local holder = UI.new("Frame", {
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.fromOffset(240, BAR_HEIGHT),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local mark = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(18, BAR_HEIGHT / 2),
		Size = UDim2.fromOffset(26, 26),
		Rotation = 45,
		BackgroundTransparency = 1,
		Parent = holder,
	}, { UI.corner(4), UI.stroke(C.Cyan, 0, 3) })
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.42, 0.42),
		BackgroundColor3 = C.Amber,
		Parent = mark,
	}, { UI.corner(2) })

	UI.text({
		Text = Theme.GameTitle,
		Font = F.Display,
		TextSize = 26,
		TextColor3 = C.Text,
		Position = UDim2.fromOffset(46, 15),
		Size = UDim2.fromOffset(180, 30),
		Parent = holder,
	})
	UI.text({
		Text = Theme.GameSubtitle,
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(48, 45),
		Size = UDim2.fromOffset(180, 14),
		Parent = holder,
	})
	-- Divider between logo and tabs.
	UI.new("Frame", {
		Position = UDim2.fromOffset(TABS_X - 32 - 22, 22),
		Size = UDim2.fromOffset(1, BAR_HEIGHT - 44),
		BackgroundColor3 = C.Line,
		BackgroundTransparency = 0.85,
		Parent = holder,
	})
end

local function keyHint(parent: Instance, key: string, x: number)
	local box = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, BAR_HEIGHT / 2),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = C.PanelRaised,
		BackgroundTransparency = 0.2,
		Parent = parent,
	}, { UI.corner(5), UI.stroke(C.Line, 0.8) })
	UI.text({
		Text = key,
		Font = F.Heavy,
		TextSize = 12,
		TextColor3 = C.TextDim,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = box,
	})
end

local function currency(parent: Instance, order: number, kind: "coin" | "gem", amount: number, color: Color3)
	local pill = UI.new("Frame", {
		LayoutOrder = order,
		Size = UDim2.fromOffset(132, 36),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.25,
		Parent = parent,
	}, { UI.corner(18), UI.stroke(C.Line, 0.88) })
	if kind == "coin" then
		UI.coin(pill, color, 20, { Position = UDim2.fromOffset(9, 8) })
	else
		UI.diamond(pill, color, 15, { Position = UDim2.fromOffset(12, 10) })
	end
	UI.text({
		Text = UI.formatNumber(amount),
		Font = F.Heavy,
		TextSize = 16,
		Position = UDim2.fromOffset(37, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Parent = pill,
	})
	local add = UI.new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.75,
		Text = "+",
		Font = F.Heavy,
		TextSize = 18,
		TextColor3 = color,
		Parent = pill,
	}, { UI.corner(12) })
	UI.hover(add)
	return add
end

function TopBar.build(parent: Instance, tabs: { TabDef }, onSelect: (index: number) -> (), onStore: () -> ()): TopBarApi
	local player = Players.LocalPlayer

	local bar = UI.new("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, BAR_HEIGHT),
		BackgroundColor3 = C.Void,
		BackgroundTransparency = 0.05,
		ZIndex = 10,
		Parent = parent,
	})
	UI.gradient(
		{ Color3.new(1, 1, 1), Color3.new(1, 1, 1) },
		0,
		NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.25),
			NumberSequenceKeypoint.new(1, 0),
		})
	).Parent = bar
	-- Hairline + soft cyan glow under the bar.
	UI.new("Frame", {
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = C.Line,
		BackgroundTransparency = 0.86,
		Parent = bar,
	})
	UI.new("Frame", {
		Position = UDim2.new(0, 0, 1, 1),
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = C.Void,
		BackgroundTransparency = 0.3,
		Parent = bar,
	}, {
		UI.gradient({ C.Void }, 90, NumberSequence.new(0.2, 1)),
	})

	logo(bar)

	-- Tabs ------------------------------------------------------------------
	local strip = UI.new("Frame", {
		Position = UDim2.fromOffset(TABS_X, 0),
		Size = UDim2.fromOffset(TAB_WIDTH * #tabs, BAR_HEIGHT),
		BackgroundTransparency = 1,
		Parent = bar,
	})
	keyHint(bar, "Q", TABS_X - 14)
	keyHint(bar, "E", TABS_X + TAB_WIDTH * #tabs + 14)

	local indicator = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(TAB_WIDTH / 2, BAR_HEIGHT),
		Size = UDim2.fromOffset(TAB_WIDTH - 34, 3),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 12,
		Parent = strip,
	}, { UI.corner(2), UI.gradient({ C.Cyan, Color3.fromRGB(140, 240, 255), C.Cyan }, 0) })
	local glow = UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(TAB_WIDTH / 2, BAR_HEIGHT),
		Size = UDim2.fromOffset(TAB_WIDTH, 34),
		BackgroundColor3 = C.Cyan,
		BackgroundTransparency = 0,
		ZIndex = 11,
		Parent = strip,
	}, {
		UI.gradient({ C.Cyan }, 90, NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0.8),
		})),
	})

	local labels: { TextButton } = {}
	local selected = 1

	local function paint(index: number, hovered: boolean)
		local label = labels[index]
		local color = if index == selected then C.Text elseif hovered then Color3.fromRGB(205, 215, 235) else C.TextDim
		UI.tween(label, 0.18, { TextColor3 = color })
	end

	for i, tab in tabs do
		local button: TextButton = UI.new("TextButton", {
			Name = tab.Name,
			Position = UDim2.fromOffset((i - 1) * TAB_WIDTH, 0),
			Size = UDim2.fromOffset(TAB_WIDTH, BAR_HEIGHT),
			Text = string.upper(tab.Name),
			Font = F.Heavy,
			TextSize = 15,
			TextColor3 = C.TextDim,
			BackgroundTransparency = 1,
			ZIndex = 13,
			Parent = strip,
		})
		labels[i] = button

		if tab.Badge then
			local isDot = tab.Badge == "dot"
			local badge = UI.new("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, isDot and 28 or 24, 0, 27),
				Size = isDot and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 16),
				AutomaticSize = isDot and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
				BackgroundColor3 = isDot and C.Amber or C.Magenta,
				ZIndex = 14,
				Parent = button,
			}, { UI.corner(8) })
			if not isDot then
				UI.padding(0, 5).Parent = badge
				UI.text({
					Text = tab.Badge :: string,
					Font = F.Heavy,
					TextSize = 11,
					TextColor3 = C.Text,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromScale(0, 1),
					ZIndex = 15,
					Parent = badge,
				})
			end
		end

		button.MouseEnter:Connect(function()
			paint(i, true)
		end)
		button.MouseLeave:Connect(function()
			paint(i, false)
		end)
		button.Activated:Connect(function()
			onSelect(i)
		end)
	end

	-- Right cluster ---------------------------------------------------------
	local right = UI.new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.fromOffset(620, BAR_HEIGHT),
		BackgroundTransparency = 1,
		Parent = bar,
	}, { UI.list(Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) })

	currency(right, 1, "coin", 24850, C.Amber).Activated:Connect(onStore)
	currency(right, 2, "gem", 1240, C.Cyan).Activated:Connect(onStore)

	UI.new("Frame", {
		LayoutOrder = 3,
		Size = UDim2.fromOffset(1, 30),
		BackgroundColor3 = C.Line,
		BackgroundTransparency = 0.85,
		Parent = right,
	})

	local playerChip = UI.new("Frame", {
		LayoutOrder = 4,
		Size = UDim2.fromOffset(210, 48),
		BackgroundTransparency = 1,
		Parent = right,
	})
	UI.headshot(playerChip, 44, C.Amber, { Position = UDim2.fromOffset(0, 2) })
	-- Level badge overlapping the avatar.
	local level = UI.diamond(playerChip, C.Amber, 20, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(40, 40),
		Size = UDim2.fromOffset(20, 20),
	})
	UI.stroke(C.Void, 0, 2).Parent = level
	UI.text({
		Text = "42",
		Font = F.Heavy,
		TextSize = 11,
		TextColor3 = C.Void,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(40, 40),
		Size = UDim2.fromOffset(20, 20),
		Parent = playerChip,
	})
	UI.text({
		Text = player.DisplayName,
		Font = F.Heavy,
		TextSize = 17,
		Position = UDim2.fromOffset(58, 5),
		Size = UDim2.fromOffset(150, 20),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = playerChip,
	})
	UI.text({
		Text = "DIAMOND II  ·  LVL 42",
		Font = F.Bold,
		TextSize = 12,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(58, 26),
		Size = UDim2.fromOffset(150, 16),
		Parent = playerChip,
	})
	-- Tiny XP strip.
	UI.progress(playerChip, 0.68, C.Amber, {
		Position = UDim2.fromOffset(58, 44),
		Size = UDim2.fromOffset(120, 3),
	})

	local api = {}
	function api.setSelected(index: number)
		selected = index
		local x = (index - 1) * TAB_WIDTH + TAB_WIDTH / 2
		UI.tween(indicator, 0.42, { Position = UDim2.fromOffset(x, BAR_HEIGHT) })
		UI.tween(glow, 0.42, { Position = UDim2.fromOffset(x, BAR_HEIGHT) })
		-- Quick squash on the underline for a springy feel.
		indicator.Size = UDim2.fromOffset(TAB_WIDTH - 10, 3)
		UI.tween(indicator, 0.5, { Size = UDim2.fromOffset(TAB_WIDTH - 34, 3) })
		for i in labels do
			paint(i, false)
		end
	end
	return api
end

TopBar.Height = BAR_HEIGHT

return TopBar
