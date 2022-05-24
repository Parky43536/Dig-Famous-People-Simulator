local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets
local Values = ReplicatedStorage.Values

local Physics = ReplicatedStorage.Physics
local PartManager = require(Physics.PartManager)
local ChunkService = require(Physics.ChunkService)

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))

local MapService = {}
local FamousPrompts = {}
local ChestPrompts = {}
local ShovelPrompts = {}

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
                    gold = rng:NextInteger(500, 1000)
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

                DataManager:GiveGold(player, promptData.gold)
                promptData.model:Destroy()
                table.remove(ChestPrompts, key)
                return true
            end
        end
    end
end

function MapService:ProcessShovel(player, promptObject)
    for key, promptData in pairs(ShovelPrompts) do
        if promptData.prompt == promptObject then
            DataManager:NewShovel(player, promptData.shovelType, promptData.cost)
        end
    end
end

---------------------------------------------------------

local Map
local MapTimer = 300

local function teleportPlayers()
    for _,player in pairs(Players:GetChildren()) do
        local character = player.Character
        if character and character.Parent ~= nil then
            local rng = Random.new()
            character:PivotTo(workspace.Game.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
        end
    end
end

local function initalizeShovels()
    for _,stand in pairs(workspace.Shovels:GetChildren()) do
        local shovelData = ShovelData[stand.Name]
        if shovelData then
            local Shovel = Assets.Shovels:FindFirstChild(stand.Name).Shovel:Clone()
            Shovel:PivotTo(stand.ShovelHolder.CFrame)
            Shovel.Anchored = true
            Shovel.Parent = stand.ShovelHolder

            stand.ShovelName.SurfaceGui.Frame.TextLabel.Text = stand.Name
            stand.ShovelName.Color = shovelData.Color

            stand.Reload.SurfaceGui.Frame.TextLabel.Text = "Reload:\n" .. shovelData.Stats.Reload
            stand.Dig.SurfaceGui.Frame.TextLabel.Text = "Dig:\n" .. shovelData.Stats.Dig
            stand.Speed.SurfaceGui.Frame.TextLabel.Text = "Speed:\n" .. shovelData.Stats.Speed
            stand.Jump.SurfaceGui.Frame.TextLabel.Text = "Jump:\n" .. shovelData.Stats.Jump
            stand.GMulti.SurfaceGui.Frame.TextLabel.Text = "G Multi:\n" .. shovelData.Stats.GMulti
            stand.Luck.SurfaceGui.Frame.TextLabel.Text = "Luck:\n" .. shovelData.Stats.Luck

            stand.ShovelHolder.ShovelPrompt.ObjectText = stand.Name
            stand.ShovelHolder.ShovelPrompt.ActionText = "Buy for " .. shovelData.Cost .. " Gold?"

            local shovelPrompt = {
                prompt = stand.ShovelHolder.ShovelPrompt,
                shovelType = stand.Name,
                cost = shovelData.Cost,
                model = stand,
            }
            table.insert(ShovelPrompts, shovelPrompt)
        end
    end
end

local function newMap()
    FamousPrompts = {}
    ChestPrompts = {}

	Map = Assets.Maps.Map:Clone()
	Map.Parent = workspace

	for _,object in pairs(Map:GetDescendants()) do
		if object:IsA("BasePart") then
			if not CollectionService:HasTag(object, "Permanent") then
				CollectionService:RemoveTag(object, "Destructable")
				CollectionService:RemoveTag(object, "Breakable")

				PartManager.addPart(object)

				local multiplyVector = Vector3.new(1,1,1)
				local isSplitablePart = false

				if object.ClassName == "Part" then
					if object.Shape == Enum.PartType.Cylinder then
						continue
					end

					multiplyVector = Vector3.new(1,1,1)
					isSplitablePart = true
				elseif object.ClassName == "WedgePart" then
					multiplyVector = Vector3.new(0,1,1)
					isSplitablePart = true
				end

				local objectAdjustedSize = object.Size * multiplyVector
				if objectAdjustedSize.Magnitude <= 15 or (object.ClassName ~= "Part" and object.ClassName ~= "WedgePart") then
					CollectionService:AddTag(object, "Destructable")
				elseif objectAdjustedSize.Magnitude >= 50 and isSplitablePart then
					local chunkModel = ChunkService.makeChunks(object)
					for _,chunk in pairs(chunkModel:GetChildren()) do
						PartManager.addPart(chunk)
					end
				else
					CollectionService:AddTag(object, "Breakable")
				end
			end
		end
	end
end

initalizeShovels()

task.spawn(function()
    while true do
        if Values.MapTimer.Value <= 0 then
            if Map then
                Map:Destroy()
            end
            teleportPlayers()
            newMap()

            Values.MapTimer.Value = MapTimer
        end

        task.wait(1)

        Values.MapTimer.Value -= 1
    end
end)

return MapService