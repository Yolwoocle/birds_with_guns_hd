require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {

    revolver = make_gun({
        name = "revolver",
        type = "laser",			--"bullet" "laser"
        category = "instant",	--"persistant" "instant"

		charge = true,
		charge_time = 1,
		charge_nbrafale = 10,
		charge_bullet_spd = 1,
		charge_laser_length = 300,
		charge_nbshot = 100,
		charge_spread = 0,
		charge_scattering = -.6,
		charge_scale = 10,
		charge_ospd = 0,
		charge_life = 0,
		charge_rafaledt = 0,
		charge_spdslow = 0,

        spr = spr_revolver, 

        bullet_spd = 1000,
        ospd = 0,
        cooldown = 1,

		scale = 1,

        max_ammo = inf,
        scattering = .6,

		spawn_x =  70,
		spawn_y =  0,

		life	= .1,

        laser_length = 300,

        rafale  = 1,
        rafaledt  = .1,

		nbshot = 3,
		spread  = pi/2,

		spdslow = .995,

		make_shot = default_shoot
		--function (g,p)
		--	return default_shoot(g,p)
		--end,
	}),
	
	pistolet = make_gun({
		name = "pistolet", 

		spawn_x =  70,
		spawn_y =  0,

		max_ammo = inf,
	}),
}


