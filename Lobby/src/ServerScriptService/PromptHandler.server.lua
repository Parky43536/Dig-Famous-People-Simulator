local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)
local MapService = require(RepServices.MapService)

local function onPromptTriggered(promptObject, player)
	if promptObject.Name == "SellPrompt" then
		ToolService:SellEquippedTool(player)
	elseif promptObject.Name == "FamousPrompt" then
		MapService:ProcessFamous(player, promptObject)
	elseif promptObject.Name == "ChestPrompt" then
		MapService:ProcessChest(player, promptObject)
	elseif promptObject.Name == "ShovelPrompt" then
		MapService:ProcessShovel(player, promptObject)
	elseif promptObject.Name == "PowerUpPrompt" then
		MapService:ProcessPowerUp(player, promptObject)
	end
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)