local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)
local MapService = require(RepServices.MapService)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)

local SCALING_CONSTANT = 3
local ABSOLUTE_MAX_COMBINE = 8

local function smoothenFaces(part)
	part.FrontSurface = Enum.SurfaceType.Smooth
	part.BackSurface = Enum.SurfaceType.Smooth
	part.LeftSurface = Enum.SurfaceType.Smooth
	part.RightSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
end

local function combineParts(model, parts, cubeSize, originalPart)
	local centralPosition = Vector3.new(0,0,0)

	for _,part in pairs(parts) do
		centralPosition += part.Position
	end

	centralPosition /= #parts

	local xMinPosition = 99e99
	local xMaxPosition = 0

	local yMinPosition = 99e99
	local yMaxPosition = 0

	local zMinPosition = 99e99
	local zMaxPosition = 0

	for _,part in pairs(parts) do
		xMinPosition = math.min(xMinPosition, part.Position.X - cubeSize.X/2)
		xMaxPosition = math.max(xMaxPosition, part.Position.X + cubeSize.X/2)

		yMinPosition = math.min(yMinPosition, part.Position.Y - cubeSize.Y/2)
		yMaxPosition = math.max(yMaxPosition, part.Position.Y + cubeSize.Y/2)

		zMinPosition = math.min(zMinPosition, part.Position.Z - cubeSize.Z/2)
		zMaxPosition = math.max(zMaxPosition, part.Position.Z + cubeSize.Z/2)
	end

	local newPart = Instance.new("Part")
	newPart.Anchored = originalPart.Anchored
	newPart.Transparency = originalPart.Transparency
	newPart.CanCollide = originalPart.CanCollide
	newPart.Color = originalPart.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	newPart.Material = originalPart.Material
	newPart.Size = Vector3.new(
		xMaxPosition - xMinPosition,
		yMaxPosition - yMinPosition,
		zMaxPosition - zMinPosition
	)
	
	if originalPart:FindFirstChild("WeldConstraint") then
		local foundWeld = originalPart:FindFirstChild("WeldConstraint")
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = newPart
		weld.Part1 = foundWeld.Part1
		weld.Parent = newPart
	end

	smoothenFaces(newPart)

	if CollectionService:HasTag(originalPart, "Decor") then
		CollectionService:AddTag(newPart, "Decor")
	end

	for _,texture in pairs(originalPart:GetChildren()) do
		if texture:IsA("Texture") then
			local clonedTexture = texture:Clone()
			clonedTexture.Parent = newPart
		end
	end

	newPart.CFrame = CFrame.new(centralPosition)
	newPart.Parent = model

	CollectionService:AddTag(newPart, "Destructable")
end

local function makeRemainingParts(player, model, parts, cubeSize, originalPart)
	local chanceParts = {}
	local chancePartsTotal = 0

	for _,part in pairs(parts) do
		if not part.combined then
			local newPart = Instance.new("Part")
			newPart.Anchored = originalPart.Anchored
			newPart.Transparency = originalPart.Transparency
			newPart.CanCollide = originalPart.CanCollide
			newPart.Color = originalPart.Color
			newPart.Material = originalPart.Material
			newPart.Size = cubeSize
			
			if originalPart:FindFirstChild("WeldConstraint") then
				local foundWeld = originalPart:FindFirstChild("WeldConstraint")
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = newPart
				weld.Part1 = foundWeld.Part1
				weld.Parent = newPart
			end

			smoothenFaces(newPart)

			for _,texture in pairs(originalPart:GetChildren()) do
				if texture:IsA("Texture") then
					local clonedTexture = texture:Clone()
					clonedTexture.Parent = newPart
				end
			end

			if CollectionService:HasTag(originalPart, "Decor") then
				CollectionService:AddTag(newPart, "Decor")
			end

			newPart.Parent = model
			newPart.CFrame = CFrame.new(part.Position)

			if chancePartsTotal < originalPart.Size.Magnitude / General.ChancePartDivider then
				local rng = Random.new()
				for key, chance in pairs(General.ItemChances) do
					if not chanceParts[key] then chanceParts[key] = {} end

					local luckMulti = 1
					if not General.ChanceLuckIgnore[key] then
						luckMulti = ((PlayerValues:GetValue(player, "Luck") or 1) - 1) * 5
					end

					if rng:NextInteger(1, chance) <= 1 + luckMulti then
						table.insert(chanceParts[key], newPart)
						if not General.ChanceTotalIgnore[key] then
							chancePartsTotal += 1
						end
						break
					end
				end
			end

			CollectionService:AddTag(newPart, "Destructable")
		end
	end

	return chanceParts
