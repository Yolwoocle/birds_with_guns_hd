require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"
require "scripts/input"
require "scripts/gun_list"
require "scripts/collision"
require "scripts/settings"

function init_player()
	local player = {
		x = 500,
		y = 200,
		w = 20,
		h = 30,
		dx = 0,
		dy = 0,
		speed = 10,
		friction = 0.95,
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
	-- Movement
	player_movement(self,dt)
	-- Collisions
	collide_object(self)
	-- Apply movement
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

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
	self.rot = self.rot % pi2

	self.gun:update(dt, self)
end

function draw_player(self)
	draw_centered(self.spr, self.x, self.y, 0, pixel_scale* self.gun.flip, pixel_scale)
	love.graphics.print(tostr(spr_pigeon), 10, 10)
	self.gun:draw(self)
	
	rect_color("line", self.x-self.w, self.y-self.h, 2*self.w, 2*self.h, {1,0,0})
	circ_color("fill", self.x, self.y, 3, {0,0,1})
end

function player_movement(self, dt)
	local dir_vector = {x = 0, y = 0}

	if love.keyboard.isScancodeDown("a") or love.keyboard.isScancodeDown("left") then
		dir_vector.x = dir_vector.x - 1
	end
	if love.keyboard.isScancodeDown("d") or love.keyboard.isScancodeDown("right") then
		dir_vector.x = dir_vector.x + 1
	end
	if love.keyboard.isScancodeDown("w") or love.keyboard.isScancodeDown("up") then
		dir_vector.y = dir_vector.y - 1
	end
	if love.keyboard.isScancodeDown("s") or love.keyboard.isScancodeDown("down") then
		dir_vector.y = dir_vector.y + 1
	end

	local norm = math.sqrt(dir_vector.x * dir_vector.x + dir_vector.y * dir_vector.y) + 0.0001

	dir_vector.x = dir_vector.x / norm
	dir_vector.y = dir_vector.y / norm

	self.dx = self.dx + (dir_vector.x * self.speed)
	self.dy = self.dy + (dir_vector.y * self.speed)
	self.dx = self.dx * self.friction
	self.dy = self.dy * self.friction
end

function collide_player(self)

end	