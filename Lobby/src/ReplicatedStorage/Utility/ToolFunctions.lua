local Players = game:GetService("Players")

local ToolFunctions = {}

function ToolFunctions:Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

function ToolFunctions:ReadyTool(Tool, famous, famousStats)
	task.spawn(function()
		local content, isReady = Players:GetUserThumbnailAsync(famous.famousType, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		Tool.TextureId = content
	end)

	Tool.ToolTip = Players:GetNameFromUserIdAsync(famous.famousType) .. ", " .. famousStats.Rarity.Value

	local dialog = famousStats:Clone()
	dialog.Parent = Tool.Handle
end

return ToolFunctions
