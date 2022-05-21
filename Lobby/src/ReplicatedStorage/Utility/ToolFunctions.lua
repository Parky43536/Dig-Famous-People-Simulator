local ToolFunctions = {}

function ToolFunctions:Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

----------------------------------------------------

--[[local function ChooseRandom(dictionary, materialPicked)
	while true do
		local list = {}
		for key, value in pairs(dictionary) do
			list[#list+1] = {key = key, value = value}
		end

		local picked = list[math.random(#list)]
		if picked.value.Material and materialPicked then
			task.wait()
		else
			return picked
		end
	end
end]]

return ToolFunctions
