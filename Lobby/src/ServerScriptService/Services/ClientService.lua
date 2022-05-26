local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)
local PlayerValues = require(RepServices.PlayerValues)

local SerServices = ServerScriptService.Services
local DataManager

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes.ClientConnection
local CollectionConnection = Remotes.CollectionConnection

local ClientService = {}

local function getDataById(database, id)
    for name, data in pairs(database) do
        if tostring(data.id) == tostring(id) then
            return name, data
        end
    end
end

function ClientService.InitializeClient(player, profile)
    PlayerValues:SetValue(player, "Famous", profile.Data.Famous, "playerOnly")
    PlayerValues:SetValue(player, "Gold", profile.Data.Gold, "playerOnly")
    PlayerValues:SetValue(player, "Prestige", profile.Data.Prestige, "playerOnly")

    ClientConnection:FireClient(player, "loadPlayerValues")
    CollectionConnection:FireClient(player, "loadPlayerFamous")

    -------------------------

    if next(profile.Data.Shovels) == nil then
        if not DataManager then DataManager = require(SerServices.DataManager) end
        DataManager:NewShovel(player, "Default Shovel")
    end

    local character = player.Character
    if character then
        ToolService:PlayerStats(player, character.Humanoid)
    end

    for id, uniqueId in pairs(profile.Data.Shovels) do
        local shovelType, shovelData = getDataById(ShovelData, id)
        if shovelData then
            ToolService:LoadShovel(player, shovelType, uniqueId)
        end
    end

    for id, uniqueId in pairs(profile.Data.Famous) do
        local famousType, famousData = getDataById(FamousData, id)
        if famousData then
            ToolService:LoadFamous(player, famousType, uniqueId)
        end
    end
end

return ClientService