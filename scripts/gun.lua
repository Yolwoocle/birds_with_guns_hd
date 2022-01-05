require "scripts/sprites"
require "scripts/utility"

function make_gun(player)
	local gun = {
		player = player,
		
		spr = spr_revolver,
		bullet_spd = 600,
		cooldown = 0.25,
		ammo = 100,

		cooldown_timer = 0,

		make_bullet = make_bullet,
		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
	}
	return gun
end

function update_gun(g, dt)
	g.cooldown_timer = math.max(0, g.cooldown_timer - dt) 
end

function draw_gun(g)
	love.graphics.draw(g.spr, g.player.x, g.player.y)
end

function shoot_gun(g)
	g.ammo = g.ammo - 1
	g.cooldown_timer = g.cooldown
end

--------------
--- BULLET ---
--------------

function make_bullet(g)
	local bullet = {
		x = g.player.x,
		y = g.player.y,
		dx = math.cos(g.player.rot) * g.bullet_spd,
		dy = math.sin(g.player.rot) * g.bullet_spd,
		rot = g.player.rot,

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