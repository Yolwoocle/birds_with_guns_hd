require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"

function init_player()
	local player = {
		x = 200,
		y = 200,
		dx = 0,
		dy = 0,
		speed = 90,
		friction = 0.8,
		bounce = 0.6,

		spr = spr_pigeon[1],
		rot = 0,

		gun_dist = 40,

		update = update_player,
		draw = draw_player,
	}
	player.gun = make_gun(player)
	return player
end

function update_player(p, dt)
	player_movement(p,dt)
	
	-- Aiming
	local mx, my = love.mouse.getPosition()
	p.rot = math.atan2(my-p.y, mx-p.x)

	p.shoot = false
	if button_down("fire") and p.gun.cooldown_timer <= 0 then
		if p.gun.ammo > 0 then
			p.shoot = true
			p.gun:shoot()
		end
	end
	p.gun:update(dt)
end

function draw_player(p)
	draw_centered(p.spr, p.x, p.y, 0, 2, 2)
	love.graphics.print(tostring(spr_pigeon), 10, 10)

	local x = p.x + math.cos(p.rot) * p.gun_dist
	local y = p.y + math.sin(p.rot) * p.gun_dist
	draw_centered(p.gun.spr, x, y, p.rot, 2, 2)

	circ_color("fill", p.x, p.y, 3, {0,0,1})
end

function player_movement(p, dt)
	-- TODO: player moves faster in diagonals
	if button_down("left") then
		p.dx = p.dx - p.speed
	end
	if button_down("right") then
		p.dx = p.dx + p.speed
	end
	if button_down("up") then
		p.dy = p.dy - p.speed
	end
	if button_down("down") then
		p.dy = p.dy + p.speed
	end

	p.dx = p.dx * p.friction
	p.dy = p.dy * p.friction

	p.x = p.x + p.dx * dt
	p.y = p.y + p.dy * dt
end