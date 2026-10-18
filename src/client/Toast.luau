--!strict
-- Slide-in notification toasts (top-right, under the nav bar). Used to give
-- fake buttons a satisfying response.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local UI = require(script.Parent.UI)
local C = Theme.Colors
local F = Theme.Fonts

local Toast = {}

local container: Frame? = nil

function Toast.mount(parent: Instance)
	container = UI.new("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 96),
		Size = UDim2.fromOffset(340, 400),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = parent,
	}, { UI.list(Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Right) })
end

function Toast.show(title: string, body: string, accent: Color3?)
	local holder = container
	if not holder then
		return
	end
	local color = accent or C.Cyan

	-- Outer slot animates height so stacked toasts glide.
	local slot = UI.new("Frame", {
		Size = UDim2.fromOffset(340, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Parent = holder,
	})
	local card = UI.panel({
		Size = UDim2.fromOffset(340, 68),
		Position = UDim2.fromOffset(380, 0),
		BackgroundColor3 = C.PanelRaised,
		BackgroundTransparency = 0.05,
		ZIndex = 50,
		Parent = slot,
	}, 12)
	UI.new("Frame", {
		Size = UDim2.new(0, 4, 1, -20),
		Position = UDim2.fromOffset(12, 10),
		BackgroundColor3 = color,
		ZIndex = 51,
		Parent = card,
	}, { UI.corner(2) })
	UI.text({
		Text = title,
		Font = F.Heavy,
		TextSize = 16,
		TextColor3 = C.Text,
		Position = UDim2.fromOffset(28, 12),
		Size = UDim2.new(1, -40, 0, 20),
		ZIndex = 51,
		Parent = card,
	})
	UI.text({
		Text = body,
		Font = F.Medium,
		TextSize = 14,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(28, 34),
		Size = UDim2.new(1, -40, 0, 20),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 51,
		Parent = card,
	})

	UI.tween(slot, 0.25, { Size = UDim2.fromOffset(340, 68) })
	UI.tween(card, 0.45, { Position = UDim2.fromOffset(0, 0) })

	task.delay(3.2, function()
		UI.tween(card, 0.35, { Position = UDim2.fromOffset(380, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.3)
		UI.tween(slot, 0.25, { Size = UDim2.fromOffset(340, 0) })
		task.wait(0.3)
		slot:Destroy()
	end)
end

return Toast
