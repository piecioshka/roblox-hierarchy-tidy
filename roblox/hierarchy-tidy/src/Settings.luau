--!strict
-- Persistent plugin settings (plugin:GetSetting / SetSetting).
-- Modules have no access to the global `plugin`, so it is injected in init.

local Settings = {}

local PREFIX = "HierarchyTidy_"
local pluginRef: Plugin? = nil

function Settings.init(instance: Plugin)
	pluginRef = instance
end

function Settings.get<T>(key: string, default: T): T
	local reference = pluginRef
	if not reference then
		return default
	end

	local ok, value = pcall(function()
		return reference:GetSetting(PREFIX .. key)
	end)

	if ok and value ~= nil then
		return value :: any
	end
	return default
end

function Settings.set(key: string, value: any)
	local reference = pluginRef
	if not reference then
		return
	end

	pcall(function()
		reference:SetSetting(PREFIX .. key, value)
	end)
end

return Settings
