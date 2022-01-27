
require "scripts/utility"
require "scripts/settings"
require "scripts/damage_zone_list"
require "scripts/damage_zone"

function make_gun(a)
	spr = a.spr or spr_revolver
	
	local gun = {
		name = a.name or "gun",
		type = a.type or "bullet",
		x = 0,
		y = 0,
		dir = 0,
		flip = 1,
		spr = a.spr or spr_revolver,
		bulletspr = a.bulletspr,
		--spr_bullet
		--spr_laser 
		--spr_rocket
		--spr_bullet
		damage 		  = a.damage		or 1,
		category	  = a.category		or "instant",
		bounce 		  = a.bounce		or 0,
		bullet_spd    = a.bullet_spd    or 600,
		offset_spd    = a.ospd	        or 0,
		cooldown      = a.cooldown      or 0.2,
		ammo	      = a.max_ammo      or 100,
		max_ammo      = a.max_ammo      or 100,
		scattering    = a.scattering    or .1,
		spawn_x	      = a.spawn_x	    or spr:getWidth(),
		spawn_y	      = a.spawn_y	    or 0,--spr:getHeight()/2,
		rafale	      = a.rafale	    or 1, --FIXME: burst pas rafale
		rafaledt      = a.rafaledt	    or .5, --FIXME: burst_spd ou jsp quoi
		bullet_life	  = a.bullet_life   or 2,	--bullet_life
		laser_length  = a.laser_length  or 100,
		nbshot 	      = a.nbshot	    or 1, --??????
		spread 	      = a.spread	    or pi/5, 
		spdslow	      = a.spdslow	    or 1,
		scale 		  = a.scale			or 0.5,
		oscale 		  = a.oscale        or 0,
		on_death 	  = a.on_death		or kill,

		charge				= a.charge 				or false,
		charge_curve		= a.charge_curve		or 2,
		charge_time 		= a.charge_time 		or 1,
		charge_nbrafale 	= a.charge_nbrafale 	or 0,
		charge_bullet_spd 	= a.charge_bullet_spd 	or 0,
		charge_laser_length = a.charge_laser_length or 0,
		charge_nbshot 		= a.charge_nbshot 		or 0,
		charge_spread 		= a.charge_spread 		or 0,
		charge_scattering	= a.charge_scattering 	or 0,
		charge_scale 		= a.charge_scale 		or 0,
		charge_oscale		= a.charge_oscale		or 0,
		charge_ospd 		= a.charge_ospd 		or 0,
		charge_life 		= a.charge_life 		or 0,
		charge_rafaledt		= a.charge_rafaledt 	or 0,
		charge_spdslow 		= a.charge_spdslow 		or 0,
		charge_damage		= a.charge_damage		or 0,

		cooldown_timer = 0,
		dt 			   = 0,
		vitesse_max	   = a.vitesse_max				or 600,

		make_shot = a.make_shot or default_shoot,

		update_option = a.update_option,
		
		screenkick = a.screenkick or 6,
		screenkick_shake = a.screenkick_shake or 1,
		screenshake = a.screenshake or 6,
		camera_offset = a.camera_offset or 0.3,

		ptc_type = a.ptc_type or "none", 
		ptc_size = a.ptc_size or 10,

		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
	}

	if gun.type == "laser" then  gun.bullet_spr = spr_laser  end 
	return gun
end

function update_gun(self, dt, p)
	self.rot = p.rot
	self.cooldown_timer = math.max(0, self.cooldown_timer - dt) 
	self.flip = -sgn( (p.rot + pi/2) % (pi*2) - pi)
	--if pi2*0.25 < p.rot and p.rot < pi2*0.75 then
	--	self.flip = -1
	--end
end

function draw_gun(self, p)
	local x = p.x + math.cos(p.rot) * p.gun_dist 
	local y = p.y + math.sin(p.rot) * p.gun_dist 
	draw_centered(p.gun.spr, x, y, p.rot, 1, p.gun.flip)

	--local x = p.x + math.cos(p.rot+pi) * p.gun_dist 
	--local y = p.y + math.sin(p.rot+pi) * p.gun_dist 
	--draw_centered(spr_firework_launcher_big, x, y, p.rot, 0.5, 0.5*p.gun.flip)
end

function shoot_gun(self)
	self.ammo = self.ammo - 1
	self.cooldown_timer = self.cooldown
end

