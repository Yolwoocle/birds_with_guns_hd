require "scripts/utility"
require "scripts/settings"
require "scripts/damage_zone_list"
require "scripts/damage_zone"

function update_bullet(self, dt, i)
	-- Movement
	self.rot = math.atan2(self.dy, self.dx)
	if (self.dx * self.spdslow)^2 + (self.dy * self.spdslow)^2 < self.speed_max^2 then
		self.dx = self.dx * self.spdslow
		self.dy = self.dy * self.spdslow
	end
	if self.update_option then 
		self:update_option(dt) 
	end
	
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt 

	self.sx = (sqr(self.dx) + sqr(self.dy)) / sqr(self.spd)

	if self.bounce>0 then
		local coll,todestroy = collide_object(self,1)
		if coll then
			self.bounce = self.bounce-1

			for _,k in pairs(todestroy) do 
				interact_map(self, map,(k.x), (k.y))
			end
			
		end
	end

	-- Particles
	if self.gun.ptc_type == "circle" and self.ptc_timer <= 0 then
		local x, y = random_polar(10)
		particles:make_circ(self.x + x, self.y + y, 10)
		self.ptc_timer = 1/30 --OPTI
	end
	self.ptc_timer = self.ptc_timer - dt

	self.time_since_creation = self.time_since_creation + dt
	self.life = self.life - dt
end

