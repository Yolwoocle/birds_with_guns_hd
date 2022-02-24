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
	elseif self.type == "modifier" then
		self.delete = true
		local rnd = math.random(1,#modifiers)
		obj.gun[modifiers[rnd][1]] = obj.gun[modifiers[rnd][1]] + modifiers[rnd][2]
		debugg = modifiers[rnd][1]
	end
end

modifiers = {{"damage",.5},{"bounce",1},{"bullet_spd",50},{"cooldown",-0.1},{"max_ammo",50},{"burst",1},{"burstdt",-0.05},
{"bullet_life",0.2},{"laser_length",50},{"nbshot",1},{"scattering",-0.1},{"spread",-0.1},{"damge_tick",-0.05},{"scale",.25},{"knockback",100}}
--spdslow
--oscale

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
	elseif type == "modifier" then
		pick.q = q
		pick.spr = spr_missing

	end
	table.insert(self.table, pick)
end

function spawn_random_loot(self, x, y)
	if love.math.random() <= 0.1 then
		self:spawn("gun", guns.revolver, x, y)
	elseif love.math.random() <= 0.1 then
		self:spawn("life", 2, x, y)
	elseif love.math.random() <= 0.1 then
		self:spawn("ammo", 0.25, x, y)

	elseif love.math.random() <= 0.1 then
		self:spawn("modifier", 1, x, y)
	elseif love.math.random() <= 0.1 then
		self:spawn("modifier", 2, x, y)
	elseif love.math.random() <= 0.1 then
		self:spawn("modifier", 3, x, y)
	end
end

function update_pickups(self, dt)
	for i = #self.table, 1, -1 do
		pick = self.table[i]
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