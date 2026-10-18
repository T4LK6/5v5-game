--!strict
-- Tiny UI toolkit: instance construction, styling helpers, and the shared
-- button/hover behavior used across every page.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(ReplicatedStorage:WaitForChild("LobbyShared"):WaitForChild("Theme"))
local C = Theme.Colors
local F = Theme.Fonts

local UI = {}

export type Props = { [string]: any }

-- new("Frame", { Size = ..., Parent = ... }, { children })
function UI.new(className: string, props: Props?, children: { any }?): any
	local inst = Instance.new(className) :: any
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		-- Labels default to no fill; buttons keep theirs (cards and pills rely on it).
		if not inst:IsA("TextButton") then
			inst.BackgroundTransparency = 1
		end
		inst.Font = F.Medium
		inst.TextColor3 = C.Text
		inst.TextSize = 16
		if inst:IsA("TextButton") then
			inst.AutoButtonColor = false
		end
	end
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		inst.BackgroundTransparency = 1
		if inst:IsA("ImageButton") then
			inst.AutoButtonColor = false
		end
	end
	local parent = nil
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function UI.corner(radius: number?): Instance
	return UI.new("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

function UI.stroke(color: Color3?, transparency: number?, thickness: number?): UIStroke
	return UI.new("UIStroke", {
		Color = color or C.Line,
		Transparency = transparency or 0.9,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.gradient(colors: { Color3 } | ColorSequence, rotation: number?, transparency: NumberSequence?): Instance
	local seq: ColorSequence
	if typeof(colors) == "ColorSequence" then
		seq = colors
	else
		local list = colors :: { Color3 }
		if #list == 1 then
			seq = ColorSequence.new(list[1])
		else
			local points = {}
			for i, color in list do
				table.insert(points, ColorSequenceKeypoint.new((i - 1) / (#list - 1), color))
			end
			seq = ColorSequence.new(points)
		end
	end
	return UI.new("UIGradient", {
		Color = seq,
		Rotation = rotation or 0,
		Transparency = transparency or NumberSequence.new(0),
	})
end

function UI.padding(all: number, horizontal: number?): Instance
	local h = horizontal or all
	return UI.new("UIPadding", {
		PaddingTop = UDim.new(0, all),
		PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, h),
		PaddingRight = UDim.new(0, h),
	})
end

function UI.list(direction: Enum.FillDirection, gap: number, hAlign: Enum.HorizontalAlignment?, vAlign: Enum.VerticalAlignment?): Instance
	return UI.new("UIListLayout", {
		FillDirection = direction,
		Padding = UDim.new(0, gap),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
	})
end

function UI.grid(cellSize: UDim2, gap: number): Instance
	return UI.new("UIGridLayout", {
		CellSize = cellSize,
		CellPadding = UDim2.fromOffset(gap, gap),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

function UI.tween(inst: Instance, time: number, goal: Props, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	local tween = TweenService:Create(
		inst,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
	return tween
end

function UI.text(props: Props): TextLabel
	local p = table.clone(props)
	p.TextXAlignment = p.TextXAlignment or Enum.TextXAlignment.Left
	return UI.new("TextLabel", p)
end

-- Glassy panel: dark fill, faint top highlight, hairline stroke.
function UI.panel(props: Props, radius: number?): Frame
	local p = table.clone(props)
	p.BackgroundColor3 = p.BackgroundColor3 or C.Panel
	p.BackgroundTransparency = p.BackgroundTransparency or 0.12
	local frame = UI.new("Frame", p)
	UI.corner(radius or 14).Parent = frame
	UI.stroke(C.Line, 0.9).Parent = frame
	UI.gradient({ Color3.new(1, 1, 1), Color3.fromRGB(200, 210, 230) }, 90).Parent = frame
	return frame
end

-- Small uppercase section header with an accent tick.
function UI.header(parent: Instance, text: string, props: Props?): Frame
	local p: Props = {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local holder = UI.new("Frame", p)
	UI.new("Frame", {
		Size = UDim2.fromOffset(3, 14),
		Position = UDim2.new(0, 0, 0.5, -7),
		BackgroundColor3 = C.Cyan,
		Parent = holder,
	})
	UI.text({
		Text = string.upper(text),
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = C.TextDim,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -12, 1, 0),
		Parent = holder,
	})
	return holder
end

-- Adds hover lift + press squish to any GuiButton.
function UI.hover(button: GuiButton, onEnter: (() -> ())?, onLeave: (() -> ())?)
	local scale = button:FindFirstChildOfClass("UIScale") or UI.new("UIScale", { Parent = button })
	button.MouseEnter:Connect(function()
		UI.tween(scale, 0.18, { Scale = 1.03 })
		if onEnter then
			onEnter()
		end
	end)
	button.MouseLeave:Connect(function()
		UI.tween(scale, 0.22, { Scale = 1 })
		if onLeave then
			onLeave()
		end
	end)
	button.MouseButton1Down:Connect(function()
		UI.tween(scale, 0.08, { Scale = 0.97 })
	end)
	button.MouseButton1Up:Connect(function()
		UI.tween(scale, 0.18, { Scale = 1.03 })
	end)
end

export type ButtonStyle = "primary" | "accent" | "ghost" | "dark"

-- Standard button. "primary" = amber hero CTA, "accent" = cyan, "ghost" = outline.
function UI.button(props: Props, style: ButtonStyle?, text: string?): TextButton
	local s = style or "dark"
	local p = table.clone(props)
	local radius = p.CornerRadius or 10
	p.CornerRadius = nil
	p.Text = text or p.Text or ""
	p.Font = p.Font or F.Heavy
	p.TextSize = p.TextSize or 17
	p.BackgroundTransparency = 0
	if s == "primary" then
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.TextColor3 = C.Void
	elseif s == "accent" then
		p.BackgroundColor3 = Color3.new(1, 1, 1)
		p.TextColor3 = C.Void
	elseif s == "ghost" then
		p.BackgroundColor3 = C.Panel
		p.BackgroundTransparency = 0.5
		p.TextColor3 = C.Text
	else
		p.BackgroundColor3 = C.PanelRaised
		p.TextColor3 = C.Text
	end
	local button: TextButton = UI.new("TextButton", p)
	UI.corner(radius).Parent = button

	if s == "primary" then
		UI.gradient({ C.Amber, C.AmberDeep }, 0).Parent = button
	elseif s == "accent" then
		UI.gradient({ C.Cyan, C.CyanDeep }, 0).Parent = button
	else
		local stroke = UI.stroke(C.Line, s == "ghost" and 0.75 or 0.88)
		stroke.Parent = button
		UI.hover(button, function()
			UI.tween(stroke, 0.18, { Transparency = 0.5 })
			UI.tween(button, 0.18, { BackgroundColor3 = C.PanelHover })
		end, function()
			UI.tween(stroke, 0.22, { Transparency = s == "ghost" and 0.75 or 0.88 })
			UI.tween(button, 0.22, { BackgroundColor3 = s == "ghost" and C.Panel or C.PanelRaised })
		end)
		return button
	end
	UI.hover(button)
	return button
end

-- A pill-shaped info chip, e.g. "EU-WEST".
function UI.chip(parent: Instance, text: string, color: Color3?, props: Props?): Frame
	local p: Props = {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		BackgroundColor3 = color or C.Cyan,
		BackgroundTransparency = 0.82,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local chip = UI.new("Frame", p)
	UI.corner(12).Parent = chip
	UI.padding(0, 10).Parent = chip
	UI.text({
		Text = text,
		Font = F.Bold,
		TextSize = 13,
		TextColor3 = color or C.Cyan,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Parent = chip,
	})
	return chip
end

-- Horizontal progress bar; returns the frame and its fill.
function UI.progress(parent: Instance, alpha: number, color: Color3?, props: Props?): (Frame, Frame)
	local p: Props = {
		Size = UDim2.new(1, 0, 0, 8),
		BackgroundColor3 = C.Void,
		BackgroundTransparency = 0.2,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local track = UI.new("Frame", p)
	UI.corner(4).Parent = track
	local fill = UI.new("Frame", {
		Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = track,
	})
	UI.corner(4).Parent = fill
	local accent = color or C.Cyan
	UI.gradient({ accent:Lerp(Color3.new(1, 1, 1), 0.25), accent }, 0).Parent = fill
	return track, fill
end

-- Diamond-shaped currency/level glyph drawn from frames.
function UI.diamond(parent: Instance, color: Color3, size: number, props: Props?): Frame
	local p: Props = {
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Rotation = 45,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local d = UI.new("Frame", p)
	UI.corner(math.floor(size * 0.2)).Parent = d
	UI.gradient({ color:Lerp(Color3.new(1, 1, 1), 0.45), color }, 45).Parent = d
	return d
end

function UI.coin(parent: Instance, color: Color3, size: number, props: Props?): Frame
	local p: Props = {
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local c = UI.new("Frame", p)
	UI.corner(size).Parent = c
	UI.gradient({ color:Lerp(Color3.new(1, 1, 1), 0.4), color, color:Lerp(Color3.new(0, 0, 0), 0.25) }, 60).Parent = c
	UI.new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = c,
	}, { UI.corner(size), UI.stroke(Color3.new(1, 1, 1), 0.35, 1.5) })
	return c
end

-- Roblox avatar thumbnail of the local player. Studio test players have
-- negative ids, so fall back to a real account to keep the image populated.
function UI.avatarUrl(kind: "head" | "body"): string
	local Players = game:GetService("Players")
	local id = Players.LocalPlayer.UserId
	if id <= 0 then
		id = 1
	end
	if kind == "head" then
		return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", id)
	end
	return string.format("rbxthumb://type=Avatar&id=%d&w=420&h=420", id)
end

-- Round avatar headshot with an accent ring.
function UI.headshot(parent: Instance, size: number, ring: Color3?, props: Props?): Frame
	local p: Props = {
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = C.PanelHover,
		Parent = parent,
	}
	if props then
		for k, v in props do
			p[k] = v
		end
	end
	local frame = UI.new("Frame", p)
	UI.corner(size).Parent = frame
	UI.gradient({ Color3.fromRGB(60, 90, 140), Color3.fromRGB(20, 30, 54) }, 90).Parent = frame
	UI.new("ImageLabel", {
		Image = UI.avatarUrl("head"),
		Size = UDim2.fromScale(1, 1),
		Parent = frame,
	}, { UI.corner(size) })
	if ring then
		UI.stroke(ring, 0, 2).Parent = frame
	end
	return frame
end

-- Marks a GuiObject for the cascade animation that plays when its page opens.
function UI.stagger(obj: GuiObject, order: number): GuiObject
	obj:SetAttribute("Stagger", order)
	return obj
end

function UI.formatNumber(n: number): string
	local s = tostring(math.floor(n))
	local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

return UI
