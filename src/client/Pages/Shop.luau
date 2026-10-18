--!strict
-- SHOP: fake storefront. Featured bundle banner, a grid of item offers and a
-- currency pack row. Prices are decorative.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.Parent.UI)
local Icons = require(script.Parent.Parent.Icons)
local Types = require(script.Parent.Types)
local C = Theme.Colors
local F = Theme.Fonts

type Offer = { Name: string, Kind: string, Rarity: string, Icon: string, Price: number, Currency: "coin" | "gem", Tag: string? }

local OFFERS: { Offer } = {
	{ Name = "Nightfall DMR", Kind = "Primary Weapon", Rarity = "Legendary", Icon = "rifle", Price = 1600, Currency = "gem", Tag = "NEW" },
	{ Name = "Arctic Ops", Kind = "Operator Skin", Rarity = "Rare", Icon = "skin", Price = 4800, Currency = "coin" },
	{ Name = "Ion Cleaver", Kind = "Melee", Rarity = "Epic", Icon = "knife", Price = 950, Currency = "gem", Tag = "HOT" },
	{ Name = "Holo Goggles", Kind = "Accessory", Rarity = "Epic", Icon = "accessory", Price = 700, Currency = "gem" },
	{ Name = "Ripper SMG", Kind = "Primary Weapon", Rarity = "Rare", Icon = "smg", Price = 3200, Currency = "coin" },
	{ Name = "Recon Drone", Kind = "Gadget", Rarity = "Common", Icon = "gadget", Price = 1500, Currency = "coin" },
}

local PACKS: { { Amount: number, Bonus: string?, Price: string } } = {
	{ Amount = 500, Bonus = nil, Price = "R$ 80" },
	{ Amount = 1200, Bonus = "+10%", Price = "R$ 180" },
	{ Amount = 2800, Bonus = "+20%", Price = "R$ 400" },
	{ Amount = 6500, Bonus = "BEST VALUE", Price = "R$ 850" },
}

local function priceTag(parent: Instance, amount: number, currency: "coin" | "gem", props: UI.Props): Frame
	local p = table.clone(props)
	p.BackgroundTransparency = 1
	p.Parent = parent
	local holder = UI.new("Frame", p)
	if currency == "coin" then
		UI.coin(holder, C.Amber, 18, { Position = UDim2.new(0, 0, 0.5, -9) })
	else
		UI.diamond(holder, C.Cyan, 13, { Position = UDim2.new(0, 3, 0.5, -6) })
	end
	UI.text({
		Text = UI.formatNumber(amount),
		Font = F.Heavy,
		TextSize = 17,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -26, 1, 0),
		Parent = holder,
	})
	return holder
end

