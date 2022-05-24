local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Values = ReplicatedStorage:WaitForChild("Values")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")

-------------------------

local function toHMS(s)
    return string.format("%01i:%02i", s/60%60, s%60)
end

Values.MapTimer.Changed:Connect(function(value)
	SideFrame.MapTimer.Text = "Map Timer: " .. toHMS(value)
end)




