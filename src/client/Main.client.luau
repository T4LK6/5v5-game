--!strict
-- HELIX menu entry point. Builds the UI shell, wires the top navigation to
-- the seven fake pages, and drives the camera / post-FX per page.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.UI)
local Toast = require(script.Parent.Toast)
local TopBar = require(script.Parent.TopBar)
local CameraRig = require(script.Parent.CameraRig)
local SlotBillboards = require(script.Parent.SlotBillboards)
local Types = require(script.Parent.Pages.Types)
local C = Theme.Colors
local F = Theme.Fonts

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

-- Layouts: "lobby" keeps the scene clear, "focus" uses the left 60% while the
-- camera frames the hero on the right, "full" centres a wide panel over a
-- blurred scene.
type Layout = "lobby" | "focus" | "full"
type PageDef = { Name: string, Layout: Layout, Badge: string?, Build: (Frame, Types.Ctx) -> () }

local Pages = script.Parent.Pages
local PAGES: { PageDef } = {
	{ Name = "Lobby", Layout = "lobby", Build = require(Pages.Lobby) },
	{ Name = "Loadout", Layout = "focus", Build = require(Pages.Loadout) },
	{ Name = "Operators", Layout = "focus", Build = require(Pages.Operators) },
	{ Name = "Shop", Layout = "full", Badge = "NEW", Build = require(Pages.Shop) },
	{ Name = "Missions", Layout = "full", Badge = "dot", Build = require(Pages.Missions) },
	{ Name = "Profile", Layout = "focus", Build = require(Pages.Profile) },
	{ Name = "Settings", Layout = "full", Build = require(Pages.Settings) },
}

local DESIGN_HEIGHT = 1080
local MIN_DESIGN_WIDTH = 1680

----------------------------------------------------------------------------
-- Core UI housekeeping
----------------------------------------------------------------------------

task.spawn(function()
	for _ = 1, 20 do
		local ok = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		end)
		if ok then
			break
		end
		task.wait(0.25)
	end
end)

task.spawn(function()
	local ok, playerModule = pcall(function()
		return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") :: ModuleScript) :: any
	end)
	if ok and playerModule then
		playerModule:GetControls():Disable()
	end
end)

----------------------------------------------------------------------------
-- Shell
----------------------------------------------------------------------------

local screen: ScreenGui = UI.new("ScreenGui", {
	Name = "HelixMenu",
	IgnoreGuiInset = true,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = playerGui,
})

-- Everything is authored against a 1080p-tall canvas and scaled to fit.
local root: Frame = UI.new("Frame", {
	Name = "Root",
	BackgroundTransparency = 1,
	Parent = screen,
})
local rootScale: UIScale = UI.new("UIScale", { Parent = root })

local function fit()
	local viewport = workspace.CurrentCamera.ViewportSize
	if viewport.X < 2 or viewport.Y < 2 then
		return
	end
	local scale = math.min(viewport.Y / DESIGN_HEIGHT, viewport.X / MIN_DESIGN_WIDTH)
	rootScale.Scale = scale
	root.Size = UDim2.fromOffset(viewport.X / scale, viewport.Y / scale)
end
fit()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)

-- Cinematic vignettes (always on).
UI.new("Frame", {
	Name = "BottomShade",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, 380),
	BackgroundColor3 = C.Void,
	Parent = root,
}, { UI.gradient({ C.Void }, 270, NumberSequence.new(0.15, 1)) })
for _, side in { 0, 1 } do
	UI.new("Frame", {
		Name = "SideShade",
		AnchorPoint = Vector2.new(side, 0),
		Position = UDim2.fromScale(side, 0),
		Size = UDim2.new(0, 260, 1, 0),
		BackgroundColor3 = C.Void,
		Parent = root,
	}, { UI.gradient({ C.Void }, if side == 0 then 0 else 180, NumberSequence.new(0.45, 1)) })
end