local function featured(parent: Instance, ctx: Types.Ctx)
	local banner: TextButton = UI.new("TextButton", {
		Text = "",
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.fromOffset(760, 564),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = true,
		Parent = parent,
	}, { UI.corner(18), UI.stroke(C.Legendary, 0.4, 1.5) })
	UI.stagger(banner, 1)
	UI.gradient({ Color3.fromRGB(92, 30, 150), Color3.fromRGB(30, 26, 90), Color3.fromRGB(4, 70, 120) }, 35).Parent = banner

	-- Light rays and a big diamond motif.
	for k = 0, 4 do
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.68 + k * 0.05, 0, 0.5, 0),
			Size = UDim2.fromOffset(14 + k * 6, 900),
			Rotation = 22,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.9 + k * 0.015,
			Parent = banner,
		})
	end
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.74, 0.46),
		Size = UDim2.fromOffset(330, 330),
		Rotation = 45,
		BackgroundTransparency = 1,
		Parent = banner,
	}, { UI.corner(30), UI.stroke(C.Legendary, 0.55, 3) })

	local avatar = UI.new("ImageLabel", {
		Image = UI.avatarUrl("body"),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.74, 0, 1, -40),
		Size = UDim2.fromOffset(420, 460),
		ScaleType = Enum.ScaleType.Crop,
		Parent = banner,
	})
	-- Gentle float.
	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not avatar.Parent then
			connection:Disconnect()
			return
		end
		avatar.Position = UDim2.new(0.74, 0, 1, -40 + math.sin(os.clock() * 1.2) * 5)
	end)

	UI.new("Frame", {
		Size = UDim2.new(0.62, 0, 1, 0),
		BackgroundColor3 = C.Void,
		Parent = banner,
	}, { UI.gradient({ C.Void }, 0, NumberSequence.new(0.35, 1)) })

	UI.chip(banner, "FEATURED  ·  LEGENDARY BUNDLE", C.Legendary, { Position = UDim2.fromOffset(32, 32), BackgroundTransparency = 0.7 })
	UI.text({
		Text = "NEON",
		Font = F.Display,
		TextSize = 64,
		Position = UDim2.fromOffset(30, 72),
		Size = UDim2.fromOffset(420, 72),
		Parent = banner,
	})
	UI.text({
		Text = "VANGUARD",
		Font = F.Display,
		TextSize = 64,
		TextColor3 = C.Legendary,
		Position = UDim2.fromOffset(30, 138),
		Size = UDim2.fromOffset(460, 72),
		Parent = banner,
	})
	UI.text({
		Text = "The Season 01 signature collection. Reactive neon trims, a charged Arc Blade and a floating Halo Crown.",
		Font = F.Medium,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(215, 210, 240),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(32, 222),
		Size = UDim2.fromOffset(380, 66),
		Parent = banner,
	})

	local contents = { { "skin", "Neon Vanguard Skin" }, { "knife", "Arc Blade" }, { "accessory", "Halo Crown" }, { "star", "1,000 Shards" } }
	for k, entry in contents do
		local y = 300 + (k - 1) * 38
		local box = UI.new("Frame", {
			Position = UDim2.fromOffset(32, y),
			Size = UDim2.fromOffset(30, 30),
			BackgroundColor3 = C.Void,
			BackgroundTransparency = 0.4,
			Parent = banner,
		}, { UI.corner(8) })
		Icons.draw(entry[1], box, C.Legendary, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
		})
		UI.text({
			Text = entry[2],
			Font = F.Bold,
			TextSize = 15,
			Position = UDim2.fromOffset(74, y),
			Size = UDim2.fromOffset(300, 30),
			Parent = banner,
		})
	end

	-- Price + buy.
	UI.chip(banner, "-25%", C.Green, { Position = UDim2.fromOffset(32, 470), BackgroundTransparency = 0.7 })
	UI.text({
		Text = "<s>2,400</s>",
		RichText = true,
		Font = F.Bold,
		TextSize = 16,
		TextColor3 = C.TextFaint,
		Position = UDim2.fromOffset(98, 470),
		Size = UDim2.fromOffset(80, 24),
		Parent = banner,
	})
	priceTag(banner, 1800, "gem", { Position = UDim2.fromOffset(32, 500), Size = UDim2.fromOffset(140, 30) })
	local buy = UI.button({
		Position = UDim2.fromOffset(190, 478),
		Size = UDim2.fromOffset(220, 56),
		TextSize = 18,
		Parent = banner,
	}, "primary", "PURCHASE")
	buy.Activated:Connect(function()
		ctx.toast("Store preview", "Purchases are disabled in this showcase build.", C.Legendary)
	end)
	UI.text({
		Text = "LEAVES IN 2D 14H",
		Font = F.Heavy,
		TextSize = 12,
		TextColor3 = C.Legendary,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -20),
		Size = UDim2.fromOffset(200, 14),
		Parent = banner,
	})
end

local function offerCard(parent: Instance, offer: Offer, order: number, ctx: Types.Ctx)
	local color = Theme.Rarity[offer.Rarity]
	local card: TextButton = UI.new("TextButton", {
		Text = "",
		LayoutOrder = order,
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.05,
		ClipsDescendants = true,
		Parent = parent,
	}, { UI.corner(14) })
	local stroke = UI.stroke(C.Line, 0.88)
	stroke.Parent = card
	UI.hover(card, function()
		UI.tween(stroke, 0.2, { Color = color, Transparency = 0.2 })
	end, function()
		UI.tween(stroke, 0.2, { Color = C.Line, Transparency = 0.88 })
	end)

	local art = UI.new("Frame", {
		Size = UDim2.new(1, 0, 0, 170),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = card,
	})
	UI.gradient({ color:Lerp(C.Void, 0.35), color:Lerp(C.Void, 0.8) }, 115).Parent = art
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(140, 140),
		Rotation = 45,
		BackgroundTransparency = 1,
		Parent = art,
	}, { UI.corner(18), UI.stroke(color, 0.6, 2) })
	Icons.draw(offer.Icon, art, Color3.new(1, 1, 1), {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(150, 150),
	})
	UI.new("Frame", {
		Position = UDim2.new(0, 0, 0, 170),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = color,
		Parent = card,
	})
	if offer.Tag then
		UI.chip(art, offer.Tag, if offer.Tag == "HOT" then C.Red else C.Green, {
			Position = UDim2.fromOffset(12, 12),
			BackgroundTransparency = 0.6,
		})
	end
	UI.text({
		Text = offer.Name,
		Font = F.Heavy,
		TextSize = 17,
		Position = UDim2.fromOffset(16, 184),
		Size = UDim2.new(1, -32, 0, 20),
		Parent = card,
	})
	UI.text({
		Text = string.upper(offer.Rarity) .. "  ·  " .. string.upper(offer.Kind),
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = color,
		Position = UDim2.fromOffset(16, 206),
		Size = UDim2.new(1, -32, 0, 14),
		Parent = card,
	})
	priceTag(card, offer.Price, offer.Currency, { Position = UDim2.fromOffset(16, 230), Size = UDim2.fromOffset(120, 26) })

	card.Activated:Connect(function()
		ctx.toast(offer.Name, "Store is visual-only in this prototype.", color)
	end)
end

