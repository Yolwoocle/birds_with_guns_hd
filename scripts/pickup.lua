require "scripts/utility"
require "scripts/sprites"
require "scripts/gun"

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
	if self.type == "ammo" then
		self.delete = true
		obj.gun.ammo = obj.gun.ammo + floor(self.q * obj.gun.max_ammo) 
	elseif self.type == "life" then
		self.delete = true
		obj.life = obj.life + self.q
	elseif self.type == "gun" then
		switch_weapon(self , obj)
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
		pick.gun = copy(q)
		pick.spr = q.spr

	end
	table.insert(self.table, pick)
end

function spawn_random_loot(self, x, y)
	if love.math.random() <= 0.1 then
		self:spawn("gun", guns.revolver, x, y)
--		self:spawn("ammo", 0.25, x, y)
	elseif love.math.random() <= 0.1 then
		self:spawn("life", 2, x, y)
	elseif love.math.random() <= 0.1 then
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