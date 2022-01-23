require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"
require "scripts/gun_list"
require "scripts/collision"
require "scripts/settings"

function init_player(x,y)
	local player = {
		x = x or 100,
		y = y or 100,
		w = 4,
		h = 4,
		dx = 0,
		dy = 0,
		walk_dir = {x=0, y=0},

		speed = 120,
		friction = 0.6, --FIXME player glides more when FPS low
		bounce = 0.6,
		is_walking = false,
		is_enemy = false,

		life = 10,
		max_life = 10,
		iframes = 2,
		iframes_timer = 0,
		iframes_flashing_time = 0.1,
		hit_w = 12,
		hit_h = 12,

		spr = nil,
		rot = 0,
		looking_up = false,
		flip = -1,

		anim_sprs = nil,
		anim_walk = anim_pigeon_walk,
		anim_idle = anim_pigeon_idle,
		anim_frame = 0,
		anim_frame_len = .05, --70 ms
		animate = animate_player,

		gun_dist = 14,

		damage = damage_player,
		get_pickups = player_get_pickups,

		update = update_player,
		draw = draw_player,
	}
	player.anim_sprs = player.anim_idle

	player.gun = copy(guns.shotgun)

	return player
end

function update_player(self, dt)
	-- Movement
	player_movement(self,dt)
	-- Collisions
	collide_object(self,.2)
	-- Apply movement
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

	-- Aiming
	aim_player(self, dt)
	self.rot = self.rot % pi2
	self.looking_up = self.rot > pi

	-- Update gun
	self.gun:update(dt, self)

	-- Pickups
	self:get_pickups()

	-- Life, damage
	self.iframes_timer = self.iframes_timer - dt
	self.invincible = self.iframes_timer > 0 
	self.life = clamp(0, self.life, self.max_life)
	self.gun.ammo = clamp(0, self.gun.ammo, self.gun.max_ammo)
	gui.elements.life_bar.val = self.life
	gui.elements.life_bar.max_val = self.max_life
	gui.elements.ammo_bar.val = self.gun.ammo
	gui.elements.ammo_bar.max_val = self.gun.max_ammo

	self:animate()
end

function draw_player(self)
	local ft = self.iframes_flashing_time
	-- Flashing
	local is_drawn = true
	if self.invincible then
		is_drawn = self.iframes_timer % (2*ft) <= ft
	end

	-- Draw player
	if is_drawn then
		if self.looking_up then self.gun:draw(self) end
		draw_centered(self.spr, self.x, self.y, 0, pixel_scale*self.gun.flip, pixel_scale)
		if not self.looking_up then self.gun:draw(self) end
	end
	love.graphics.setColor(1,1,1)
	

	--rect_color("line", floor(self.x-self.w), floor(self.y-self.h), floor(2*self.w), floor(2*self.h), {1,0,0})
	--circ_color("fill", self.x, self.y, 3, {1,0,0})
end

function player_movement(self, dt)
	local dir_vector = {x = 0, y = 0}

	self.walk_dir = {x=0, y=0}
	self.is_walking = false
	if button_down("left") or (joystick and joystick.x<-joystick_deadzone) then
		if (joystick and joystick.x<-joystick_deadzone) then 
			dir_vector.x = dir_vector.x + joystick.x
		else
		dir_vector.x = dir_vector.x - 1
		end
		self.is_walking = true
		self.walk_dir.x = self.walk_dir.x - 1
	end
	if button_down("right") or (joystick and joystick.x>joystick_deadzone) then
		if (joystick and joystick.x>joystick_deadzone) then 
			dir_vector.x = dir_vector.x + joystick.x
		else
		dir_vector.x = dir_vector.x + 1
		end
		self.is_walking = true
		self.walk_dir.x = self.walk_dir.x + 1
	end
	if button_down("up") or (joystick and joystick.y<-joystick_deadzone) then
		if (joystick and joystick.y<-joystick_deadzone) then 
			dir_vector.y = dir_vector.y + joystick.y
		else
		dir_vector.y = dir_vector.y - 1
		end
		self.is_walking = true
	end
	if button_down("down") or (joystick and joystick.y>joystick_deadzone) then
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
	self.dx = self.dx * self.friction
	self.dy = self.dy * self.friction
end

function aim_player(self, dt)
	local mx, my = get_cursor_pos(camera)
	self.rot = math.atan2(my - self.y, mx - self.x)
	self.shoot = false
	if self.gun.cooldown_timer <= 0 then
		if (not(self.gun.charge) and button_down("fire")) 
		or (prevfire and not(button_down("fire")) 
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
				camera:shake(self.gun.rot, self.gun.screenshake)
				self.gun.dt = 0
				
			end
		elseif button_down("fire") and self.gun.charge then
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
		self.life = self.life - dmg
		self.iframes_timer = self.iframes
	end
end

function player_get_pickups(self)
	print("enter func{")
	for _,pick in ipairs(pickups.table) do
		print("	pickup")
		if coll_rect_objects(self, pick) then
			print("	COLLISION")
			pick:is_picked(self)
		end
	end
	print("}")
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