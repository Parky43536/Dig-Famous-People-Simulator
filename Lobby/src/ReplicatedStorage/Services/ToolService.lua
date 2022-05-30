local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

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
local AudioService = require(Utility:WaitForChild("AudioService"))

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))
local ChanceData = require(DataBase:WaitForChild("ChanceData"))

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes:WaitForChild("ClientConnection")

local ToolService = {}

local DigCooldown = {}

function ToolService:PlayerStats(player, character)
    local shovelStats = {}
    local equipData = PlayerValues:GetValue(player, "Equipped")
    if equipData and equipData.dataType == "Shovels" then
        shovelStats = equipData.shovelStats.Stats
    end

    local defaultStats = ShovelData["Default Shovel"].Stats
    local prestige = PlayerValues:GetValue(player, "Prestige") or 0
    local SpeedPowerUp = PlayerValues:GetValue(player, "SpeedPowerUp") or 0
    local JumpPowerUp = PlayerValues:GetValue(player, "JumpPowerUp") or 0
    local GMultiPowerUp = PlayerValues:GetValue(player, "GMultiPowerUp") or 0
    local LuckPowerUp = PlayerValues:GetValue(player, "LuckPowerUp") or 0

    local newStats = {
        Reload = (shovelStats.Reload or defaultStats.Reload),
        Dig = (shovelStats.Dig or defaultStats.Dig),
        Speed = (shovelStats.Speed or defaultStats.Speed) + (General.PrestigeBonus.Speed * prestige) + SpeedPowerUp,
        Jump = (shovelStats.Jump or defaultStats.Jump) + (General.PrestigeBonus.Jump * prestige) + JumpPowerUp,
        GMulti = (shovelStats.GMulti or defaultStats.GMulti) + (General.PrestigeBonus.GMulti * prestige) + GMultiPowerUp,
        Luck = (shovelStats.Luck or defaultStats.Luck) + (General.PrestigeBonus.Luck * prestige) + LuckPowerUp,
    }

    if equipData and equipData.shovelStats and equipData.shovelStats.Special then
        if equipData.shovelStats.Special == "Double Speed" or equipData.shovelStats.Special == "All Specials" then
            newStats.Speed *= 2
        end
        if equipData.shovelStats.Special == "Double Jump" or equipData.shovelStats.Special == "All Specials" then
            newStats.Jump *= 2
        end
        if equipData.shovelStats.Special == "Double G Multi" or equipData.shovelStats.Special == "All Specials" then
            newStats.GMulti *= 2
        end
        if equipData.shovelStats.Special == "Double Luck" or equipData.shovelStats.Special == "All Specials" then
            newStats.Luck *= 2
        end
    end

    character.Humanoid.WalkSpeed = newStats.Speed
    character.Humanoid.JumpHeight = newStats.Jump

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

    local function powerUpEffect(powerUpType, add)
        local attachment = character.PrimaryPart:FindFirstChild("Attachment")
        if not attachment then
            attachment = Instance.new("Attachment")
            attachment.Parent = character.PrimaryPart
        end

        local findEffect = attachment:FindFirstChild(powerUpType .. "Effect")
        if add then
            if not findEffect then
                local effect = Assets.PowerUps:FindFirstChild(powerUpType .. "Effect"):Clone()
                effect.Parent = attachment
            end
        else
            if findEffect then
                findEffect:Destroy()
            end
        end
    end
    if SpeedPowerUp > 0 then
        powerUpEffect("SpeedPowerUp", true)
    else
        powerUpEffect("SpeedPowerUp", false)
    end
    if JumpPowerUp > 0 then
        powerUpEffect("JumpPowerUp", true)
    else
        powerUpEffect("JumpPowerUp", false)
    end
    if GMultiPowerUp > 0 then
        powerUpEffect("GMultiPowerUp", true)
    else
        powerUpEffect("GMultiPowerUp", false)
    end
    if LuckPowerUp > 0 then
        powerUpEffect("LuckPowerUp", true)
    else
        powerUpEffect("LuckPowerUp", false)
    end
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

    local function CheckIfAlive(player)
        return player
        and player.Character
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0
    end

    local function Dig()
        if not MapService then MapService = require(RepServices.MapService) end
        if not MapService.MakingNewMap then
            local dig = shovelStats.Stats.Dig
            if shovelStats.Special then
                if shovelStats.Special == "Double Dig" or shovelStats.Special == "All Specials" then
                    dig *= 2
                end
            end

            if not ExplosionService then ExplosionService = require(Physics.ExplosionService) end
            ExplosionService.create(player, Handle.Position, dig, 10)
        end

        AudioService:Create(12222216, Handle, {Volume = 0.6})

        if Humanoid then
            if Humanoid.RigType == Enum.HumanoidRigType.R6 then
                local Anim = Instance.new("StringValue")
                Anim.Name = "toolanim"
                Anim.Value = "Lunge"
                Anim.Parent = Tool
            elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
                local Track = Humanoid:LoadAnimation(Assets.Animations.ShovelSlash)
                Track:Play(0)
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

        local reload = shovelStats.Stats.Reload
        if shovelStats.Special then
            if shovelStats.Special == "Half Reload" or shovelStats.Special == "All Specials" then
                reload /= 2
            end
        end
        task.wait(reload)

        DigCooldown[player] = nil
        Tool.Enabled = true
    end

    local function Equipped()
        if not CheckIfAlive(player) then
            return
        end

        PlayerValues:SetValue(player, "Equipped", {dataType = "Shovels", data = shovel, tool = Tool, shovelStats = shovelStats})
        ToolService:PlayerStats(player, Character)

        if shovelStats.Special == "Flight" or shovelStats.Special == "All Specials" then
            PlayerValues:SetValue(player, "Flight", true, "playerOnly")
        end
        
        ToolEquipped = true
    end

    local function Unequipped()
        PlayerValues:SetValue(player, "Equipped", nil)
        ToolService:PlayerStats(player, Character)

        if shovelStats.Special == "Flight" or shovelStats.Special == "All Specials" then
            PlayerValues:SetValue(player, "Flight", nil, "playerOnly")
        end

        ToolEquipped = false
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
        Tool.ToolTip = famousStats.Name .. ", " .. famousStats.Rarity .. ", " .. MapService:RoundDeci(1 / ChanceData[famousStats.Rarity].chance * General.ChanceMulti, 2) .. "%"
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

        PlayerValues:SetValue(player, "Equipped", {dataType = "Famous", data = famous, tool = Tool, famousStats = famousStats})
    end

    local function Unequipped()
        PlayerValues:SetValue(player, "Equipped", nil)
    end

    Tool.Equipped:Connect(Equipped)
    Tool.Unequipped:Connect(Unequipped)
end

function ToolService:SellEquippedTool(player)
    local equipData = PlayerValues:GetValue(player, "Equipped")
    if equipData then
        local gold = 0
        local minMax
        if equipData.dataType == "Famous" then
            gold = General.RarityData[equipData.famousStats.Rarity].goldValue
        elseif equipData.dataType == "Shovels" then
            gold = equipData.shovelStats.Cost * General.ShovelValue
            minMax = {min = 0, max = equipData.shovelStats.Cost * General.ShovelValue}
        end

        if not DataManager then DataManager = require(SerServices.DataManager) end
        local removed = DataManager:SellTool(player, equipData.dataType, equipData.data.uniqueId, gold, minMax)
        if removed then
            equipData.tool:Destroy()
            PlayerValues:SetValue(player, "Equipped", nil)

            if player then
                ToolService:PlayerStats(player, player.Character)
            end
        end
    end
end

return ToolService