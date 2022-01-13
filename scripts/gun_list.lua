require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {

    revolver = make_gun({
        name = "revolver",
        type = "bullet",			--"bullet" "laser"
        category = "persistent",	--"persistent" "instant"
		bounce = false,

		charge = false,
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

        spr = spr_revolver, 

        bullet_spd = 500,
        ospd = 0,
        cooldown = .3,

		scale = 1,

        max_ammo = inf,
        scattering = .6,

		damage = 1,

		spawn_x = nil,
		spawn_y = 0,

		life	= .5,

        laser_length = 300,

        rafale  = 1,
        rafaledt  = .1,

		nbshot = 1,
		spread  = pi/2,

		spdslow = 1,

		screenshake = 3,

		make_shot = default_shoot
	}),
	
	pistolet = make_gun({
		name = "pistolet", 

		spawn_x =  70,
		spawn_y =  0,

		max_ammo = inf,
	}),
}


