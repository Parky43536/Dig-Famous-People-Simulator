local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Physics = ReplicatedStorage:WaitForChild("Physics")
local BreakService = require(Physics:WaitForChild("BreakService"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local CollectionSelect = require(Utility:WaitForChild("CollectionSelect"))

local IsServer = RunService:IsServer()

local Signal
if IsServer then
	Signal = Instance.new("RemoteEvent")
	Signal.Name = "Signal"
	Signal.Parent = script
else
	Signal = script:WaitForChild("Signal")
end

local function getNearbyParts(position, radius, filteredInstances)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = filteredInstances
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.CollisionGroup = "Default"

	local depth = radius / 2
	--local partsInBounds = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(radius, depth, radius), overlapParams)
	local partsInBounds = workspace:GetPartBoundsInRadius(position, radius/2, overlapParams)
	return partsInBounds
end

local function setPartVelocity(part, origin, force, client)
	local initialVelocity = ((part.Position - origin).Unit + Vector3.new(0, 0.45, 0))
		* (force - math.clamp((part.Position - origin).Magnitude/1.05, force/2, force))
		* force

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = false
	
	if part:FindFirstChild("WeldConstraint") then
		part:FindFirstChild("WeldConstraint"):Destroy()
	end
	
	part:SetNetworkOwner(nil)
	task.wait()
	part:ApplyImpulse(initialVelocity * part:GetMass())
	part:ApplyAngularImpulse(Vector3.new(100,0,0))

	game.Debris:AddItem(part, 20/force)
end

local ExplosionService = {}

function ExplosionService.create(player, position, radius, force, client)
	if not IsServer then
		Signal:FireServer(position, radius, force)
		return
	end

	force /= 1.25
	local t = tick()

	local filteredInstances = CollectionSelect:SelectAll({"Destructable", "Breakable"})

	local nearbyParts = getNearbyParts(position, radius, filteredInstances)
	for _,part in pairs(nearbyParts) do
		local hitPlayer = game.Players:GetPlayerFromCharacter(part.Parent) or game.Players:GetPlayerFromCharacter(part.Parent.Parent)
		
		if not CollectionService:HasTag(part, "Processing") then
			if CollectionService:HasTag(part, "Breakable") then
				CollectionService:AddTag(part, "Processing")

				task.spawn(function()
					local splitModel, splitSeed = BreakService.split(player, part)
					local filteredDescendants = splitModel:GetChildren()
				
					local inRange = getNearbyParts(position, radius, filteredDescendants)
					for _,splitPart in pairs(inRange) do
						task.defer(setPartVelocity, splitPart, position, force)
					end
				end)
			elseif not hitPlayer then
				task.defer(setPartVelocity, part, position, force)
			end
		end
	end
end

--------------------------

if IsServer then
	-- Signal.OnServerEvent:Connect(function(client, testParts)
	-- 	for _,part in pairs(testParts) do
	-- 		part.Anchored = false
	-- 		part:SetNetworkOwner(client)
	-- 	end
	-- end)
	Signal.OnServerEvent:Connect(function(client, position, radius, force)
		ExplosionService.create(position, radius, force, client)
	end)
end

return ExplosionService