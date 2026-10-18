--!strict
-- Scripted menu camera: eased transitions between named shots, a slow idle
-- drift, and subtle mouse parallax so the scene feels alive.

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))

local CameraRig = {}

type Shot = { CFrame: CFrame, Fov: number }

local hero = Theme.Lobby.Slots[1].Position + Vector3.new(0, 1.1, 0)

local SHOTS: { [string]: Shot } = {
	-- Full party framing.
	Wide = {
		CFrame = CFrame.lookAt(Vector3.new(0, 6.2, 25), Vector3.new(0, 3.3, 0)),
		Fov = 40,
	},
	-- Close on the hero, pushed to screen-right so left-side panels don't cover them.
	Focus = {
		CFrame = CFrame.lookAt(hero + Vector3.new(1.5, 3.2, 12.5), hero + Vector3.new(0, 2.5, 0))
			* CFrame.Angles(0, math.rad(17), 0),
		Fov = 42,
	},
	-- Intro starting point: high and far, dollies into Wide.
	Intro = {
		CFrame = CFrame.lookAt(Vector3.new(-6, 12, 42), Vector3.new(0, 4, 0)),
		Fov = 50,
	},
}

local camera = workspace.CurrentCamera
local current: CFrame = SHOTS.Intro.CFrame
local currentFov = SHOTS.Intro.Fov
local target: Shot = SHOTS.Intro
local speed = 2.2
local parallax = Vector2.zero

function CameraRig.setShot(name: string, transitionSpeed: number?)
	local shot = SHOTS[name] or SHOTS.Wide
	if shot == target and not transitionSpeed then
		return -- already heading there; keep the current easing
	end
	target = shot
	speed = transitionSpeed or 3.2
end

function CameraRig.start()
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = current
	camera.FieldOfView = currentFov

	RunService:BindToRenderStep("HelixMenuCamera", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
		camera.CameraType = Enum.CameraType.Scriptable

		local alpha = 1 - math.exp(-dt * speed)
		current = current:Lerp(target.CFrame, alpha)
		currentFov += (target.Fov - currentFov) * alpha

		-- Mouse parallax, normalized to -1..1 around screen center.
		local viewport = camera.ViewportSize
		local mouse = UserInputService:GetMouseLocation()
		local goal = Vector2.new(
			math.clamp((mouse.X / math.max(viewport.X, 1)) * 2 - 1, -1, 1),
			math.clamp((mouse.Y / math.max(viewport.Y, 1)) * 2 - 1, -1, 1)
		)
		parallax = parallax:Lerp(goal, 1 - math.exp(-dt * 2.5))

		local t = os.clock()
		local drift = CFrame.new(math.sin(t * 0.21) * 0.25, math.sin(t * 0.33) * 0.12, 0)
			* CFrame.Angles(math.sin(t * 0.27) * 0.004, math.sin(t * 0.19) * 0.006, 0)
		local sway = CFrame.new(parallax.X * 0.45, -parallax.Y * 0.2, 0)
			* CFrame.Angles(-parallax.Y * 0.008, -parallax.X * 0.012, 0)

		camera.CFrame = current * drift * sway
		camera.FieldOfView = currentFov
	end)
end

return CameraRig
