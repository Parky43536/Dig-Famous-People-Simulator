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
		if cost then
			if playerProfile.Data.Gold >= cost then
				DataManager:GiveGold(player, -cost, true)
			else
				return false
			end
		end

		if not playerProfile.Data.Shovels[tostring(shovelData.id)] then
			playerProfile.Data.Shovels[tostring(shovelData.id)] = {}
		end

		local uniqueId = HttpService:GenerateGUID(false)
		table.insert(playerProfile.Data.Shovels[tostring(shovelData.id)], uniqueId)

		if cost then
			ToolService:LoadShovel(player, shovelType, uniqueId)
		end

		return playerProfile.Data.Shovels[tostring(shovelData.id)]
	end
end

function DataManager:NewFamous(player, famousType)
    local playerProfile = self:GetProfile(player)
	local famousData = FamousData[famousType]

	if playerProfile and famousData then
		if not playerProfile.Data.Famous[tostring(famousData.id)] then
			playerProfile.Data.Famous[tostring(famousData.id)] = {}
		end

		local uniqueId = HttpService:GenerateGUID(false)
		table.insert(playerProfile.Data.Famous[tostring(famousData.id)], uniqueId)

		ToolService:LoadFamous(player, famousType, uniqueId)

		PlayerValues:SetValue(player, "Famous", playerProfile.Data.Famous, "playerOnly")

		return playerProfile.Data.Famous[tostring(famousData.id)]
	end
end

function DataManager:SellTool(player, dataType, uniqueId, gold)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		for id, uniqueIds in pairs(playerProfile.Data[dataType]) do
			for key, dataUniqueId in pairs(uniqueIds) do
				if tostring(dataUniqueId) == tostring(uniqueId) then
					table.remove(playerProfile.Data[dataType][id], key)

					if next(playerProfile.Data[dataType][id]) == nil then
						playerProfile.Data[dataType][id] = nil
					end

					DataManager:GiveGold(player, gold, true)

					if dataType == "Famous" then
						PlayerValues:SetValue(player, "Famous", playerProfile.Data.Famous, "playerOnly")
					end

					return true
				end
			end
		end
	end
end

function DataManager:GiveGold(player, gold, ignoreMulti)
	if not ignoreMulti then
		gold = math.floor(gold * (PlayerValues:GetValue(player, "GMulti") or 1))
	end

	DataManager:IncrementValue(player, "Gold", gold)
	PlayerValues:IncrementValue(player, "Gold", gold, "playerOnly")
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
			PlayerValues:SetValue(player, "Gold", 0, "playerOnly")
			PlayerValues:SetValue(player, "Prestige", playerProfile.Data.Prestige, "playerOnly")

			player:LoadCharacter()
		end
	end
end

PrestigeRemote.OnServerEvent:Connect(function(player)
	DataManager:Prestige(player)
end)

return DataManager