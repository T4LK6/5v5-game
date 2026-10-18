--!strict
-- Builds the HELIX hero bay: lighting, environment, and the four party pads.
-- Presentation only — no gameplay. The local player's character is parked on
-- the hero pad (slot 1); slots 2-4 are empty "invite" pads.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local C = Theme.Colors

local CAMERA_POS = Vector3.new(0, 6.2, 25)

----------------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------------

local root = Instance.new("Folder")
root.Name = "HelixLobby"

local function part(props: { [string]: any }, parent: Instance?): BasePart
	local className = props.ClassName or "Part"
	local p = Instance.new(className) :: BasePart
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for key, value in props do
		if key ~= "ClassName" then
			(p :: any)[key] = value
		end
	end
	p.Parent = parent or root
	return p
end

-- Cylinders in Roblox run along X; this stands one upright.
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))

local function disc(position: Vector3, diameter: number, height: number, props: { [string]: any }, parent: Instance?)
	props.Shape = Enum.PartType.Cylinder
	props.Size = Vector3.new(height, diameter, diameter)
	props.CFrame = CFrame.new(position + Vector3.new(0, height / 2, 0)) * UPRIGHT
	return part(props, parent)
end

local function neon(color: Color3, transparency: number?): { [string]: any }
	return { Material = Enum.Material.Neon, Color = color, Transparency = transparency or 0 }
end

local function merge(a: { [string]: any }, b: { [string]: any }): { [string]: any }
	local out = table.clone(a)
	for k, v in b do
		out[k] = v
	end
	return out
end

----------------------------------------------------------------------------
-- Lighting & post-processing
----------------------------------------------------------------------------

local function setupLighting()
	-- Technology is not scriptable; default.project.json sets it to Future.
	Lighting.ClockTime = 0.2
	Lighting.Brightness = 0.6
	Lighting.Ambient = Color3.fromRGB(14, 18, 30)
	Lighting.OutdoorAmbient = Color3.fromRGB(22, 28, 46)
	Lighting.ColorShift_Top = Color3.fromRGB(120, 170, 255)
	Lighting.ColorShift_Bottom = Color3.fromRGB(10, 20, 40)
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = 0.15
	Lighting.FogEnd = 100000

	for _, child in Lighting:GetChildren() do
		if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") then
			child:Destroy()
		end
	end

	local sky = Instance.new("Sky")
	sky.StarCount = 1500
	sky.CelestialBodiesShown = false
	sky.Parent = Lighting

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.32
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(46, 70, 120)
	atmosphere.Decay = Color3.fromRGB(12, 16, 34)
	atmosphere.Glare = 0
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.85
	bloom.Size = 30
	bloom.Threshold = 1.15
	bloom.Parent = Lighting

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "Grade"
	grade.Contrast = 0.14
	grade.Saturation = 0.08
	grade.Brightness = 0.01
	grade.TintColor = Color3.fromRGB(238, 244, 255)
	grade.Parent = Lighting

	local dof = Instance.new("DepthOfFieldEffect")
	dof.FocusDistance = 24
	dof.InFocusRadius = 16
	dof.FarIntensity = 0.3
	dof.NearIntensity = 0
	dof.Parent = Lighting

	-- Tweened by the client when a full-screen page opens.
	local blur = Instance.new("BlurEffect")
	blur.Name = "MenuBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

----------------------------------------------------------------------------
-- Environment
----------------------------------------------------------------------------

local function buildFloor()
	part({
		Name = "Floor",
		Size = Vector3.new(160, 1, 120),
		CFrame = CFrame.new(0, -0.5, -10),
		Color = C.Floor,
		Reflectance = 0.14,
		CanCollide = true,
	})

	-- Raised stage plate the pads sit on.
	part({
		Name = "Stage",
		Size = Vector3.new(36, 0.25, 16),
		CFrame = CFrame.new(0, 0.125, -1),
		Color = C.FloorTrim,
		Material = Enum.Material.Metal,
		Reflectance = 0.05,
	})
	part(merge(neon(C.Cyan, 0.15), {
		Name = "StageEdge",
		Size = Vector3.new(36, 0.08, 0.12),
		CFrame = CFrame.new(0, 0.26, 7),
	}))
	part(merge(neon(C.Amber, 0), {
		Name = "StageEdgeHero",
		Size = Vector3.new(7, 0.1, 0.16),
		CFrame = CFrame.new(-4.2, 0.27, 7.02),
	}))

	-- Faint floor grid in front of the stage for depth.
	for i = 0, 5 do
		local z = 9 + i * 4
		part(merge(neon(C.Cyan, 0.86 + i * 0.02), {
			Name = "GridZ",
			Size = Vector3.new(60, 0.02, 0.06),
			CFrame = CFrame.new(0, 0.011, z),
		}))
	end
	for x = -28, 28, 7 do
		part(merge(neon(C.Cyan, 0.9), {
			Name = "GridX",
			Size = Vector3.new(0.06, 0.02, 24),
			CFrame = CFrame.new(x, 0.011, 19),
		}))
	end
