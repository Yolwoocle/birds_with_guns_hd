require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
	revolver = make_gun({
		name = "revolver",
		type = "laser",			--"bullet" "laser"
		
        category = "instant",	--"persistent" "instant"
		bounce = true,

		charge = true,
		charge_time = 1,
		charge_nbrafale = 10,
		charge_bullet_spd = 1,
		charge_laser_length = 300,
		charge_nbshot = 10,
		charge_spread = 0,
		charge_scattering = -.6, --difference between scattering and spread?
		charge_scale = 2,
		charge_ospd = 0,
		charge_life = 1,
		charge_rafaledt = 0,
		charge_spdslow = .002,
		charge_damage = 10,
		charge_oscale = 10,

		spr = spr_revolver, 

        bullet_spd = 100,
        ospd = 0,
        cooldown = 1,

		scale = .25,
		oscale = 0,

        max_ammo = inf,
        scattering = 1,

		damage = 1,

		spawn_x = nil,
		spawn_y = 0,

		bullet_life	= 3,

		laser_length = 300,

		rafale  = 1,
		rafaledt  = .1,

		nbshot = 5,
		spread  = pi/2,

		spdslow = 1,

		screenshake = 3,

		make_shot = default_shoot
	}),
	
	pistolet = make_gun({
		name = "pistolet", 
		type = "bullet",
		category = "instent",--FIXME "instant" not INSTENT GODDAMNIT
		charge = true,
		charge_time = .1,
		bounce = true,
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
		type = "laser",
		laser_length = 3000,
		category = "instent",
		bounce = 1,
		max_ammo = 200000,
		charge = true,
		charge_curve = 2,			
		charge_time = 1,
		charge_nbrafale = 10,
		scattering = 0,

		spread  = pi/2,

		scale = .75,
		oscale = 0,
		nbshot = 10,

		bullet_life = 10,

		cooldown = 0,
		screenshake = 10,

		bullet_spd = 100,
		on_death = function(self , k)
			 --table.insert(zones, zone.fire:spawn_zone( self.x, self.y))
			 table.remove(bullets, k)
		end

	}),

	boum = make_gun({
		name = "jsp", 
		type = "bullet",
		category = "instent",
		bounce = false,
		max_ammo = 400,
		charge = false,
		charge_curve = 2,			
		charge_time = 1,
		charge_nbrafale = 10,
		scattering = .1,

		spread  = pi/2,

		scale = 1,
		oscale = 0,
		nbshot = 1,

		bullet_life = 10,


		cooldown = .5,

		spdslow = 1.1,

		bullet_spd = 100,
		on_death = function(self , k)
			
			 table.remove(bullets, k)
			 --bullets = {}
			 table.insert(zones, zone.explosion:spawn_zone( self.x, self.y))
		end

	}),
}


