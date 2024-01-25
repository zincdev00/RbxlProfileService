local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Class = require(ReplicatedStorage.common.packages.Class)

local Profile = Class:create()


function Profile:new(data)
	local self = self:create(data)
	self:meta().ClosedEvent = Instance.new("BindableEvent")
	return self
end

function Profile:ApplyTemplate(template, object)
	local template = template
	local object = object or self
	for key, value in pairs(template) do
		if typeof(value) == "table" then
			object[key] = object[key] or {}
			self:ApplyTemplate(value, object[key])
		else
			object[key] = value
		end
	end
end

function Profile:FireClosed()
	self:meta().ClosedEvent:Fire(self)
end

function Profile:BindClosed(func)
	self:meta().ClosedEvent.Event:Connect(func)
end


return Profile