end

local function getAvailableSize(parts, randomGenerator, x, y, z, maxValues)
	local validParts = {}

	local xSizes = {}
	local ySizes = {}
	local zSizes = {}

	for i = 1,maxValues.X do
		table.insert(xSizes, {i, randomGenerator:NextInteger(1,100)})
	end

	for i = 1,maxValues.Y do
		table.insert(ySizes, {i, randomGenerator:NextInteger(1,100)})
	end

	for i = 1,maxValues.Z do
		table.insert(zSizes, {i, randomGenerator:NextInteger(1,100)})
	end

	table.sort(xSizes, function(a,b) return a[2] < b[2] end)
	table.sort(ySizes, function(a,b) return a[2] < b[2] end)
	table.sort(zSizes, function(a,b) return a[2] < b[2] end)

	for _,xS in pairs(xSizes) do
		local valid = true
		for _,yS in pairs(ySizes) do
			valid = true
			for _,zS in pairs(zSizes) do
				valid = true
				for xO = 0,xS[1]-1 do
					for yO = 0,yS[1]-1 do
						for zO = 0,zS[1]-1 do
							table.insert(validParts, parts[x+xO][y+yO][z+zO])

							if parts[x+xO][y+yO][z+zO].combined then
								valid = false
								break
							end

							if not valid then break end

						end
						if not valid then break end
					end
					if not valid then break end
				end

				if valid then
					return Vector3.new(xS[1], yS[1], zS[1]), validParts
				else
					validParts = {}
				end
			end
		end
	end

	return Vector3.new(1,1,1), {parts[x][y][z]}
end

local BreakService = {}
function BreakService.split(player, part, randomSeed, optionalModel)
	local seed = randomSeed or os.time() + math.random(-100000,100000)
	local randomGenerator = Random.new(seed)
	local randomObject = {
		seed = seed,
		generator = randomGenerator
	}
	
	if part.ClassName == "Part" then
		return BreakService.splitRectangle(player, part, randomObject, optionalModel), seed
	elseif part.ClassName == "WedgePart" then
		return BreakService.splitWedge(player, part, randomObject, optionalModel), seed
	end
	
	warn(part, part.ClassName)
end