function update_laser(self, dt , i)
	self.active = false
	self.time_since_creation = self.time_since_creation + dt
	if self.init then
		self.init = false
		init_laser(self)
	end

	if self.category == "persistent" and button_down("fire", self.player.n,self.player.input_device) and self.gun.ammo>0 and self.gun == self.player.gun then
		self.bounce = self.maxbounce
		self.length = {}
		self.life = self.life + dt
		self.x = self.player.x + math.cos(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		self.y = self.player.y + math.sin(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		
		self.dx = math.cos(self.player.rot + self.scatter + self.spread) * self.spd
		self.dy = math.sin(self.player.rot + self.scatter + self.spread) * self.spd
		self.rot = self.player.rot + self.scatter + self.spread

		init_laser(self)
		self.active = false
		if self.time_since_creation >= self.damge_tick then
			self.time_since_creation = 0
			self.active = true
		end

		shoot_gun(self.gun)
	end

	self.life = self.life - dt 
end

function bouncedir(self)
	for odx = 1,-1,-2 do
		for ody = 1,-1,-2 do
			--if (odx+ody==2) then
			self.x = self.x+(self.dx)*odx*4
			self.y = self.y+(self.dy)*ody*4
			if not(checkdeath(self)) then
				self.x = self.x-(self.dx)*odx*1 --change if bugs with laser bounce
				self.y = self.y-(self.dy)*ody*1 --change if bugs with laser bounce

				if not(odx+ody==-2 or odx+ody==2) then
					self.rot = -self.rot
				end

				return {odx=odx,ody=ody}
			end
			self.x = self.x-(self.dx)*odx*4
			self.y = self.y-(self.dy)*ody*4
			--end
		end
	end
	nwlength = 0
	return {odx=1,ody=1}
end

function draw_bullet(self)
	local spr = self.spr
	local sx = self.scale*self.sx
	local sy = self.scale*self.sy
	
	-- Muzzle flash
	if self.time_since_creation <= 1/30 and self.do_muzzle_flash then
		spr = spr_muzzle_flash
		sx, sy = 1, 1
	end
	draw_centered(spr, self.x, self.y, self.rot, sx, sy)
	
	--rect_color("line", floor(self.x-self.scale*6), floor(self.y-self.scale*6), floor(2*self.scale*6), floor(2*self.scale*6), {1,0,0})
	--love.graphics.pr int(self.scale,self.x+10,self.y+10)
end

function draw_laser(self)
	for i,v in ipairs(self.length) do

		if self.active then
			if checkdeath({x=v.x ,y=v.y,life = 10}) then
				local mapx, mapy = v.x / block_width, v.y / block_width
				if map:is_solid(mapx, mapy) then
				interact_map(self, map, mapx, mapy)
				end
			end
		end



		local scmax = (-(-self.maxlife/-2)^2)+(-self.maxlife/-2)*self.maxlife
		local scaleof = ((-(self.life^2)+self.life*self.maxlife)/scmax)
		if self.category == "persistent" then
			scaleof = 1
		end

		draw_line_spr(v.x1, v.y1, v.x, v.y, self.spr, self.scale*scaleof)
		circ_color("fill",v.x1,v.y1,self.scale*7*scaleof,white)
		circ_color("fill",v.x,v.y,self.scale*7*scaleof,white)

		--love.graphics.print(v.bounce, v.x, v.y-10)
	end
end

function interact_map(self, map, x, y)
	local tile = map:get_tile(x, y)
	if tile.is_destructible then
		map:set_tile(x, y, 1)
	end
end

function checkdeath(self)
	-- bullet
	if self.life <= 0 then
		self.remove = true
		return true
	end

	local mapx, mapy = self.x / block_width, self.y / block_width
	if map:is_solid(mapx, mapy) then
		self.remove = true
		return true
	end

	return false
end

function damage_everyone(self, k) -- problemes de remove des bullets avec index
	if self.type ==  "bullet" then
		if checkdeath(self) then 
			if self.life <= 0 then
				self:on_death(k)
				return
				--nb_delet = nb_delet+1
			end
			local mapx, mapy = self.x / block_width, self.y / block_width
			if map:is_solid(mapx, mapy) then
			interact_map(self, map, mapx, mapy)
			self:on_death(k)
			return
			--nb_delet = nb_delet+1
			end
		end
	elseif self.type == "laser" then
		if self.life <= 0 then
			self:on_death(k)
		return
		end
	end

	-- Collisions between enemies and bullets
	for i = #mobs , 1 , -1 do
		m = mobs[i]
		--rect_color("line", floor(self.x-self.w*8), floor(self.y-self.h*8), floor(2*self.w*8), floor(2*self.h*8), {1,0,0})
		if self.type ==  "bullet" then
			-- Bullet
			local coll = coll_rect(m.x, m.y, m.w*3, m.h*3, self.x, self.y, self.scale*3, self.scale*3)
			if not self.is_enemy and coll then

				m:damage(self.damage,self.dx,self.dy)
				m:knockback(self.dx, self.dy, self.knockback)
				self:on_death(k)

				if m.life<=0 then
					m:kill(mobs,i)
				end

				return
			end

		elseif self.type == "laser" then
			-- Laser
			for l,v in ipairs(self.length) do
				if self.active then
					local dist = dist_to_segment({x=m.x, y=m.y}, {x=v.x1, y=v.y1}, {x=v.x, y=v.y})
					if dist < self.scale*25 and not self.is_enemy then
						m:damage(self.damage,self.dx,self.dy)
						--table.remove(bullets, k)

						if m.life<=0 then
							m:kill(mobs,i)
						end

					end
				end
			end
		end
	end

	for pi = #player_list , 1 , -1 do
		p = player_list[pi]
		local coll = coll_rect(p.x, p.y, p.w*1.3, p.h*1.3, self.x, self.y, self.scale, self.scale)
		if self.type ==  "bullet" then
			if self.is_enemy and coll then

				p:damage(self.damage)
				self:on_death(k)
				return
			end
		elseif self.type == "laser" then
			for i,v in ipairs(self.length) do
				if self.active then
					local dist = dist_to_segment({x=p.x, y=p.y}, {x=v.x1, y=v.y1}, {x=v.x, y=v.y})
					if dist < self.scale*20 and self.is_enemy then

						p:damage(self.damage)
						--table.remove(bullets, k)

					end
				end
			end
		end
	end
end

function kill(self , k)
	table.remove(bullets, k)
end
