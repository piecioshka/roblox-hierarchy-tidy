--!strict
-- Searching the hierarchy: by name, by class and for duplicate names.

local Find = {}

export type Query = {
	text: string,
	className: string?,
	limit: number,
}

local function isA(instance: Instance, className: string): boolean
	local ok, result = pcall(function()
		return instance:IsA(className)
	end)
	return ok and result
end

--[[
	Returns descendants of the root matching the query.
	Empty `text` means "any name" (then only the class filters).
]]
function Find.search(root: Instance, query: Query): { Instance }
	local needle = string.lower(query.text)
	local className = query.className
	local matches: { Instance } = {}

	for _, descendant in root:GetDescendants() do
		if #matches >= query.limit then
			break
		end

		local nameOk = needle == "" or string.find(string.lower(descendant.Name), needle, 1, true) ~= nil
		if nameOk and (className == nil or className == "" or isA(descendant, className)) then
			table.insert(matches, descendant)
		end
	end

	return matches
end

--[[
	Finds objects that share a name with a sibling — the usual mess left
	behind by copy-paste (Part, Part, Part…).
	Returns every member of each colliding group.
]]
function Find.duplicateNames(root: Instance, limit: number): { Instance }
	local matches: { Instance } = {}

	local function inspect(parent: Instance)
		local byName: { [string]: { Instance } } = {}
		for _, child in parent:GetChildren() do
			byName[child.Name] = byName[child.Name] or {}
			table.insert(byName[child.Name], child)
			inspect(child)
		end

		for _, group in byName do
			if #group > 1 then
				for _, instance in group do
					if #matches < limit then
						table.insert(matches, instance)
					end
				end
			end
		end
	end

	inspect(root)
	return matches
end

--[[ Resolves a scope name to an instance ("Selection" is handled in the UI) ]]
function Find.serviceByName(name: string): Instance?
	local ok, service = pcall(function()
		return game:GetService(name :: any)
	end)
	return if ok then service else nil
end

return Find
