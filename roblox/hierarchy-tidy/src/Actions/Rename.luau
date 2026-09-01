--!strict
-- Bulk renaming with numbering.

local Rename = {}

export type Options = {
	pattern: string, -- e.g. "Wall_{n}"
	startIndex: number,
	padding: number, -- 1 = 1,2,3 ; 3 = 001,002,003
	sortByName: boolean?,
}

--[[
	Renames by pattern. `{n}` is replaced with the number, `{class}` with the
	ClassName. If the pattern has no `{n}`, the number is appended at the end.
	Returns the number of renamed objects.
]]
function Rename.sequence(objects: { Instance }, options: Options): number
	assert(#objects > 0, "Nothing to rename")
	assert(options.pattern ~= "", "Enter a name pattern")

	local pattern = options.pattern
	if not string.find(pattern, "{n}", 1, true) then
		pattern ..= "_{n}"
	end

	local ordered = table.clone(objects)
	if options.sortByName ~= false then
		table.sort(ordered, function(a, b)
			return a.Name < b.Name
		end)
	end

	local padding = math.clamp(math.floor(options.padding), 1, 6)
	local index = math.floor(options.startIndex)

	for _, object in ordered do
		local number = string.format("%0" .. padding .. "d", index)
		local name = string.gsub(pattern, "{n}", number)
		name = string.gsub(name, "{class}", object.ClassName)
		object.Name = name
		index += 1
	end

	return #ordered
end

return Rename
