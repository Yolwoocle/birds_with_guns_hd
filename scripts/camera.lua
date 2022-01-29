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
		kick_fric = 60,
		kick_x = 0,
		kick_y = 0,
		
		lock_x = false,
		lock_y = false,

		smoothing = 10,
		aim_offset = 0.2,

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

	-- Offset
	--local mx, my = get_mouse_pos(self)

	--mx, my = love.mouse.getPosition()
	--mx, my = mx/screen_sx + camera.x, my/screen_sy + camera.y

	if not self.lock_x then
		self.offset_x = (mx - window_w/2) * self.aim_offset
	end
	if not self.lock_y then
		self.offset_y = (my - window_h/2) * self.aim_offset
	end
	self.fake_x = self.fake_x + self.offset_x
	self.fake_y = self.fake_y + self.offset_y

	self.kick_x = self.kick_x * inv_dt(self.kick_fric, dt)
	self.kick_y = self.kick_y * inv_dt(self.kick_fric, dt)

	-- Apply shake
	local rnd_ang = love.math.random() * pi2
	local rnd_rad = love.math.random() * self.shake_rad
	self.shake_x = math.cos(rnd_ang) * rnd_rad
	self.shake_y = math.sin(rnd_ang) * rnd_rad
	self.shake_rad = self.shake_rad * inv_dt(self.shake_fric, dt)
	self.shake_rad = round_if_near_zero(self.shake_rad) 

	self.x = self.fake_x + self.kick_x + self.shake_x 
	self.y = self.fake_y + self.kick_y + self.shake_y 
	self.x = floor(self.x)
	self.y = floor(self.y)
	----------------------------------------------------------------
	self.x = player_list[1].x-16*15
	self.y = player_list[1].y-16*8.5
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