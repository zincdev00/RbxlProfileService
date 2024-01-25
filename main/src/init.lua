local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Class = require(ReplicatedStorage.common.packages.Class)

local ProfileService = Class:create({
	ProfileStore = require(script.ProfileStore),
	Profile = require(script.Profile),
})


function ProfileService:Init()
end

function ProfileService:Exit()
	for _, player in pairs(Players:GetPlayers()) do
		player:Kick("Server Shutdown")
	end
end


return ProfileService