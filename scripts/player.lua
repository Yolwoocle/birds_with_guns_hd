require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"
require "scripts/gun_list"
require "scripts/options"

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
	player.gun = guns.revolver
	return player
end

function update_player(self, dt)
	player_movement(self,dt)
	
	-- Aiming
	local mx, my = love.mouse.getPosition()
	self.rot = math.atan2(my - self.y, mx - self.x)

	self.shoot = false
	if button_down("fire") and self.gun.cooldown_timer <= 0 then
		if self.gun.ammo > 0 then
			self.shoot = true
			self.gun:shoot()
		end
	end
	self.gun:update(dt,self)

end

function draw_player(self)
	draw_centered(self.spr, self.x, self.y, 0, pixel_scale, pixel_scale)
	love.graphics.print(tostr(spr_pigeon), 10, 10)

	self.gun:draw(self)
	circ_color("fill", self.x, self.y, 3, {0,0,1})
end

function player_movement(self, dt)
	-- TODO: player moves faster in diagonals
	if button_down("left") then
		self.dx = self.dx - self.speed
	end
	if button_down("right") then
		self.dx = self.dx + self.speed
	end
	if button_down("up") then
		self.dy = self.dy - self.speed
	end
	if button_down("down") then
		self.dy = self.dy + self.speed
	end

	self.dx = self.dx * self.friction
	self.dy = self.dy * self.friction

	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end