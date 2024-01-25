local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Class = require(ReplicatedStorage.common.packages.Class)
local ProfileService = require(ServerStorage.server.packages.ProfileService)

local Test = Class:create()


local PROFILE_TEMPLATE = {
	Currency1 = 0,
	Currency2 = 0,
	Cards = {},
	Characters = {},
}


function Test:Init()
	print(game.JobId)
	print(game.PrivateServerId)
	self.ProfileStore = ProfileService.ProfileStore:new("TestData", "Inventory")
	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			self:OnPlayerAdded(player)
		end)
	end
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoving(player)
	end)
end

function Test:Exit()
end


function Test:GetProfileKey(player)
	return "Player_" .. player.UserId
end

function Test:OnPlayerAdded(player)
	local key = self:GetProfileKey(player)
	local success, result = self.ProfileStore:TryLockProfile(key, 2)
	if not success then
		warn(result)
		player:Kick("Error when loading data. Please wait a moment and retry or contact support.")
	else
		local profile = ProfileService.Profile:new(result)
		profile.UserId = player.UserId
		profile:ApplyTemplate(PROFILE_TEMPLATE)
		profile:BindClosed(function(profile)
			self.ProfileStore:TryReleaseProfile(key, profile, 2)
			self.ProfileStore:SetStoredProfile(key, nil)
			player:Kick()
		end)
		if player:IsDescendantOf(Players) then
			self.ProfileStore:SetStoredProfile(key, profile)
		else
			profile:FireClosed()
		end
	end
	
	print(self.ProfileStore:GetStoredProfile(self:GetProfileKey(player)))
end

function Test:OnPlayerRemoving(player)
	local key = self:GetProfileKey(player)
	self.ProfileStore:GetStoredProfile(key):FireClosed()
end


return Test