--!strict
-- Shared art direction for the HELIX lobby prototype.
-- Everything visual (scene + UI) pulls colors and fonts from here so the
-- whole menu stays on one palette.

local Theme = {}

Theme.GameTitle = "HELIX"
Theme.GameSubtitle = "TACTICAL OPS"
Theme.SeasonName = "SEASON 01 // NEON FRONTIER"

Theme.Colors = {
	-- Surfaces
	Void = Color3.fromRGB(6, 8, 15),
	Deep = Color3.fromRGB(10, 14, 24),
	Panel = Color3.fromRGB(14, 19, 32),
	PanelRaised = Color3.fromRGB(21, 28, 46),
	PanelHover = Color3.fromRGB(29, 38, 62),
	Line = Color3.fromRGB(255, 255, 255),

	-- Text
	Text = Color3.fromRGB(236, 241, 250),
	TextDim = Color3.fromRGB(150, 162, 190),
	TextFaint = Color3.fromRGB(92, 104, 132),

	-- Accents
	Cyan = Color3.fromRGB(0, 214, 255),
	CyanDeep = Color3.fromRGB(0, 120, 220),
	Amber = Color3.fromRGB(255, 186, 38),
	AmberDeep = Color3.fromRGB(255, 112, 20),
	Magenta = Color3.fromRGB(255, 64, 148),
	Green = Color3.fromRGB(64, 232, 150),
	Red = Color3.fromRGB(255, 76, 96),

	-- Rarity
	Common = Color3.fromRGB(150, 160, 180),
	Rare = Color3.fromRGB(60, 150, 255),
	Epic = Color3.fromRGB(178, 92, 255),
	Legendary = Color3.fromRGB(255, 180, 40),

	-- Scene materials
	Floor = Color3.fromRGB(13, 17, 28),
	FloorTrim = Color3.fromRGB(24, 31, 48),
	Wall = Color3.fromRGB(17, 22, 36),
	WallInset = Color3.fromRGB(11, 14, 24),
	Metal = Color3.fromRGB(40, 48, 68),
	PadTop = Color3.fromRGB(22, 28, 44),
}

Theme.Fonts = {
	Display = Enum.Font.Michroma,
	Heavy = Enum.Font.BuilderSansExtraBold,
	Bold = Enum.Font.BuilderSansBold,
	Medium = Enum.Font.BuilderSansMedium,
	Regular = Enum.Font.BuilderSans,
}

-- Rarity name -> color lookup used by item and shop cards.
Theme.Rarity = {
	Common = Theme.Colors.Common,
	Rare = Theme.Colors.Rare,
	Epic = Theme.Colors.Epic,
	Legendary = Theme.Colors.Legendary,
}

-- Lobby layout (world space). The camera sits at +Z looking toward -Z,
-- so +X reads as screen-right.
Theme.Lobby = {
	FloorY = 0,
	PadHeight = 0.9,
	Slots = {
		-- Slot 1 is the local player's hero pad: slightly forward and larger.
		{ Position = Vector3.new(-4.2, 0, 1.6), Radius = 4.4, Hero = true },
		{ Position = Vector3.new(4.2, 0, 0), Radius = 3.8, Hero = false },
		{ Position = Vector3.new(-12.4, 0, -3.4), Radius = 3.8, Hero = false },
		{ Position = Vector3.new(12.4, 0, -3.4), Radius = 3.8, Hero = false },
	},
}

return Theme
