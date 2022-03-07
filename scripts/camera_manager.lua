require "scripts.camera"

local CameraManager = {}

function CameraManager:new(camera, players)
	local instance = {}
	instance.camera = camera
	instance.players = players -- reference to the player list
	return setmetatable(instance, {__index = CameraManager})
end

function CameraManager:update(dt)
	
end

function CameraManager:draw()
end

return CameraManager