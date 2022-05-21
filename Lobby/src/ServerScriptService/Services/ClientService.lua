local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)

local ClientService = {}

function ClientService.InitializeClient(player, profile)

end

function ClientService.InitializeTools(player, profile)
    for _,shovel in pairs(profile.Data.Shovels) do
        ToolService:LoadShovel(player, shovel)
    end

    for _,famous in pairs(profile.Data.Famous) do
        ToolService:LoadFamous(player, famous)
    end
end

return ClientService