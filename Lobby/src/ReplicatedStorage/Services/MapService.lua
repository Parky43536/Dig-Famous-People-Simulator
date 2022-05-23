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
    Legendary = 3000,
    Epic = 1000,
    Rare = 500,
    Common = 100,

    GoldChestLegendary = 3000,
    GoldChestRare = 500,
    GoldChestCommon = 100,

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
                return picked.key
            else
                task.wait()
            end
        else
            local picked = list[math.random(#list)]
            if picked.Rarity == rarity then
                return picked
            else
                task.wait()
            end
        end
	end
end

function MapService:RoundDeci(n: number, decimal: number)
    return math.round(n * 10 ^ decimal) / (10 ^ decimal)
end

function MapService:ChanceParts(chanceParts)
    local rng = Random.new()

    local function famousHandler(tabler, rarity)
        for _,part in pairs(tabler) do
            if coveredPart(part) then
                local chosen = chooseRandom(FamousData, rarity)
                local famousStats = FamousData[chosen]
                if chosen and famousStats then
                    local famous = Assets.Famous.FamousHolder:Clone()
                    CharacterService:CreateCharacterRig(famous, chosen)
                    famous:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                    famous.Parent = part.Parent
                    part:Destroy()

                    famous.FamousPrompt.ObjectText = rarity .. ", " .. MapService:RoundDeci(1 / MapService.chances[rarity] * 5000, 2) .. "%"
                    famous.FamousPrompt.ActionText = "Collect " .. famousStats.Name

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

    local function chestHandler(tabler, rarity)
        for _,part in pairs(tabler) do
            if coveredPart(part) then
                local chest = Assets.Chests:FindFirstChild(rarity):Clone()
                chest:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                chest.Parent = part.Parent
                part:Destroy()

                local gold = 0
                if rarity == "GoldChestLegendary" then
                    gold = rng:NextInteger(2500, 5000)
                elseif rarity == "GoldChestRare" then
                    gold = rng:NextInteger(250, 500)
                elseif rarity == "GoldChestCommon" then
                    gold = rng:NextInteger(100, 200)
                end

                chest.Root.ChestPrompt.ObjectText = string.gsub(rarity, "GoldChest", "") .. ", " .. MapService:RoundDeci(1 / MapService.chances[rarity] * 5000, 2) .. "%"
                chest.Root.ChestPrompt.ActionText = "Collect " .. gold .. " Gold"

                local chestPrompt = {
                    prompt = chest.PrimaryPart.ChestPrompt,
                    rarity = rarity,
                    gold = gold,
                    model = chest,
                }
                table.insert(ChestPrompts, chestPrompt)
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

    if chanceParts.GoldChestLegendary then
        chestHandler(chanceParts.GoldChestLegendary, "GoldChestLegendary")
    end

    if chanceParts.GoldChestRare then
        chestHandler(chanceParts.GoldChestRare, "GoldChestRare")
    end

    if chanceParts.GoldChestCommon then
        chestHandler(chanceParts.GoldChestCommon, "GoldChestCommon")
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

function MapService:ProcessChest(player, promptObject)
    for key, promptData in pairs(ChestPrompts) do
        if promptData.prompt == promptObject then
            if not promptData.processing then
                promptData.processing = true

                promptData.model:Destroy()
                table.remove(ChestPrompts, key)
                return true
            end
        end
    end
end

return MapService