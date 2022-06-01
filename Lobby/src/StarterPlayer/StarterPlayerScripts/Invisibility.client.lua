local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")

local isInvisibile = false

local function setInvisibility(invisible)
	isInvisibile = invisible

	if isInvisibile then
		
	else
		
	end
end

PlayerValues:SetCallback("Invisibility", function(player, value)
    if SideFrame then
        if value then
            SideFrame.Actions.Invisibility.Visible = true
        else
            SideFrame.Actions.Invisibility.Visible = false
            setInvisibility(false)
        end
    end
end)

local function processInvisible()
    if not PlayerValues:GetValue(LocalPlayer, "Invisibility") then
        return
    end
    setInvisibility(not isInvisibile)
end

SideFrame.Actions.Invisibility.Activated:Connect(function()
    processInvisible()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.F and gameProcessedEvent == false then
		processInvisible()
	end
end

UserInputService.InputBegan:Connect(onKeyPress)




