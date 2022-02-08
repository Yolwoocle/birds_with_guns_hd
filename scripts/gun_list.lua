require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
	revolver = make_gun({
		name = "revolver",
		spr = spr_revolver,
		screenkick = 10,
		bullet_spd = 500,
		make_shot = default_shoot,
		scale = 0.5,
	}),
	laser = make_gun{
		name = "laser pistol",
		type = "laser",
		spr_bullet = spr_laser,
		spr = spr_revolver,
		screenkick = 10,
		bullet_life = .1,
		bullet_spd = 500,
		make_shot = default_shoot,
		scale = 0.5,
	},
	shotgun = make_gun{
		name = "shotgun",
		spr = spr_shotgun,
		nbshot = 10,
		offset_spd = 300,
		scattering    = 1,
		cooldown = 0.5,
		bullet_life = .3,
	},
	assault_rifle = make_gun{
		name = "assault rifle",
		spr = spr_assault_rifle,
		cooldown = 0.4,
		scattering = 0.2,
		damage = 2,

		scale = 0.5, 

		burst = 5,
		burstdt = 0.05,

		screenkick = 10,		
	},
	fire_extinguisher = make_gun({
		name = "fire extinguisher",
		spr = spr_fire_extinguisher,
		spr_bullet = spr_empty,
		nbshot = 10,
		damage = 0.1,
		bullet_life = .75,

		spdslow = 1,
		bullet_spd = 200,
		screenkick = 7,

		spawn_x = 40,
		spread = 0.3,
		scattering = 0.3,

		bullet_spr = spr_empty,
		scale = 1,
		cooldown = 0.01,

		ptc_type = "circle",
		max_ammo = 300,

		update_option = function(self,dt)
			--table.insert(zones, zone.explosion:spawn_zone( self.x, self.y))
		end
	}),


	knight_gun = make_gun({
		name = "knight_gun",
		spr = spr_fire_extinguisher,
		nbshot = 10,
		spr_bullet = spr_bullet_red,
		bullet_life = 5,

		--spdslow = 1,
		bullet_spd = 100,
		screenkick = 0,

		spawn_x = 20,
		
		scale = 1.25,
		cooldown = 4,
		burst  = 1,
		max_ammo = 300,
		make_shot = default_shoot,
		spread  = pi,
	}),

	firework_launcher = make_gun({
		name = "firework launcher",
		--type = "laser",
		spr = spr_firework_launcher,
		spr_bullet = spr_rocket,

		nbshot = 1,

		spdslow = 1.3,
		bullet_spd = 500,
		scattering    = 0,

		screenkick = 20,

		scale = 1,
		cooldown = 0.4,
		burst  = 1,
		max_ammo = 300,
		make_shot = default_shoot,
		bullet_life = 1.5,
		ptc_type = "circle",

		on_death = function(self , k)
			obj = copy(self.player)
			obj.rot = math.atan2(self.dy,self.dx)
			obj.x = self.x-math.cos(obj.rot)*30
			obj.y = self.y-math.sin(obj.rot)*30
			obj.gun = copy(guns.firework_explosion)
			--table.insert(_shot_, obj.gun:make_shot(obj))
			append_list(_shot, obj.gun:make_shot(obj))
			--table.insert(zones, zone.explosion:spawn_zone( self.x, self.y))
			table.remove(bullets, k)
	   end
	}),
	firework_explosion = make_gun({
		name = "firework_explosion", 
		type = "bullet",
		--bounce = 1,
		scale = .75,
		oscale = 0,
		nbshot = 40,
		spread  = pi2,
		scattering = pi2,
		spdslow = .95,

		--ptc_type = "circle",
		cooldown = .5,
		bullet_spd = 500,
		offset_spd = 100,
		bullet_life = .75,

	}),
	paper_plane_gun = make_gun{
		name = "paper plane gun",
		type = "bullet",
		spr = spr_paper_plane_gun,
		spr_bullet = spr_paper_plane,
		scale = 1.5,
		damage = 4,

		cooldown = 0,
		max_ammo = 100,
		bullet_spd = 500,
		spdslow = 0.99,
		bounce = math.huge,

		screenkick = 9,
		bounce = 1,
	
		update_option = function(self,dt)
			if self.turn_dir == nil then
				self.turn_dir = math.random(8)
			end
			local angle = math.atan2(self.dy,self.dx)

			local angleoffset = pi/60
			local timetoturn = 7
			local toadd = 1+self.turn_dir--+math.random()

			if self.turn_dir<=timetoturn then

				angle = (angle + angleoffset)*60*dt
				self.turn_dir= toadd

			elseif self.turn_dir<=timetoturn*2 then

				angle = (angle - angleoffset)*60*dt
				self.turn_dir= toadd

			else
				self.turn_dir= 0
			end

			--angle = angle + math.cos((self.maxlife-self.life+.5)*7)/10
			self.dx=math.cos(angle)*self.spd
			self.dy=math.sin(angle)*self.spd
			--
		end,
	},

	------------------------------------

	death_explosion = make_gun({
		name = "death_explosion", 
		type = "bullet",
		spr_bullet = spr_bullet_pink,
		--bounce = 1,
		scale = .85,
		oscale = 0,
		nbshot = 10,
		spread  = pi2,
		spdslow = .95,

		--ptc_type = "circle",
		cooldown = .5,
		bullet_spd = 150,
		bullet_life = 1.5,

	}),

	shotgunregular = make_gun{
		name = "shotgunregular",
		spr = spr_shotgun,
		spr_bullet = spr_bullet_red,
		nbshot = 5,
		spread  = pi/1.5,
		cooldown = 2,
		bullet_spd = 60,
		bullet_life = 5,
		scale = 1.5,
	},

	shotgunregular2 = make_gun{
		name = "shotgunregular",
		spr = spr_shotgun,
		spr_bullet = spr_bullet_red,
		nbshot = 6,
		spread  = pi/1.3,
		cooldown = 2,
		bullet_spd = 60,
		burst  = 2,
		burstdt  = .4,
		bullet_life = 5,
		scale = 1.5,
	},

	fox_revolver = make_gun({
		name = "Fox revolver",
		type = "bullet",
		spr_bullet = spr_bullet_red,
		spr = spr_revolver,
		bullet_spd = 100,
		
		scale = 1,
		cooldown = 3,
		make_shot = default_shoot,
		scale = 1.5,
	}),
	
	pistolet = make_gun({
		name = "pistolet", 
		type = "bullet",
		category = "instent",--FIXME "instant" not INSTENT GODDAMNIT
		charge = true,
		charge_time = .1,
		bounce = 1,
		laser_length = 300,
		scale = .1,
		scattering = 0,
		spawn_x = 17,
		spawn_y = 0,
		charge_scale = 10,
		bullet_spd = 100,
		cooldown = .1,
		charge_damage = 10,

		bullet_life = 3,
		nbshot = 1,
		spread  = pi/2,

		spawn_x =  10,

		spawn_y =  0,

		max_ammo = 300,
	}),

	jsp = make_gun({
		name = "jsp", 
		type = "bullet",
		bounce = 1,
		scale = .5,
		oscale = 0,

		cooldown = 1,
		bullet_spd = 100,
	}),

	jspp = make_gun({
		name = "jsp", 
		type = "bullet",
		laser_length = 3000,
		category = "instent",
		bounce = 1,
		max_ammo = 200000,
		charge = true,
		charge_curve = 2,			
		charge_time = 1,
		charge_nbburst = 10,
		scattering = 0,

		spread  = pi/2,

		scale = .75,
		oscale = 0,
		nbshot = 10,

		bullet_life = 10,

		--cooldown = 0,
		screenkick = 10,

		bullet_spd = 100,
		on_death = function(self , k)
			 table.insert(zones, zone.fire:spawn_zone( self.x, self.y))
			 table.remove(bullets, k)
		end

	}),

	boum = make_gun({
		name = "jsp", 

		--type = "laser",
		--spr_bullet = spr_laser,

		type = "bullet",
		spr_bullet = spr_bullet,
		--category = "instent",
		bounce = 0,
		max_ammo = 400,
		charge = true,
		charge_curve = 2,			
		charge_time = 1,
		charge_nbburst = 10,
		scattering = .1,

		spread  = pi/2,

		scale = 1,
		oscale = 0,
		nbshot = 1,

		bullet_life = 1,


		cooldown = .1,

		spdslow = 1.1,

		bullet_spd = 100,

		on_death = function(self , k)
			
			 table.remove(bullets, k)
			 --bullets = {}
			 --table.insert(zones, zone.explosion:spawn_zone( self.x, self.y))
		end

	}),
	
}