function default_shoot(g,p)

	local shot = {}
		nbshot = g.nbshot-1
		for k=0,g.rafale-1 do
		if nbshot==0 then
			table.insert(shot,{gun=g,player=p,angle=p.rot,offset=0,time=k*g.rafaledt})
		else
			for i=0,nbshot do
				local o=((i/g.nbshot)-(g.nbshot/2/g.nbshot)+(1/g.nbshot/2))*g.spread
				table.insert(shot,{
					gun = g,
					player = p,
					angle = p.rot,
					offset = o,
					time = k*g.rafaledt
				})
			end
		end
	end
	return shot
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------- BULLET -------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function make_bullet(self, p, angle, spread, type, spr)
	--`p`: player or entity shooting
	local spread = spread or 0
	local offsetangle = math.atan2(-self.spawn_y,self.spawn_x)
	local dist = dist(self.spawn_x+p.x,self.spawn_y+p.y,p.x,p.y)
	local scatter = random_float(-self.scattering/2,self.scattering/2)
	local spd = (self.bullet_spd + random_pos_neg(self.offset_spd/2))
	local oscale = random_float(0, self.oscale)

	local bullet = {
		x = p.x + math.cos(angle + offsetangle * self.flip) * dist,
		y = p.y + math.sin(angle + offsetangle * self.flip) * dist,
		spr = spr,
		dx = math.cos(angle+scatter+spread) * spd,
		dy = math.sin(angle+scatter+spread) * spd,
		rot = angle+scatter+spread,

		spdslow = self.spdslow,
		life = self.bullet_life,
		maxlife = self.bullet_life,
		delete = false,
		category	  = self.category,
		type = self.type,
		gun = self,
		spr = self.bulletspr or spr_bullet,
		player = p,
		offsetangle = offsetangle,
		dist = dist,
		spd = spd,
		scatter = scatter,
		spread = spread,
		scale = self.scale + oscale,
		damage = self.damage,
		bounce =  self.bounce,
		maxbounce = self.bounce,
		length = {},
		on_death = self.on_death,

		is_enemy = p.is_enemy,

		vitesse_max = self.vitesse_max,
		ptc_timer = 0,

		update_option = self.update_option,

		w=0,--(self.scale + oscale ),
		h=0,--(self.scale + oscale ),
	}
	if self.type ==  "bullet" then
		bullet.draw = draw_bullet
		bullet.update = update_bullet

	elseif self.type ==  "laser" then
		bullet.draw = draw_laser
		bullet.update = update_laser
		bullet.laser_length = self.laser_length

		bullet.init = true
	end

	bullet.interact_map = interact_map

	return bullet
end

function init_laser(self)

	self.active = true
	ray = raycast(self.x,self.y,self.dx/self.spd,self.dy/self.spd,self.laser_length,3)
	table.insert(self.length , {length = ray.dist,x=ray.x ,y=ray.y,rot = self.rot,dx=self.dx/self.spd,dy=self.dy/self.spd,x1 = self.x,y1 = self.y,bounce = self.bounce})

	if self.bounce > 0 then
		prevray = ray
		prevray.dx = self.dx/self.spd
		prevray.dy = self.dy/self.spd
		prevray.rot = self.rot

		nwlength = self.laser_length-ray.dist

		while nwlength>0 and self.bounce>0 do
			self.bounce = self.bounce-1

			bobject = {x=prevray.x ,y=prevray.y ,dx=(prevray.dx) ,dy=(prevray.dy) ,h=0 ,w=0,life = 10,rot = prevray.rot}

			of = bouncedir(bobject)
			bobject.dx = bobject.dx*of.odx
			bobject.dy = bobject.dy*of.ody

			ray = raycast(bobject.x,bobject.y,bobject.dx,bobject.dy,nwlength,3)

			table.insert(self.length , {
				length = ray.dist,
				x = ray.x,
				y = ray.y, 
				rot = bobject.rot,
				dx = bobject.dx,
				dy = bobject.dy,
				x1 = bobject.x,
				y1 = bobject.y,
				bounce = self.bounce
			})

			nwlength = nwlength-ray.dist

			prevray = ray
			prevray.dx = bobject.dx
			prevray.dy = bobject.dy
			prevray.rot = bobject.rot
		end
	end
end

