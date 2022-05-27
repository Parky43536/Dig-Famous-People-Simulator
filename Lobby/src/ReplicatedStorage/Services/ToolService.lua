local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage.Assets

local Physics = ReplicatedStorage:WaitForChild("Physics")
local ExplosionService

local SerServices = ServerScriptService.Services
local DataManager

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)
local MapService

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CharacterService = require(Utility:WaitForChild("CharacterService"))
local General = require(Utility:WaitForChild("General"))

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes:WaitForChild("ClientConnection")

local ToolService = {}

local EquippedTracker = {}
local DigCooldown = {}

function ToolService:PlayerStats(player, Humanoid, shovelStats)
    if not shovelStats then shovelStats = {} end
    local defaultStats = ShovelData["Default Shovel"].Stats

    local newStats = {
        Reload = (shovelStats.Reload or defaultStats.Reload),
        Dig = (shovelStats.Dig or defaultStats.Dig),
        Speed = (shovelStats.Speed or defaultStats.Speed),
        Jump = (shovelStats.Jump or defaultStats.Jump),
        GMulti = (shovelStats.GMulti or defaultStats.GMulti),
        Luck = (shovelStats.Luck or defaultStats.Luck),
    }

    Humanoid.WalkSpeed = newStats.Speed
    Humanoid.JumpHeight = newStats.Jump

    PlayerValues:SetValue(player, "GMulti", newStats.GMulti)
    PlayerValues:SetValue(player, "Luck", newStats.Luck)

    if next(shovelStats) == nil then
        for stat, value in pairs(newStats) do
            if value == ShovelData["Default Shovel"].Stats[stat] then
                newStats[stat] = "Hide"
            end
        end
    end

    ClientConnection:FireClient(player, "showPlayerStats", {
        newStats = newStats
    })
end

function ToolService:LoadShovel(player, shovelType, uniqueId)
    local shovelStats = ShovelData[shovelType]
    if shovelStats then
        local shovel = {
            uniqueId = uniqueId,
            shovelType = shovelType,
        }

        local Tool = Assets.Shovels:FindFirstChild(shovel.shovelType):Clone()
        Tool.ToolTip = shovel.shovelType

        if not player.Character then
            repeat task.wait(1) until player.Character
        end
        Tool.Parent = player.Backpack

        ToolService:ShovelManager(player, Tool, shovel, shovelStats)
    end
end

function ToolService:ShovelManager(player, Tool, shovel, shovelStats)
    local Handle = Tool:WaitForChild("Handle")
    local Character = player.Character
    local Humanoid = Character.Humanoid
    local ToolEquipped = false

    local function Create(ty)
        return function(data)
            local obj = Instance.new(ty)
            for k, v in pairs(data) do
                if type(k) == 'number' then
                    v.Parent = obj
                else
                    obj[k] = v
                end
            end
            return obj
        end
    end

    local Sounds = {
        Dig = Handle:WaitForChild("Dig")
    }

    local Animations = {
        Slash = 522635514,
    }

    local function CheckIfAlive(player)
        return player
        and player.Character
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
    end

    local function Dig()
        if not ExplosionService then ExplosionService = require(Physics.ExplosionService) end
        ExplosionService.create(player, Handle.Position, shovelStats.Stats.Dig, 10)

        Sounds.Dig:Play()

        if Humanoid then
            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                local Anim = Instance.new("StringValue")
                Anim.Name = "toolanim"
                Anim.Value = "Lunge"
                Anim.Parent = Tool
            elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
                local Anim = (Tool:FindFirstChild("Slash") or Create("Animation"){
                    Name = "Slash",
                    AnimationId = "rbxassetid://" .. Animations.Slash,
                    Parent = Tool
                })
                if Anim then
                    local Track = Humanoid:LoadAnimation(Anim)
                    Track:Play(0)
                end
            end
        end
    end

    local function Activated()
        if not Tool.Enabled or not ToolEquipped or DigCooldown[player] or not CheckIfAlive(player) then
            return
        end

        DigCooldown[player] = true
        Tool.Enabled = false

        Dig()

        task.wait(shovelStats.Stats.Reload)

        DigCooldown[player] = nil
        Tool.Enabled = true
    end

    local function Equipped()
        if not CheckIfAlive(player) then
            return
        end

        ToolService:PlayerStats(player, Humanoid, shovelStats.Stats)

        EquippedTracker[player] = {dataType = "Shovels", data = shovel, tool = Tool, shovelStats = shovelStats}
        ToolEquipped = true
    end

    local function Unequipped()
        ToolService:PlayerStats(player, Humanoid)

        ToolEquipped = false
        EquippedTracker[player] = nil
    end

    Tool.Activated:Connect(Activated)
    Tool.Equipped:Connect(Equipped)
    Tool.Unequipped:Connect(Unequipped)
end

function ToolService:LoadFamous(player, famousType, uniqueId)
    local famousStats = FamousData[famousType]
    if famousStats then
        local famous = {
            uniqueId = uniqueId,
            famousType = famousType,
        }

        local Tool = Assets.Famous.Tool:Clone()

        task.spawn(function()
            Tool.TextureId = CharacterService:CreateCharacterIcon(famous.famousType)
        end)

        CharacterService:CreateCharacterRig(Tool.Handle, famous.famousType)

        if not MapService then MapService = require(RepServices.MapService) end
        Tool.ToolTip = famousStats.Name .. ", " .. famousStats.Rarity .. ", " .. MapService:RoundDeci(1 / General.ItemChances[famousStats.Rarity] * 5000, 2) .. "%"
        Tool.Name = famousStats.Name

        if not player.Character then
            repeat task.wait(1) until player.Character
        end
        Tool.Parent = player.Backpack

        ToolService:FamousManager(player, Tool, famous, famousStats)
    end
end

function ToolService:FamousManager(player, Tool, famous, famousStats)
    local Handle = Tool:WaitForChild("Handle")

    local function CheckIfAlive(player)
        return player
        and player.Character
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
    end

    local function Equipped()
        if not CheckIfAlive(player) then
            return
        end

        local rig = Handle:FindFirstChildOfClass("Model")
        if rig then
            rig.Humanoid.PlatformStand = true
        end

        EquippedTracker[player] = {dataType = "Famous", data = famous, tool = Tool, famousStats = famousStats}
    end

    local function Unequipped()
        EquippedTracker[player] = nil
    end

    Tool.Equipped:Connect(Equipped)
    Tool.Unequipped:Connect(Unequipped)
end

function ToolService:SellEquippedTool(player)
    local equipData = EquippedTracker[player]
    if equipData then
        local gold = 0
        local minMax
        if equipData.dataType == "Famous" then
            gold = General.RarityData[equipData.famousStats.Rarity].goldValue
        elseif equipData.dataType == "Shovels" then
            gold = equipData.shovelStats.Cost * General.ShovelValue
            minMax = {min = 0, max = equipData.shovelStats.Cost}
        end

        if not DataManager then DataManager = require(SerServices.DataManager) end
        local removed = DataManager:SellTool(player, equipData.dataType, equipData.data.uniqueId, gold, minMax)
        if removed then
            equipData.tool:Destroy()
            EquippedTracker[player] = nil

            local character = player.Character
            if character then
                ToolService:PlayerStats(player, character.Humanoid)
            end
        end
    end
end

return ToolService