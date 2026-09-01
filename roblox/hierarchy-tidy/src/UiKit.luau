--!strict
-- A minimal set of UI controls matched to the Studio theme.

local Theme = require(script.Parent.Theme)

local UiKit = {}

local function corner(parent: Instance, radius: number)
	local instance = Instance.new("UICorner")
	instance.CornerRadius = UDim.new(0, radius)
	instance.Parent = parent
end

local function padding(parent: Instance, px: number)
	local instance = Instance.new("UIPadding")
	instance.PaddingTop = UDim.new(0, px)
	instance.PaddingBottom = UDim.new(0, px)
	instance.PaddingLeft = UDim.new(0, px)
	instance.PaddingRight = UDim.new(0, px)
	instance.Parent = parent
end

--[[ Vertical container with automatic height ]]
function UiKit.column(parent: Instance, gap: number): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, gap)
	layout.Parent = frame

	frame.Parent = parent
	return frame
end

--[[ Horizontal row, children share the width evenly ]]
function UiKit.row(parent: Instance, gap: number, height: number): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, height)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, gap)
	layout.Parent = frame

	frame.Parent = parent
	return frame
end

function UiKit.label(parent: Instance, text: string, options: { bold: boolean?, dim: boolean?, size: number? }?): TextLabel
	local opts = options or {}
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, opts.size and opts.size + 6 or 18)
	label.Font = if opts.bold then Enum.Font.GothamBold else Enum.Font.Gotham
	label.TextSize = opts.size or 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = text

	Theme.onChange(function()
		label.TextColor3 = Theme.color(if opts.dim then "DimmedText" else "MainText")
	end)

	label.Parent = parent
	return label
end

--[[ Section with a header, returns the content container ]]
function UiKit.section(parent: Instance, title: string): Frame
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BorderSizePixel = 0
	corner(card, 6)
	padding(card, 10)

	Theme.onChange(function()
		card.BackgroundColor3 = Theme.color("MainBackground")
	end)

	local content = UiKit.column(card, 6)
	UiKit.label(content, string.upper(title), { bold = true, dim = true, size = 11 })

	card.Parent = parent
	return content
end

function UiKit.button(parent: Instance, text: string, options: { primary: boolean?, width: number? }?, onClick: () -> ()): TextButton
	local opts = options or {}
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 12
	button.Text = text
	button.Size = if opts.width then UDim2.new(0, opts.width, 1, 0) else UDim2.new(1, 0, 0, 28)
	corner(button, 5)

	local hovered = false

	local function repaint()
		if opts.primary then
			button.BackgroundColor3 = Theme.color("DialogMainButton", if hovered then "Hover" else "Default")
			button.TextColor3 = Theme.color("DialogMainButtonText")
		else
			button.BackgroundColor3 = Theme.color("Button", if hovered then "Hover" else "Default")
			button.TextColor3 = Theme.color("ButtonText")
		end
	end

	Theme.onChange(repaint)

	button.MouseEnter:Connect(function()
		hovered = true
		repaint()
	end)
	button.MouseLeave:Connect(function()
		hovered = false
		repaint()
	end)
	button.MouseButton1Click:Connect(function()
		local ok, err = pcall(onClick)
		if not ok then
			warn("[HierarchyTidy] " .. tostring(err))
		end
	end)

	button.Parent = parent
	return button
end

function UiKit.input(parent: Instance, labelText: string, default: string, placeholder: string): TextBox
	local wrapper = UiKit.column(parent, 3)
	UiKit.label(wrapper, labelText, { dim = true, size = 11 })

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 26)
	box.BorderSizePixel = 1
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Code
	box.TextSize = 13
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Text = default
	box.PlaceholderText = placeholder
	corner(box, 5)

	local boxPadding = Instance.new("UIPadding")
	boxPadding.PaddingLeft = UDim.new(0, 8)
	boxPadding.PaddingRight = UDim.new(0, 8)
	boxPadding.Parent = box

	Theme.onChange(function()
		box.BackgroundColor3 = Theme.color("InputFieldBackground")
		box.BorderColor3 = Theme.color("InputFieldBorder")
		box.TextColor3 = Theme.color("MainText")
		box.PlaceholderColor3 = Theme.color("DimmedText")
	end)

	box.Parent = wrapper
	return box
end

--[[ Cycling switch — behaves like a lightweight dropdown ]]
function UiKit.cycle(
	parent: Instance,
	labelText: string,
	values: { string },
	options: { initial: string?, onChange: ((string) -> ())? }?
): { get: () -> string }
	local opts = options or {}
	local wrapper = UiKit.column(parent, 3)
	UiKit.label(wrapper, labelText, { dim = true, size = 11 })

	local index = 1
	if opts.initial then
		local found = table.find(values, opts.initial)
		if found then
			index = found
		end
	end

	local button: TextButton

	local function refresh()
		button.Text = values[index] .. "  ⇄"
	end

	button = UiKit.button(wrapper, "", nil, function()
		index = if index >= #values then 1 else index + 1
		refresh()
		if opts.onChange then
			opts.onChange(values[index])
		end
	end)
	refresh()

	return {
		get = function()
			return values[index]
		end,
	}
end

return UiKit
