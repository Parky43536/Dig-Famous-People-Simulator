local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets

local DataBase = ReplicatedStorage.Database
local FamousData = require(DataBase:WaitForChild("FamousData"))

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))

local MapService = {}
local FamousPrompts = {}

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

local function chooseRandom(dictionary, rarity)
	while true do
		local list = dictionary
        if not list[1] then
            list = {}
            for key, value in pairs(dictionary) do
                list[#list+1] = {key = key, value = value}
            end

            local picked = list[math.random(#list)]
            if picked.value.Rarity == rarity then
                return picked.Name
            else
                task.wait()
            end
        else
            local picked = list[math.random(#list)]
            if picked.Rarity == rarity then
                return picked.Name
            else
                task.wait()
            end
        end
	end
end

function MapService:ChanceParts(chanceParts)
    local function famousHandler(tabler, rarity)
        for _,part in pairs(tabler) do
            if coveredPart(part) then
                local chosen = chooseRandom(FamousData, rarity)
                if chosen then
                    local famous = Assets.Famous.FamousHolder:Clone()
                    CharacterService:CreateCharacter(famous, chosen)
                    famous:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                    famous.Parent = part.Parent
                    part:Destroy()

                    famous.FamousPrompt.ObjectText = rarity .. ", " .. 1 / MapService.chances[rarity] * 5000
                    famous.FamousPrompt.ActionText = "Collect " .. Players:GetNameFromUserIdAsync(chosen)

                    local famousPrompt = {
                        prompt = famous.FamousPrompt,
                        famousType = chosen,
                        model = famous,
                    }
                    table.insert(FamousPrompts, famousPrompt)
                end
            end
        end
    end

    if chanceParts.Mythic then
        famousHandler(chanceParts.Mythic, "Mythic")
    end

    if chanceParts.Legendary then
        famousHandler(chanceParts.Legendary, "Legendary")
    end

    if chanceParts.Epic then
        famousHandler(chanceParts.Epic, "Epic")
    end

    if chanceParts.Rare then
        famousHandler(chanceParts.Rare, "Rare")
    end

    if chanceParts.Common then
        famousHandler(chanceParts.Common, "Common")
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

function MapService:ProcessFamous(player, promptObject)
    for key, promptData in pairs(FamousPrompts) do
        if promptData.prompt == promptObject then
            if not promptData.processing then
                promptData.processing = true

                local added = DataManager:NewFamous(player, promptData.famousType)
                if added then
                    promptData.model:Destroy()
                    table.remove(FamousPrompts, key)
                    return true
                else
                    promptData.processing = nil
                end
            end
        end
    end
end

return MapService