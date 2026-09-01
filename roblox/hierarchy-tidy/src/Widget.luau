--!strict
-- Contents of the plugin's dockable window.

local Selection = game:GetService("Selection")

local Theme = require(script.Parent.Theme)
local UiKit = require(script.Parent.UiKit)
local History = require(script.Parent.History)
local Settings = require(script.Parent.Settings)
local Group = require(script.Parent.Actions.Group)
local Rename = require(script.Parent.Actions.Rename)
local Cleanup = require(script.Parent.Actions.Cleanup)
local Find = require(script.Parent.Actions.Find)

local SEARCH_LIMIT = 500

local Widget = {}

local function toNumber(text: string, fallback: number): number
	return tonumber(text) or fallback
end

--[[ Saves the field's content on focus loss so it survives a Studio restart ]]
local function persist(box: TextBox, key: string)
	box.FocusLost:Connect(function()
		Settings.set(key, box.Text)
	end)
end

--[[ Mounts the UI in the given PluginGui. Returns a cleanup function. ]]
function Widget.mount(parentGui: Instance): () -> ()
	local connections: { RBXScriptConnection } = {}

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.Size = UDim2.fromScale(1, 1)
	root.BorderSizePixel = 0

	Theme.onChange(function()
		root.BackgroundColor3 = Theme.color("ScrollBarBackground")
	end)

	local scroller = Instance.new("ScrollingFrame")
	scroller.Size = UDim2.fromScale(1, 1)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 6
	scroller.CanvasSize = UDim2.new()
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.Parent = root

	local scrollerPadding = Instance.new("UIPadding")
	scrollerPadding.PaddingTop = UDim.new(0, 10)
	scrollerPadding.PaddingBottom = UDim.new(0, 10)
	scrollerPadding.PaddingLeft = UDim.new(0, 10)
	scrollerPadding.PaddingRight = UDim.new(0, 10)
	scrollerPadding.Parent = scroller

	local page = UiKit.column(scroller, 10)

	----------------------------------------------------------------
	-- Header: selection state
	----------------------------------------------------------------
	local header = UiKit.section(page, "Selection")
	local selectionLabel = UiKit.label(header, "—", { bold = true })
	local selectionDetail = UiKit.label(header, "Select objects in the Explorer", { dim = true, size = 11 })
	selectionDetail.TextWrapped = true
	selectionDetail.Size = UDim2.new(1, 0, 0, 30)

	----------------------------------------------------------------
	-- Status (log of the last operation)
	----------------------------------------------------------------
	local statusLabel: TextLabel

	local function setStatus(text: string, isError: boolean?)
		statusLabel.Text = text
		statusLabel.TextColor3 = Theme.color(if isError then "ErrorText" else "DimmedText")
	end

	local function refreshSelection()
		local selected = Selection:Get()
		selectionLabel.Text = if #selected == 0
			then "Nothing selected"
			else string.format("%d object(s)", #selected)
		selectionDetail.Text = if #selected == 0 then "Select objects in the Explorer" else Cleanup.describe(selected)
	end

	--[[ Runs an operation on the selection inside a history recording ]]
	local function run(actionName: string, body: ({ Instance }) -> string)
		local selected = Selection:Get()
		if #selected == 0 then
			setStatus("Select something in the Explorer first.", true)
			return
		end

		local ok, result = History.record(actionName, function()
			return body(selected)
		end)

		if ok then
			setStatus(tostring(result))
		else
			setStatus(tostring(result), true)
			warn("[HierarchyTidy] " .. tostring(result))
		end
		refreshSelection()
	end

	----------------------------------------------------------------
	-- Find and select
	----------------------------------------------------------------
	local finding = UiKit.section(page, "Find and select")
	local searchBox = UiKit.input(finding, "Name fragment (empty = everything)", Settings.get("searchText", ""), "wall")
	persist(searchBox, "searchText")
	local classBox = UiKit.input(finding, "Class filter (optional)", Settings.get("searchClass", ""), "BasePart")
	persist(classBox, "searchClass")

	local searchScope = UiKit.cycle(finding, "Search in", { "Workspace", "Selection", "ServerScriptService", "StarterGui" }, {
		initial = Settings.get("searchScope", "Workspace"),
		onChange = function(value)
			Settings.set("searchScope", value)
		end,
	})

	--[[ Returns the search roots for the chosen scope ]]
	local function searchRoots(): { Instance }?
		local scopeName = searchScope.get()
		if scopeName == "Selection" then
			local selected = Selection:Get()
			if #selected == 0 then
				setStatus("Scope is the selection, but nothing is selected.", true)
				return nil
			end
			return selected
		end

		local service = Find.serviceByName(scopeName)
		if not service then
			setStatus("Service not found: " .. scopeName, true)
			return nil
		end
		return { service }
	end

	local searchRow = UiKit.row(finding, 6, 28)
	UiKit.button(searchRow, "Select matches", { primary = true, width = 130 }, function()
		local roots = searchRoots()
		if not roots then
			return
		end

		local found: { Instance } = {}
		for _, root in roots do
			for _, instance in Find.search(root, {
				text = searchBox.Text,
				className = classBox.Text,
				limit = SEARCH_LIMIT - #found,
			}) do
				table.insert(found, instance)
			end
		end

		Selection:Set(found)
		if #found == 0 then
			setStatus("No matches.")
		elseif #found >= SEARCH_LIMIT then
			setStatus(string.format("Selected %d (limit) — narrow the query.", #found))
		else
			setStatus(string.format("Matches selected: %d.", #found))
		end
	end)

	UiKit.button(searchRow, "Duplicate names", { width = 120 }, function()
		local roots = searchRoots()
		if not roots then
			return
		end

		local found: { Instance } = {}
		for _, root in roots do
			for _, instance in Find.duplicateNames(root, SEARCH_LIMIT - #found) do
				table.insert(found, instance)
			end
		end

		Selection:Set(found)
		setStatus(if #found == 0
			then "No siblings share a name."
			else string.format("Colliding names selected: %d.", #found))
	end)

	----------------------------------------------------------------
	-- Grouping
	----------------------------------------------------------------
	local grouping = UiKit.section(page, "Grouping")
	local groupNameBox = UiKit.input(grouping, "Container name", Settings.get("groupName", ""), "e.g. Building_A")
	persist(groupNameBox, "groupName")

	local groupRow = UiKit.row(grouping, 6, 28)
	UiKit.button(groupRow, "Into Folder", { primary = true, width = 90 }, function()
		run("Group into Folder", function(selected)
			local container = Group.into(selected, "Folder", groupNameBox.Text)
			Selection:Set({ container })
			return string.format('Grouped %d object(s) into "%s".', #selected, container.Name)
		end)
	end)
	UiKit.button(groupRow, "Into Model", { width = 90 }, function()
		run("Group into Model", function(selected)
			local container = Group.into(selected, "Model", groupNameBox.Text)
			Selection:Set({ container })
			return string.format('Grouped %d object(s) into "%s".', #selected, container.Name)
		end)
	end)

	UiKit.button(grouping, "Split by class (Parts / Scripts / …)", nil, function()
		run("Group by class", function(selected)
			local created = Group.byClass(selected)
			return string.format("Split %d object(s), new folders: %d.", #selected, created)
		end)
	end)

	UiKit.button(grouping, "Unpack container (children up)", nil, function()
		run("Unpack container", function(selected)
			local moved, removed = Group.flatten(selected)
			return string.format("Moved %d children, containers removed: %d.", moved, removed)
		end)
	end)

	----------------------------------------------------------------
	-- Renaming
	----------------------------------------------------------------
	local renaming = UiKit.section(page, "Renaming")
	local patternBox =
		UiKit.input(renaming, "Pattern ({n} = number, {class} = class)", Settings.get("pattern", "Part_{n}"), "Wall_{n}")
	persist(patternBox, "pattern")

	local numberRow = UiKit.row(renaming, 6, 46)
	local startWrapper = Instance.new("Frame")
	startWrapper.BackgroundTransparency = 1
	startWrapper.Size = UDim2.new(0.5, -3, 1, 0)
	startWrapper.Parent = numberRow
	local startBox = UiKit.input(startWrapper, "Start", Settings.get("startIndex", "1"), "1")
	persist(startBox, "startIndex")

	local padWrapper = Instance.new("Frame")
	padWrapper.BackgroundTransparency = 1
	padWrapper.Size = UDim2.new(0.5, -3, 1, 0)
	padWrapper.Parent = numberRow
	local padBox = UiKit.input(padWrapper, "Digits (001)", Settings.get("padding", "1"), "1")
	persist(padBox, "padding")

	local sortMode = UiKit.cycle(renaming, "Order", { "Alphabetical", "Selection order" }, {
		initial = Settings.get("sortMode", "Alphabetical"),
		onChange = function(value)
			Settings.set("sortMode", value)
		end,
	})

	UiKit.button(renaming, "Rename", { primary = true }, function()
		run("Rename", function(selected)
			local count = Rename.sequence(selected, {
				pattern = patternBox.Text,
				startIndex = toNumber(startBox.Text, 1),
				padding = toNumber(padBox.Text, 1),
				sortByName = sortMode.get() == "Alphabetical",
			})
			return string.format("Renamed: %d.", count)
		end)
	end)

	----------------------------------------------------------------
	-- Tidy up
	----------------------------------------------------------------
	local tidy = UiKit.section(page, "Tidy up")
	local scope = UiKit.cycle(tidy, "Cleanup scope", { "Selection", "Whole Workspace" }, {
		initial = Settings.get("cleanupScope", "Selection"),
		onChange = function(value)
			Settings.set("cleanupScope", value)
		end,
	})

	UiKit.button(tidy, "Remove empty Folders / Models", nil, function()
		local roots: { Instance }
		if scope.get() == "Whole Workspace" then
			roots = { workspace }
		else
			roots = Selection:Get()
			if #roots == 0 then
				setStatus("Select a container or switch the scope to Workspace.", true)
				return
			end
		end

		local ok, result = History.record("Remove empty containers", function()
			return Cleanup.removeEmpty(roots)
		end)

		if ok then
			setStatus(string.format("Empty containers removed: %d.", result))
		else
			setStatus(tostring(result), true)
		end
		refreshSelection()
	end)

	UiKit.button(tidy, "Sort LayoutOrder alphabetically", nil, function()
		run("Sort LayoutOrder", function(selected)
			local touched = Cleanup.sortLayoutOrder(selected)
			if touched == 0 then
				return "No GuiObject children to sort."
			end
			return string.format("Elements reordered: %d.", touched)
		end)
	end)

	----------------------------------------------------------------
	-- Status footer
	----------------------------------------------------------------
	local footer = UiKit.section(page, "Status")
	statusLabel = UiKit.label(footer, "Ready. Every operation supports Ctrl+Z.", { dim = true, size = 11 })
	statusLabel.TextWrapped = true
	statusLabel.Size = UDim2.new(1, 0, 0, 32)

	table.insert(connections, Selection.SelectionChanged:Connect(refreshSelection))
	refreshSelection()

	root.Parent = parentGui

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end
		root:Destroy()
	end
end

return Widget
