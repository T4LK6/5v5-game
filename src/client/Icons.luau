--!strict
-- Flat vector-style icons built from Frames, so the prototype needs no
-- uploaded image assets. Each icon fills a square container.

local UI = require(script.Parent.UI)

local Icons = {}

type Rect = { number } -- { x, y, w, h, rotation?, cornerScale? } in 0..1 space

local SHAPES: { [string]: { Rect } } = {
	rifle = {
		{ 0.16, 0.40, 0.58, 0.13, 0, 0.2 }, -- receiver
		{ 0.72, 0.435, 0.24, 0.05, 0, 0 }, -- barrel
		{ 0.03, 0.42, 0.16, 0.17, -6, 0.2 }, -- stock
		{ 0.46, 0.52, 0.08, 0.2, 12, 0.2 }, -- mag
		{ 0.29, 0.52, 0.06, 0.16, -16, 0.3 }, -- grip
		{ 0.34, 0.31, 0.24, 0.06, 0, 0.5 }, -- optic
		{ 0.40, 0.36, 0.04, 0.05, 0, 0 },
	},
	smg = {
		{ 0.22, 0.38, 0.46, 0.15, 0, 0.2 },
		{ 0.66, 0.42, 0.18, 0.06, 0, 0 },
		{ 0.08, 0.41, 0.15, 0.08, 0, 0.2 },
		{ 0.48, 0.52, 0.07, 0.26, 4, 0.2 },
		{ 0.3, 0.52, 0.07, 0.15, -14, 0.3 },
	},
	pistol = {
		{ 0.22, 0.34, 0.56, 0.13, 0, 0.2 },
		{ 0.25, 0.45, 0.15, 0.32, -12, 0.25 },
		{ 0.4, 0.46, 0.12, 0.08, 0, 0.5 },
	},
	knife = {
		{ 0.38, 0.44, 0.56, 0.09, -28, 0.5 },
		{ 0.06, 0.6, 0.3, 0.1, -28, 0.4 },
		{ 0.33, 0.5, 0.04, 0.2, -28, 0.3 },
	},
	gadget = {
		{ 0.3, 0.36, 0.4, 0.44, 0, 1 },
		{ 0.42, 0.26, 0.16, 0.12, 0, 0.2 },
		{ 0.56, 0.2, 0.18, 0.05, 30, 0.5 },
	},
	skin = {
		{ 0.32, 0.28, 0.36, 0.52, 0, 0.25 },
		{ 0.16, 0.3, 0.16, 0.36, 14, 0.4 },
		{ 0.68, 0.3, 0.16, 0.36, -14, 0.4 },
		{ 0.42, 0.18, 0.16, 0.08, 0, 0.5 },
	},
	accessory = {
		{ 0.12, 0.4, 0.34, 0.2, 0, 0.5 },
		{ 0.54, 0.4, 0.34, 0.2, 0, 0.5 },
		{ 0.44, 0.45, 0.12, 0.05, 0, 0 },
	},
	assault = {
		{ 0.47, 0.12, 0.06, 0.26, 0, 0 },
		{ 0.47, 0.62, 0.06, 0.26, 0, 0 },
		{ 0.12, 0.47, 0.26, 0.06, 0, 0 },
		{ 0.62, 0.47, 0.26, 0.06, 0, 0 },
		{ 0.44, 0.44, 0.12, 0.12, 0, 1 },
	},
	scout = {
		{ 0.3, 0.3, 0.4, 0.4, 45, 0.15 },
	},
	support = {
		{ 0.4, 0.16, 0.2, 0.68, 0, 0.2 },
		{ 0.16, 0.4, 0.68, 0.2, 0, 0.2 },
	},
	defender = {
		{ 0.26, 0.2, 0.48, 0.42, 0, 0.15 },
		{ 0.32, 0.38, 0.36, 0.36, 45, 0.15 },
	},
	recon = {
		{ 0.18, 0.3, 0.3, 0.12, 40, 0.5 },
		{ 0.52, 0.3, 0.3, 0.12, -40, 0.5 },
		{ 0.18, 0.54, 0.3, 0.12, 40, 0.5 },
		{ 0.52, 0.54, 0.3, 0.12, -40, 0.5 },
	},
	trophy = {
		{ 0.28, 0.18, 0.44, 0.38, 0, 0.45 },
		{ 0.45, 0.54, 0.1, 0.16, 0, 0 },
		{ 0.32, 0.7, 0.36, 0.1, 0, 0.3 },
	},
	star = {
		{ 0.3, 0.3, 0.4, 0.4, 45, 0.1 },
		{ 0.3, 0.3, 0.4, 0.4, 0, 0.1 },
	},
}

-- Hollow ring used by a few icons (e.g. the scout lens).
local RINGS: { [string]: { number } } = {
	scout = { 0.5, 0.5, 0.18 },
	assault = { 0.5, 0.5, 0.3 },
}

function Icons.draw(kind: string, parent: Instance, color: Color3, props: UI.Props?): Frame
	local p: UI.Props = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local holder: Frame = UI.new("Frame", p)
	UI.new("UIAspectRatioConstraint", { AspectRatio = 1, Parent = holder })

	for _, r in SHAPES[kind] or SHAPES.star do
		local w, h = r[3], r[4]
		local rect = UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(r[1] + w / 2, r[2] + h / 2),
			Size = UDim2.fromScale(w, h),
			Rotation = r[5] or 0,
			BackgroundColor3 = color,
			Parent = holder,
		})
		local cornerScale = r[6] or 0
		if cornerScale > 0 then
			UI.new("UICorner", { CornerRadius = UDim.new(cornerScale * 0.5, 0), Parent = rect })
		end
	end

	local ring = RINGS[kind]
	if ring then
		UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(ring[1], ring[2]),
			Size = UDim2.fromScale(ring[3] * 2, ring[3] * 2),
			BackgroundTransparency = 1,
			Parent = holder,
		}, {
			UI.new("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
			UI.new("UIStroke", { Color = color, Thickness = 3 }),
		})
	end

	return holder
end

return Icons
