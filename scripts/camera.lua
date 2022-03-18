require "scripts.utility"
require "scripts.constants"

function make_camera()
	local cam = {}
	cam.fake_x = 0
	cam.fake_y = 0
	cam.target_x = 0
	cam.target_y = 0
	cam.offset_x = 0
	cam.offset_y = 0
	cam.x = 0
	cam.y = 0
	cam.sx = 1
	cam.sy = 1

	cam.min_x = 0
	cam.max_x = 2^16
	cam.min_y = 0
	cam.max_y = 2^16

	cam.shake = shake_camera
	cam.shake_x = 0
	cam.shake_y = 0
	cam.shake_rad = 0
	cam.shake_fric = 50

	cam.kick = kick_camera
	cam.kick_fric = 0.9
	cam.kick_x = 0
	cam.kick_y = 0
	
	cam.lock_x = false
	cam.lock_y = false

	cam.smoothing = 10
	cam.aim_offset = 0.8

	cam.init = init_camera
	cam.update = update_camera
	cam.draw = draw_camera
	cam.set_pos = camera_set_pos
	cam.set_target = camera_set_target
	cam.set_offset = camera_set_offset
	cam.set_scale = camera_set_scale
	cam.get_bounds = get_bounds
	cam.manage_camera_lock = manage_camera_lock
	cam.clamp_to_allowed_coordinates = clamp_to_allowed_coordinates
	cam.within_mob_loading_zone = within_mob_loading_zone

	cam:init()

	return cam
end

function init_camera(self)
	local y = MAIN_PATH_PIXEL_Y - (window_h-ROOM_PIXEL_H)/2
	self:set_target(0, y)
	self.lock_x = true
	self.lock_y = true
	self.fake_y = y
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
		--[[
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
		--]]
	end
end

function within_mob_loading_zone(self, mob)
	local border_x = 16*8
	local border_y = 16*2
	local vx = (self.x-border_x < mob.x and mob.x < self.x+window_w+border_x)
	local vy = (self.y-border_y < mob.y and mob.y < self.y+window_h+border_y)
	return vx and vy
end