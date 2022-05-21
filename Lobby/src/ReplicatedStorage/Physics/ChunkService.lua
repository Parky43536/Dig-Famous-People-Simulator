local CollectionService = game:GetService("CollectionService")

local OVERLAP_VECTOR = Vector3.new(0, 0, 0)

local function smoothenFaces(part)
	part.FrontSurface = Enum.SurfaceType.Smooth
	part.BackSurface = Enum.SurfaceType.Smooth
	part.LeftSurface = Enum.SurfaceType.Smooth
	part.RightSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
end

local function getLargestPartAxis(part)
	local x = part.Size.X
	local y = part.Size.Y
	local z = part.Size.Z

	if x >= y and x >= z then
		return Vector3.new(2,1,1), Vector3.new(0.5,0,0)
	elseif y >= x and y >= z then
		return Vector3.new(1,2,1), Vector3.new(0,0.5,0)
	elseif z >= x and z >= y then
		return Vector3.new(1,1,2), Vector3.new(0,0,0.5)
	end
end

local ChunkService = {}

function ChunkService.makeChunks(part, optionalModel)
	if part.ClassName == "Part" then
		return ChunkService.chunkPart(part, optionalModel)
	elseif part.ClassName == "WedgePart" then
		return ChunkService.chunkWedge(part, optionalModel)
	end
end

function ChunkService.chunkPart(part, optionalModel)
	local model = optionalModel or Instance.new("Model")
	if not optionalModel then
		model.Parent = part.Parent
	end
	
	local sizeVector, positionVector = getLargestPartAxis(part)
	
	local hasWeld = false
	if part:FindFirstChild("WeldConstraint") then
		local foundWeld = part:FindFirstChild("WeldConstraint")
		hasWeld = foundWeld.Part1
		foundWeld:Destroy()
	end

	local newPart1 = part:Clone()
	
	newPart1.CanCollide = part.CanCollide
	newPart1.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))--
	newPart1.Size = part.Size / sizeVector + OVERLAP_VECTOR
	newPart1:PivotTo(part.CFrame * CFrame.new(part.Size * positionVector - newPart1.Size * positionVector))
	smoothenFaces(newPart1)
	newPart1.Parent = model
	
	if hasWeld then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = newPart1
		weld.Part1 = hasWeld
		weld.Parent = newPart1
	end
	
	local newPart2 = newPart1:Clone()
	
	if newPart2:FindFirstChild("WeldConstraint") then
		newPart2:FindFirstChild("WeldConstraint"):Destroy()
	end
	
	newPart2.CanCollide = part.CanCollide
	newPart2.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))--
	newPart2:PivotTo(part.CFrame * CFrame.new(-part.Size * positionVector + newPart2.Size * positionVector))
	smoothenFaces(newPart2)
	newPart2.Parent = model
	
	if hasWeld then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = newPart2
		weld.Part1 = hasWeld
		weld.Parent = newPart2
	end

	CollectionService:AddTag(newPart1, "Breakable")
	CollectionService:AddTag(newPart2, "Breakable")

	if CollectionService:HasTag(part, "Decor") then
		CollectionService:AddTag(newPart1, "Decor")
		CollectionService:AddTag(newPart2, "Decor")
	end

	if newPart1.Size.Magnitude >= 50 then
		ChunkService.makeChunks(newPart1, model)
	end

	if newPart2.Size.Magnitude >= 50 then
		ChunkService.makeChunks(newPart2, model)
	end
	
	part:Destroy()
	
	return model
end

function ChunkService.chunkWedge(part, optionalModel)
	local model = optionalModel or Instance.new("Model")
	if not optionalModel then
		model.Parent = part.Parent
	end
	
	local newParts = {}
	local count = #model:GetChildren()
	
	local wedge1 = Instance.new("WedgePart")
	wedge1.CanCollide = part.CanCollide
	wedge1.Anchored = true
	wedge1.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))--
	wedge1.Material = part.Material
	wedge1.Size = part.Size / Vector3.new(1,2,2) + OVERLAP_VECTOR
	wedge1.CFrame = part.CFrame * CFrame.new(0, wedge1.Size.Y / 2, wedge1.Size.Z / 2)
	wedge1.Name = part.Name..count+1
	smoothenFaces(wedge1)
	wedge1.Parent = model

	local wedge2 = Instance.new("WedgePart")
	wedge2.CanCollide = part.CanCollide
	wedge2.Anchored = true
	wedge2.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))--
	wedge2.Material = part.Material
	wedge2.Size = Vector3.new(part.Size.X, part.Size.Z / 2, part.Size.Y / 2) + OVERLAP_VECTOR
	wedge2.CFrame = part.CFrame * CFrame.new(0, wedge2.Size.Z / -2, wedge2.Size.Y / -2) * CFrame.Angles(math.rad(90), 0, math.rad(180))
	wedge2.Name = part.Name..count+2
	smoothenFaces(wedge2)
	wedge2.Parent = model

	local part3 = Instance.new("Part")
	part3.CanCollide = part.CanCollide
	part3.Anchored = true
	part3.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))--
	part3.Material = part.Material
	part3.Size = part.Size / Vector3.new(1,2,2) + OVERLAP_VECTOR
	part3.CFrame = part.CFrame * CFrame.new(0, part3.Size.Y / -2, part3.Size.Z / 2)
	part3.Name = part.Name..count+3
	smoothenFaces(part3)
	part3.Parent = model

	if CollectionService:HasTag(part, "Decor") then
		CollectionService:AddTag(wedge1, "Decor")
		CollectionService:AddTag(wedge2, "Decor")
		CollectionService:AddTag(part3, "Decor")
	end
	
	table.insert(newParts, wedge1)
	table.insert(newParts, wedge2)
	table.insert(newParts, part3)

	for _,object in pairs(newParts) do
		CollectionService:AddTag(object, "Breakable")
		
		local multiplyVector
		if object.ClassName == "WedgePart" then
			multiplyVector = Vector3.new(0,1,1)
		else
			multiplyVector = Vector3.new(1,1,1)
		end

		if (object.Size * multiplyVector).Magnitude >= 75 then
			ChunkService.makeChunks(object, model)
		end

		CollectionService:AddTag(object, "Destructable")
	end
	
	part:Destroy()
	
	return model
end

return ChunkService