end

local WALL_CENTER = Vector3.new(0, 0, 10)
local WALL_RADIUS = 26
local WALL_HEIGHT = 24
local WALL_PANELS = 13
local WALL_SPAN = math.rad(130)

local function wallCFrame(angle: number, radius: number, y: number): CFrame
	local pos = WALL_CENTER + Vector3.new(math.sin(angle) * radius, y, -math.cos(angle) * radius)
	return CFrame.lookAt(pos, Vector3.new(WALL_CENTER.X, y, WALL_CENTER.Z))
end

local function surfaceGui(host: BasePart, pixelsPerStud: number, brightness: number): SurfaceGui
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = pixelsPerStud
	gui.LightInfluence = 0
	gui.Brightness = brightness
	gui.AlwaysOnTop = false
	gui.Parent = host
	return gui
end

local function label(parent: Instance, text: string, font: Enum.Font, color: Color3, pos: UDim2, size: UDim2, xAlign: Enum.TextXAlignment?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font
	l.TextColor3 = color
	l.TextScaled = true
	l.Position = pos
	l.Size = size
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Center
	l.Parent = parent
	return l
end

local function buildEmblem()
	local plate = part({
		Name = "Emblem",
		Size = Vector3.new(18, 7, 0.1),
		CFrame = wallCFrame(0, WALL_RADIUS - 1.2, 11),
		Transparency = 1,
	})
	local gui = surfaceGui(plate, 60, 2.2)

	local ring = Instance.new("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.13, 0.5)
	ring.Size = UDim2.fromOffset(260, 260)
	ring.BackgroundTransparency = 1
	ring.Rotation = 45
	ring.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = C.Cyan
	stroke.Thickness = 14
	stroke.Parent = ring
	local core = Instance.new("Frame")
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	core.Position = UDim2.fromScale(0.5, 0.5)
	core.Size = UDim2.fromScale(0.42, 0.42)
	core.BackgroundColor3 = C.Amber
	core.BorderSizePixel = 0
	core.Parent = ring

	label(gui, Theme.GameTitle, Theme.Fonts.Display, C.Text, UDim2.fromScale(0.26, 0.12), UDim2.fromScale(0.72, 0.55), Enum.TextXAlignment.Left)
	label(gui, Theme.GameSubtitle .. "  //  SQUAD HQ", Theme.Fonts.Bold, C.Cyan, UDim2.fromScale(0.265, 0.7), UDim2.fromScale(0.7, 0.16), Enum.TextXAlignment.Left)
end

local function buildWallScreen(angle: number, title: string, lines: { string })
	local screen = part({
		Name = "WallScreen",
		Size = Vector3.new(7.5, 4.4, 0.2),
		CFrame = wallCFrame(angle, WALL_RADIUS - 1.0, 8),
		Color = Color3.fromRGB(4, 8, 16),
	})
	part(merge(neon(C.Cyan, 0.35), {
		Name = "WallScreenFrame",
		Size = Vector3.new(7.9, 4.8, 0.1),
		CFrame = screen.CFrame * CFrame.new(0, 0, 0.12),
	}))
	local gui = surfaceGui(screen, 50, 1.6)
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(6, 14, 28)
	bg.BorderSizePixel = 0
	bg.Parent = gui
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new(Color3.fromRGB(20, 60, 110), Color3.fromRGB(4, 10, 22))
	gradient.Parent = bg

	label(bg, title, Theme.Fonts.Display, C.Cyan, UDim2.fromScale(0.07, 0.08), UDim2.fromScale(0.86, 0.17), Enum.TextXAlignment.Left)
	for i, line in lines do
		label(bg, line, Theme.Fonts.Bold, C.Text, UDim2.fromScale(0.07, 0.3 + (i - 1) * 0.17), UDim2.fromScale(0.86, 0.12), Enum.TextXAlignment.Left)
	end
	local bar = Instance.new("Frame")
	bar.Position = UDim2.fromScale(0.07, 0.86)
	bar.Size = UDim2.fromScale(0.55, 0.04)
	bar.BackgroundColor3 = C.Amber
	bar.BorderSizePixel = 0
	bar.Parent = bg
end

local function buildWall()
	local step = WALL_SPAN / (WALL_PANELS - 1)
	local panelWidth = 2 * WALL_RADIUS * math.sin(step / 2) + 0.15

	for i = 0, WALL_PANELS - 1 do
		local angle = -WALL_SPAN / 2 + i * step
		local fromCenter = math.abs(i - (WALL_PANELS - 1) / 2)

		part({
			Name = "WallPanel",
			Size = Vector3.new(panelWidth, WALL_HEIGHT, 1),
			CFrame = wallCFrame(angle, WALL_RADIUS, WALL_HEIGHT / 2),
			Color = C.Wall,
			Material = Enum.Material.Metal,
			Reflectance = 0.04,
		})
		-- Recessed inset for depth.
		part({
			Name = "WallInset",
			Size = Vector3.new(panelWidth * 0.78, 9, 0.3),
			CFrame = wallCFrame(angle, WALL_RADIUS - 0.6, 12.5),
			Color = C.WallInset,
		})
		-- Baseboard light.
		part(merge(neon(C.Cyan, 0.45), {
			Name = "WallBase",
			Size = Vector3.new(panelWidth * 0.86, 0.14, 0.1),
			CFrame = wallCFrame(angle, WALL_RADIUS - 0.62, 1.4),
		}))
		-- Cornice light.
		part(merge(neon(C.CyanDeep, 0.3), {
			Name = "WallTop",
			Size = Vector3.new(panelWidth, 0.2, 0.1),
			CFrame = wallCFrame(angle, WALL_RADIUS - 0.55, 20.5),
		}))

		-- Vertical seams: brighter toward the center so the eye is pulled in.
		if i > 0 then
			local seamAngle = angle - step / 2
			local seamHeight = 6 + math.max(0, 6 - fromCenter) * 1.6
			part(merge(neon(C.Cyan, 0.1 + fromCenter * 0.06), {
				Name = "WallSeam",
				Size = Vector3.new(0.18, seamHeight, 0.18),
				CFrame = wallCFrame(seamAngle, WALL_RADIUS - 0.7, 1.6 + seamHeight / 2),
			}))
		end
	end

	-- Soft wash so the wall isn't a black void.
	for _, x in { -14, 0, 14 } do
		local wash = part({
			Name = "WallWash",
			Size = Vector3.new(1, 1, 1),
			CFrame = CFrame.lookAt(Vector3.new(x, 1, -8), Vector3.new(x * 1.1, 14, -18)),
			Transparency = 1,
		})
		local light = Instance.new("SpotLight")
		light.Color = Color3.fromRGB(60, 140, 255)
		light.Brightness = 2.2
		light.Range = 22
		light.Angle = 80
		light.Face = Enum.NormalId.Front
		light.Parent = wash
	end

	buildEmblem()
	buildWallScreen(math.rad(-36), "SQUAD STATUS", { "OPERATIVES  1 / 4", "READY CHECK  PENDING", "REGION  EU-WEST" })
	buildWallScreen(math.rad(36), "INTEL FEED", { "EVENT  NEON FRONTIER", "DOUBLE XP  ACTIVE", "NEXT DROP  02:14:07" })
end

local function buildPillars()
	for _, side in { -1, 1 } do
		local base = Vector3.new(side * 19.5, 0, -5.5)
		local pillar = part({
			Name = "Pillar",
			Size = Vector3.new(2.6, 22, 2.6),
			CFrame = CFrame.new(base + Vector3.new(0, 11, 0)) * CFrame.Angles(0, math.rad(45 * side), 0),
			Color = C.Metal,
			Material = Enum.Material.Metal,
			Reflectance = 0.06,
		})
		part(merge(neon(side < 0 and C.Cyan or C.Amber, 0.05), {
			Name = "PillarStrip",
			Size = Vector3.new(0.16, 16, 0.16),
			CFrame = pillar.CFrame * CFrame.new(0, -1, -1.35),
		}))
		part({
			Name = "PillarCap",
			Size = Vector3.new(3.4, 0.6, 3.4),
			CFrame = pillar.CFrame * CFrame.new(0, -10.7, 0),
			Color = C.FloorTrim,
			Material = Enum.Material.Metal,
		})
	end

	-- Overhead light bars, out of frame but casting soft fill on the pads.
	for _, x in { -9, 0, 9 } do
		local bar = part(merge(neon(Color3.fromRGB(200, 225, 255), 0.2), {
			Name = "CeilingBar",
			Size = Vector3.new(6, 0.25, 0.6),
			CFrame = CFrame.new(x, 19, 2),
		}))
		local fill = Instance.new("SurfaceLight")
		fill.Face = Enum.NormalId.Bottom
		fill.Color = Color3.fromRGB(170, 200, 255)
		fill.Brightness = 0.8
		fill.Range = 22
		fill.Angle = 70
		fill.Parent = bar
	end
end

local function buildDust()
	local volume = part({
		Name = "DustVolume",
		Size = Vector3.new(44, 12, 22),
		CFrame = CFrame.new(0, 7, -2),
		Transparency = 1,
	})
	local dust = Instance.new("ParticleEmitter")
	dust.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	dust.Rate = 14
	dust.Lifetime = NumberRange.new(7, 12)
	dust.Speed = NumberRange.new(0.15, 0.5)
	dust.SpreadAngle = Vector2.new(180, 180)
	dust.Size = NumberSequence.new(0.12)
	dust.LightEmission = 1
	dust.Color = ColorSequence.new(Color3.fromRGB(140, 220, 255))
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.55),
		NumberSequenceKeypoint.new(0.7, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Shape = Enum.ParticleEmitterShape.Box
	dust.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	dust.Parent = volume
end

----------------------------------------------------------------------------
-- Party pads
----------------------------------------------------------------------------

local function buildPad(index: number, slot: { Position: Vector3, Radius: number, Hero: boolean })
	local folder = Instance.new("Folder")
	folder.Name = "Slot" .. index
	folder:SetAttribute("Slot", index)
	folder:SetAttribute("Hero", slot.Hero)
	folder.Parent = root

	local accent = slot.Hero and C.Amber or C.Cyan
	local r = slot.Radius
	local origin = slot.Position + Vector3.new(0, 0.25, 0) -- on top of the stage

	-- Floor light pool.
	disc(origin, r * 2 + 4, 0.02, merge(neon(accent, slot.Hero and 0.84 or 0.9), { Name = "Halo" }), folder)
	-- Body.
	disc(origin, r * 2 + 0.8, 0.5, { Name = "Base", Color = C.Metal, Material = Enum.Material.Metal, Reflectance = 0.08 }, folder)
	local ring = disc(origin + Vector3.new(0, 0.5, 0), r * 2 + 0.35, 0.12, merge(neon(accent), { Name = "Ring" }), folder)
	disc(origin + Vector3.new(0, 0.62, 0), r * 2, 0.22, { Name = "Top", Color = C.PadTop, Reflectance = 0.12 }, folder)
	-- Engraved inner ring on the top face.
	local topY = origin.Y + 0.84
	disc(Vector3.new(origin.X, topY, origin.Z), r * 1.35, 0.02, merge(neon(accent, 0.45), { Name = "InnerRing" }), folder)
	disc(Vector3.new(origin.X, topY + 0.01, origin.Z), r * 1.27, 0.02, { Name = "InnerFill", Color = C.PadTop, Reflectance = 0.12 }, folder)

	-- Light pips around the base.
	for k = 0, 11 do
		local a = k / 12 * math.pi * 2
		local p = origin + Vector3.new(math.cos(a) * (r + 0.42), 0.25, math.sin(a) * (r + 0.42))
		part(merge(neon(accent, 0.2), {
			Name = "Pip",
			Size = Vector3.new(0.12, 0.18, 0.5),
			CFrame = CFrame.lookAt(p, Vector3.new(origin.X, p.Y, origin.Z)),
		}), folder)
	end

	local glow = Instance.new("PointLight")
	glow.Color = accent
	glow.Brightness = slot.Hero and 2.4 or 1.4
	glow.Range = slot.Hero and 12 or 9
	glow.Parent = ring

	-- Where the client attaches nameplates / invite buttons.
	local anchor = part({
		Name = "Anchor",
		Size = Vector3.new(0.2, 0.2, 0.2),
		CFrame = CFrame.new(origin.X, topY, origin.Z),
		Transparency = 1,
	}, folder)

	if slot.Hero then
		-- Key light from above-front and a cool rim from behind.
		local key = part({
			Name = "KeyLight",
			Size = Vector3.new(0.5, 0.5, 0.5),
			CFrame = CFrame.lookAt(origin + Vector3.new(3, 15, 9), origin + Vector3.new(0, 2.5, 0)),
			Transparency = 1,
		}, folder)
		local spot = Instance.new("SpotLight")
		spot.Face = Enum.NormalId.Front
		spot.Color = Color3.fromRGB(255, 236, 210)
		spot.Brightness = 5
		spot.Range = 26
		spot.Angle = 32
		spot.Shadows = true
		spot.Parent = key

		local rim = part({
			Name = "RimLight",
			Size = Vector3.new(0.5, 0.5, 0.5),
			CFrame = CFrame.lookAt(origin + Vector3.new(-2, 7, -6), origin + Vector3.new(0, 3, 0)),
			Transparency = 1,
		}, folder)
		local rimSpot = Instance.new("SpotLight")
		rimSpot.Face = Enum.NormalId.Front
		rimSpot.Color = C.Cyan
		rimSpot.Brightness = 4
		rimSpot.Range = 14
		rimSpot.Angle = 50
		rimSpot.Parent = rim

		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "HeroSpawn"
		spawn.Anchored = true
		spawn.CanCollide = false
		spawn.Transparency = 1
		spawn.Size = Vector3.new(4, 0.2, 4)
		spawn.CFrame = CFrame.new(origin.X, topY + 0.1, origin.Z)
		spawn.Duration = 0
		spawn.Neutral = true
		spawn.Parent = folder
	else
		-- Holographic column above the empty pad.
		local beamHeight = 9
		disc(Vector3.new(origin.X, topY, origin.Z), r * 1.25, beamHeight, merge(neon(C.Cyan, 0.94), {
			Name = "HoloBeam",
			CastShadow = false,
		}), folder)
		disc(Vector3.new(origin.X, topY, origin.Z), r * 0.5, beamHeight * 0.75, merge(neon(C.Cyan, 0.96), {
			Name = "HoloCore",
		}), folder)
	end

	return anchor
end

----------------------------------------------------------------------------
-- Character staging
----------------------------------------------------------------------------

local function stageCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	local hrp = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	if not humanoid or not hrp then
		return
	end

	local slot = Theme.Lobby.Slots[1]
	local topY = slot.Position.Y + 0.25 + 0.84
	local feetToRoot = if humanoid.RigType == Enum.HumanoidRigType.R6 then 3 else humanoid.HipHeight + hrp.Size.Y / 2
	local pos = Vector3.new(slot.Position.X, topY + feetToRoot, slot.Position.Z)
	-- Angle toward the camera for a 3/4 hero stance.
	local facing = Vector3.new(CAMERA_POS.X + 3, pos.Y, CAMERA_POS.Z)

	humanoid.WalkSpeed = 0
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	local stance = CFrame.lookAt(pos, facing)
	hrp.Anchored = true
	character:PivotTo(stance)
	-- Spawn placement can land a frame later; re-apply once it settles.
	task.delay(0.2, function()
		if character.Parent then
			character:PivotTo(stance)
		end
	end)
end

----------------------------------------------------------------------------
-- Build
----------------------------------------------------------------------------

local existing = workspace:FindFirstChild("HelixLobby")
if existing then
	existing:Destroy()
end
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

setupLighting()
buildFloor()
buildWall()
buildPillars()
buildDust()
for index, slot in Theme.Lobby.Slots do
	buildPad(index, slot)
end
root.Parent = workspace

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(stageCharacter)
	if player.Character then
		task.spawn(stageCharacter, player.Character)
	end
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	onPlayer(player)
end
