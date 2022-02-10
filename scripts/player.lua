require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"
require "scripts/gun_list"
require "scripts/collision"
require "scripts/settings"

function init_player(n,x,y, spr, controle,nbcontroller)
	local player = {
		n = n,
		x = x or 32,
		y = y or 32,
		w = 4,
		h = 4,
		dx = 0,
		dy = 0,
		walk_dir = {x=0, y=0},

		speed = 64,
		friction = 20, --FIXME player glides more when FPS low
		bounce = 0.6,
		is_walking = false,
		is_enemy = false,

		life = 5,
		alive = true, 
		max_life = 5,
		iframes = 2,
		iframes_timer = 0,
		iframes_flashing_time = 0.1,
		set_iframes = set_iframes,

		hit_w = 12,
		hit_h = 12,
		revive_timer = 0,
		max_revive_timer = 3,
		revive_radius = 64,

		spr = spr,
		spr_dead = spr_pigeon_dead,
		rot = 0,
		looking_up = false,
		flip = -1,

		anim_sprs = nil,
		anim_walk = anim_duck_walk,
		anim_idle = anim_duck_walk,--anim_pigeon_idle,
		anim_frame = 0,
		anim_frame_len = .05, --70 ms
		animate = animate_player,

		gun = nil,
		gun_dist = 14,
		guns = {
			copy(guns.paper_plane_gun), 
			copy(guns.fire_extinguisher), 
			copy(guns.shotgun), 
			copy(guns.assault_rifle), 
			copy(guns.firework_launcher), 
			copy(guns.laser)
		},
		gun_n = 1,
		set_gun = ply_set_gun,
		update_gun = ply_update_gun,
		set_gun = ply_get_gun,

		damage = damage_player,
		get_pickups = player_get_pickups,
		pickup_cd = 0,
		max_pickup_cd = 1,

		get_nearest_enemy = get_nearest_enemy,
		autoaim_max_dist = 360,
		last_autoaim_dist = math.huge,
		cu_x = x,
		cu_y = y+10,
		dircux = 0,
		dircuy = 0,
		draw_hud = draw_player_hud,

		update = update_player,
		draw = draw_player,

		--TODO add keybinds
		input_device = {keybinds,controle,nbcontroller}, --"keyboard+mouse" "keyboard" "joystick"
		show_cu = true,

		debugcanvas = love.graphics.newCanvas(),
	}
	player.anim_sprs = player.anim_idle

	player.gun = player.guns[1]

	return player
end

