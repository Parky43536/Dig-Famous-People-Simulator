local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Physics = ReplicatedStorage.Physics
local PartManager = require(Physics.PartManager)
local ChunkService = require(Physics.ChunkService)

for _,object in pairs(workspace.Map:GetDescendants()) do
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
	end
end
