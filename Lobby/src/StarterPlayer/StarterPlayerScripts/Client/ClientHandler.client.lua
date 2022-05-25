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
        SideFrame.Gold.GoldAmount.Text = value
    end
end

local function loadPrestige(value)
    if SideFrame then
        SideFrame.CollectionAndStats.Stats.Prestige.Text = "Prestige: " .. value
        SideFrame.CollectionAndStats.Stats.Prestige.Visible = (value ~= 0)
    end
end

local function showStats(newStats)
    if SideFrame then
        for stat, value in pairs(newStats) do
            local statHolder = SideFrame.CollectionAndStats.Stats:FindFirstChild(stat)
            if value ~= "Hide" then
                if stat == "GMulti" then
                    statHolder.Text = "G Multi: " .. value
                else
                    statHolder.Text = stat .. ": " .. value
                end
            else
                statHolder.Text = ""
            end
        end
    end
end

PlayerValues:SetCallback("Gold", function(player, value)
    loadGold(value)
end)

PlayerValues:SetCallback("Prestige", function(player, value)
    loadPrestige(value)
end)

ClientConnection.OnClientEvent:Connect(function(action, args)
    if action == "loadPlayerValues" then
        loadGold(PlayerValues:GetValue(LocalPlayer, "Gold"))
        loadPrestige(PlayerValues:GetValue(LocalPlayer, "Prestige"))
    elseif action == "showPlayerStats" then
        showStats(args.newStats)
    end
end)
