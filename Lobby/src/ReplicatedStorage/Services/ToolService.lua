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

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local ToolService = {}

local Loaded = {}
local EquippedTracker = {}
local DigCooldown = {}

function ToolService:LoadShovel(player, shovelType, uniqueId)
    local shovelStats = ShovelData[shovelType]
    if shovelStats then
        local shovel = {
            uniqueId = uniqueId,
            shovelType = shovelType,
        }

        local Tool = Assets.Shovels:FindFirstChild(shovel.shovelType):Clone()
        Tool.ToolTip = shovel.shovelType

        if not Loaded[player] then
            repeat task.wait(1) until Loaded[player]
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

        Humanoid.WalkSpeed = shovelStats.Stats.Speed
        Humanoid.JumpHeight = shovelStats.Stats.Jump
        PlayerValues:SetValue(player, "GMulti", shovelStats.Stats.GMulti)
        PlayerValues:SetValue(player, "Luck", shovelStats.Stats.Luck)

        EquippedTracker[player] = {dataType = "Shovels", data = shovel, tool = Tool}
        ToolEquipped = true
    end

    local function Unequipped()
        Humanoid.WalkSpeed = ShovelData["Default Shovel"].Stats.Speed
        Humanoid.JumpHeight = ShovelData["Default Shovel"].Stats.Jump
        PlayerValues:SetValue(player, "GMulti", ShovelData["Default Shovel"].Stats.GMulti)
        PlayerValues:SetValue(player, "Luck", ShovelData["Default Shovel"].Stats.Luck)
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

        CharacterService:CreateCharacterIcon(Tool, famous.famousType)
        CharacterService:CreateCharacterRig(Tool.Handle, famous.famousType)

        if not MapService then MapService = require(RepServices.MapService) end
        Tool.ToolTip = famousStats.Name .. ", " .. famousStats.Rarity .. ", " .. MapService:RoundDeci(1 / MapService.chances[famousStats.Rarity] * 5000, 2) .. "%"

        if not Loaded[player] then
            repeat task.wait(1) until Loaded[player]
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

        EquippedTracker[player] = {dataType = "Famous", data = famous, tool = Tool}
    end

    local function Unequipped()
        EquippedTracker[player] = nil
    end

    Tool.Equipped:Connect(Equipped)
    Tool.Unequipped:Connect(Unequipped)
end

function ToolService:DeleteEquippedTool(player)
    local equipData = EquippedTracker[player]
    if equipData then
        if not DataManager then DataManager = require(SerServices.DataManager) end
        local removed = DataManager:DeleteTool(player, equipData.dataType, equipData.data.uniqueId)
        if removed then
            equipData.tool:Destroy()
            EquippedTracker[player] = nil

            local Character = player.Character
            local Humanoid = Character.Humanoid
            Humanoid.WalkSpeed = ShovelData["Default Shovel"].Stats.Speed
            Humanoid.JumpHeight = ShovelData["Default Shovel"].Stats.Jump
            PlayerValues:SetValue(player, "GMulti", ShovelData["Default Shovel"].Stats.GMulti)
            PlayerValues:SetValue(player, "Luck", ShovelData["Default Shovel"].Stats.Luck)
        end
    end
end

Players.PlayerAdded:Connect(function(playerAdded)
    playerAdded.CharacterAdded:Connect(function(newCharacter)
        Loaded[playerAdded] = true
    end)
end)

return ToolService