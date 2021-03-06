local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Assets = ReplicatedStorage.Assets

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))
local General = require(Utility:WaitForChild("General"))

local DataBase = ReplicatedStorage.Database
local FamousData = require(DataBase:WaitForChild("FamousData"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")
local CollectionUi = PlayerGui:WaitForChild("CollectionUi")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CollectionConnection = Remotes:WaitForChild("CollectionConnection")
local PrestigeRemote = Remotes:WaitForChild("PrestigeRemote")

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

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Z and gameProcessedEvent == false then
		collectionUiEnable()
	end
end

CollectionUi.CollectionFrame.BottomFrame.Prestige.Activated:Connect(function()
    PrestigeRemote:FireServer("prestige")
end)

local function length(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter += 1
	end
	return counter
end

local function getDataById(database, id)
    for name, data in pairs(database) do
        if tostring(data.id) == tostring(id) then
            return name, data
        end
    end
end

local function loadFamous(data)
    local total = 0
    local lengthOfFamousData = length(FamousData)
    local famousPlace = CollectionUi.CollectionFrame.ScrollingFrame

    for id = 1 , lengthOfFamousData do
        local famousId, famousData = getDataById(FamousData, id)

        if famousId then
            local famousUi = famousPlace:FindFirstChild(famousId)
            local playerFamousData = data[tostring(id)]

            if not famousUi then
                famousUi = Assets.Ui.Famous:Clone()
                famousUi.Name = famousId

                task.spawn(function()
                    famousUi.FamousHolder.FamousImage.Image = CharacterService:CreateCharacterIcon(famousId)
                end)

                famousUi.FamousHolder.FamousName.Text = famousData.Name
                famousUi.FamousHolder.FamousRarity.Text = famousData.Rarity
                famousUi.FamousHolder.FamousRarity.TextColor3 = General.RarityData[famousData.Rarity].color
            end

            if playerFamousData then
                total += 1
                famousUi.FamousHolder.FamousName.BackgroundColor3 = General.RarityData[famousData.Rarity].color:Lerp(Color3.fromRGB(0,0,0), 0.75)
                famousUi.FamousHolder.FamousImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
                famousUi.LayoutOrder = General.RarityData[famousData.Rarity].order
                --famousUi.FamousHolder.FamousQuantity.Text = "x" .. #playerFamousData
            else
                famousUi.FamousHolder.FamousName.BackgroundColor3 = Color3.fromRGB(0,0,0)
                famousUi.FamousHolder.FamousImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
                famousUi.LayoutOrder = General.RarityData[famousData.Rarity].order + 10
                --famousUi.FamousHolder.FamousQuantity.Text = ""
            end

            famousUi.Parent = famousPlace
        end
    end

    SideFrame.CollectionAndStats.CollectionAmount.Text = total .. "/" .. lengthOfFamousData

    local prestigeButton = CollectionUi.CollectionFrame.BottomFrame.Prestige
    if total == lengthOfFamousData then
        prestigeButton.BackgroundColor3 = Color3.fromRGB(0, 213, 255)
        prestigeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        prestigeButton.UIGradient.Enabled = true
        prestigeButton.AutoButtonColor = true
        prestigeButton.Active = true
    else
        prestigeButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        prestigeButton.TextColor3 = Color3.fromRGB(136, 136, 136)
        prestigeButton.UIGradient.Enabled = false
        prestigeButton.AutoButtonColor = false
        prestigeButton.Active = false
    end
end

PlayerValues:SetCallback("Famous", function(player, value)
    loadFamous(value)
end)

CollectionConnection.OnClientEvent:Connect(function(action, args)
    if action == "loadPlayerFamous" then
        loadFamous(PlayerValues:GetValue(LocalPlayer, "Famous"))
    end
end)

UserInputService.InputBegan:Connect(onKeyPress)
