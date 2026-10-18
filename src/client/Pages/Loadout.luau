--!strict
-- LOADOUT: fake equipment page. Category slots on the left, item grid in the
-- middle, detail + Equip on the right. All state is local and throwaway.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

type Item = { Name: string, Rarity: string, Icon: string, Stats: { number }, Blurb: string }
type Category = { Name: string, Items: { Item } }

local STAT_NAMES = { "DAMAGE", "FIRE RATE", "RANGE", "MOBILITY" }

local CATEGORIES: { Category } = {
	{ Name = "Primary", Items = {
		{ Name = "Halcyon AR", Rarity = "Epic", Icon = "rifle", Stats = { 0.72, 0.68, 0.7, 0.55 }, Blurb = "Balanced assault rifle with a crisp holo optic." },
		{ Name = "VX-9 Striker", Rarity = "Rare", Icon = "rifle", Stats = { 0.64, 0.74, 0.6, 0.6 }, Blurb = "Fast-cycling rifle favoured by entry fraggers." },
		{ Name = "Nightfall DMR", Rarity = "Legendary", Icon = "rifle", Stats = { 0.92, 0.38, 0.95, 0.42 }, Blurb = "Precision marksman platform. One tap, one story." },
		{ Name = "Kestrel SMG", Rarity = "Common", Icon = "smg", Stats = { 0.48, 0.9, 0.35, 0.86 }, Blurb = "Compact and forgiving up close." },
		{ Name = "Ripper SMG", Rarity = "Rare", Icon = "smg", Stats = { 0.55, 0.94, 0.3, 0.82 }, Blurb = "Shreds at short range. Hungry for ammo." },
		{ Name = "Echo Carbine", Rarity = "Common", Icon = "rifle", Stats = { 0.58, 0.6, 0.62, 0.7 }, Blurb = "Reliable standard-issue carbine." },
	} },
	{ Name = "Secondary", Items = {
		{ Name = "Vesper Auto", Rarity = "Rare", Icon = "pistol", Stats = { 0.42, 0.85, 0.35, 0.92 }, Blurb = "Machine pistol for panic moments." },
		{ Name = "M7 Sidearm", Rarity = "Common", Icon = "pistol", Stats = { 0.45, 0.6, 0.45, 0.9 }, Blurb = "Dependable backup pistol." },
		{ Name = "Duke .50", Rarity = "Epic", Icon = "pistol", Stats = { 0.88, 0.3, 0.6, 0.75 }, Blurb = "Hand cannon. Loud and decisive." },
		{ Name = "Pulse Pistol", Rarity = "Legendary", Icon = "pistol", Stats = { 0.7, 0.62, 0.55, 0.85 }, Blurb = "Experimental energy sidearm." },
	} },
	{ Name = "Melee", Items = {
		{ Name = "Arc Blade", Rarity = "Epic", Icon = "knife", Stats = { 0.8, 0.6, 0.12, 0.95 }, Blurb = "Charged edge with a cyan arc trail." },
		{ Name = "Combat Knife", Rarity = "Common", Icon = "knife", Stats = { 0.6, 0.7, 0.1, 0.95 }, Blurb = "Standard field knife." },
		{ Name = "Tanto", Rarity = "Rare", Icon = "knife", Stats = { 0.7, 0.65, 0.12, 0.92 }, Blurb = "Angular blade, quick draw." },
		{ Name = "Ion Cleaver", Rarity = "Legendary", Icon = "knife", Stats = { 0.95, 0.4, 0.15, 0.8 }, Blurb = "Heavy, humming, unforgettable." },
	} },
	{ Name = "Gadget", Items = {
		{ Name = "Recon Drone", Rarity = "Epic", Icon = "gadget", Stats = { 0.1, 0.4, 0.95, 0.8 }, Blurb = "Scouts ahead and pings enemies." },
		{ Name = "Frag Grenade", Rarity = "Common", Icon = "gadget", Stats = { 0.85, 0.2, 0.5, 0.7 }, Blurb = "Classic. Cooks in 3 seconds." },
		{ Name = "Flash Charge", Rarity = "Rare", Icon = "gadget", Stats = { 0.1, 0.3, 0.55, 0.75 }, Blurb = "Blinds anyone looking its way." },
		{ Name = "Smoke Canister", Rarity = "Common", Icon = "gadget", Stats = { 0, 0.2, 0.6, 0.75 }, Blurb = "Instant cover for pushes and revives." },
	} },
	{ Name = "Skin", Items = {
		{ Name = "Neon Vanguard", Rarity = "Legendary", Icon = "skin", Stats = { 0, 0, 0, 0 }, Blurb = "Season 01 signature suit with reactive glow." },
		{ Name = "Standard Issue", Rarity = "Common", Icon = "skin", Stats = { 0, 0, 0, 0 }, Blurb = "Clean tactical fatigues." },
		{ Name = "Arctic Ops", Rarity = "Rare", Icon = "skin", Stats = { 0, 0, 0, 0 }, Blurb = "White-out camo for cold insertions." },
		{ Name = "Crimson Unit", Rarity = "Epic", Icon = "skin", Stats = { 0, 0, 0, 0 }, Blurb = "Elite red-trim officer kit." },
	} },
	{ Name = "Accessory", Items = {
		{ Name = "Tac Visor", Rarity = "Rare", Icon = "accessory", Stats = { 0, 0, 0, 0 }, Blurb = "Tinted HUD visor." },
		{ Name = "Holo Goggles", Rarity = "Epic", Icon = "accessory", Stats = { 0, 0, 0, 0 }, Blurb = "Projected lenses with scan-line shimmer." },
		{ Name = "Field Cap", Rarity = "Common", Icon = "accessory", Stats = { 0, 0, 0, 0 }, Blurb = "Low-profile operator cap." },
		{ Name = "Halo Crown", Rarity = "Legendary", Icon = "accessory", Stats = { 0, 0, 0, 0 }, Blurb = "Floating ring of light. Flex responsibly." },
	} },
}

