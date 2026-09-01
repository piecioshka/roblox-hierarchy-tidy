--!strict
-- Grouping selected objects into Folders / Models.

local Group = {}

local function commonParent(objects: { Instance }): Instance
	local parent = objects[1].Parent
	for _, object in objects do
		if object.Parent ~= parent then
			-- Mixed parents — group inside the parent of the first selected object.
			return parent or workspace
		end
	end
	return parent or workspace
end

--[[ Drops objects whose ancestor is also selected (avoids reparenting loops) ]]
local function topLevelOnly(objects: { Instance }): { Instance }
	local set = {}
	for _, object in objects do
		set[object] = true
	end

	local result = {}
	for _, object in objects do
		local ancestor = object.Parent
		local nested = false
		while ancestor do
			if set[ancestor] then
				nested = true
				break
			end
			ancestor = ancestor.Parent
		end
		if not nested then
			table.insert(result, object)
		end
	end
	return result
end

--[[ Groups every object into a single container. Returns the container. ]]
function Group.into(objects: { Instance }, className: "Folder" | "Model", name: string): Instance
	local targets = topLevelOnly(objects)
	assert(#targets > 0, "Nothing to group")

	local container = Instance.new(className)
	container.Name = if name ~= "" then name else className
	container.Parent = commonParent(targets)

	for _, object in targets do
		object.Parent = container
	end

	return container
end

--[[
	Groups objects into separate folders by ClassName.
	Returns the number of folders created.
]]
function Group.byClass(objects: { Instance }): number
	local targets = topLevelOnly(objects)
	assert(#targets > 0, "Nothing to group")

	local parent = commonParent(targets)
	local buckets: { [string]: { Instance } } = {}

	for _, object in targets do
		local key = object.ClassName
		if object:IsA("BasePart") then
			key = "Parts"
		elseif object:IsA("LuaSourceContainer") then
			key = "Scripts"
		end
		buckets[key] = buckets[key] or {}
		table.insert(buckets[key], object)
	end

	local created = 0
	for key, list in buckets do
		local folder = parent:FindFirstChild(key)
		if not folder or not folder:IsA("Folder") then
			folder = Instance.new("Folder")
			folder.Name = key
			folder.Parent = parent
			created += 1
		end
		for _, object in list do
			object.Parent = folder
		end
	end

	return created
end

--[[
	Unpacks selected Folders / Models: children move up to the container's
	parent and the empty container is removed.
	Returns the number of children moved and containers removed.
]]
function Group.flatten(objects: { Instance }): (number, number)
	local moved = 0
	local removed = 0

	for _, object in objects do
		local parent = object.Parent
		local isContainer = object:IsA("Folder") or object:IsA("Model")
		if isContainer and parent then
			for _, child in object:GetChildren() do
				child.Parent = parent
				moved += 1
			end
			object:Destroy()
			removed += 1
		end
	end

	assert(removed > 0, "Select a Folder or Model to unpack")
	return moved, removed
end

return Group
