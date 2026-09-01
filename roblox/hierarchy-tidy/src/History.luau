--!strict
-- Wraps an operation in a ChangeHistoryService recording so Ctrl+Z works.

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local History = {}

--[[
	Runs `body` inside a single history entry.
	Returns (ok, resultOrError).
]]
function History.record<T>(name: string, body: () -> T): (boolean, any)
	local identifier = ChangeHistoryService:TryBeginRecording(name, name)

	if not identifier then
		-- Could not open a recording (e.g. another one is already active).
		-- Still run the operation, just without its own history entry.
		return pcall(body)
	end

	local ok, result = pcall(body)

	ChangeHistoryService:FinishRecording(
		identifier,
		if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel
	)

	return ok, result
end

return History
