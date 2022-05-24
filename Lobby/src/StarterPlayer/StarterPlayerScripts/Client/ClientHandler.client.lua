local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui
local PlayerUi
local SideFrame

PlayerValues:SetCallback("Gold", function(player, value)
    if player == LocalPlayer and SideFrame then
        SideFrame.Gold.Text = "Gold: " .. value
    end
end)

PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
PlayerUi = PlayerGui:WaitForChild("PlayerUi")
SideFrame = PlayerUi:WaitForChild("SideFrame")

SideFrame.Spawn.Activated:Connect(function()
    local character = LocalPlayer.Character
    if character and character.Parent ~= nil then
        local rng = Random.new()
        character:PivotTo(workspace.Spawn.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
    end
end)
