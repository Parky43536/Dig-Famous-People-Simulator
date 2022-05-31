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
local ChanceData = require(DataBase:WaitForChild("ChanceData"))

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)
local ToolService

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))
local General = require(Utility:WaitForChild("General"))
local TweenService = require(Utility:WaitForChild("TweenService"))
local AudioService = require(Utility:WaitForChild("AudioService"))

local MapService = {}
local FamousPrompts = {}
local ChestPrompts = {}
local ShovelPrompts = {}
local PowerUpPrompts = {}

local HazardCooldown = 1
local HazardCooldowns = {}

MapService.MakingNewMap = false

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

local function getPlayersInRadius(position, radius)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    radius += 2 --limbs

    for _,player in pairs(currentPlayers) do
        if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
            table.insert(playersInRadius, player)
        end
    end

    return playersInRadius
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

local function toHMS(s)
    return string.format("%01i:%02i", s/60%60, s%60)
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

                    famous.FamousPrompt.ObjectText = rarity .. ", " .. MapService:RoundDeci(1 / ChanceData[rarity].chance * General.ChanceMulti, 2) .. "%"
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
                chest.Parent = workspace.Map:FindFirstChild("ChanceParts")

                part:Destroy()

                local gold = rng:NextInteger(General.ChestGold[rarity].min, General.ChestGold[rarity].max)

                chest.Root.ChestPrompt.ObjectText = string.gsub(rarity, "GoldChest", "") .. ", " .. MapService:RoundDeci(1 / ChanceData[rarity].chance * General.ChanceMulti, 2) .. "%"
                chest.Root.ChestPrompt.ActionText = "Collect " .. comma_value(gold) .. " Gold"

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

    local function powerUpHandler(tabler, powerUpType)
        for _,part in pairs(tabler) do
            if coveredPart(part) then
                local powerUp = Assets.PowerUps:FindFirstChild(powerUpType):Clone()
                powerUp:PivotTo(part.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))

                if not workspace.Map:FindFirstChild("ChanceParts") then
                    local model = Instance.new("Model")
                    model.Name = "ChanceParts"
                    model.Parent = workspace.Map
                end
                powerUp.Parent = workspace.Map:FindFirstChild("ChanceParts")
                task.spawn(function()
                    local spinTime = 2
                    while powerUp.Parent ~= nil do
                        local goal = {Orientation = Vector3.new(0, powerUp.Effects.Orientation.Y + 360, 0)}
                        local properties = {Time = spinTime}
                        self.currentTween = TweenService.tween(powerUp.Effects, goal, properties)
                        task.wait(spinTime)
                    end
                end)

                part:Destroy()

                powerUp.PrimaryPart.PowerUpPrompt.ObjectText = toHMS(ChanceData[powerUpType].duration) .. " duration"

                if powerUpType == "GMultiPowerUp" then
                    powerUp.PrimaryPart.PowerUpPrompt.ActionText = "Collect G Multi Power Up"
                else
                    powerUp.PrimaryPart.PowerUpPrompt.ActionText = "Collect " .. string.gsub(powerUpType, "PowerUp", "") .. " Power Up"
                end

                local powerUpPrompt = {
                    prompt = powerUp.PrimaryPart.PowerUpPrompt,
                    powerUpType = powerUpType,
                    value = ChanceData[powerUpType].value,
                    model = powerUp,
                }
                table.insert(PowerUpPrompts, powerUpPrompt)
            end
        end
    end

    if chanceParts.Godly then
        famousHandler(chanceParts.Godly, "Godly")
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

    if chanceParts.SpeedPowerUp then
        powerUpHandler(chanceParts.SpeedPowerUp, "SpeedPowerUp")
    end

    if chanceParts.JumpPowerUp then
        powerUpHandler(chanceParts.JumpPowerUp, "JumpPowerUp")
    end

    if chanceParts.GMultiPowerUp then
        powerUpHandler(chanceParts.GMultiPowerUp, "GMultiPowerUp")
    end

    if chanceParts.LuckPowerUp then
        powerUpHandler(chanceParts.LuckPowerUp, "LuckPowerUp")
    end

    if chanceParts.Bomb then
        for _,part in pairs(chanceParts.Bomb) do
            if coveredPart(part) then
                local Bomb = Assets.MapAssets.Bomb:Clone()
                Bomb:PivotTo(part.CFrame * CFrame.Angles(0, math.random(0, 360), 0))
                Bomb.Parent = workspace.Map:FindFirstChild("ChanceParts")
                part:Destroy()

                task.spawn(function()
                    repeat task.wait(2) until not coveredPart(Bomb)
                    if Bomb.Parent ~= nil then
                        for _,particle in pairs(Bomb:GetDescendants()) do
                            if particle.ClassName == "ParticleEmitter" then
                                particle.Enabled = true
                            end
                        end
                        AudioService:Create(11565378, Bomb.Position, {Volume = 0.8, Duration = 2})

                        task.wait(2)

                        for _,player in pairs(getPlayersInRadius(Bomb.Position, ChanceData["Bomb"].size / 2)) do
                            if player.Character then
                                local damage = ChanceData["Bomb"].damage
                                local equipData = PlayerValues:GetValue(player, "Equipped")
                                if equipData and equipData.dataType == "Shovels" then
                                    if equipData.shovelStats.Special == "Bomb Resistance" then
                                        damage /= 2
                                    end
                                end

                                player.Character.Humanoid:TakeDamage(damage)
                            end
                        end

                        if not MapService.MakingNewMap then
                            if not ExplosionService then ExplosionService = require(Physics.ExplosionService) end
                            ExplosionService.create("Server", Bomb.Position, ChanceData["Bomb"].size, 15)
                        end

                        local particle = Assets.MapAssets.Explosion:Clone()
                        particle:PivotTo(Bomb.CFrame)
                        particle.Parent = workspace

                        AudioService:Create(16433289, Bomb.Position, {Volume = 0.8})

                        local growsize = Vector3.new(1, 1, 1) * ChanceData["Bomb"].size
                        local goal = {Transparency = 0.9, Size = growsize}
                        local properties = {Time = 0.15}
                        TweenService.tween(particle, goal, properties)

                        local goal = {Transparency = 1}
                        local properties = {Time = 1.35}
                        TweenService.tween(particle, goal, properties)

                        game.Debris:AddItem(particle, 1.5)
                        Bomb:Destroy()
                    end
                end)
            end
        end
    end

    if chanceParts.Spike then
        for _,part in pairs(chanceParts.Spike) do
            if coveredPart(part) then
                local Spike = Assets.MapAssets.Spike:Clone()
                Spike:PivotTo(part.CFrame * CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                Spike.Parent = part.Parent
            end
        end
    end

    if chanceParts.Lava then
        for _,part in pairs(chanceParts.Lava) do
            if coveredPart(part) then
                local Lava = Assets.MapAssets.Lava:Clone()
                Lava:PivotTo(part.CFrame)
                Lava.Size = part.Size
                Lava.Parent = part.Parent
                part:Destroy()
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
    for _, promptData in pairs(ShovelPrompts) do
        if promptData.prompt == promptObject then
            DataManager:NewShovel(player, promptData.shovelType, promptData.cost)
            break
        end
    end
end

function MapService:ProcessPowerUp(player, promptObject)
    for key, promptData in pairs(PowerUpPrompts) do
        if promptData.prompt == promptObject then
            PlayerValues:IncrementValue(player, promptData.powerUpType, promptData.value, "playerOnly")

            if player.Character then
                if not ToolService then ToolService = require(RepServices.ToolService) end
                ToolService:PlayerStats(player, player.Character)
            end

            promptData.model:Destroy()
            table.remove(PowerUpPrompts, key)

            task.wait(ChanceData[promptData.powerUpType].duration)

            if player then
                PlayerValues:IncrementValue(player, promptData.powerUpType, -promptData.value, "playerOnly")

                if player.Character then
                    ToolService:PlayerStats(player, player.Character)
                end
            end
        end
    end
end

---------------------------------------------------------

local Map
local MapTimer = General.MapTimer

local function teleportPlayers()
    for _,player in pairs(Players:GetChildren()) do
        local character = player.Character
        if character and character.Parent ~= nil then
            local rng = Random.new()
            character:PivotTo(workspace.Permanent.SpawnLocation.CFrame + Vector3.new(rng:NextInteger(-8, 8), 4, rng:NextInteger(-8, 8)))
        end
    end
end

local function initalizeShovels()
    for _,standHolder in pairs(workspace.Permanent.Shovels:GetChildren()) do
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

            if shovelData.Special then
                Stand.Special.SurfaceGui.Frame.TextLabel.Text = "Special:\n" .. shovelData.Special
            end

            Stand.ShovelHolder.ShovelPrompt.ObjectText = Stand.Name
            Stand.ShovelHolder.ShovelPrompt.ActionText = "Buy for " .. comma_value(shovelData.Cost) .. " Gold?"

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
    PowerUpPrompts = {}

	Map = Assets.Map:Clone()
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
end

task.spawn(function()
    if workspace:FindFirstChild("Map") then
        workspace.Map.Parent = ReplicatedStorage.Assets
    end

    initalizeShovels()

    while true do
        if Values.MapTimer.Value <= 0 then
            if Map then
                Map:Destroy()
            end
            teleportPlayers()

            MapService.MakingNewMap = true
            newMap()
            MapService.MakingNewMap = false

            Values.MapTimer.Value = MapTimer
        end

        task.wait(1)

        Values.MapTimer.Value -= 1
    end
end)

return MapService