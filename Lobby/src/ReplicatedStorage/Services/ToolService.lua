local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Physics = ReplicatedStorage:WaitForChild("Physics")
local ExplosionService

local SerServices = ServerScriptService.Services
local DataManager

local Utility = ReplicatedStorage:WaitForChild("Utility")
local ToolFunctions = require(Utility:WaitForChild("ToolFunctions"))
local CharacterService = require(Utility:WaitForChild("CharacterService"))

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))

local Assets = ReplicatedStorage.Assets
local FamousData = ReplicatedStorage.Database.FamousData

local ToolService = {}

local Loaded = {}
local EquippedTracker = {}

function ToolService:CreateShovel(player, shovelType)
    local shovel = {
        uniqueId = HttpService:GenerateGUID(false),
        shovelType = shovelType,
    }

    if shovel.shovelType ~= "Default" then
        ToolService:LoadShovel(player, shovel)
    end

    return shovel
end

function ToolService:LoadShovel(player, shovel)
    local Tool = Assets.Shovels:FindFirstChild(shovel.shovelType):Clone()
    local shovelStats = ShovelData[shovel.shovelType]

    if shovel.shovelType ~= "Default" then
        Tool.ToolTip = shovel.shovelType .. ", " .. shovelStats.Rarity
    end

    if not Loaded[player] then
        repeat task.wait(1) until Loaded[player]
    end
    Tool.Parent = player.Backpack

    ToolService:ShovelManager(player, Tool, shovel, shovelStats)
end

function ToolService:ShovelManager(player, Tool, shovel, shovelStats)
    local Handle = Tool:WaitForChild("Handle")
    local Character = player.Character
    local Humanoid = Character.Humanoid
    local ToolEquipped = false

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
        ExplosionService.create(Handle.Position, shovelStats.Stats.Dig, 10)

        Sounds.Dig:Play()

        if Humanoid then
            local Anim = (Tool:FindFirstChild("Slash") or ToolFunctions:Create("Animation"){
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

    local function Activated()
        if not Tool.Enabled or not ToolEquipped or not CheckIfAlive(player) then
            return
        end

        Tool.Enabled = false
        Dig()
        task.wait(shovelStats.Stats.Cooldown)
        Tool.Enabled = true
    end

    local function Equipped()
        if not CheckIfAlive(player) then
            return
        end

        Humanoid.WalkSpeed = shovelStats.Stats.Speed
        Humanoid.JumpHeight = shovelStats.Stats.Jump

        EquippedTracker[player] = {dataType = "Shovels", data = shovel, tool = Tool}
        ToolEquipped = true
    end

    local function Unequipped()
        Humanoid.WalkSpeed = ShovelData["Default"].Stats.Speed
        Humanoid.JumpHeight = ShovelData["Default"].Stats.Jump
        ToolEquipped = false
        EquippedTracker[player] = nil
    end

    Tool.Activated:Connect(Activated)
    Tool.Equipped:Connect(Equipped)
    Tool.Unequipped:Connect(Unequipped)
end

function ToolService:CreateFamous(player, famousType)
    local famous = {
        uniqueId = HttpService:GenerateGUID(false),
        famousType = famousType,
    }

    ToolService:LoadFamous(player, famous)

    return famous
end

function ToolService:LoadFamous(player, famous)
    local Tool = Assets.Famous.Tool:Clone()
    local famousStats = FamousData:FindFirstChild(famous.famousType)

    ToolFunctions:ReadyTool(Tool, famous, famousStats)

    CharacterService:CreateCharacter(Tool.Handle, famous.famousType)

    if not Loaded[player] then
        repeat task.wait(1) until Loaded[player]
    end
    Tool.Parent = player.Backpack

    ToolService:FamousManager(player, Tool, famous, famousStats)
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

        Handle.Character.Humanoid.PlatformStand = true

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
            Humanoid.WalkSpeed = ShovelData["Default"].Stats.Speed
            Humanoid.JumpHeight = ShovelData["Default"].Stats.Jump
        end
    end
end

Players.PlayerAdded:Connect(function(playerAdded)
    playerAdded.CharacterAdded:Connect(function(newCharacter)
        Loaded[playerAdded] = true
    end)
end)

return ToolService