function update_bullet(self, dt , i)
	if (self.dx * self.spdslow)^2 + (self.dy * self.spdslow)^2 < self.vitesse_max^2 then
		self.dx = self.dx * self.spdslow
		self.dy = self.dy * self.spdslow
	end

	if self.update_option then self:update_option(dt) end

	self.life = self.life - dt
	self.life = self.life - dt
	
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt 
	
	self.rot = math.atan2(self.dy, self.dx)

	if self.bounce>0 then
		local coll = collide_object(self,1)
		if coll then
			self.bounce = self.bounce-1

			local x = self.x
			local y = self.y
			local h = 3
			local w = 3

			local mapx, mapy = self.x / block_width, self.y / block_width
			if map:is_solid(mapx, mapy) then
			interact_map(self, map, mapx, mapy)
			end

			interact_map(self,map,(x-w)/ block_width, (y-h)/ block_width)
			interact_map(self,map,(x+w)/ block_width, (y-h)/ block_width)
			interact_map(self,map,(x-w)/ block_width, (y+h)/ block_width)
			interact_map(self,map,(x+w)/ block_width, (y+h)/ block_width)

			interact_map(self,map,(x  )/ block_width, (y-h)/ block_width)
        	interact_map(self,map,(x-w)/ block_width, (y  )/ block_width)
       	 	interact_map(self,map,(x+w)/ block_width, (y  )/ block_width)
        	interact_map(self,map,(x  )/ block_width, (y+h)/ block_width)
		end
	end
	
	if checkdeath(self) then 
		if self.life <= 0 then
			self:on_death(i)
			nb_delet = nb_delet+1
		end
		local mapx, mapy = self.x / block_width, self.y / block_width
		if map:is_solid(mapx, mapy) then
		interact_map(self, map, mapx, mapy)
		self:on_death(i)
		nb_delet = nb_delet+1
		end
	end

	-- Particles
	if self.gun.ptc_type == "circle" and self.ptc_timer <= 0 then
		local x, y = random_polar(10)
		particles:make("circle", self.x + x, self.y + y, 10)
		self.ptc_timer = 1/30 --OPTI
	end
	self.ptc_timer = self.ptc_timer - dt
end

function update_laser(self, dt , i)
	self.active = false
	if self.init then
		self.init = false
		init_laser(self)
	end

	if self.category == "persistent" and button_down("fire") then
		self.bounce = self.maxbounce
		self.length = {}
		self.life = self.life + dt
		self.x = self.player.x + math.cos(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		self.y = self.player.y + math.sin(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		
		self.dx = math.cos(self.player.rot + self.scatter + self.spread) * self.spd
		self.dy = math.sin(self.player.rot + self.scatter + self.spread) * self.spd
		self.rot = self.player.rot + self.scatter + self.spread

		init_laser(self)

		shoot_gun(self.gun)
	end

	self.life = self.life - dt 

	if self.life < 0 then
		self:on_death(i)
	end
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
	draw_centered(self.spr, self.x, self.y, self.rot, self.scale, self.scale)
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
		draw_line_spr(v.x1, v.y1, v.x, v.y, self.spr, self.scale*((-(self.life^2)+self.life*self.maxlife)/scmax))

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
	
	-- Collisions between enemies and bullets
	for i,m in ipairs(mobs) do
		--rect_color("line", floor(self.x-self.w*8), floor(self.y-self.h*8), floor(2*self.w*8), floor(2*self.h*8), {1,0,0})
		if self.type ==  "bullet" then
			-- Bullet
			local coll = coll_rect(m.x, m.y, m.w*3, m.h*3, self.x, self.y, self.scale*3, self.scale*3)
			if not self.is_enemy and coll then
				m:damage(self.damage)
				self:on_death(k)

				if m.life<=0 then
					m:kill(mobs,i)
				end

				return
			end

		elseif self.type == "laser" then
			-- Laser
			for i,v in ipairs(self.length) do
				if self.active then
					local dist = dist_to_segment({x=m.x, y=m.y}, {x=v.x1, y=v.y1}, {x=v.x, y=v.y})
					if dist < self.scale*25 and not self.is_enemy then
						m:damage(self.damage)
						--table.remove(bullets, k)

						if m.life<=0 then
							m:kill(mobs,i)
						end

					end
				end
			end
		end
	end

	for _,p in ipairs(player_list) do
		local coll = coll_rect(p.x, p.y, p.w*3, p.h*3, self.x, self.y, self.scale*3, self.scale*3)
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
