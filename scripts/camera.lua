require "scripts/utility"

function init_camera()
	local camera = {
		fake_x = 0,
		fake_y = 0,
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
		shk_x = 0,
		shk_y = 0,
		
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
	local smoothing = math.min(self.smoothing * dt, 1)
	if not self.lock_x then 
		self.fake_x = self.fake_x + (self.target_x - self.fake_x) * smoothing  
	end
	if not self.lock_y then 
		self.fake_y = self.fake_y + (self.target_y - self.fake_y) * smoothing
	end

	self.shk_x = self.shk_x * min(1, self.shk_fric * dt)
	self.shk_y = self.shk_y * min(1, self.shk_fric * dt)
	
	-- Apply shake
	self.x = self.fake_x + self.shk_x
	self.y = self.fake_y + self.shk_y
end

function draw_camera(self, dt)
	-- Put this in love.draw, while update_camera should be in update. 
	love.graphics.translate(-self.x, -self.y)
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

	self.shk_x = self.shk_x + math.cos(self.shk_dir) * self.shk_dist
	self.shk_y = self.shk_y + math.sin(self.shk_dir) * self.shk_dist
end
