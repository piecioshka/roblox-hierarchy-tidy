--!strict
-- Access to the current Studio theme + subscription to theme changes.

local Studio = settings().Studio

local Theme = {}

type Painter = () -> ()

local painters: { Painter } = {}

function Theme.color(name: string, modifier: string?): Color3
	local guide = (Enum.StudioStyleGuideColor :: any)[name]
	if modifier then
		return Studio.Theme:GetColor(guide, (Enum.StudioStyleGuideModifier :: any)[modifier])
	end
	return Studio.Theme:GetColor(guide)
end

--[[
	Registers a painter function. Calls it immediately and on every Studio
	theme change. Returns an unsubscribe function.
]]
function Theme.onChange(painter: Painter): () -> ()
	table.insert(painters, painter)
	painter()

	return function()
		local index = table.find(painters, painter)
		if index then
			table.remove(painters, index)
		end
	end
end

local connection = Studio.ThemeChanged:Connect(function()
	for _, painter in painters do
		task.spawn(painter)
	end
end)

function Theme.destroy()
	connection:Disconnect()
	table.clear(painters)
end

return Theme