-- Per-layout backdrops.
local focusShade: Frame = UI.new("Frame", {
	Name = "FocusShade",
	Size = UDim2.new(0.72, 0, 1, 0),
	BackgroundColor3 = C.Void,
	BackgroundTransparency = 1,
	Parent = root,
})
local focusGradient = UI.gradient({ C.Void }, 0, NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.7, 0.35),
	NumberSequenceKeypoint.new(1, 1),
}))
focusGradient.Parent = focusShade
local fullShade: Frame = UI.new("Frame", {
	Name = "FullShade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = C.Void,
	BackgroundTransparency = 1,
	Parent = root,
})

Toast.mount(root)

local pageArea: Frame = UI.new("Frame", {
	Name = "Pages",
	Position = UDim2.fromOffset(40, TopBar.Height + 16),
	Size = UDim2.new(1, -80, 1, -(TopBar.Height + 16 + 28)),
	BackgroundTransparency = 1,
	Parent = root,
})

----------------------------------------------------------------------------
-- Post FX
----------------------------------------------------------------------------

local blur = Lighting:WaitForChild("MenuBlur", 10) :: BlurEffect?
local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")

local function applyLayoutFx(layout: Layout)
	if layout == "focus" then
		CameraRig.setShot("Focus")
		UI.tween(focusShade, 0.5, { BackgroundTransparency = 0 })
		UI.tween(fullShade, 0.5, { BackgroundTransparency = 1 })
	elseif layout == "full" then
		CameraRig.setShot("Wide")
		UI.tween(focusShade, 0.5, { BackgroundTransparency = 1 })
		UI.tween(fullShade, 0.5, { BackgroundTransparency = 0.45 })
	else
		CameraRig.setShot("Wide")
		UI.tween(focusShade, 0.5, { BackgroundTransparency = 1 })
		UI.tween(fullShade, 0.5, { BackgroundTransparency = 1 })
	end
	if blur then
		UI.tween(blur, 0.6, { Size = if layout == "full" then 16 else 0 })
	end
	if dof then
		UI.tween(dof, 0.8, {
			FocusDistance = if layout == "focus" then 12.5 else 24,
			InFocusRadius = if layout == "focus" then 5 else 16,
			FarIntensity = if layout == "focus" then 0.55 else 0.3,
		})
	end
	SlotBillboards.setVisible(layout == "lobby")
end

----------------------------------------------------------------------------
-- Pages
----------------------------------------------------------------------------

local groups: { CanvasGroup } = {}
local current = 0
local switching = false
local topBar: TopBar.TopBarApi

local function playStagger(group: CanvasGroup)
	for _, obj in group:GetDescendants() do
		local order = obj:GetAttribute("Stagger")
		if typeof(order) ~= "number" or not obj:IsA("GuiObject") then
			continue
		end
		local parent = obj.Parent
		if parent and parent:FindFirstChildWhichIsA("UIGridStyleLayout") then
			continue
		end
		local base = obj:GetAttribute("BasePosition")
		if typeof(base) ~= "UDim2" then
			base = obj.Position
			obj:SetAttribute("BasePosition", base)
		end
		local target = base :: UDim2
		obj.Position = target + UDim2.fromOffset(0, 26)
		task.delay(0.05 + order * 0.06, function()
			UI.tween(obj, 0.55, { Position = target })
		end)
	end
end

