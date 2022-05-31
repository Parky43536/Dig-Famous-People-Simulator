local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices:WaitForChild("ToolService"))
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local DataBase = ReplicatedStorage.Database
local ShovelData = require(DataBase:WaitForChild("ShovelData"))
local FamousData = require(DataBase:WaitForChild("FamousData"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility:WaitForChild("General"))
local AudioService = require(Utility:WaitForChild("AudioService"))

local Remotes = ReplicatedStorage.Remotes
local PrestigeRemote = Remotes.PrestigeRemote

local SerServices = ServerScriptService.Services
local DataStorage = SerServices.DataStorage
local ProfileService = require(DataStorage.ProfileService)
local ProfileTemplate = require(DataStorage.ProfileTemplate)

local DataManager = {}
DataManager.Profiles = {}

function DataManager:Initialize(player, storeName)
	local PlayerDataProfileStore = ProfileService.GetProfileStore(
		storeName,
		ProfileTemplate
	)

	local profile = PlayerDataProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			if not RunService:IsStudio() then
				player:Kick(ErrorCodeHelper.FormatCode("0001"))
			end
		end)

		if player:IsDescendantOf(Players) then
			self.Profiles[player] = profile
		else
			-- player left before data was loaded
			profile:Release()
		end
	elseif not RunService:IsStudio() then
		player:Kick(ErrorCodeHelper.FormatCode("0002"))
	end

	return profile
end

function DataManager:SetValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = value
	end

	return nil
end

function DataManager:IncrementValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = (playerProfile.Data[property] or 0) + value
	end

	return playerProfile.Data[property]
end

function DataManager:GetData(player, property)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		if property then
			return playerProfile.Data[property]
		else
			return playerProfile.Data
		end
	end

	warn(player, "has no profile stored in the data")
	return nil
end

function DataManager:GetProfile(player)
	return self.Profiles[player]
end

----------------------------------------------------------------------------------

local function length(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter += 1
	end
	return counter
end

function DataManager:NewShovel(player, shovelType, cost)
	local playerProfile = self:GetProfile(player)
	local shovelData = ShovelData[shovelType]

	if playerProfile and shovelData then
		local uniqueId = HttpService:GenerateGUID(false)

		if playerProfile.Data.Shovels[tostring(shovelData.id)] then
			return false
		end

		if cost then
			if playerProfile.Data.Gold >= cost then
				DataManager:GiveGold(player, -cost, {minMax = {min = -shovelData.Cost, max = 0}})
				ToolService:LoadShovel(player, shovelType, uniqueId)
			else
				return false
			end
		end

		playerProfile.Data.Shovels[tostring(shovelData.id)] = uniqueId

		return true
	end
end

function DataManager:NewFamous(player, famousType)
    local playerProfile = self:GetProfile(player)
	local famousData = FamousData[famousType]

	if playerProfile and famousData then
		if playerProfile.Data.Famous[tostring(famousData.id)] then
			local gold = General.RarityData[famousData.Rarity].goldValue
			DataManager:GiveGold(player, gold)
		else
			local uniqueId = HttpService:GenerateGUID(false)
			playerProfile.Data.Famous[tostring(famousData.id)] = uniqueId
			ToolService:LoadFamous(player, famousType, uniqueId)
			PlayerValues:SetValue(player, "Famous", playerProfile.Data.Famous, "playerOnly")
		end

		return true
	end
end

function DataManager:SellTool(player, dataType, uniqueId, gold, minMax)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		for id, dataUniqueId in pairs(playerProfile.Data[dataType]) do
			if tostring(dataUniqueId) == tostring(uniqueId) then
				playerProfile.Data[dataType][id] = nil

				DataManager:GiveGold(player, gold, {minMax = minMax})

				if dataType == "Famous" then
					PlayerValues:SetValue(player, "Famous", playerProfile.Data.Famous, "playerOnly")
				end

				return true
			end
		end
	end
end

function DataManager:GiveGold(player, gold, args)
	if not args then args = {} end
	if player and gold then
		gold = math.floor(gold * (PlayerValues:GetValue(player, "GMulti") or 1))

		if args.minMax then
			gold = math.clamp(gold, args.minMax.min, args.minMax.max)
		end

		local volume = 0.6
		if args.lowVolume then
			volume /= 2
		end
		local rng = Random.new()
		AudioService:Create(9781176124, player, {Volume = volume, Pitch = rng:NextNumber(0.9, 1.1)})

		DataManager:IncrementValue(player, "Gold", gold)
		PlayerValues:IncrementValue(player, "Gold", gold, "playerOnly")
	end
end

function DataManager:Prestige(player)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		if length(playerProfile.Data.Famous) == length(FamousData) then
			playerProfile.Data.Famous = {}
			playerProfile.Data.Shovels = {}
			playerProfile.Data.Gold = 0
			playerProfile.Data.Prestige += 1

			PlayerValues:SetValue(player, "Famous", playerProfile.Data.Famous, "playerOnly")
			PlayerValues:SetValue(player, "Gold", playerProfile.Data.Gold, "playerOnly")
			PlayerValues:SetValue(player, "Prestige", playerProfile.Data.Prestige, "playerOnly")

			player:LoadCharacter()
		end
	end
end

PrestigeRemote.OnServerEvent:Connect(function(player)
	DataManager:Prestige(player)
end)

return DataManager