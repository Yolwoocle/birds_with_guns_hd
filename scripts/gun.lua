
require "scripts/utility"

function make_gun(a)
	--name, spr, bullet_spd, cooldown, max_ammo, ofbuld,bofbula,mkbullet
	spr = a.spr or spr_revolver
	local gun = {
		name       = a.name       or "null",
		spr 	   = a.spr        or spr,
		bullet_spd = a.bullet_spd or 80,
		cooldown   = a.cooldown   or 0.2,
		ammo       = a.max_ammo   or 100,
		maxammo    = a.max_ammo   or 100,
		angle_var  = a.angle_var  or 0,
		spawn_x    = a.spawn_x    or spr:getWidth(),
		spawn_y    = a.spawn_y    or spr:getHeight(),

		cooldown_timer = 0,

		make_bullet = a.make_bullet,
		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
	}
	return gun
end

function update_gun(g,dt,p)
	g.cooldown_timer = math.max(0, g.cooldown_timer - dt) 
	g.flip = -sgn( (p.rot + pi/2) % (pi*2) - pi)
end

function draw_gun(p)
	local x = p.x + math.cos(p.rot) * p.gun_dist 
	local y = p.y + math.sin(p.rot) * p.gun_dist 
	draw_centered(p.gun.spr, x, y, p.rot, 1.75, 1.75 * p.gun.flip)
end

function shoot_gun(g)
	g.ammo = g.ammo - 1
	g.cooldown_timer = g.cooldown
end

--------------
--- BULLET ---
--------------

function make_bullet(g,p)
	local bullet = {
		x = p.x + math.cos(p.rot + g.angle_var * g.flip) * g.spawn_x,
		y = p.y + math.sin(p.rot + g.angle_var * g.flip) * g.spawn_y,
		dx = math.cos(p.rot) * g.bullet_spd,
		dy = math.sin(p.rot) * g.bullet_spd,
		rot = p.rot,

		spr = spr_bullet,
		
		life = 2,
		delete = false,
		update = update_bullet,
		draw = draw_bullet,
	}
	return bullet
end

function update_bullet(b,dt)
	b.life = b.life - dt
	b.x = b.x + b.dx * dt
	b.y = b.y + b.dy * dt 

	if b.life < 0 then
		b.delete = true
	end
end

function draw_bullet(b)
	draw_centered(b.spr, b.x, b.y, 1, 2, 2)
	circ_color("fill", b.x, b.y, 3, {0, 1, 0})
end