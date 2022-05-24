local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local ClientService = {}

local function getDataById(database, id)
    for name, data in pairs(database) do
        if tostring(data.id) == tostring(id) then
            return name, data
        end
    end
end

function ClientService.InitializeClient(player, profile)

end

function ClientService.InitializeTools(player, profile)
    for id, uniqueIds in pairs(profile.Data.Shovels) do
        local shovelType, shovelData = getDataById(ShovelData, id)
        if shovelData then
            for _, uniqueId in pairs(uniqueIds) do
                ToolService:LoadShovel(player, shovelType, uniqueId)
            end
        end
    end

    for id, uniqueIds in pairs(profile.Data.Famous) do
        local famousType, famousData = getDataById(FamousData, id)
        if famousData then
            for _, uniqueId in pairs(uniqueIds) do
                ToolService:LoadFamous(player, famousType, uniqueId)
            end
        end
    end
end

return ClientService