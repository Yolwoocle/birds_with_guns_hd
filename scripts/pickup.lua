require "scripts.utility"
require "scripts.sprites"
require "scripts.gun"

--TODO: rework pickups

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
	local col 

	if self.type == "ammo" then
		self.delete = true
		obj.gun.ammo = obj.gun.ammo + floor(self.q * obj.gun.max_ammo) 
		col = color(blue_bullet)

	elseif self.type == "life" then
		self.delete = true
		obj.life = obj.life + self.q
		col = color(red_heart)

	elseif self.type == "gun" then
		switch_weapon(self , obj)
		col = color(0x8b9bb4)

	elseif self.type == "modifier" then
		self.delete = true
		local modif_lis = modifiers[self.q]
		local rnd = math.random(1,#modif_lis)

		if obj.gun.type == "laser" and love.math.random() <= 0.5 then 
			modif_lis = modifiers[4]
		end

		if modif_lis[rnd][3] then
			obj.gun[modif_lis[rnd][1]] = obj.gun[modif_lis[rnd][1]] * modif_lis[rnd][2]
		else
			obj.gun[modif_lis[rnd][1]] = obj.gun[modif_lis[rnd][1]] + modif_lis[rnd][2]
		end

		debugg = modif_lis[rnd][1]

	end

	for i=1,5 do 
		--local ox, oy = love.math.random(-10,10), love.math.random(-10,10)
		--particles:make_circ(self.x + ox, self.y + oy, love.math.random(4,12), col)
	end
end

modifiers = {{{"damage",.5},{"bounce",1},{"burst",1},{"nbshot",1}} , {{"bullet_spd",50},{"knockback",50},{"cooldown",0.85,"multi"},{"burstdt",0.85,"multi"}} , 
			 {{"max_ammo",50},{"bullet_life",0.1},{"scale",.25}} , {{"laser_length",50},{"damge_tick",.85,"multi"}}}
--spdslow
--oscale
--{"scattering",-0.1},{"spread",-0.1},

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
		--self:spawn("gun", get_random_gun(), x, y)
		
	elseif love.math.random() <= 0.1 then
		self:spawn("life", 2, x, y)

	elseif love.math.random() <= 0.1 then
		self:spawn("ammo", 0.25, x, y)

	elseif love.math.random() <= -0.5 then
		self:spawn("modifier", math.random(1,3), x, y)
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