function BreakService.splitRectangle(player, part, randomObject)
	local model = Instance.new("Model")
	
	local partSizeMagnitude = part.Size.Magnitude

	local scalingSizeFactor = partSizeMagnitude / SCALING_CONSTANT  -- smaller = bigger parts

	local scalerValues = Vector3.new(                               -- how to scale the part depending on directional scale of part to it's magnitude
		part.Size.X / partSizeMagnitude,
		part.Size.Y / partSizeMagnitude,
		part.Size.Z / partSizeMagnitude
	)

	local vecSize = Vector3.new(
		math.clamp(math.floor(scalingSizeFactor * scalerValues.X + 0.5), 1, 99e99),
		math.clamp(math.floor(scalingSizeFactor * scalerValues.Y + 0.5), 1, 99e99),
		math.clamp(math.floor(scalingSizeFactor * scalerValues.Z + 0.5), 1, 99e99)
	)

	local vecCombine = Vector3.new(
		math.floor(math.clamp(vecSize.X/2.5 * scalerValues.X, 1, ABSOLUTE_MAX_COMBINE) + 0.5),
		math.floor(math.clamp(vecSize.Y/2.5 * scalerValues.Y, 1, ABSOLUTE_MAX_COMBINE) + 0.5),
		math.floor(math.clamp(vecSize.Y/2.5 * scalerValues.Z, 1, ABSOLUTE_MAX_COMBINE) + 0.5)
	)

	local cubeSize = part.Size / vecSize

	local splitParts = {}
	local uncombinedParts = {}

	for x = 1,vecSize.X do
		splitParts[x] = {}
		for y = 1,vecSize.Y do
			splitParts[x][y] = {}
			for z = 1,vecSize.Z do
				splitParts[x][y][z] = {
					part = {Position = Vector3.new((x-1) * cubeSize.X, (y-1) * cubeSize.Y, (z-1) * cubeSize.Z)},
					combined = false
				}
			end
		end
	end

	for x = 1,vecSize.X do
		for y = 1,vecSize.Y do
			for z = 1,vecSize.Z do
				if not splitParts[x][y][z].combined then
					local combineSize, validParts = getAvailableSize(splitParts, randomObject.generator, x, y, z, Vector3.new(
						math.clamp(vecSize.X-x, 1, vecCombine.X),
						math.clamp(vecSize.Y-y, 1, vecCombine.Y),
						math.clamp(vecSize.Z-z, 1, vecCombine.Z)
						))

					if #validParts > 1 then
						local partsToSend = {}
						for _,part in pairs(validParts) do
							part.combined = true
							table.insert(partsToSend, part.part)
						end

						combineParts(model, partsToSend, cubeSize, part)
					else
						table.insert(uncombinedParts, splitParts[x][y][z].part)
					end
				end
			end
		end
	end

	local chanceParts = makeRemainingParts(player, model, uncombinedParts, cubeSize, part)

	model:PivotTo(part:GetPivot())
	model.Parent = part.Parent
	part:Destroy()

	MapService:ChanceParts(chanceParts)

	return model
end

function BreakService.splitWedge(player, part, randomObject, optionalModel)
	local model = optionalModel or Instance.new("Model")
	if not optionalModel then
		model.Parent = part.Parent
	end
	
	local newParts = {}
	
	local count = #model:GetChildren()

	local wedge1 = Instance.new("WedgePart")
	wedge1.Anchored = true
	wedge1.CanCollide = part.CanCollide
	wedge1.Transparency = part.Transparency
	wedge1.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	wedge1.Material = part.Material
	wedge1.Size = part.Size / Vector3.new(1,2,2)
	wedge1.CFrame = part.CFrame * CFrame.new(0, wedge1.Size.Y / 2, wedge1.Size.Z / 2)
	wedge1.Name = part.Name..count+1
	smoothenFaces(wedge1)
	wedge1.Parent = model

	local wedge2 = Instance.new("WedgePart")
	wedge2.Anchored = true
	wedge2.CanCollide = part.CanCollide
	wedge2.Transparency = part.Transparency
	wedge2.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	wedge2.Material = part.Material
	wedge2.Size = Vector3.new(part.Size.X, part.Size.Z / 2, part.Size.Y / 2)
	wedge2.CFrame = part.CFrame * CFrame.new(0, wedge2.Size.Z / -2, wedge2.Size.Y / -2) * CFrame.Angles(math.rad(90), 0, math.rad(180))
	wedge2.Name = part.Name..count+2
	smoothenFaces(wedge2)
	wedge2.Parent = model

	local part3 = Instance.new("Part")
	part3.Anchored = true
	part3.CanCollide = part.CanCollide
	part3.Transparency = part.Transparency
	part3.Color = part.Color--Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	part3.Material = part.Material
	part3.Size = part.Size / Vector3.new(1,2,2)
	part3.CFrame = part.CFrame * CFrame.new(0, part3.Size.Y / -2, part3.Size.Z / 2)
	part3.Name = part.Name..count+3
	smoothenFaces(part3)
	part3.Parent = model

	table.insert(newParts, wedge1)
	table.insert(newParts, wedge2)
	table.insert(newParts, part3)

	for _,object in pairs(newParts) do
		local multiplyVector
		if object.ClassName == "WedgePart" then
			multiplyVector = Vector3.new(0,1,1)
		else
			multiplyVector = Vector3.new(1,1,1)
		end

		if (object.Size * multiplyVector).Magnitude >= 25 then
			BreakService.split(object, randomObject.seed, model)
		end

		CollectionService:AddTag(object, "Destructable")
	end
	
	part:Destroy()

	return model
end
return BreakService
