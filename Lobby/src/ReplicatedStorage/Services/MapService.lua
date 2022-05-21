local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local MapService = {}
local ChestPrompts = {}

local rayCastParams = RaycastParams.new()
rayCastParams.FilterType = Enum.RaycastFilterType.Blacklist

local directions = {
	Top = Vector3.new(1, 0, 0),
	Bottom = Vector3.new(-1, 0, 0),
	Front = Vector3.new(0, 0, 1),
	Back = Vector3.new(0, 0, -1),
	Right = Vector3.new(0, 1, 0),
	Left = Vector3.new(0, -1, 0)
}

MapService.chances = {
    Mythic = 10000,
    Legendary = 3200,
    Epic = 1500,
    Rare = 750,
    Common = 125,
    Crystal = 30,
    Variety = 3,
}

local function coveredPart(part)
	local position = part.Position
	local returnTable = directions
	local raycastPos = part.Size.X / 2 + 1
	for _, dir in pairs(returnTable) do
		local direction = dir * raycastPos
		local origin = position
		local result = workspace:Raycast(origin, direction, rayCastParams)
		if not result then
			return false
		end
	end

	return true
end

function MapService:ChanceParts(chanceParts)
    --[[if chanceParts.Legendary then
        for _,part in pairs(chanceParts.Legendary) do
            if coveredPart(part) then
                local chest = Assets.Chests.Legendary:Clone()
                chest:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                chest.Parent = part.Parent
                part:Destroy()

                local chestPrompt = {
                    prompt = chest.PrimaryPart.ChestPrompt,
                    chestType = "LegendaryChest",
                    model = chest,
                }
                table.insert(ChestPrompts, chestPrompt)
            end
        end
    end

    if chanceParts.RareChest then
        for _,part in pairs(chanceParts.RareChest) do
            if coveredPart(part) then
                local chest = Assets.Chests.Rare:Clone()
                chest:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                chest.Parent = part.Parent
                part:Destroy()

                local chestPrompt = {
                    prompt = chest.PrimaryPart.ChestPrompt,
                    chestType = "RareChest",
                    model = chest,
                }
                table.insert(ChestPrompts, chestPrompt)
            end
        end
    end]]

    if chanceParts.Common then
        for _,part in pairs(chanceParts.Common) do
            if coveredPart(part) then
                local chest = Assets.Famous.FamousHolder:Clone()
                --createlook
                chest:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                chest.Parent = part.Parent
                part:Destroy()

                local chestPrompt = {
                    prompt = chest.PrimaryPart.ChestPrompt,
                    chestType = "CommonChest",
                    model = chest,
                }
                table.insert(ChestPrompts, chestPrompt)
            end
        end
    end

    if chanceParts.Crystal then
        for _,part in pairs(chanceParts.Crystal) do
            if coveredPart(part) then
                local crystal = Assets.Crystals.Default:Clone()
                crystal:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                crystal.Outside.Color = Color3.fromRGB(math.random(100,255),math.random(100,255),math.random(100,255))
                crystal.Outside.PointLight.Color = crystal.Outside.Color
                crystal.Inside.Color = crystal.Outside.Color
                crystal.Parent = part.Parent
                part:Destroy()
            end
        end
    end

    if chanceParts.Variety then
        for _,part in pairs(chanceParts.Variety) do
            if coveredPart(part) then
                part.Color = part.Color:Lerp(Color3.fromRGB(0,0,0), 0.25)
            end
        end
    end
end

function MapService:ProcessChest(player, promptObject)
    for key, promptData in pairs(ChestPrompts) do
        if promptData.prompt == promptObject then
            if not promptData.processing then
                promptData.processing = true

                local added = DataManager:NewChest(player, promptData.chestType)
                if added then
                    promptData.model:Destroy()
                    table.remove(ChestPrompts, key)
                    return true
                else
                    promptData.processing = nil
                end
            end
        end
    end
end

return MapService