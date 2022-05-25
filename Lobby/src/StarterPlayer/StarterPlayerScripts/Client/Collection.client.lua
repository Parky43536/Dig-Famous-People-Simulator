local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")
local CollectionUi = PlayerGui:WaitForChild("CollectionUi")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
--local CollectionConnection = Remotes:WaitForChild("ClientConnection")

local function collectionUiEnable()
    if CollectionUi.Enabled == true then
        CollectionUi.Enabled = false
    else
        CollectionUi.Enabled = true
    end
end

SideFrame.CollectionAndStats.Collection.Activated:Connect(function()
    collectionUiEnable()
end)

CollectionUi.CollectionFrame.TopFrame.Close.Activated:Connect(function()
    collectionUiEnable()
end)

--[[PlayerValues:SetCallback("Gold", function(player, value)
    if player == LocalPlayer then
        loadGold(value)
    end
end)

ClientConnection.OnClientEvent:Connect(function(action, args)
    if action == "loadPlayerValues" then
        loadGold(PlayerValues:GetValue(LocalPlayer, "Gold"))
    elseif action == "showPlayerStats" then
        showStats(args.newStats)
    end
end)]]
