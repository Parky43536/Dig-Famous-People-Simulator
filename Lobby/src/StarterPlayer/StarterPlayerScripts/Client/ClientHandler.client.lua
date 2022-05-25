local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")

SideFrame.Spawn.Activated:Connect(function()
    local character = LocalPlayer.Character
    if character and character.Parent ~= nil then
        local rng = Random.new()
        character:PivotTo(workspace.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
    end
end)

local function loadGold(value)
    if SideFrame then
        SideFrame.Gold.Text = "Gold: " .. value
    end
end

PlayerValues:SetCallback("Gold", function(player, value)
    if player == LocalPlayer then
        loadGold(value)
    end
end)

ClientConnection.OnClientEvent:Connect(function(action)
    if action == "loadPlayerValues" then
        loadGold(PlayerValues:GetValue(LocalPlayer, "Gold"))
    end
end)
