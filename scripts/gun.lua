
require "scripts/utility"

function make_gun(bname,bspr,bspd,bcd,bmaxammo,bofbuld,bofbula,mkbullet)
	local gun = {

		name=bname,
		spr = bspr,
		bullet_spd = bspd,
		cooldown = bcd,
		ammo = bmaxammo,
		maxammo=bmaxammo,

		cooldown_timer = 0,

		make_bullet = mkbullet,
		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
		ofbuld=bofbuld,
		ofbula=bofbula,
	}
	return gun
end

function update_gun(g, dt,p)
	g.cooldown_timer = math.max(0, g.cooldown_timer - dt) 
	g.flip = -sng((p.rot+pi/2)%(pi*2)-pi)
end

function draw_gun(p)
	local x = p.x + math.cos(p.rot) * p.gun_dist 
	local y = p.y + math.sin(p.rot) * p.gun_dist 
	draw_centered(p.gun.spr, x, y, p.rot, 1.75, 1.75*p.gun.flip)
	
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
		x = p.x + math.cos(p.rot+g.ofbula*g.flip)*g.ofbuld ,
		y = p.y + math.sin(p.rot+g.ofbula*g.flip)*g.ofbuld ,
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