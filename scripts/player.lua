require "scripts.sprites"
require "scripts.gun"
require "scripts.utility"
require "scripts.input"
require "scripts.gun_list"
require "scripts.collision"
require "scripts.constants"
local gun_distrib = require "probability_tables.gun"

function make_player(n,x,y, a)
	a = a or {}

	local p = {}
	p.type = "player"
	p.n = n
	p.x = x or 32
	p.y = y or 32
	p.w = 7
	p.h = 7
	p.dx = 0
	p.dy = 0
	p.walk_dir = {x=0, y=0}
	p.sx = 1
	p.sy = 1
	p.ox = 0
	p.oy = 0

	p.speed = 64
	p.friction = 20 --FIXME:dt ply fric
	p.bounce = 0.6
	p.is_walking = false
	p.is_enemy = false

	-- Life
	p.life = 5
	p.alive = true
	p.max_life = 5
	p.iframes = 2
	p.iframes_timer = 0
	p.iframes_flashing_time = 0.1
	p.set_iframes = set_iframes

	-- Reviving
	p.revive_timer = 0
	p.max_revive_timer = 3
	p.revive_radius = 64
	
	-- Hitbox
	p.hit_w = 4
	p.hit_h = 4

	-- Collisions
	p.is_solid = false

	-- Visual information
	p.rot = 0
	p.looking_up = false
	p.flip = 1
	p.outline_color = (a.outline_color or COLORS_PLAYERS[n]) or white
	p.show_tutorial = true
	p.show_player_number = true

	-- Animation 
	p.spr = a.spr_idle or spr_pigeon_idle
	p.spr_idle = a.spr_idle or spr_pigeon_idle
	p.spr_jump = a.spr_jump or spr_pigeon_jump
	p.spr_dead = a.spr_dead or spr_pigeon_dead
	p.anim_idle = anim_duck_walk --anim_pigeon_idle
	p.anim_sprs = p.anim_idle
	p.anim_frame = 0
	p.anim_frame_len = .05 --70 ms
	p.animate = animate_player
	p.timer = 0

	-- Animation > bounce + squash'&'stretch
	p.bounce_a = 0
	p.bounce_y = 0
	p.bounce_squash = 1
	p.reset_squash = reset_squash

	-- Particles
	p.ptc_timer = 0

	-- Guns
	p.gun = nil
	p.gun_dist = 14
	p.guns = {}
	for k,v in pairs(gun_distrib) do 
		table.insert(p.guns, copy(guns[k]))
	end
	p.gun = p.guns[1]
	p.gun_n = 1

	-- Methods
	p.set_gun = ply_set_gun
	p.update_gun = ply_update_gun
	p.set_gun = ply_get_gun
	p.damage = damage_player
	p.kill = kill_player
	p.revive = revive_player

	-- Pickups
	p.get_pickups = player_get_pickups
	p.pickup_cd = 0
	p.max_pickup_cd = 1

	-- Cursor
	p.spr_cu = sprs_cursor[n]
	p.cu_x = x
	p.cu_y = y+10
	p.dircux = 0
	p.dircuy = 0
	p.show_cu = true	
	--- Cursor methods
	p.update_cursor = player_update_cursor
	p.draw_cursor = player_draw_cursor
	
	-- Autoaiming
	p.autoaim_max_dist = 360
	p.last_autoaim_dist = math.huge
	--- Autoaiming methods
	p.get_nearest_enemy = get_nearest_enemy
	p.get_autoaim = get_autoaim

	p.init = function(self)
		collision:object_join_world(self)
	end

	p.move = function(self, dt)
		self.is_walking = false
		
		local dir_x, dir_y = input:get_movement_axis(self.n)
		self.walk_dir = {x=dir_x, y=dir_y}

		if not (dir_x == 0 and dir_y == 0) then
			self.is_walking = true
		end

		self.dx = self.dx + (dir_x * self.speed)
		self.dy = self.dy + (dir_y * self.speed)
		
		-- Idk why this friction works but thanks stackoverflow
		local fricratio = 1 / (1 + dt * self.friction);--FIXME:dt ply
		self.dx = self.dx * fricratio
		self.dy = self.dy * fricratio 

		local goal_x = self.x + self.dx*dt
		local goal_y = self.y + self.dy*dt
		local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
		
		-- Apply movement
		-- Check if the collision is a tile
		self.x = actual_x--self.x + self.dx * dt
		self.y = actual_y--self.y + self.dy * dt
	end

	p.aim = function(self, dt)
		--TODO: rework ply aiming
		local mmx, mmy = input:get_world_cursor_pos(self.n, self)

		self.cu_x = mmx or self.cu_x
		self.cu_y = mmy or self.cu_x

		self.rot = math.atan2(mmy - self.y, mmx - self.x)
		self.rot = self.rot % pi2
		self.shoot = false

		-- Firing
		-- god why is this code such a mess 
		if self.gun.cooldown_timer <= 0 then

			local button_active = false
			if self.gun.is_auto then
				button_active = input:button_down("fire", self.n)
			else
				button_active = input:button_pressed("fire", self.n)
			end

			if (not self.gun.charge and button_active) 
			or ((prevfire and not button_active) and self.gun.charge) then
				if self.gun.ammo > 0 then

					if self.gun.charge then
						local avancement = (self.gun.dt/self.gun.charge_time)^self.gun.charge_curve
						if self.gun.save_burst then
							load_save_gun_stats(self)
						end

						save_gun_stats(self)

						advancementtoactive(self,avancement)--tf is advancement
					end

					self.shoot = true
					self.gun:shoot()
					camera:kick(self.rot + pi, self.gun.screenkick)
					--kick_camera(self, dir, dist, offset_ang)
					self.gun.dt = 0
					
				end
			elseif input:button_down("fire", self.n) and self.gun.charge then
				self.gun.dt = math.min(self.gun.dt+dt,self.gun.charge_time)
			end
		end
	end

	p.switch_guns = function(self)
		if input:button_pressed("alt", self.n) then
			self.gun_n = mod_plus_1(self.gun_n + 1, #self.guns)
			self.gun = self.guns[self.gun_n]
			self.gun.cooldown_timer = math.min(self.gun.cooldown_timer + 0.25,self.gun.cooldown)

			for k = #_shot , 1 , -1 do
				v = _shot[k]
				if v.player == self then
					table.remove(_shot, k)
				end
			end
		end
	end

	p.on_leave_start_area = function(self)
		self.show_tutorial = false
		self.show_player_number = false
	end
	p.is_off_screen = function(self)
		local x = (self.x < camera.x - self.w) or (camera.x + self.w < self.x)
	end

	p.update = function(self, dt)
		self.timer = self.timer + dt
		self.ptc_timer = self.ptc_timer - dt

		if self.alive then 
			self:move(dt)
			--collision_response(self, map)

			-- Aiming
			self:update_cursor(dt)
			self:aim(dt)
			self.rot = self.rot % pi2
			self.looking_up = self.rot > pi

			-- Update gun
			self:switch_guns()
			self.gun:update(dt, self)

			-- Pickups
			self.pickup_cd = max(0, self.pickup_cd - dt)
			if self.pickup_cd <= 0 then
				self:get_pickups()
			end
			
			self:animate()
		else -- If the player is dead
			self.spr = self.spr_dead

			-- Reviving
			--- Get all near players
			local number_of_nearby_players = 0
			for _,p in pairs(players) do
				local near = dist_sq(self.x, self.y, p.x, p.y) <= sqr(self.revive_radius) 
				if near and p.n ~= self.n and p.alive then
					number_of_nearby_players = number_of_nearby_players + 1
				end
			end
			if number_of_nearby_players > 0 then
				self.revive_timer = self.revive_timer + dt*number_of_nearby_players
			else
				self.revive_timer = max(self.revive_timer - dt, 0)
			end
			
			if self.revive_timer > self.max_revive_timer then
				self:revive()
				--[[
				self.alive = true
				self.life = 1
				self:set_iframes()
				self.revive_timer = 0
				--]]
			end
		end

		-- Default bahviour that will always be executed
		-- Life, damage
		self.life = clamp(0, self.life, self.max_life)
		self.gun.ammo = clamp(0, self.gun.ammo, self.gun.max_ammo)

		self.iframes_timer = self.iframes_timer - dt
		self.invincible = self.iframes_timer > 0 

		if self.life <= 0 then
			self:kill()
		end
		
	end

	p.draw = function(self)
		draw_shadow(self)

		local ft = self.iframes_flashing_time
		-- Flashing
		local is_drawn = true
		if self.invincible then
			is_drawn = (self.iframes_timer % (2*ft)) <= ft
		end

		-- Draw player
		if is_drawn then
			if self.looking_up then  self.gun:draw(self)  end
			draw_centered(self.spr, self.x-self.ox, self.y-self.oy, 0, self.sx*self.flip, self.sy)
			if not self.looking_up then  self.gun:draw(self)  end
		end
		love.graphics.setColor(1,1,1) 
	end
	
	p.draw_hud = function(self)
		-- HUD
		local s = 8
		local oy = 38

		--- Health bar
		for i=1, self.max_life do
			local spr = (i <= self.life) and spr_heart or spr_heart_empty
			
			local w = (self.max_life*s)/2
			local x = self.x - w + (i-1)*s + s/2
			draw_centered(spr, floor(x), floor(self.y-oy))
		end

		--- Ammo bar
		local spr = spr_bar_small_empty
		local h = spr:getHeight()
		local x,y = floor(self.x - 10), floor(self.y - oy + 8)
		local sprw = spr:getWidth() - 4
		local w = floor((self.gun.ammo / self.gun.max_ammo) * sprw)

		love.graphics.draw(spr_ammo, x-11, y)
		love.graphics.draw(spr, x, y)
		local buffer_quad = love.graphics.newQuad(2, 0, w, h, spr:getDimensions())
		love.graphics.draw(spr_bar_small_ammo, buffer_quad, x+2, y)
		
		love.graphics.setFont(font_small)
		love.graphics.print(self.gun:get_ammo_display_value(), x+5, y-1)
		love.graphics.setFont(font_default)

		-- "P1", "P2"... icon
		local cx, cy = 12, 10
		local x = floor(clamp(camera.x + cx, self.x, camera.x + window_w - cy))
		local y = floor(clamp(camera.y + cy, self.y-oy-12, camera.y + window_h - cy))
		if self.show_player_number then
			draw_centered(sprs_icon_ply[self.n], x, y)
		end

		-- Tutorial (TEMPORARY)
		local x = self.x
		local y = self.y+oy+6
		if self.show_tutorial then
			draw_centered(spr_symb_walk, x-22, y-8)
			-- Arrows
			local ax = x + 12
			local o = 12
			local keybinds = input:get_user(self.n).keybinds
			draw_icon("keyboard", keybinds.down[1], ax, y)
			draw_icon("keyboard", keybinds.left[1], ax-o, y)
			draw_icon("keyboard", keybinds.right[1], ax+o, y)
			draw_icon("keyboard", keybinds.up[1], ax, y-o)
			
			draw_centered(spr_symb_shoot, x-22, y+16)
			draw_icon("keyboard", keybinds.fire[1], ax, y+16)

			draw_centered(spr_symb_switch_gun, x-22, y+32)
			draw_icon("keyboard", keybinds.alt[1], ax, y+32)
		end
	end

	p:init()
	return p
end


function player_update_cursor(self)
end
function player_draw_cursor(self)
	-- Cursor
	if self.show_cu then
		local spr = self.spr_cu or spr_cursor
		draw_centered(spr, self.cu_x, self.cu_y)
	end
end

function get_autoaim(self)
	local ne = self:get_nearest_enemy()
	local x, y
	if ne then
		x = ne.x
		y = ne.y 
		self.show_cu = true
	else 

		if dist_sq(0,0, math.abs(self.dx), math.abs(self.dy)) > sqr(4) then
			self.dircux, self.dircuy = self.dx, self.dy
			self.show_cu = true
			local dir = math.atan2(self.dircuy, self.dircux)
			local rad = 64
			x = self.x + self.dircux*0.6--math.cos(dir) * rad
			y = self.y + self.dircuy*0.6--math.sin(dir) * rad
		else 
			self.show_cu = false
			x = self.cu_x
			y = self.cu_y
		end
	end

	local dt = love.timer.getDelta()
	x = lerp(self.cu_x, x, 0.1)
	y = lerp(self.cu_y, y, 0.1)
	return x, y
end

function animate_player(self)
	-- Flip player if looking left
	local flip = (self.rot - pi/2) % pi2 <= pi
	self.flip = ternary(flip, -1, 1)
	self.gun.flip = self.flip
	
	--[[
	self.anim_sprs = self.anim_idle
	self.spr = self.anim_idle[1]

	if self.is_walking then
		self.anim_sprs = self.anim_walk
		-- Walk anim
		self.frame = floor((love.timer.getTime()/self.anim_frame_len) % #self.anim_sprs)
		
		--Walk backwards
		if sign(self.flip) ~= sign(self.walk_dir.x) then
			self.frame = -self.frame % #self.anim_sprs
		end
		
		self.spr = self.anim_sprs[self.frame + 1]
	else
		self.anim_sprs = self.anim_idle
	end	
	--]]

	-- Bounce :3
	local dt = love.timer.getDelta()
	--- Compute bounce_a
	local bounce_speed = 15
	local bounce_height = 8
	local squash_amount = 0.17

	self.bounce_a = self.bounce_a + bounce_speed * dt

	if self.is_walking then
		self.bounce_a = self.bounce_a % pi
	end

	if self.bounce_a < pi + 0.001 then
		--- Compute bounce height
		local sin_a = math.sin(self.bounce_a)
		self.bounce_y = math.abs(sin_a) * bounce_height
		self.oy = self.bounce_y 
		
		--- Bounce squash
		local speed_a = math.cos(self.bounce_a) --cos is the derivative, aka rate of change of sin
		self.bounce_squash = speed_a*squash_amount + 1
		self.sx = self.bounce_squash
		self.sy = 1/self.bounce_squash

		--- Jump sprite
		self.spr = self.spr_idle
		if self.is_walking then
			local below_threshold = (self.bounce_y <= 6)
			self.spr = ternary(below_threshold, self.spr_idle, self.spr_jump)
		end
	else
		self.sx = 1
		self.sy = 1
		self.oy = 0
		self.bounce_a = pi
	end

	-- Particles
	--[[
	if self.is_walking and self.ptc_timer < 0 then
		local rx, ry = random_neighbor(4), random_neighbor(4)
		local rr = 4 + love.math.random()*5
		particles:make_circ(self.x+rx, self.y+ry+16, rr, white, 0,0, nil, 0.99)
		self.ptc_timer = self.ptc_timer + 0.1
	end
	--]]  
end

function reset_squash(self)
	self.sx = 1
	self.sy = 1
	self.oy = 0
	self.bounce_a = pi
end

function set_iframes(frames)
	self.iframes_timer = frames
end

function damage_player(self, dmg)
	if self.alive and self.iframes_timer <= 0 then
		audio:play(sfx_hurt)
		camera:shake(5)
		
		self.life = self.life - dmg
		self:set_iframes(self.iframes)
	end
end

function kill_player(self)
	self.alive = false
	self.show_cu = false
end

function revive_player(self, life)
	life = life or self.max_life
	self.life = life
	self.alive = true
	
	self.show_cu = true
end

function ply_set_gun(self, gun)
	self.guns[self.gun_n] = gun
	self:update_gun()
end

function ply_update_gun(self)
	self.gun = self.guns[self.gun_n]
end

function ply_get_gun(self)
	return self.gun
end

function set_iframes(self, n)
	if n then
		self.iframes_timer = n
	else
		self.iframes_timer = self.iframes
	end
end

function player_get_pickups(self)
	for _,pick in ipairs(pickups.table) do
		if coll_rect_objects(self, pick) then
			-- On collision
			pick:is_picked(self)
			if pick.type == "gun" then
				self.pickup_cd = self.max_pickup_cd
			end 
		end
	end
end

function get_nearest_enemy(self)
	local nearest = nil
	local min_dist = math.huge
	for i,m in ipairs(mobs) do
		local d = dist_sq(self.x, self.y, m.x, m.y)

		local a = math.atan2(m.y-self.y, m.x-self.x)
		local r = raycast(self.x, self.y, math.cos(a), math.sin(a), math.sqrt(d), 3)

		if d <= sqr(self.autoaim_max_dist) and d < min_dist and r.hit then
			nearest = m
			min_dist = d 
		end
	end
	return nearest
end

function save_gun_stats(self)
	-- WHY IS THIS A METHOD OF PLAYER
	self.gun.save_burst 	 	= self.gun.burst
	self.gun.save_bullet_spd  	= self.gun.bullet_spd
	self.gun.save_laser_length 	= self.gun.laser_length
	self.gun.save_nbshot 	 	= self.gun.nbshot
	self.gun.save_spread 	 	= self.gun.spread
	self.gun.save_scattering	= self.gun.scattering
	self.gun.save_offset_spd  	= self.gun.offset_spd
	self.gun.save_life 		 	= self.gun.life			
	self.gun.save_burstdt	 	= self.gun.burstdt 
	self.gun.save_spdslow 	 	= self.gun.spdslow	
	self.gun.save_scale 		= self.gun.scale
	self.gun.save_damage 		= self.gun.damage
	self.gun.save_oscale		= self.gun.oscale
end

function load_save_gun_stats(self)
	self.gun.burst 	 	= self.gun.save_burst
	self.gun.bullet_spd  	= self.gun.save_bullet_spd
	self.gun.laser_length 	= self.gun.save_laser_length
	self.gun.nbshot 	 	= self.gun.save_nbshot
	self.gun.spread 	 	= self.gun.save_spread
	self.gun.scattering		= self.gun.save_scattering
	self.gun.offset_spd  	= self.gun.save_offset_spd
	self.gun.life 			= self.gun.save_life			
	self.gun.burstdt	 	= self.gun.save_burstdt 
	self.gun.spdslow 	 	= self.gun.save_spdslow	
	self.gun.scale 			= self.gun.save_scale
	self.gun.damage 		= self.gun.save_damage
	self.gun.oscale			= self.gun.save_oscale
end

function advancementtoactive(self,avancement)
	self.gun.burst 	 		= self.gun.burst 		+ floor( self.gun.charge_nbburst 		* avancement)
	self.gun.bullet_spd   = self.gun.bullet_spd 	+ self.gun.charge_bullet_spd 			* avancement
	self.gun.laser_length = self.gun.laser_length	+ self.gun.charge_laser_length 			* avancement
	self.gun.nbshot 		 	= self.gun.nbshot 		+ floor( self.gun.charge_nbshot 		* avancement)
	self.gun.spread 		 	= self.gun.spread 		+ self.gun.charge_spread 				* avancement	
	self.gun.scattering	  = self.gun.scattering	+ self.gun.charge_scattering			* avancement	 		 
	self.gun.offset_spd   = self.gun.offset_spd 	+ self.gun.charge_ospd 					* avancement
	self.gun.bullet_life  = self.gun.bullet_life  + self.gun.charge_life 					* avancement
	self.gun.burstdt	 		= self.gun.burstdt		+ self.gun.charge_burstdt				* avancement
	self.gun.spdslow 	 		= self.gun.spdslow 	 	+ self.gun.charge_spdslow 				* avancement
	self.gun.scale 				= self.gun.scale        + self.gun.charge_scale					* avancement
	self.gun.damage				= self.gun.damage		+ self.gun.charge_damage				* avancement
	self.gun.oscale		  = self.gun.oscale 			+ self.gun.charge_oscale 				* avancement
end