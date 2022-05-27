local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets
local Values = ReplicatedStorage.Values

local Physics = ReplicatedStorage.Physics
local PartManager = require(Physics.PartManager)
local ChunkService = require(Physics.ChunkService)
local ExplosionService

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))
local General = require(Utility:WaitForChild("General"))
local TweenService = require(Utility:WaitForChild("TweenService"))
local AudioService = require(Utility:WaitForChild("AudioService"))

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
                    famous:PivotTo(part.CFrame * CFrame.Angles(math.rad(-90), 0, math.rad(math.random(0, 360))))

                    if not workspace.Map:FindFirstChild("ChanceParts") then
                        local model = Instance.new("Model")
                        model.Name = "ChanceParts"
                        model.Parent = workspace.Map
                    end
                    famous.Parent =  workspace.Map:FindFirstChild("ChanceParts")

                    part:Destroy()

                    famous.FamousPrompt.ObjectText = rarity .. ", " .. MapService:RoundDeci(1 / General.ItemChances[rarity] * 5000, 2) .. "%"
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
                local chest = Assets.MapAssets:FindFirstChild(rarity):Clone()
                chest:PivotTo(part.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))

                if not workspace.Map:FindFirstChild("ChanceParts") then
                    local model = Instance.new("Model")
                    model.Name = "ChanceParts"
                    model.Parent = workspace.Map
                end
                chest.Parent =  workspace.Map:FindFirstChild("ChanceParts")

                part:Destroy()

                local gold = rng:NextInteger(General.ChestGold[rarity].min, General.ChestGold[rarity].max)

                chest.Root.ChestPrompt.ObjectText = string.gsub(rarity, "GoldChest", "") .. ", " .. MapService:RoundDeci(1 / General.ItemChances[rarity] * 5000, 2) .. "%"
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

    if chanceParts.Bomb then
        for _,part in pairs(chanceParts.Bomb) do
            if coveredPart(part) then
                local Bomb = Assets.MapAssets.Bomb:Clone()
                Bomb:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                Bomb.Parent = part.Parent
                part:Destroy()

                task.spawn(function()
                    repeat task.wait(2) until not coveredPart(part)
                    --AudioService:Create(16433289, Bomb.Position, {Volume = 0.8})
                    task.wait(2)

                    local size = 20

                    if not ExplosionService then ExplosionService = require(Physics.ExplosionService) end
                    ExplosionService.create("Server", Bomb.Position, 15, 15)

                    local particle = Assets.MapAssets.Explosion:Clone()
                    particle:PivotTo(Bomb.CFrame)
                    particle.Parent = workspace

                    AudioService:Create(16433289, Bomb.Position, {Volume = 0.8})

                    local growsize = Vector3.new(size, size, size)
                    local goal = {Transparency = 0.9, Size = growsize}
                    local properties = {Time = 0.15}
                    TweenService.tween(particle, goal, properties)

                    local goal = {Transparency = 1}
                    local properties = {Time = 1.35}
                    TweenService.tween(particle, goal, properties)

                    game.Debris:AddItem(particle, 1.5)
                    Bomb:Destroy()
                end)
            end
        end
    end

    if chanceParts.Crystal then
        for _,part in pairs(chanceParts.Crystal) do
            if coveredPart(part) then
                local crystal = Assets.MapAssets.Crystal:Clone()
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
            character:PivotTo(workspace.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
        end
    end
end

local function initalizeShovels()
    for _,standHolder in pairs(workspace.Map.Shovels:GetChildren()) do
        local shovelData = ShovelData[standHolder.Name]
        if shovelData then
            local Stand
            if shovelData.Special then
                Stand = Assets.MapAssets.SpecialShovelStand:Clone()
            else
                Stand = Assets.MapAssets.ShovelStand:Clone()
            end

            Stand.Name = standHolder.Name
            Stand:PivotTo(standHolder.CFrame)
            Stand.Parent = standHolder.Parent

            standHolder:Destroy()

            local Shovel = Assets.Shovels:FindFirstChild(Stand.Name).Shovel:Clone()
            Shovel:PivotTo(Stand.ShovelHolder.CFrame)
            Shovel.Anchored = true
            Shovel.Parent = Stand.ShovelHolder

            Stand.ShovelName.SurfaceGui.Frame.TextLabel.Text = Stand.Name
            Stand.ShovelName.Color = shovelData.Color

            Stand.Reload.SurfaceGui.Frame.TextLabel.Text = "Reload:\n" .. shovelData.Stats.Reload
            Stand.Dig.SurfaceGui.Frame.TextLabel.Text = "Dig:\n" .. shovelData.Stats.Dig
            Stand.Speed.SurfaceGui.Frame.TextLabel.Text = "Speed:\n" .. shovelData.Stats.Speed
            Stand.Jump.SurfaceGui.Frame.TextLabel.Text = "Jump:\n" .. shovelData.Stats.Jump
            Stand.GMulti.SurfaceGui.Frame.TextLabel.Text = "G Multi:\n" .. shovelData.Stats.GMulti
            Stand.Luck.SurfaceGui.Frame.TextLabel.Text = "Luck:\n" .. shovelData.Stats.Luck

            Stand.ShovelHolder.ShovelPrompt.ObjectText = Stand.Name
            Stand.ShovelHolder.ShovelPrompt.ActionText = "Buy for " .. shovelData.Cost .. " Gold?"

            local shovelPrompt = {
                prompt = Stand.ShovelHolder.ShovelPrompt,
                shovelType = Stand.Name,
                cost = shovelData.Cost,
                model = Stand,
            }
            table.insert(ShovelPrompts, shovelPrompt)
        end
    end
end

local function newMap()
    FamousPrompts = {}
    ChestPrompts = {}
    ShovelPrompts = {}

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
        elseif object.Name == "DialogInserter" then
            local dialog = Assets.Dialogs:FindFirstChild(object.Value):Clone()
            dialog.Parent = object.Parent
            object:Destroy()
		end
	end

    initalizeShovels()
end

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