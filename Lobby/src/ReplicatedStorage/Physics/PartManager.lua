local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local IsServer = RunService:IsServer()
local LocalPlayer

local Signal
if IsServer then
	Signal = Instance.new("RemoteEvent")
	Signal.Name = "Signal"
	Signal.Parent = script
else
	Signal = script:WaitForChild("Signal")
	LocalPlayer = Players.LocalPlayer
end

local CurrentId = 0

local PartManager = {}
PartManager.Parts = {}

function PartManager.addPart(part, replicate)
	--assert(IsServer == true, "PartManager can only be run on the [Server] at the moment")
	
	CurrentId += 1
	
	local id
	if IsServer then
		id = tostring(CurrentId)
	else
		id = "c_"..CurrentId..LocalPlayer.UserId
	end
	
	local partObject = {
		object = part,
		id = id
	}
	
	function partObject:destroy()
		if IsServer then
			Signal:FireAllClients({
				object = nil,
				id = self.id
			})
		end
		
		if self.object then self.object:Destroy() end
		PartManager.Parts[self.id] = nil
	end
	
	PartManager.Parts[partObject.id] = partObject
	
	if replicate then
		Signal:FireAllClients({partObject})
	end
	
	return partObject
end

function PartManager.setId(part, id)
	local partObject = {
		object = part,
		id = id
	}

	function partObject:destroy()
		if IsServer then
			Signal:FireAllClients({
				object = nil,
				id = self.id
			})
		end
		
		if self.object then self.object:Destroy() end
		PartManager.Parts[self.id] = nil
	end
	
	PartManager.Parts[partObject.id] = partObject
	
	return partObject
end

function PartManager.makePart(psuedoPart, optionalId)
	local newPart = Instance.new(psuedoPart.ClassName)
	
	for property,value in pairs(psuedoPart) do
		if property == "Parent" then
			newPart.Parent = value.Parent
		elseif property ~= "ClassName" and property ~= "psuedo" then
			newPart[property] = value
		end
	end
	
	if optionalId then
		return PartManager.setId(newPart, optionalId)
	else
		return PartManager.addPart(newPart)
	end
end

function PartManager.getPartFromId(id)
	return PartManager.Parts[tostring(id)]
end

function PartManager.getPartFromObject(object)
	for _,partObject in pairs(PartManager.Parts) do
		if partObject.object == object then
			return partObject
		end
	end
end

function PartManager.syncClient(client)
	Signal:FireClient(client, PartManager.Parts)
end

function PartManager.syncClients()
	Signal:FireAllClients(PartManager.Parts)
end

function PartManager.clear(client)
	for _,partObject in pairs(PartManager.Parts) do
		if partObject.object then
			partObject.object:Destroy()
		end
	end

	PartManager.Parts = {}
	Signal:FireAllClients(client, nil)
end

function PartManager.packageSplitParts(original, parts, forceTable)
	local package = {}
	package.original = original
	package.parts = {}
	
	for _,partObject in pairs(parts) do
		local object = {
			siz = partObject.object.Size,
			cfm = partObject.object.CFrame,
			clr = partObject.object.Color,
			mtl = partObject.object.Material,
			id = partObject.id
		}
		
		if forceTable[partObject.object] then
			object.vel = forceTable[partObject.object]
		end

		table.insert(package.parts, object)
	end
	
	return package
end

function PartManager.count()
	local count = 0
	
	for i,v in pairs(PartManager.Parts) do
		count += 1
	end
	
	return count
end

---------------------------------------------

if not IsServer then
	Signal.OnClientEvent:Connect(function(parts)
		if parts then
			for _,partObject in pairs(parts) do
				if partObject.object == nil then
					if PartManager.Parts[partObject.id] then
						PartManager.Parts[partObject.id]:destroy()
					end
				else
					if CollectionService:HasTag(partObject.object, "ServerPart") then
						local clientPart = partObject.object:Clone()
						
						clientPart.Transparency = 0
						clientPart.CanQuery = true
						clientPart.CanCollide = true
						clientPart.Parent = partObject.object.Parent
						
						CollectionService:AddTag(clientPart, "Destructable")
						PartManager.setId(clientPart, partObject.id)
					else
						PartManager.setId(partObject.object, partObject.id)
					end
				end
			end
		else
			for _,partObject in pairs(PartManager.Parts) do
				if partObject.object then
					partObject.object:Destroy()
				end
			end

			PartManager.Parts = {}
		end
	end)
end

return PartManager
