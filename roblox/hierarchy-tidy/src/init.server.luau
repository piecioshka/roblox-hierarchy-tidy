--!strict
-- HierarchyTidy — tidying up the hierarchy in Roblox Studio.
-- Entry point: toolbar, dockable window and keyboard shortcuts.

local Selection = game:GetService("Selection")

local Theme = require(script.Theme)
local Widget = require(script.Widget)
local Settings = require(script.Settings)
local History = require(script.History)
local Group = require(script.Actions.Group)
local Cleanup = require(script.Actions.Cleanup)

local PLUGIN_NAME = "Hierarchy Tidy"
local WIDGET_ID = "HierarchyTidy_MainWidget"

Settings.init(plugin)

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local toggleButton = toolbar:CreateButton(
	"HierarchyTidyToggle",
	"Open the hierarchy tidying panel",
	"", -- swap in your own rbxassetid if you want an icon
	"Hierarchy Tidy"
)
toggleButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	Settings.get("widgetOpen", false), -- state from the previous session
	false, -- do not override the previous state
	320, -- width
	520, -- height
	280, -- min width
	360 -- min height
)

local widgetGui = plugin:CreateDockWidgetPluginGui(WIDGET_ID, widgetInfo)
widgetGui.Name = "HierarchyTidy"
widgetGui.Title = PLUGIN_NAME
widgetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local unmount: (() -> ())? = nil

local function ensureMounted()
	if widgetGui.Enabled and not unmount then
		unmount = Widget.mount(widgetGui)
	end
end

toggleButton.Click:Connect(function()
	widgetGui.Enabled = not widgetGui.Enabled
end)

widgetGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	toggleButton:SetActive(widgetGui.Enabled)
	Settings.set("widgetOpen", widgetGui.Enabled)
	ensureMounted()
end)

toggleButton:SetActive(widgetGui.Enabled)
ensureMounted()

----------------------------------------------------------------
-- Keyboard shortcuts (File → Advanced → Customize Shortcuts)
----------------------------------------------------------------

--[[ Creates an action with its own shortcut, wrapped in a history recording ]]
local function createAction(id: string, label: string, tip: string, body: ({ Instance }) -> string)
	local action = plugin:CreatePluginAction(id, label, tip, "", true)
	action.Triggered:Connect(function()
		local selected = Selection:Get()
		if #selected == 0 then
			warn("[HierarchyTidy] Select something in the Explorer first.")
			return
		end

		local ok, result = History.record(label, function()
			return body(selected)
		end)
		if ok then
			print("[HierarchyTidy] " .. tostring(result))
		else
			warn("[HierarchyTidy] " .. tostring(result))
		end
	end)
end

createAction(
	"HierarchyTidy_GroupFolder",
	"Hierarchy Tidy: group into Folder",
	"Moves the selected objects into a new Folder",
	function(selected)
		local container = Group.into(selected, "Folder", "")
		Selection:Set({ container })
		return string.format("Grouped %d object(s).", #selected)
	end
)

createAction(
	"HierarchyTidy_Flatten",
	"Hierarchy Tidy: unpack container",
	"Moves the children of the selected containers up and removes the empty containers",
	function(selected)
		local moved, removed = Group.flatten(selected)
		return string.format("Moved %d children, containers removed: %d.", moved, removed)
	end
)

createAction(
	"HierarchyTidy_RemoveEmpty",
	"Hierarchy Tidy: remove empty containers",
	"Removes empty Folders and Models within the selection",
	function(selected)
		return string.format("Empty containers removed: %d.", Cleanup.removeEmpty(selected))
	end
)

plugin.Unloading:Connect(function()
	if unmount then
		unmount()
		unmount = nil
	end
	Theme.destroy()
end)
