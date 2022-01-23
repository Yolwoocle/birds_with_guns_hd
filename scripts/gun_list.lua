require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
	revolver = make_gun({
		name = "revolver",
		spr = spr_revolver,
		bullet_spd = 50,
		make_shot = default_shoot
	}),
	shotgun = make_gun({
		name = "shotgun",
		spr = spr_shotgun,
		nbshot = 10,
		bullet_spd = 50,
		make_shot = default_shoot
	}),
}


