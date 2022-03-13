require "scripts.sprites"
require "scripts.interactable"
require "scripts.utility"

interactable_list = {
	end_of_level = make_interactable({
		spr = spr_end_of_level,
		
		condition = function(self, dt,i)
			for i,b in ipairs(bullets) do
				if dist_sq(b.x,b.y,self.x,self.y) < 15*15 then
					table.remove(bullets,i)
					return true
				end
			end
		end,

		on_interaction = function(self, dt, i)
			game:create_new_level()
		end,
	}),

	chest = make_interactable({
		name = "chest",
		spr = spr_chest,

		init = function(self)
			self.life = 10
		end,

		condition = function (self, dt,i)
			for i,b in ipairs(bullets) do
				if dist_sq(b.x,b.y,self.x,self.y) < 15*15 and not b.is_enemy then
					self.life = self.life - b.damage
				end
			end

			if self.life <= 0 then
				table.remove(bullets,i)
				return true
			end

			return false
		end,

		on_interaction = function (self, dt, i)
			--pickups:spawn("gun", guns.machinegun, self.x, self.y)
			pickups:spawn("gun", get_random_gun(), self.x, self.y)
			table.remove(interactables,i)
		end,
	}),
}