return function(page: Frame, ctx: Types.Ctx)
	local equipped: { number } = {}
	for i in CATEGORIES do
		equipped[i] = 1
	end
	local categoryIndex = 1
	local itemIndex = 1

	-- Title ----------------------------------------------------------------
	UI.stagger(UI.text({
		Text = "LOADOUT",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(400, 42),
		Parent = page,
	}), 0)
	UI.stagger(UI.text({
		Text = "KIT 01  ·  ASSAULT PRESET",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(400, 18),
		Parent = page,
	}), 0)
	for k = 1, 3 do
		local preset = UI.button({
			Position = UDim2.fromOffset(780 + (k - 1) * 52, 24),
			Size = UDim2.fromOffset(44, 36),
			TextSize = 14,
			Parent = page,
		}, if k == 1 then "accent" else "ghost", string.format("%02d", k))
		preset.Activated:Connect(function()
			ctx.toast("Kit " .. string.format("%02d", k), "Loadout presets are visual-only in this prototype.")
		end)
	end

	local body = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(1060, 640),
		BackgroundTransparency = 1,
		Parent = page,
	})

	-- Columns ----------------------------------------------------------------
	local slotColumn = UI.new("Frame", {
		Size = UDim2.fromOffset(300, 640),
		BackgroundTransparency = 1,
		Parent = body,
	}, { UI.list(Enum.FillDirection.Vertical, 10) })
	UI.stagger(slotColumn, 1)

	local gridHolder = UI.panel({
		Position = UDim2.fromOffset(320, 0),
		Size = UDim2.fromOffset(420, 610),
		Parent = body,
	}, 16)
	UI.stagger(gridHolder, 2)
	local gridTitle = UI.header(gridHolder, "PRIMARY", { Position = UDim2.fromOffset(20, 16), Size = UDim2.new(1, -40, 0, 22) })
	local gridTitleLabel = gridTitle:FindFirstChildOfClass("TextLabel") :: TextLabel
	local grid = UI.new("Frame", {
		Position = UDim2.fromOffset(20, 52),
		Size = UDim2.new(1, -40, 1, -70),
		BackgroundTransparency = 1,
		Parent = gridHolder,
	}, { UI.grid(UDim2.fromOffset(184, 170), 12) })

	local detail = UI.panel({
		Position = UDim2.fromOffset(760, 0),
		Size = UDim2.fromOffset(300, 610),
		Parent = body,
	}, 16)
	UI.stagger(detail, 3)

	-- Detail panel contents (rebuilt on selection).
	local detailContent = UI.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = detail })
	local equipButton: TextButton = UI.button({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -20),
		Size = UDim2.new(1, -40, 0, 52),
		TextSize = 18,
		Parent = detail,
	}, "primary", "EQUIP")

	local slotCards: { { frame: TextButton, stroke: UIStroke, name: TextLabel, rarity: Frame, icon: Frame } } = {}
	local refreshSlots: () -> ()
	local renderGrid: () -> ()

	local function renderDetail()
		detailContent:ClearAllChildren()
		local item = CATEGORIES[categoryIndex].Items[itemIndex]
		local color = Theme.Rarity[item.Rarity]

		local hero = UI.new("Frame", {
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.new(1, -32, 0, 170),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = detailContent,
		}, { UI.corner(12) })
		UI.gradient({ color:Lerp(C.Void, 0.45), C.Void:Lerp(color, 0.08) }, 120).Parent = hero
		Icons.draw(item.Icon, hero, Color3.new(1, 1, 1), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.78, 0.78),
		})

		UI.text({
			Text = string.upper(item.Rarity),
			Font = F.Heavy,
			TextSize = 12,
			TextColor3 = color,
			Position = UDim2.fromOffset(20, 200),
			Size = UDim2.new(1, -40, 0, 14),
			Parent = detailContent,
		})
		UI.text({
			Text = item.Name,
			Font = F.Display,
			TextSize = 20,
			Position = UDim2.fromOffset(20, 216),
			Size = UDim2.new(1, -40, 0, 28),
			Parent = detailContent,
		})
		UI.text({
			Text = item.Blurb,
			Font = F.Medium,
			TextSize = 14,
			TextColor3 = C.TextDim,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(20, 250),
			Size = UDim2.new(1, -40, 0, 40),
			Parent = detailContent,
		})

		local hasStats = item.Stats[1] + item.Stats[2] + item.Stats[3] + item.Stats[4] > 0
		if hasStats then
			for s, statName in STAT_NAMES do
				local y = 304 + (s - 1) * 44
				UI.text({
					Text = statName,
					Font = F.Bold,
					TextSize = 12,
					TextColor3 = C.TextDim,
					Position = UDim2.fromOffset(20, y),
					Size = UDim2.fromOffset(150, 14),
					Parent = detailContent,
				})
				UI.text({
					Text = tostring(math.floor(item.Stats[s] * 100)),
					Font = F.Heavy,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					Position = UDim2.new(1, -60, 0, y),
					Size = UDim2.fromOffset(40, 14),
					Parent = detailContent,
				})
				local _, fill = UI.progress(detailContent, 0, color, {
					Position = UDim2.fromOffset(20, y + 20),
					Size = UDim2.new(1, -40, 0, 6),
				})
				UI.tween(fill, 0.6 + s * 0.08, { Size = UDim2.fromScale(item.Stats[s], 1) })
			end
		else
			UI.chip(detailContent, "COSMETIC  ·  NO STAT CHANGES", C.Cyan, { Position = UDim2.fromOffset(20, 306) })
		end

		local isEquipped = equipped[categoryIndex] == itemIndex
		equipButton.Text = if isEquipped then "EQUIPPED" else "EQUIP"
		equipButton.AutoButtonColor = false
		;(equipButton:FindFirstChildOfClass("UIGradient") :: UIGradient).Color = if isEquipped
			then ColorSequence.new(C.Green, Color3.fromRGB(20, 170, 110))
			else ColorSequence.new(C.Amber, C.AmberDeep)
	end

	renderGrid = function()
		grid:ClearAllChildren()
		UI.grid(UDim2.fromOffset(184, 170), 12).Parent = grid
		local category = CATEGORIES[categoryIndex]
		gridTitleLabel.Text = string.upper(category.Name) .. "  ·  " .. #category.Items .. " OWNED"

		for i, item in category.Items do
			local color = Theme.Rarity[item.Rarity]
			local isSelected = i == itemIndex
			local card: TextButton = UI.new("TextButton", {
				Text = "",
				LayoutOrder = i,
				BackgroundColor3 = if isSelected then C.PanelHover else C.PanelRaised,
				Parent = grid,
			}, { UI.corner(12) })
			local stroke = UI.stroke(if isSelected then C.Cyan else C.Line, if isSelected then 0 else 0.88, if isSelected then 2 else 1)
			stroke.Parent = card
			UI.hover(card)

			local art = UI.new("Frame", {
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.new(1, -16, 0, 104),
				BackgroundColor3 = Color3.new(1, 1, 1),
				Parent = card,
			}, { UI.corner(8) })
			UI.gradient({ color:Lerp(C.Void, 0.55), C.Void }, 110).Parent = art
			Icons.draw(item.Icon, art, Color3.fromRGB(235, 240, 250), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),
			})
			UI.new("Frame", {
				Position = UDim2.new(0, 8, 0, 112),
				Size = UDim2.new(1, -16, 0, 3),
				BackgroundColor3 = color,
				Parent = card,
			})
			UI.text({
				Text = item.Name,
				Font = F.Heavy,
				TextSize = 15,
				Position = UDim2.fromOffset(12, 122),
				Size = UDim2.new(1, -24, 0, 18),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = card,
			})
			UI.text({
				Text = string.upper(item.Rarity),
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = color,
				Position = UDim2.fromOffset(12, 142),
				Size = UDim2.new(1, -24, 0, 14),
				Parent = card,
			})
			if equipped[categoryIndex] == i then
				UI.chip(card, "EQUIPPED", C.Green, {
					Position = UDim2.fromOffset(14, 14),
					Size = UDim2.fromOffset(0, 20),
					BackgroundTransparency = 0.7,
				})
			end

			card.Activated:Connect(function()
				itemIndex = i
				renderGrid()
				renderDetail()
			end)
		end
	end

	refreshSlots = function()
		for i, slot in slotCards do
			local isSelected = i == categoryIndex
			local item = CATEGORIES[i].Items[equipped[i]]
			slot.name.Text = item.Name
			slot.rarity.BackgroundColor3 = Theme.Rarity[item.Rarity]
			UI.tween(slot.stroke, 0.2, { Color = if isSelected then C.Cyan else C.Line, Transparency = if isSelected then 0 else 0.88 })
			UI.tween(slot.frame, 0.2, { BackgroundColor3 = if isSelected then C.PanelHover else C.Panel })
			slot.icon:Destroy()
			slot.icon = Icons.draw(item.Icon, slot.frame, if isSelected then C.Cyan else C.TextDim, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(64, 64),
			})
		end
	end

	for i, category in CATEGORIES do
		local card: TextButton = UI.new("TextButton", {
			Text = "",
			LayoutOrder = i,
			Size = UDim2.fromOffset(300, 92),
			BackgroundColor3 = C.Panel,
			BackgroundTransparency = 0.1,
			Parent = slotColumn,
		}, { UI.corner(12) })
		local stroke = UI.stroke(C.Line, 0.88)
		stroke.Parent = card
		UI.hover(card)
		local rarity = UI.new("Frame", {
			Position = UDim2.fromOffset(0, 18),
			Size = UDim2.fromOffset(3, 56),
			BackgroundColor3 = C.Common,
			Parent = card,
		})
		UI.text({
			Text = string.upper(category.Name),
			Font = F.Bold,
			TextSize = 12,
			TextColor3 = C.TextFaint,
			Position = UDim2.fromOffset(18, 24),
			Size = UDim2.fromOffset(180, 14),
			Parent = card,
		})
		local name = UI.text({
			Text = "",
			Font = F.Heavy,
			TextSize = 18,
			Position = UDim2.fromOffset(18, 42),
			Size = UDim2.fromOffset(190, 22),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
		local icon = UI.new("Frame", { BackgroundTransparency = 1, Parent = card })
		slotCards[i] = { frame = card, stroke = stroke, name = name, rarity = rarity, icon = icon }

		card.Activated:Connect(function()
			categoryIndex = i
			itemIndex = equipped[i]
			refreshSlots()
			renderGrid()
			renderDetail()
		end)
	end

	equipButton.Activated:Connect(function()
		if equipped[categoryIndex] == itemIndex then
			return
		end
		equipped[categoryIndex] = itemIndex
		local item = CATEGORIES[categoryIndex].Items[itemIndex]
		ctx.toast("Equipped " .. item.Name, CATEGORIES[categoryIndex].Name .. " slot updated.", Theme.Rarity[item.Rarity])
		refreshSlots()
		renderGrid()
		renderDetail()
	end)

	refreshSlots()
	renderGrid()
	renderDetail()
end
