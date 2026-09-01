--!strict
-- Removing empty containers and sorting layout order.

local Cleanup = {}

local function isEmptyContainer(instance: Instance): boolean
	if not (instance:IsA("Folder") or instance:IsA("Model") or instance:IsA("Configuration")) then
		return false
	end
	return #instance:GetChildren() == 0
end

--[[
	Removes empty Folders / Models inside the given roots (recursively, from
	the leaves up, so nested empty chains disappear too).
	The roots themselves are never removed.
	Returns the number of removed objects.
]]
function Cleanup.removeEmpty(roots: { Instance }): number
	local removed = 0

	local function walk(instance: Instance)
		for _, child in instance:GetChildren() do
			walk(child)
		end
		if isEmptyContainer(instance) then
			instance:Destroy()
			removed += 1
		end
	end

	for _, root in roots do
		for _, child in root:GetChildren() do
			walk(child)
		end
	end

	return removed
end

--[[
	Sets LayoutOrder of children alphabetically — useful for GUI elements,
	where the order actually drives the layout.
	Returns the number of reordered elements.
]]
function Cleanup.sortLayoutOrder(parents: { Instance }): number
	local touched = 0

	for _, parent in parents do
		local children = {}
		for _, child in parent:GetChildren() do
			if child:IsA("GuiObject") then
				table.insert(children, child)
			end
		end

		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)

		for index, child in children do
			child.LayoutOrder = index
			touched += 1
		end
	end

	return touched
end

--[[ Short summary of the selection: per-class counts ]]
function Cleanup.describe(objects: { Instance }): string
	local counts: { [string]: number } = {}
	for _, object in objects do
		counts[object.ClassName] = (counts[object.ClassName] or 0) + 1
	end

	local parts = {}
	for className, count in counts do
		table.insert(parts, className .. " x" .. count)
	end
	table.sort(parts)

	return table.concat(parts, ", ")
end

return Cleanup
