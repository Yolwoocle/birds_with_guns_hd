require "scripts.utility"
require "scripts.constants"

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

		min_x = 0,
		max_x = 2^16,
		min_y = 0,
		max_y = 2^16,

		shake = shake_camera,
		shake_x = 0,
		shake_y = 0,
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
		set_offset = camera_set_offset,
		set_scale = camera_set_scale,
		get_bounds = get_bounds,
		manage_camera_lock = manage_camera_lock,
		clamp_to_allowed_coordinates = clamp_to_allowed_coordinates,
		within_mob_loading_zone = within_mob_loading_zone,
	}
	return camera
end

function update_camera(self, dt)
	local smoothing = math.min(self.smoothing * dt, 1)
	
	-- Lerp to player
	self.fake_x = lerp(self.fake_x, self.target_x, smoothing)--FIXME:dt cam smoothing
	self.fake_y = lerp(self.fake_y, self.target_y, smoothing)--FIXME:dt cam smoothing--self.fake_x + (self.target_x - self.fake_x) * smoothing  

	-- Exit lock on if target is far away enough/certain positions
	self:manage_camera_lock()

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
	self.shake_rad = max(0, self.shake_rad - dt*10) --* self.kick_fric--inv_dt(self.shake_fric, dt) 

	local pos_x = self.fake_x + self.offset_x 
	local pos_y = self.fake_y + self.offset_y
	self.x, self.y = self:clamp_to_allowed_coordinates(pos_x, pos_y)

	-- Apply screen disturbance (kick + shake)
	self.x = self.x + self.kick_x + self.shake_x
	self.y = self.y + self.kick_y + self.shake_y
	self.x = floor(self.x)
	self.y = floor(self.y)
end

function draw_camera(self, dt)
	-- Put this in love.draw, while update_camera should be in update. 
	love.graphics.translate(-self.x*self.sx, -self.y*self.sy)
	love.graphics.scale(self.sx, self.sy)
end

function camera_set_pos(self, x, y)
	x, y = self:clamp_to_allowed_coordinates(x, y)
	self.x = x
	self.y = y
end

function camera_set_target(self, x, y)
	x, y = self:clamp_to_allowed_coordinates(x, y)
	if not self.lock_x then
		self.target_x = x
	end
	if not self.lock_y then
		self.target_y = y
	end
end

function camera_set_offset(self, x, y)
	self.offset_x = x
	self.offset_y = y
end

function camera_set_scale(self, sx, sy)
	self.sx = sx
	self.sy = sy
end

function kick_camera(self, dir, dist, offset_ang)
	dist = dist / number_of_players

	local oa = offset_ang or 1 
	self.kick_dir = dir + love.math.random()*oa - oa/2
	self.kick_dist = dist

	self.kick_x = self.kick_x + math.cos(self.kick_dir) * self.kick_dist
	self.kick_y = self.kick_y + math.sin(self.kick_dir) * self.kick_dist
end

function shake_camera(self, r)
	r = r / number_of_players
	self.shake_rad = r 
end

function get_bounds(self)
	local x1 = (self.x / BLOCK_WIDTH) 
	local x2 = ((self.x + window_w) / BLOCK_WIDTH ) 
	local y1 = (self.y / BLOCK_WIDTH) 
	local y2 = ((self.y + window_h + 16) / BLOCK_WIDTH ) 

	return floor(x1), floor(x2), floor(y1), floor(y2)
end

function clamp_to_allowed_coordinates(self, x, y)
	local new_x = clamp(self.min_x, x, self.max_x)
	local new_y = clamp(self.min_y, y, self.max_y)
	return new_x, new_y
end

function manage_camera_lock(self)
	for i,p in pairs(players) do
		-- If players exit the beginning room, exit x-lock
		if p.x > ROOM_PIXEL_W then
			self.lock_x = false
			for k,p in pairs(players) do
				p:on_leave_start_area()
			end
			audio:on_leave_start_area()
		end

		-- Move if on branch
		if p.y < MAIN_PATH_PIXEL_Y then 
			self.target_y = MAIN_PATH_PIXEL_Y - ROOM_PIXEL_H
		end
		if p.y > MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H then
			self.target_y = MAIN_PATH_PIXEL_Y + ROOM_PIXEL_H
		end

		-- Back to main branch
		local y1, y2 = MAIN_PATH_PIXEL_Y, MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H
		if y1 < p.y and p.y < y2 then 
			self.target_y = MAIN_PATH_PIXEL_Y
		end
	end
end

function within_mob_loading_zone(self, mob)
	local border_x = 16*8
	local border_y = 16*2
	local vx = (self.x-border_x < mob.x and mob.x < self.x+window_w+border_x)
	local vy = (self.y-border_y < mob.y and mob.y < self.y+window_h+border_y)
	return vx and vy
end