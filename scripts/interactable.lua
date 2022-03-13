function make_interactable(a)
	local interactable = {
		name = a.name or "interactable",
		spr = a.spr or spr_missing,

		init = a.init or function(self)  end,

		condition = a.condition or function (self, dt,i)
			for i,p in ipairs(players) do
				if p.shoot and dist_sq(p.x,p.y,self.x,self.y)<15^2 then
					return true
				end
			end
		end,

		on_interaction = a.on_interaction or function (self, dt,i)
			print("activated")
		end,
		
		spawn = function(self, x, y)
			local c = copy(self)
			x = x or 0 
			y = y or 0
			c.x = x
			c.y = y
			table.insert(interactables , c)
		end,

		draw = function (self)
			draw_centered(self.spr, self.x, self.y)
		end,

		update = function (self, dt , i)
			if self:condition(dt,i) then
				self:on_interaction(dt,i)
			end
		end,

	}

	interactable:init()
	return interactable
end