local function switchTo(index: number)
	if index == current or switching or not groups[index] then
		return
	end
	switching = true
	local direction = if index > current then 1 else -1
	local old = groups[current]
	local new = groups[index]
	current = index
	topBar.setSelected(index)
	applyLayoutFx(PAGES[index].Layout)

	if old then
		UI.tween(old, 0.32, {
			Position = UDim2.fromOffset(-direction * 140, 0),
			GroupTransparency = 1,
		}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.32, function()
			if groups[current] ~= old then
				old.Visible = false
			end
		end)
	end

	new.Visible = true
	new.Position = UDim2.fromOffset(direction * 180, 0)
	new.GroupTransparency = 1
	task.delay(if old then 0.12 else 0, function()
		UI.tween(new, 0.55, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
		playStagger(new)
	end)
	task.delay(0.3, function()
		switching = false
	end)
end

local function indexOf(name: string): number?
	for i, def in PAGES do
		if def.Name == name then
			return i
		end
	end
	return nil
end

local ctx: Types.Ctx = {
	toast = Toast.show,
	goTo = function(name: string)
		local i = indexOf(name)
		if i then
			switchTo(i)
		end
	end,
	invite = function(slot: number)
		Toast.show("Invite a friend", string.format("Slot %02d is open — invites are visual-only in this prototype.", slot), C.Cyan)
	end,
}

for i, def in PAGES do
	local group: CanvasGroup = UI.new("CanvasGroup", {
		Name = def.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = pageArea,
	})
	local content: Frame
	if def.Layout == "lobby" then
		content = UI.new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = group })
	elseif def.Layout == "focus" then
		content = UI.new("Frame", { Size = UDim2.new(0, 1060, 1, 0), BackgroundTransparency = 1, Parent = group })
	else
		content = UI.new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(0, 1600, 1, 0),
			BackgroundTransparency = 1,
			Parent = group,
		})
	end
	content.Name = "Content"
	def.Build(content, ctx)
	groups[i] = group
end

local tabs: { TopBar.TabDef } = {}
for _, def in PAGES do
	table.insert(tabs, { Name = def.Name, Badge = def.Badge })
end
topBar = TopBar.build(root, tabs, switchTo, function()
	ctx.goTo("Shop")
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q then
		switchTo(math.max(1, current - 1))
	elseif input.KeyCode == Enum.KeyCode.E then
		switchTo(math.min(#PAGES, current + 1))
	end
end)

----------------------------------------------------------------------------
-- Intro
----------------------------------------------------------------------------

local curtain: Frame = UI.new("Frame", {
	Name = "Curtain",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = C.Void,
	ZIndex = 100,
	Parent = root,
})
local curtainTitle = UI.text({
	Text = Theme.GameTitle,
	Font = F.Display,
	TextSize = 72,
	TextColor3 = C.Text,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.46),
	Size = UDim2.fromOffset(800, 90),
	ZIndex = 101,
	Parent = curtain,
})
local curtainSub = UI.text({
	Text = Theme.SeasonName,
	Font = F.Bold,
	TextSize = 16,
	TextColor3 = C.Cyan,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.54),
	Size = UDim2.fromOffset(800, 20),
	ZIndex = 101,
	Parent = curtain,
})
local _, curtainBar = UI.progress(curtain, 0, C.Cyan, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.6),
	Size = UDim2.fromOffset(240, 3),
	ZIndex = 101,
})

local topBarFrame = root:WaitForChild("TopBar") :: Frame
topBarFrame.Position = UDim2.fromOffset(0, -TopBar.Height - 30)

CameraRig.start()
SlotBillboards.build(ctx.invite)
SlotBillboards.setVisible(false)

UI.tween(curtainBar, 1.1, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
task.wait(1.2)

-- Reveal: curtain fades, camera dollies in, UI drops into place.
UI.tween(curtain, 1.0, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
UI.tween(curtainTitle, 0.6, { TextTransparency = 1 })
UI.tween(curtainSub, 0.6, { TextTransparency = 1 })
UI.tween(curtainBar.Parent :: Frame, 0.4, { BackgroundTransparency = 1 })
UI.tween(curtainBar, 0.4, { BackgroundTransparency = 1 })
CameraRig.setShot("Wide", 1.6)
task.delay(0.6, function()
	UI.tween(topBarFrame, 0.8, { Position = UDim2.fromOffset(0, 0) })
	switchTo(1)
end)
task.delay(1.2, function()
	curtain:Destroy()
end)
