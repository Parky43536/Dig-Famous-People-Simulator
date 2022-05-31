local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerValues = require(ServerScriptService.ServerValues)

local Assets = ReplicatedStorage.Assets

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local ClientService = require(SerServices.ClientService)

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))

local PlayerProfiles = {}

local function getPlayerProfile(player)
    return DataManager:Initialize(player, ServerValues.DATASTORE_NAME)
end

local function loadPlayerProfile(player, profile)
    PlayerProfiles[player] = profile
end

local function playerAdded(newPlayer)
    local profile = getPlayerProfile(newPlayer)
	if profile ~= nil then
		loadPlayerProfile(newPlayer, profile)
	else
        warn("Could not load player profile")
    end

    local function loadPlayer()
        task.spawn(function()
            if not newPlayer.Character then
                repeat task.wait(1) until newPlayer.Character
            end

            local character = newPlayer.Character
            if character then
                ToolService:PlayerStats(newPlayer, character)
            end

            local light = Instance.new("PointLight")
            light.Parent = newPlayer.Character.PrimaryPart

            local hitbox = Assets.Player.HitBox:Clone()
            hitbox.CFrame = CFrame.new(newPlayer.Character.PrimaryPart.Position)
            hitbox.Parent = newPlayer.Character

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = newPlayer.Character.PrimaryPart
            weld.Part1 = hitbox
            weld.Parent = hitbox

            local lastHit
            hitbox.Touched:connect(function(hitPart)
                if CollectionService:HasTag(hitPart, "Hazard") then
                    local ticker = tick()
                    if not lastHit or ticker - lastHit > General.HazardCooldown then
                        lastHit = ticker
                        newPlayer.Character.Humanoid:TakeDamage(General.HazardDamage)
                    end
                end
            end)
        end)

        ClientService.InitializeClient(newPlayer, profile)

        --prestige overhead
    end

    loadPlayer()

    newPlayer.CharacterAdded:Connect(function()
        loadPlayer()
    end)
end

local function playerRemoved(player)
	local profile = PlayerProfiles[player]
	if profile ~= nil then
		profile:Release()
        PlayerProfiles[player] = nil
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoved)

for _,currentPlayers in pairs(Players:GetChildren()) do
    playerAdded(currentPlayers)
end