local function packs(parent: Instance, ctx: Types.Ctx)
	local row = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 680),
		Size = UDim2.fromOffset(1600, 170),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	UI.stagger(row, 3)
	UI.header(row, "Shard Packs")
	local list = UI.new("Frame", {
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 0, 130),
		BackgroundTransparency = 1,
		Parent = row,
	}, { UI.list(Enum.FillDirection.Horizontal, 20) })

	for k, pack in PACKS do
		local card = UI.button({
			LayoutOrder = k,
			Size = UDim2.fromOffset(385, 120),
			Parent = list,
		}, "dark", "")
		-- A cluster of gems, growing with the pack size.
		for g = 1, k + 1 do
			UI.diamond(card, C.Cyan, 26 - g, {
				Size = UDim2.fromOffset(30 - g * 2, 30 - g * 2),
				Position = UDim2.fromOffset(22 + (g - 1) * 16, 30 + (g % 2) * 26),
			})
		end
		UI.text({
			Text = UI.formatNumber(pack.Amount),
			Font = F.Display,
			TextSize = 24,
			Position = UDim2.fromOffset(150, 26),
			Size = UDim2.fromOffset(200, 30),
			Parent = card,
		})
		UI.text({
			Text = "HELIX SHARDS",
			Font = F.Bold,
			TextSize = 12,
			TextColor3 = C.Cyan,
			Position = UDim2.fromOffset(152, 60),
			Size = UDim2.fromOffset(200, 14),
			Parent = card,
		})
		UI.text({
			Text = pack.Price,
			Font = F.Heavy,
			TextSize = 16,
			TextColor3 = C.Text,
			Position = UDim2.fromOffset(152, 82),
			Size = UDim2.fromOffset(120, 18),
			Parent = card,
		})
		if pack.Bonus then
			UI.chip(card, pack.Bonus, if k == #PACKS then C.Amber else C.Green, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 14),
				BackgroundTransparency = 0.7,
			})
		end
		card.Activated:Connect(function()
			ctx.toast(UI.formatNumber(pack.Amount) .. " Shards", "Purchases are disabled in this showcase build.", C.Cyan)
		end)
	end
end

return function(content: Frame, ctx: Types.Ctx)
	UI.stagger(UI.text({
		Text = "SHOP",
		Font = F.Display,
		TextSize = 34,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(300, 42),
		Parent = content,
	}), 0)
	UI.stagger(UI.text({
		Text = "NEW OFFERS EVERY DAY",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.Cyan,
		Position = UDim2.fromOffset(2, 58),
		Size = UDim2.fromOffset(300, 18),
		Parent = content,
	}), 0)

	-- Section tabs.
	local sections = UI.new("Frame", {
		Position = UDim2.fromOffset(260, 22),
		Size = UDim2.fromOffset(700, 40),
		BackgroundTransparency = 1,
		Parent = content,
	}, { UI.list(Enum.FillDirection.Horizontal, 8) })
	UI.stagger(sections, 0)
	local sectionButtons: { TextButton } = {}
	for k, name in { "FEATURED", "DAILY", "BUNDLES", "CURRENCY" } do
		local b: TextButton = UI.new("TextButton", {
			LayoutOrder = k,
			Text = name,
			Font = F.Heavy,
			TextSize = 13,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 36),
			BackgroundColor3 = if k == 1 then C.Cyan else C.Panel,
			TextColor3 = if k == 1 then C.Void else C.TextDim,
			Parent = sections,
		}, { UI.corner(18), UI.padding(0, 18), UI.stroke(C.Line, 0.85) })
		UI.hover(b)
		sectionButtons[k] = b
		b.Activated:Connect(function()
			for j, other in sectionButtons do
				UI.tween(other, 0.2, {
					BackgroundColor3 = if j == k then C.Cyan else C.Panel,
					TextColor3 = if j == k then C.Void else C.TextDim,
				})
			end
		end)
	end

	-- Reset timer (ticks down for flavour).
	local timer = UI.text({
		Text = "",
		Font = F.Heavy,
		TextSize = 14,
		TextColor3 = C.TextDim,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 34),
		Size = UDim2.fromOffset(300, 18),
		Parent = content,
	})
	local resetAt = os.clock() + 7 * 3600 + 42 * 60 + 13
	task.spawn(function()
		while timer.Parent do
			local left = math.max(0, math.floor(resetAt - os.clock()))
			timer.Text = string.format("DAILY RESET  %02d:%02d:%02d", left // 3600, (left % 3600) // 60, left % 60)
			task.wait(1)
		end
	end)

	featured(content, ctx)

	local grid = UI.new("Frame", {
		Position = UDim2.fromOffset(780, 96),
		Size = UDim2.fromOffset(820, 564),
		BackgroundTransparency = 1,
		Parent = content,
	}, { UI.grid(UDim2.fromOffset(260, 272), 20) })
	UI.stagger(grid, 2)
	for k, offer in OFFERS do
		offerCard(grid, offer, k, ctx)
	end

	packs(content, ctx)
end
