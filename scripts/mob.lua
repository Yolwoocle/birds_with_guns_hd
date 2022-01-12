require "scripts/utility"

function make_mob(a)
	spr 	   = a.spr or spr_revolver
	local mob = {
		name           = a.name       or "null",
		spr 	       = a.spr        or spr_revolver,
		life	       = a.life		  or 2,	
		cooldown_timer = 0,

		x        = a.x		  or 30,
		y        = a.y          or 30,
		w        = a.w          or 20,
		h        = a.h          or 30,
		dx       = a.dx         or 0,
		dy       = a.dy         or 0,
		speed    = a.speed      or 20,
		friction = a.friction   or 0.95,
		bounce   = a.bounce     or 0.6,

		spawn = spawn_mob,
		shoot = shoot_gun,

		update = update_mob,
		draw = draw_mob,
	}

	mob.gun = guns.revolver

	return mob
end

function spawn_mob(self, x, y)
	local c = copy(self)
	x = x or 0 
	y = y or 0
	c.x = x
	c.y = y
	return c
end

function update_mob(self, dt)
	collide_object(self)
end

function draw_mob(self)
	draw_centered(spr_fox[1], self.x, self.y)
end