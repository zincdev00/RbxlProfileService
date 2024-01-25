local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")

local Class = require(ReplicatedStorage.common.packages.Class)
local DataService = require(ServerStorage.server.packages.DataService)

local ProfileStore = Class:create()


function ProfileStore:new(key, scope, exceptionHandler)
	return self:create({
		DataStore = DataStoreService:GetDataStore(key, scope),
		Profiles = {},
		ExceptionHandler = exceptionHandler or {},
	})
end

function ProfileStore:TryLockProfile(key, timeout)
	local success = false
	local result = nil
	local request = DataService:Update(self.DataStore, key, function(profile)
		profile = profile or {}
		if (not profile.SessionId) or (profile.SessionId == game.JobId) then
			profile.SessionId = game.JobId
			result = profile
		else
			result = "Session not yet closed."
		end
		return profile
	end)
	request.Future:await(timeout):resolve(function(val)
		success = true
	end, function(err)
		result = err
	end)
	return success, result
end

function ProfileStore:TryReleaseProfile(key, profile, timeout)
	profile.SessionId = nil
	self:SaveProfile(key, profile, timeout)
end

function ProfileStore:SaveProfile(key, profile, timeout)
	local request = DataService:Set(self.DataStore, key, profile)
	request.Future:await(timeout):resolve(nil, function(err)
		warn(err)
	end)
end

function ProfileStore:GetStoredProfile(key)
	return self.Profiles[key]
end

function ProfileStore:SetStoredProfile(key, profile)
	self.Profiles[key] = profile
	return profile
end


return ProfileStore