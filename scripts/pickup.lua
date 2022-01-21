require "scripts/utility"
require "scripts/sprites"

function make_pickups()
	local p = {
		table = {},
	
		spawn = spawn_pickup,
		update = update_pickups,
		draw = draw_pickups,
	}
	return p 
end

function is_picked(self, obj)
	self.delete = true
	if self.type == "ammo" then
		obj.gun.ammo = obj.gun.ammo + self.q
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
		w = 5,
		h = 5,

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