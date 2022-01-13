require "scripts/utility"

function init_camera()
	local camera = {
		x = 0,
		y = 0,
		target_x = 0,
		target_y = 0,
		sx = 1,
		sy = 1,

		shake = shake_camera,
		shk_dir = 0,
		shk_dist = 0,
		shk_fric = 50,
		
		lock_x = false,
		lock_y = false,

		smoothing = 20,

		update = update_camera,
		draw = draw_camera,
		set_pos = camera_set_pos,
		set_target = camera_set_target,
		set_scale = camera_set_scale,
	}
	return camera
end

function update_camera(self, dt)
	if not self.lock_x then 
		self.x = self.x + (self.target_x - self.x) * math.min(self.smoothing * dt, 1)  
	end
	if not self.lock_y then 
		self.y = self.y + (self.target_y - self.y) * math.min(self.smoothing * dt, 1)
	end
	self.shk_dist = self.shk_dist * min(1, self.shk_fric * dt)
	
	self.real_x = -(self.x + math.cos(self.shk_dir) * self.shk_dist)
	self.real_y = -(self.y + math.sin(self.shk_dir) * self.shk_dist)
end

function draw_camera(self, dt)
	-- Put this in love.draw, while update_camera should be in update. 
	love.graphics.translate(self.real_x, self.real_y)
	love.graphics.scale(self.sx, self.sy)
end

function camera_set_pos(self, x, y)
	self.x = x
	self.y = y
end

function camera_set_target(self, x, y)
	self.target_x = x
	self.target_y = y
end

function camera_set_scale(self, sx, sy)
	self.sx = sx
	self.sy = sy
end

function shake_camera(self, dir, dist)
	self.shk_dir = dir
	self.shk_dist = dist
end