function update_player(self, dt)
	if self.alive then 
		-- Movement
		player_movement(self,dt)
		-- Collisions
		--self.dx = round_if_near_zero(self.dx)
		--self.dy = round_if_near_zero(self.dy)
		collide_object(self,.01)
		--collision_response(self, map)
		-- Apply movement 
		self.x = self.x + self.dx * dt
		self.y = self.y + self.dy * dt

		-- Aiming
		aim_player(self, dt)
		self.rot = self.rot % pi2
		self.looking_up = self.rot > pi

		-- Update gun
		if button_pressed("alt", self.n,self.input_device) then
			self.gun_n = mod_plus_1(self.gun_n + 1, #self.guns)
			self.gun = self.guns[self.gun_n]
			--self.gun.cooldown_timer = math.min(self.gun.cooldown_timer + 0.05,self.gun.cooldown)

			for k = #_shot , 1 , -1 do
				v = _shot[k]
				if v.player == self then
					table.remove(_shot , k)
				end
			end

		end
		self.gun:update(dt, self)

		-- Pickups
		self.pickup_cd = max(0, self.pickup_cd - dt)
		if self.pickup_cd <= 0 then
			self:get_pickups()
		end
		
		self:animate()
	else -- if the player is dead
		self.spr = self.spr_dead

		-- Reviving
		--- Get all near players
		local n = 0
		for _,p in pairs(player_list) do
			local near = dist_sq(self.x, self.y, p.x, p.y) <= sqr(self.revive_radius) 
			if near and p.n ~= self.n and p.alive then
				n = n + 1
			end
		end
		print(n)
		if n > 0 then
			self.revive_timer = self.revive_timer + dt*n
		else
			self.revive_timer = max(self.revive_timer - dt, 0)
		end
		
		if self.revive_timer > self.max_revive_timer then
			self.alive = true
			self.life = 1
			self:set_iframes()
			self.revive_timer = 0
		end
	end

	-- Default bahviour that will always be executed
	-- Life, damage
	self.life = clamp(0, self.life, self.max_life)
	self.gun.ammo = clamp(0, self.gun.ammo, self.gun.max_ammo)

	self.iframes_timer = self.iframes_timer - dt
	self.invincible = self.iframes_timer > 0 

	hud.elements.life_bar.val = self.life
	hud.elements.life_bar.max_val = self.max_life
	hud.elements.ammo_bar.val = self.gun.ammo
	hud.elements.ammo_bar.max_val = self.gun.max_ammo
	if self.life <= 0 then
		self.alive = false
	end
	
	hud.elements.gun_1.spr = self.guns[1].spr
	hud.elements.gun_2.spr = self.guns[2].spr
	hud.elements.gun_list.sprs = self.guns
	local x = hud.elements.gun_1.x + hud.elements.gun_1.spr:getWidth() + 6
	hud.elements.gun_2.x = x
end

function draw_player(self)
	local ft = self.iframes_flashing_time
	-- Flashing
	local is_drawn = true
	if self.invincible then
		is_drawn = (self.iframes_timer % (2*ft)) <= ft
	end

	-- Draw player
	if is_drawn then
		if self.looking_up then  self.gun:draw(self)  end
		draw_centered(self.spr, self.x, self.y, 0, pixel_scale*self.gun.flip, pixel_scale)
		if not self.looking_up then  self.gun:draw(self)  end
	end
	love.graphics.setColor(1,1,1)

	if self.show_cu then 
		draw_centered(spr_cursor, self.cu_x, self.cu_y)
	end

	self:draw_hud()
end

function draw_player_hud(self)
	-- HUD
	local s = 8
	--- Health bar
	for i=1, self.max_life do
		local spr = (i <= self.life) and spr_heart or spr_heart_empty
		
		local w = (self.max_life*s)/2
		local x = self.x - w + (i-1)*s + s/2
		draw_centered(spr, floor(x), floor(self.y-32))
	end

	--- Ammo bar
	local spr = spr_bar_small_empty
	local h = spr:getHeight()
	local x,y = floor(self.x - 10), floor(self.y - 24)
	local sprw = spr:getWidth() - 4
	local w = floor((self.gun.ammo / self.gun.max_ammo) * sprw)

	love.graphics.draw(spr_ammo, x-11, y)
	love.graphics.draw(spr, x, y)
	local buffer_quad = love.graphics.newQuad(2, 0, w, h, spr:getDimensions())
	love.graphics.draw(spr_bar_small_ammo, buffer_quad, x+2, y)
	
	love.graphics.setFont(font_small)
	love.graphics.print(self.gun.ammo, x+5, y-1)
	love.graphics.setFont(font_default)
end

function player_movement(self, dt)
	local dir_vector = {x = 0, y = 0}

	local j
	if self.input_device[2] == "joystick" then
		j = joysticks[self.input_device[3]]
		if j then
		joystick = {}
		joystick.x = j:getAxis(1)
		joystick.y = j:getAxis(2)
		else
			joystick = nil
		end
	else
		joystick = nil
	end
	local inp = self.input_device

	self.walk_dir = {x=0, y=0}
	self.is_walking = false
	if button_down("left", self.n, inp) or (joystick and joystick.x<-joystick_deadzone) then
		if (joystick and joystick.x < -joystick_deadzone) then 
			dir_vector.x = dir_vector.x + joystick.x
		else
		dir_vector.x = dir_vector.x - 1
		end
		self.is_walking = true
		self.walk_dir.x = self.walk_dir.x - 1
	end
	if button_down("right", self.n,inp) or (joystick and joystick.x>joystick_deadzone) then
		if (joystick and joystick.x > joystick_deadzone) then 
			dir_vector.x = dir_vector.x + joystick.x
		else
		dir_vector.x = dir_vector.x + 1
		end
		self.is_walking = true
		self.walk_dir.x = self.walk_dir.x + 1
	end
	if button_down("up", self.n,inp) or (joystick and joystick.y<-joystick_deadzone) then
		if (joystick and joystick.y<-joystick_deadzone) then 
			dir_vector.y = dir_vector.y + joystick.y
		else
		dir_vector.y = dir_vector.y - 1
		end
		self.is_walking = true
	end
	if button_down("down", self.n,inp) or (joystick and joystick.y>joystick_deadzone) then
		if (joystick and joystick.y>joystick_deadzone) then 
			dir_vector.y = dir_vector.y + joystick.y
		else
		dir_vector.y = dir_vector.y + 1
		end
		self.is_walking = true
	end

	self.walk_dir = dir_vector
	if dir_vector.x == 0 and dir_vector.y == 0 then
		self.is_walking = false
	end
	-- We normalise the direction vector to avoid faster speed in diagonals
	local norm = math.sqrt(dir_vector.x * dir_vector.x + dir_vector.y * dir_vector.y) + 0.0001 -- utiliser la fonction dist()

	dir_vector.x = dir_vector.x / norm
	dir_vector.y = dir_vector.y / norm

	self.dx = self.dx + (dir_vector.x * self.speed)
	self.dy = self.dy + (dir_vector.y * self.speed)
	
	-- Idk why this friction works but thanks stackoverflow
	local fricratio = 1 / (1 + dt * self.friction);
	self.dx = self.dx * fricratio
	self.dy = self.dy * fricratio 
end

function aim_player(self, dt)
	--print(self.input_device[2])
	--love.event.quit()
	--if self.input_device[2] == "keyboard" then --input_device
	--else
	--	mmx, mmy = get_mouse_pos(self.input_device, camera , self)
	--end

		mmx, mmy = get_world_cursor_pos(self, self.input_device,dt, camera)

	self.cu_x = mmx or self.cu_x
	self.cu_y = mmy or self.cu_x

	self.rot = math.atan2(mmy - self.y, mmx - self.x)
	self.shoot = false
	if self.gun.cooldown_timer <= 0 then
		if (not(self.gun.charge) and button_down("fire", self.n,self.input_device)) 
		or (prevfire and not(button_down("fire", self.n,self.input_device)) 
		and self.gun.charge) then
			if self.gun.ammo > 0 then

				if self.gun.charge then
					local avancement = (self.gun.dt/self.gun.charge_time)^self.gun.charge_curve
				if self.gun.save_rafale then
					load_save_gun_stats(self)
				end

				save_gun_stats(self)

				advancementtoactive(self,avancement)
				end

				self.shoot = true
				self.gun:shoot()
				camera:kick(self.rot + pi, self.gun.screenkick)
				--kick_camera(self, dir, dist, offset_ang)
				self.gun.dt = 0
				
			end
		elseif button_down("fire", self.n,self.input_device) and self.gun.charge then
			self.gun.dt = math.min(self.gun.dt+dt,self.gun.charge_time)
		end
	end
end

function animate_player(self)
	-- Flip player if looking left (why is this in player.gun but whatever)
	self.flip = self.gun.flip
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
end

function damage_player(self, dmg)
	if self.iframes_timer <= 0 then
		camera:shake(5)
		self.life = self.life - dmg
		self.iframes_timer = self.iframes
	end
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
	-- TODO: move it to gun ?????????? 
	self.gun.save_rafale 	 	= self.gun.rafale
	self.gun.save_bullet_spd  	= self.gun.bullet_spd
	self.gun.save_laser_length 	= self.gun.laser_length
	self.gun.save_nbshot 	 	= self.gun.nbshot
	self.gun.save_spread 	 	= self.gun.spread
	self.gun.save_scattering	= self.gun.scattering
	self.gun.save_offset_spd  	= self.gun.offset_spd
	self.gun.save_life 		 	= self.gun.life			
	self.gun.save_rafaledt	 	= self.gun.rafaledt 
	self.gun.save_spdslow 	 	= self.gun.spdslow	
	self.gun.save_scale 		= self.gun.scale
	self.gun.save_damage 		= self.gun.damage
	self.gun.save_oscale		= self.gun.oscale
end

function load_save_gun_stats(self)
	self.gun.rafale 	 	= self.gun.save_rafale
	self.gun.bullet_spd  	= self.gun.save_bullet_spd
	self.gun.laser_length 	= self.gun.save_laser_length
	self.gun.nbshot 	 	= self.gun.save_nbshot
	self.gun.spread 	 	= self.gun.save_spread
	self.gun.scattering		= self.gun.save_scattering
	self.gun.offset_spd  	= self.gun.save_offset_spd
	self.gun.life 			= self.gun.save_life			
	self.gun.rafaledt	 	= self.gun.save_rafaledt 
	self.gun.spdslow 	 	= self.gun.save_spdslow	
	self.gun.scale 			= self.gun.save_scale
	self.gun.damage 		= self.gun.save_damage
	self.gun.oscale			= self.gun.save_oscale
end

function advancementtoactive(self,avancement)
	self.gun.rafale 	 		= self.gun.rafale 		+ floor( self.gun.charge_nbrafale 		* avancement)
	self.gun.bullet_spd   = self.gun.bullet_spd 	+ self.gun.charge_bullet_spd 			* avancement
	self.gun.laser_length = self.gun.laser_length	+ self.gun.charge_laser_length 			* avancement
	self.gun.nbshot 		 	= self.gun.nbshot 		+ floor( self.gun.charge_nbshot 		* avancement)
	self.gun.spread 		 	= self.gun.spread 		+ self.gun.charge_spread 				* avancement	
	self.gun.scattering	  = self.gun.scattering	+ self.gun.charge_scattering			* avancement	 		 
	self.gun.offset_spd   = self.gun.offset_spd 	+ self.gun.charge_ospd 					* avancement
	self.gun.bullet_life  = self.gun.bullet_life  + self.gun.charge_life 					* avancement
	self.gun.rafaledt	 		= self.gun.rafaledt		+ self.gun.charge_rafaledt				* avancement
	self.gun.spdslow 	 		= self.gun.spdslow 	 	+ self.gun.charge_spdslow 				* avancement
	self.gun.scale 				= self.gun.scale        + self.gun.charge_scale					* avancement
	self.gun.damage				= self.gun.damage		+ self.gun.charge_damage				* avancement
	self.gun.oscale		  = self.gun.oscale 			+ self.gun.charge_oscale 				* avancement
end