local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local CharacterService = {}

local blockedAccessories = {
	["Jacket-TrenchCoat-White-8648380153"] = true
}

function CharacterService:CreateCharacterIcon(Tool, userId)
	if not Assets.Storage.Icons:FindFirstChild(userId) then
		task.spawn(function()
			local content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

			Tool.TextureId = content

			local stringValue = Instance.new("StringValue")
			stringValue.Value = content
			stringValue.Name = userId
			stringValue.Parent = Assets.Storage.Icons
		end)
	else
		Tool.TextureId = Assets.Storage.Icons:FindFirstChild(userId).Value
	end
end

function CharacterService:CreateCharacterRig(Part, userId)
	local characterModel

	if not Assets.Storage.Rigs:FindFirstChild(userId) then
		local characterData = Players:GetCharacterAppearanceAsync(userId)

		characterModel = Assets.Famous.R15:Clone()
		local characterHead = characterModel.Head
		local characterHumanoid = characterModel.Humanoid
		characterModel.Name = userId

		for _,obj in next, characterData:GetChildren() do
			if obj:IsA("Accessory") then
				if not blockedAccessories[obj.Name] then
					characterHumanoid:AddAccessory(obj)
				end
			end
		end

		for _,obj in next, characterData:GetChildren() do
			if obj.Name == "R15ArtistIntent" then
				for _,bodyPart in next, obj:GetChildren() do
					characterHumanoid:ReplaceBodyPartR15(Enum.BodyPartR15[bodyPart.Name], bodyPart)
				end
			end
		end
		
		local bodyColors = characterData:FindFirstChild("Body Colors")
		if bodyColors then
			bodyColors.Parent = characterModel
		end
		
		local shirt = characterData:FindFirstChild("Shirt")
		if shirt then
			shirt.Parent = characterModel
		end
		
		local tshirt = characterData:FindFirstChild("Shirt Graphic")
		if tshirt then
			tshirt.Parent = characterModel
		end
		
		local pants = characterData:FindFirstChild("Pants")
		if pants then
			pants.Parent = characterModel
		end
		
		local head = characterData:FindFirstChild("Mesh")
		if head then
			characterHead.Mesh:Destroy()
			head.Parent = characterHead
		end
		
		local face = characterData:FindFirstChild("face")
		if face then
			characterHead.face:Destroy()
			face.Parent = characterHead
		end

		for _,obj in next, characterModel:GetDescendants() do
			if obj:IsA("BasePart") then
				obj.Anchored = false
				obj.Massless = true
				obj.CanCollide = false
			end
		end

		characterHumanoid.BodyDepthScale.Value /= 2
		characterHumanoid.BodyWidthScale.Value /= 2
		characterHumanoid.BodyHeightScale.Value /= 2
		characterHumanoid.BodyHeightScale.Value -= 0.1

		if not Assets.Storage.Rigs:FindFirstChild(userId) then
			local storage = characterModel:Clone()
			storage.Parent = Assets.Storage.Rigs
		end

		characterData:Destroy()
	else
		characterModel = Assets.Storage.Rigs:FindFirstChild(userId):Clone()
	end

	characterModel.Parent = Part
	Part.Position = characterModel.PrimaryPart.Position

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = Part
	weld.Part1 = characterModel.PrimaryPart
	weld.Parent = characterModel.PrimaryPart

	return characterModel
end

return CharacterService