require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
	revolver = make_gun({
		name = "revolver",
		spr = spr_revolver,
		screenkick = 10,
		bullet_spd = 500,
		make_shot = default_shoot
	}),
	shotgun = make_gun{
		name = "shotgun",
		spr = spr_shotgun,
		nbshot = 10,
		offset_spd = 5,
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
		bulletspr = spr_empty,
		nbshot = 10,
		damage = 0.02,

		spdslow = 1,
		bullet_spd = 200,
		screenkick = 7,

		spawn_x = 40,
		spread = pi2ds,

		bullet_spr = spr_empty,
		scale = 1,
		cooldown = 0.01,

		ptc_type = "circle",
		max_ammo = inf,

		update_option = function(self,dt)
			--table.insert(zones, zone.explosion:spawn_zone( self.x, self.y))
		end
	}),

	

	knight_gun = make_gun({
		name = "knight_gun",
		spr = spr_fire_extinguisher,
		nbshot = 10,
		bulletspr = spr_bullet,
		bullet_life = 5,

		--spdslow = 1,
		bullet_spd = 100,
		screenkick = 0,

		spawn_x = 20,
		
		scale = 1.25,
		cooldown = 1,
		burst  = 1,
		max_ammo = inf,
		make_shot = default_shoot,
		spread  = pi,
	}),

	firework_launcher = make_gun({
		name = "firework launcher",
		--type = "laser",
		spr = spr_firework_launcher,
		bulletspr = spr_rocket,

		nbshot = 1,

		spdslow = 1.3,
		bullet_spd = 500,
		scattering    = 0,

		screenkick = 20,

		scale = 1,
		cooldown = 0.1,
		burst  = 1,
		max_ammo = inf,
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
		scale = 1,
		oscale = 0,
		nbshot = 1300,
		spread  = pi2,
		spdslow = .95,

		--ptc_type = "circle",
		cooldown = .5,
		bullet_spd = 500,
		bullet_life = .75,

	}),

	fox_revolver = make_gun({
		name = "Fox revolver",
		type = "bullet",
		spr = spr_revolver,
		bullet_spd = 100,
		
		scale = 1,
		cooldown = 0.8,
		make_shot = default_shoot,
	}),

	test = make_gun({
		type = "bullet",			--"bullet" "laser"
		category = "instant",	--"persistent" "instant"
		bounce = 0,
		
		charge = true,
		charge_time = 1,
		charge_nbburst = 10,
		charge_bullet_spd = 1,
		charge_laser_length = 30000,
		charge_nbshot = 10,
		charge_spread = 0,
		charge_scattering = -.6, --difference between scattering and spread?
		charge_scale = 2,
		charge_ospd = 0,
		charge_life = 0,
		charge_burstdt = 0,
		charge_spdslow = .002,
		charge_damage = 10,
		charge_oscale = 10,

		spr = spr_revolver, 

		bullet_spd = 100,
		ospd = 0,
		cooldown = .1,

		scale = .25,
		oscale = 0,

		max_ammo = inf,
		scattering = 1,

		damage = 1,

		spawn_x = nil,
		spawn_y = 0,

		bullet_life	= 10,

		laser_length = 300,

		burst  = 1,
		burstdt  = .1,

		nbshot = 5,
		spread  = pi/2,

		spdslow = 1,

		screenkick = 3,

		make_shot = default_shoot
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

		max_ammo = inf,
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
		--bulletspr = spr_laser,

		type = "bullet",
		bulletspr = spr_bullet,
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


