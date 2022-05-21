local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local RepServices = ReplicatedStorage.Services
local ToolService = require(RepServices.ToolService)

local SerServices = ServerScriptService.Services
local DataStorage = SerServices.DataStorage
local ClientService = require(SerServices.ClientService)
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

function DataManager:InitalizeLife(player)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		if next(playerProfile.Data.Shovels) == nil then
			DataManager:NewShovel(player, "Default")
		end

		ClientService.InitializeTools(player, playerProfile)
	end
end

function DataManager:NewShovel(player, shovelType)
    local playerProfile = self:GetProfile(player)

	if playerProfile then
		local newShovel = ToolService:CreateShovel(player, shovelType)

		table.insert(playerProfile.Data.Shovels, newShovel)

		return newShovel
	end
end

function DataManager:NewFamous(player, famousType)
    local playerProfile = self:GetProfile(player)

	if playerProfile then
		local newFamous = ToolService:CreateFamous(player, famousType)

		table.insert(playerProfile.Data.Famous, newFamous)

		return newFamous
	end
end

function DataManager:DeleteTool(player, dataType, uniqueId)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		for key, tool in pairs(playerProfile.Data[dataType]) do
			if tool.uniqueId == uniqueId then
				table.remove(playerProfile.Data[dataType], key)
				return true
			end
		end
	end
end

return DataManager