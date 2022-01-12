require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"
require "scripts/gun_list"
require "scripts/collision"
require "scripts/settings"

function init_player()
	local player = {
		x = 500,
		y = 200,
		w = 20,
		h = 30,
		dx = 0,
		dy = 0,
		speed = 20,
		friction = 0.95,
		bounce = 0.6,

		spr = spr_pigeon[1],
		rot = 0,
		looking_up = false,

		gun_dist = 30,

		update = update_player,
		draw = draw_player,
	}
	player.gun = guns.pistolet
	return player
end

function update_player(self, dt, camera)
	-- Movement
	player_movement(self,dt)
	-- Collisions
	collide_object(self,.2)
	-- Apply movement
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

	-- Aiming
	local mx, my = love.mouse.getPosition()
	self.rot = math.atan2(my - self.y, mx - self.x)
	self.shoot = false
	if self.gun.cooldown_timer <= 0 then
		if (not(self.gun.charge) and button_down("fire")) or (prevfire and not(button_down("fire")) and self.gun.charge) then
			if self.gun.ammo > 0 then


				if self.gun.charge then
				local avancement = self.gun.dt/self.gun.charge_time
				if self.gun.save_rafale then
				load_save_stats(self)
				end

				save_stats(self)

				self.gun.rafale 	 		= self.gun.rafale 		+ floor( self.gun.charge_nbrafale 		* avancement)
				self.gun.bullet_spd 		= self.gun.bullet_spd 	+ self.gun.charge_bullet_spd 			* avancement
				self.gun.laser_length 		= self.gun.laser_length	+ self.gun.charge_laser_length 			* avancement
				self.gun.nbshot 		 	= self.gun.nbshot 		+ floor( self.gun.charge_nbshot 		* avancement)
				self.gun.spread 		 	= self.gun.spread 		+ self.gun.charge_spread 				* avancement	
				self.gun.scattering	 		= self.gun.scattering	+ self.gun.charge_scattering			* avancement	 		 
				self.gun.offset_spd 		= self.gun.offset_spd 	+ self.gun.charge_ospd 					* avancement
				self.gun.life 		 		= self.gun.life 		+ self.gun.charge_life 					* avancement
				self.gun.rafaledt	 		= self.gun.rafaledt		+ self.gun.charge_rafaledt				* avancement
				self.gun.spdslow 	 		= self.gun.spdslow 	 	+ self.gun.charge_spdslow 				* avancement
				self.gun.scale 				= self.gun.scale        + self.gun.charge_scale					* avancement
				self.gun.damage				= self.gun.damage		+ self.gun.charge_damage				* avancement
				end

				self.shoot = true
				self.gun:shoot()
				self.gun.dt = 0
				
			end
		elseif button_down("fire") and self.gun.charge then
			self.gun.dt = math.min(self.gun.dt+dt,self.gun.charge_time)
		end
	end --prevfire = button_down("fire")
	self.rot = self.rot % pi2

	self.looking_up = self.rot > math.pi

	self.gun:update(dt, self)
end

function draw_player(self)
	if     self.looking_up then self.gun:draw(self) end
	draw_centered(self.spr, self.x, self.y, 0, pixel_scale* self.gun.flip, pixel_scale)
	if not self.looking_up then self.gun:draw(self) end

	love.graphics.print(tostr(self.looking_up), self.x, self.y - 100)
	
	--rect_color("line", self.x-self.w, self.y-self.h, 2*self.w, 2*self.h, {1,0,0})
	--circ_color("fill", self.x, self.y, 3, {1,0,0})
end

function player_movement(self, dt)
	local dir_vector = {x = 0, y = 0}

	if button_down("left") then
		dir_vector.x = dir_vector.x - 1
	end
	if button_down("right") then
		dir_vector.x = dir_vector.x + 1
	end
	if button_down("up") then
		dir_vector.y = dir_vector.y - 1
	end
	if button_down("down") then
		dir_vector.y = dir_vector.y + 1
	end

	local norm = math.sqrt(dir_vector.x * dir_vector.x + dir_vector.y * dir_vector.y) + 0.0001

	dir_vector.x = dir_vector.x / norm
	dir_vector.y = dir_vector.y / norm

	self.dx = self.dx + (dir_vector.x * self.speed)
	self.dy = self.dy + (dir_vector.y * self.speed)
	self.dx = self.dx * self.friction
	self.dy = self.dy * self.friction
end

function collide_player(self)

end	

function save_stats(self)
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
end

function load_save_stats(self)
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
end