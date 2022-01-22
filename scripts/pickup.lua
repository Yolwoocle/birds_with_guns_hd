require "scripts/utility"
require "scripts/sprites"

function make_pickups()
	local p = {
		table = {},
	
		spawn = spawn_pickup,
		spawn_random_loot = spawn_random_loot,
		update = update_pickups,
		draw = draw_pickups,
	}
	return p 
end

function is_picked(self, obj)
	self.delete = true
	if self.type == "ammo" then
		obj.gun.ammo = obj.gun.ammo + floor(self.q * obj.gun.max_ammo) 
	elseif self.type == "life" then
		obj.life = obj.life + self.q
	elseif self.type == "gun" then
		obj.gun = self.gun
	end
end

function spawn_pickup(self, type, q, x, y)
	local pick = {
		--n = #self.table + 1,
		type = type,
		x = floor(x),
		y = floor(y),
		w = 8,
		h = 8,

		q = 0,
		spr = spr_missing,
		is_picked = is_picked,
	}

	if type == "ammo" then
		pick.q = q
		pick.spr = spr_pick_ammo
	
	elseif type == "life" then
		pick.q = q
		pick.spr = spr_pick_life

	elseif type == "gun" then
		pick.gun = q

	end
	table.insert(self.table, pick)
end

function spawn_random_loot(self, x, y)
	if love.math.random() <= 1.03 then
		self:spawn("gun", 0.25, x, y)
	elseif love.math.random() <= 0.03 then
		self:spawn("life", 2, x, y)
	elseif love.math.random() <= 0.01 then
		self:spawn("ammo", 0.25, x, y)
	end
end

function update_pickups(self, dt)
	for i,pick in ipairs(self.table) do
		if pick.delete then
			table.remove(self.table, i)
		end
	end
end

function draw_pickups(self)
	for i,pick in ipairs(self.table) do
		draw_centered(pick.spr, pick.x, pick.y)
	end
end