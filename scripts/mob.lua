require "scripts/utility"

function make_mob(a)
	spr 	   = a.spr or spr_revolver
	local mob = {

		name       = a.name       or "null",
		spr 	   = a.spr        or spr_revolver,
		life	   = a.life		  or 2,	
		cooldown_timer = 0,

		make_bullet = a.make_bullet or function (g,p)return normaleshoot(g,p)end,
		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
	}
	return gun
end