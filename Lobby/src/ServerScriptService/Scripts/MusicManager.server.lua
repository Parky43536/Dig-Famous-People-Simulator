local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local AudioService = require(Utility:WaitForChild("AudioService"))

local Music = {
    1845502313, --Camps Bay Cruiser
    1845542736, --Epic Fill (no Vox)
    1845507606, --Mali Bounce
    1842850693, --Skin Tight
    1845520384, --Tribal Moon
}

local function shallowCopy(list)
	local newList = {}
	for i,v in pairs(list) do
		newList[i] = v
	end

	return newList
end

local musicList = shallowCopy(Music)

while true do
    if next(musicList) == nil then
        musicList = shallowCopy(Music)
    end

    local key = math.random(1, #musicList)
    local picked = musicList[key]
    table.remove(musicList, key)

    local music = AudioService:Create(picked, workspace.Sound)
    music.Loaded:Wait()
    task.wait(music.TimeLength)
end