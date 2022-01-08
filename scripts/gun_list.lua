require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {

    revolver = make_gun({
        name = "revolver",
        type = "laser",
        category = "persistant",
        spr = spr_revolver, 

        bullet_spd = 1000,
        ospd = 0,
        cooldown = 2,

        max_ammo = inf,
        scattering = 0,

		spawn_x =  70,
		spawn_y =  0,

		life	= .02,

        laser_length = 300,

        rafale  = 1,
        rafaledt  = .1,

		nbshot = 6,
		spread  = pi/4,

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


