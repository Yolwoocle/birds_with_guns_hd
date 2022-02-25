require "scripts/utility"

function init_camera()
	local camera = {
		fake_x = 0,
		fake_y = 0,
		target_x = 0,
		target_y = 0,
		offset_x = 0,
		offset_y = 0,
		x = 0,
		y = 0,
		sx = 1,
		sy = 1,

		shake = shake_camera,
		shake_rad = 0,
		shake_fric = 50,

		kick = kick_camera,
		kick_fric = 0.9,
		kick_x = 0,
		kick_y = 0,
		
		lock_x = false,
		lock_y = false,

		smoothing = 10,
		aim_offset = 0.8,

		update = update_camera,
		draw = draw_camera,
		set_pos = camera_set_pos,
		set_target = camera_set_target,
		set_scale = camera_set_scale,
		get_bounds = get_bounds,
	}
	return camera
end

function update_camera(self, dt)
	--Clamp on border
	self.target_x = self.target_x
	self.target_y = self.target_y
	
	local smoothing = math.min(self.smoothing * dt, 1)
	-- Move to player
	if not self.lock_x then 
		self.fake_x = self.fake_x + (self.target_x - self.fake_x) * smoothing  
	end
	if not self.lock_y then 
		self.fake_y = self.fake_y + (self.target_y - self.fake_y) * smoothing
	end

	-- Aiming offset
	if self.lock_x then
		self.offset_x = 0
	end
	if self.lock_y then
		self.offset_y = 0
	end

	-- Apply screenkick (aka directional screenshake)
	self.kick_x = self.kick_x * self.kick_fric--inv_dt(self.kick_fric, dt)
	self.kick_y = self.kick_y * self.kick_fric--inv_dt(self.kick_fric, dt)
	
	-- Apply shake
	local rnd_ang = love.math.random() * pi2
	local rnd_rad = love.math.random() * self.shake_rad
	self.shake_x = math.cos(rnd_ang) * rnd_rad
	self.shake_y = math.sin(rnd_ang) * rnd_rad
	self.shake_rad = self.shake_rad * self.kick_fric--inv_dt(self.shake_fric, dt)
	--self.shake_rad = round_if_near_zero(self.shake_rad) 

	self.x = self.fake_x + self.offset_x + self.kick_x + self.shake_x
	self.y = self.fake_y + self.offset_y + self.kick_y + self.shake_y
	self.x = floor(self.x)
	self.y = floor(self.y)
end

function draw_camera(self, dt)
	-- Put this in love.draw, while update_camera should be in update. 
	love.graphics.translate(-self.x*self.sx, -self.y*self.sy)
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

function kick_camera(self, dir, dist, offset_ang)
	local oa = offset_ang or 1 
	self.kick_dir = dir + love.math.random()*oa - oa/2
	self.kick_dist = dist

	self.kick_x = self.kick_x + math.cos(self.kick_dir) * self.kick_dist
	self.kick_y = self.kick_y + math.sin(self.kick_dir) * self.kick_dist
end

function shake_camera(self, r)
	self.shake_rad = r
end

function get_bounds(self)
	local x1 = (self.x / block_width) 
	local x2 = ((self.x + window_w) / block_width ) 
	local y1 = (self.y / block_width) 
	local y2 = ((self.y + window_h + 16) / block_width ) 

	return floor(x1), floor(x2), floor(y1), floor(y2)
end