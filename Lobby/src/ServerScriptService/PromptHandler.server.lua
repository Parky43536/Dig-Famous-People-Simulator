local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)
local MapService = require(RepServices.MapService)

local function onPromptTriggered(promptObject, player)
	if promptObject.Name == "TrashPrompt" then
		ToolService:DeleteEquippedTool(player)
	elseif promptObject.Name == "ChestPrompt" then
		MapService:ProcessChest(player, promptObject)
	end
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)