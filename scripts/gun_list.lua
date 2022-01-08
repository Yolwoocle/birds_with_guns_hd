require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
	revolver = make_gun({
		name = "revolver",
		spr = spr_revolver, 

		bullet_spd = 1000,
		ospd = 100,
		cooldown = 1,

		max_ammo = inf,
		scattering = 0.1,

		spawn_x =  70,
		spawn_y =  0,

		life	= 1.25,

		rafale  = 5,
		rafaledt  = .1,

		nbshot = 10,
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


