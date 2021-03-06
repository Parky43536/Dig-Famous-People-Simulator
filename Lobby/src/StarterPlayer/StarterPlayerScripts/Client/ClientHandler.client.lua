local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")

local Utility = ReplicatedStorage:WaitForChild("Utility")
local TweenService = require(Utility:WaitForChild("TweenService"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")

local function toSpawn()
    local character = LocalPlayer.Character
    if character and character.Parent ~= nil then
        local rng = Random.new()
        character:PivotTo(workspace.Permanent.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
    end
end

SideFrame.Spawn.Activated:Connect(function()
    toSpawn()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.X and gameProcessedEvent == false then
		toSpawn()
	end
end

local function comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local currentGold
local currentTween
local lastGoldUpate
local function loadGold(value)
    if SideFrame then
        if currentGold then
            local goldGain = value - currentGold
            if goldGain ~= 0 then
                if goldGain > 0 then
                    SideFrame.Gold.GoldIncrease.Text = "+" .. comma_value(goldGain)
                else
                    SideFrame.Gold.GoldIncrease.Text = comma_value(goldGain)
                end

                if currentTween then currentTween:Cancel() end
                SideFrame.Gold.GoldIncrease.Size = UDim2.new(0.6, 0, 0.6, 0)
                SideFrame.Gold.GoldIncrease.TextColor3 = Color3.fromRGB(255, 255, 0)
                local goal = {Size = SideFrame.Gold.GoldIncrease.Size + UDim2.new(0.2, 0, 0.2, 0), TextColor3 = Color3.fromRGB(255, 175, 110)}
                local properties = {Time = 1, Dir = "In", Style = "Bounce", Reverse = true}
                currentTween = TweenService.tween(SideFrame.Gold.GoldIncrease, goal, properties)
                SideFrame.Gold.GoldIncrease.Visible = true

                local ticker = tick()
                lastGoldUpate = ticker
                task.delay(2, function()
                    if lastGoldUpate == ticker then
                        SideFrame.Gold.GoldIncrease.Visible = false
                        currentGold = value
                    end
                end)
            end
        else
            currentGold = value
        end

        SideFrame.Gold.GoldAmount.Text = comma_value(value)
    end
end

local function loadPrestige(value)
    if SideFrame then
        SideFrame.CollectionAndStats.Stats.Prestige.Text = "Prestige: " .. comma_value(value)
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

                local PowerUp = PlayerValues:GetValue(LocalPlayer, stat .. "PowerUp")
                if PowerUp and PowerUp > 0 then
                    statHolder.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    statHolder.TextColor3 = Color3.fromRGB(255, 255, 255)
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

UserInputService.InputBegan:Connect(onKeyPress)
