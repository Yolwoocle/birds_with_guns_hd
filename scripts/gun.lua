
require "scripts/utility"
require "scripts/settings"

function make_gun(a)
	spr = a.spr or spr_revolver
	
	local gun = {
		name          = a.name          or "null",
		type          = a.type          or "bullet",
		damage 		  = a.damage		or 1,
		category	  = a.category		or "instant",
		bounce 		  = a.bounce		or false,
		spr 	      = a.spr           or spr_revolver,
		bullet_spd    = a.bullet_spd    or 600,
		offset_spd    = a.ospd	        or 0,
		cooldown      = a.cooldown      or 0.2,
		ammo	      = a.max_ammo      or 100,
		maxammo	      = a.max_ammo      or 100,
		scattering    = a.scattering    or .1,
		spawn_x	      = a.spawn_x	    or spr:getWidth(),
		spawn_y	      = a.spawn_y	    or spr:getHeight()/2,
		rafale	      = a.rafale	    or 1, --FIXME: burst pas rafale
		rafaledt      = a.rafaledt	    or .5, --FIXME: burst_spd ou jsp quoi
		bullet_life	  = a.nullet_life   or 2,	--bullet_life
		laser_length  = a.laser_length  or 100,
		nbshot 	      = a.nbshot	    or 1, --??????
		spread 	      = a.spread	    or pi/5, 
		spdslow	      = a.spdslow	    or 1, --FIXME: slowdown/speed_mult
		scale 		  = a.scale			or 2,

		charge				= a.charge 				or false,
		charge_time 		= a.charge_time 		or 1,
		charge_nbrafale 	= a.charge_nbrafale 	or 0,
		charge_bullet_spd 	= a.charge_bullet_spd 	or 0,
		charge_laser_length = a.charge_laser_length or 0,
		charge_nbshot 		= a.charge_nbshot 		or 0,
		charge_spread 		= a.charge_spread 		or 0,
		charge_scattering	= a.charge_scattering 	or 0,
		charge_scale 		= a.charge_scale 		or 0,
		charge_ospd 		= a.charge_ospd 		or 0,
		charge_life 		= a.charge_life 		or 0,
		charge_rafaledt		= a.charge_rafaledt 	or 0,
		charge_spdslow 		= a.charge_spdslow 		or 0,
		charge_damage		= a.charge_damage		or 0,

		cooldown_timer = 0,
		dt 			   = 0,

		make_shot = a.make_shot or default_shoot, 

		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
		--new = new_of_self, TODO: not have to rely on copy() function 
	}
	return gun
end

function update_gun(self, dt, p)
	self.cooldown_timer = math.max(0, self.cooldown_timer - dt) 
	self.flip = 1 -- -sgn( (p.rot + pi/2) % (pi*2) - pi)
	if pi2*0.25 < p.rot and p.rot < pi2*0.75 then
		self.flip = -1
	end
end

function draw_gun(self, p)
	local x = p.x + math.cos(p.rot) * p.gun_dist 
	local y = p.y + math.sin(p.rot) * p.gun_dist 
	draw_centered(p.gun.spr, x, y, p.rot, 1, p.gun.flip)
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

--default_shoot_laser
--[[
function default_laser(g,p)
	local shot = {}
	  nbshot = g.nbshot-1
	  for k=0,g.rafale-1 do
		if nbshot==0 then
			table.insert(shot,{gun=g,player=p,angle=p.rot,offset=0,time=k*g.rafaledt})
		else
			for i=0,nbshot do
				local o=((i/g.nbshot)-(g.nbshot/2/g.nbshot))*g.spread
				table.insert(shot,{gun=g,player=p,angle=p.rot,offset=o,time=k*g.rafaledt})
			end
		end
	end
	return shot
end
--]]

--------------
--- BULLET ---
--------------

function make_bullet(self, p,angle,spread,type)
	local spread = spread or 0
	local offsetangle = math.atan2(-self.spawn_y,self.spawn_x)
	local dist = dist(self.spawn_x+p.x,self.spawn_y+p.y,p.x,p.y)
	local scatter = random_float(-self.scattering/2,self.scattering/2)
	local spd = (self.bullet_spd + random_pos_neg(self.offset_spd/2))

	local bullet = {
		x = p.x + math.cos(angle + offsetangle * self.flip) * dist,
		y = p.y + math.sin(angle + offsetangle * self.flip) * dist,
		dx = math.cos(angle+scatter+spread) * spd,
		dy = math.sin(angle+scatter+spread) * spd,
		rot = angle+scatter+spread,
		spdslow = self.spdslow,
		life = self.bullet_life,
		delete = false,
		category	  = self.category,
		type = self.type,
		gun = self,

		player = p,
		offsetangle = offsetangle,
		dist = dist,
		spd = spd,
		scatter = scatter,
		spread = spread,
		scale = self.scale,
		damage		= self.damage,
		bounce   =  self.bounce,
		length = {},

		w=self.scale*4,
		h=self.scale*4,
	}
	if self.type ==  "bullet" then
		bullet.draw = draw_bullet
		bullet.update = update_bullet
		bullet.spr = spr_bullet
	elseif self.type ==  "laser" then
		bullet.draw = draw_laser
		bullet.update = update_laser
		bullet.laser_length = self.laser_length
		bullet.spr = spr_laser
	end

	bullet.interact_map = interact_map

	return bullet
end

function update_bullet(self, dt)
	self.dx = self.dx * self.spdslow
	self.dy = self.dy * self.spdslow
	self.life = self.life - dt
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt 
	
	if self.bounce then
		local coll = collide_object(self,1)
		if coll then
			local x = self.x
			local y = self.y
			local h = self.h*3.5
			local w = self.w*3.5
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
	checkdeath(self)
end

function update_laser(self, dt)
	if self.category == "persistent" and button_down("fire") then
		self.life = self.life + dt
		self.x = self.player.x + math.cos(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		self.y = self.player.y + math.sin(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		
		self.dx = math.cos(self.player.rot + self.scatter + self.spread) * self.spd
		self.dy = math.sin(self.player.rot + self.scatter + self.spread) * self.spd
		self.rot = self.player.rot + self.scatter + self.spread

		shoot_gun(self.gun)
	end
	self.life = self.life - dt 

	ray = raycast(self.x,self.y,self.dx/self.spd,self.dy/self.spd,self.laser_length,3)
	table.insert(self.length , {length = ray.dist,x=ray.x ,y=ray.y,rot = self.rot,dx=self.dx/self.spd,dy=self.dy/self.spd,x1 = self.x,y1 = self.y})
	--table.insert(debug , {x=ray.x,y=ray.y})

	if self.bounce then

		prevray = ray
		prevray.dx = self.dx/self.spd
		prevray.dy = self.dy/self.spd
		prevray.rot = self.rot
		_continue = true

		nwlength = self.laser_length-ray.dist

		while nwlength>0 do
		--table.insert(debug , {x=prevray.x,y=prevray.y})
		bobject = {x=prevray.x ,y=prevray.y ,dx=(prevray.dx) ,dy=(prevray.dy) ,h=0 ,w=0,life = 10,rot = prevray.rot}
		--table.insert(debug , bobject)
		of = bouncedir(bobject)
		bobject.dx = bobject.dx*of.odx
		bobject.dy = bobject.dy*of.ody
		--table.insert(debug , {x=bobject.x+bobject.dx*30,y=bobject.y+bobject.dy*30})
		ray = raycast(bobject.x,bobject.y,bobject.dx,bobject.dy,nwlength,3)

		table.insert(self.length , {length = ray.dist,x= ray.x,
		y= ray.y , rot =  bobject.rot ,dx=bobject.dx,dy=bobject.dy,x1 = bobject.x ,y1 = bobject.y})

		nwlength = nwlength-ray.dist

		--if not(ray.hit) then _continue = false end

		prevray = ray
		prevray.dx = bobject.dx
		prevray.dy = bobject.dy
		prevray.rot = bobject.rot

		end
	end
		----table.insert(debug , bobject)
		--if collide_object(bobject) then
		--	table.insert(debug , bobject)
		--	table.insert(debug , {x=bobject.x+bobject.dx*-30,y=bobject.y+bobject.dy*30})
		----collide_object(bobject)
		--qd = szqd
		--ray = raycast(bobject.x,bobject.y,bobject.dx,bobject.dy,self.laser_length-ray.dist,3)

		--table.insert(self.length , {length = ray.dist,x=bobject.x,y=bobject.y,rot = self.rot,dx=bobject.dx,dy=bobject.dy})---ray.dist*bobject.dx*.5
		--end
		--local distravelled = ray.dist
		--while self.laser_length-distravelled > 1 do
		--	local endprevlaserx = ray.x
		--	local endprevlasery = ray.y
		--	local endprevlaserrot = ray.rot
		--	local endprevlaserdx = ray.dx
		--	local endprevlaserdy = ray.dy
		--	ray = raycast(endprevlaserx-ray.dx*.1,endprevlasery-ray.dy*.1,endprevlaserdx/self.spd,endprevlaserdy/self.spd,self.laser_length-distravelled,3)
		--	ray.rot = self.rot
		--	ray.dx = self.dx
		--	ray.dy = self.dy
		--	table.insert(self.length , {length = ray.dist,x=endprevlaserx,y=endprevlasery,rot = -endprevlaserrot,dx=-endprevlaserdx,dy=-endprevlaserdy})
		--	distravelled = distravelled+ray.dist
		--end
	--end

	if self.life < 0 then
		self.delete = true
	end
end

function bouncedir(self)
	for odx = 1,-1,-2 do
		for ody = 1,-1,-2 do
			--if not(odx+ody==2) then
			self.x = self.x+(self.dx)*odx*4
			self.y = self.y+(self.dy)*ody*4
			--table.insert(debug , {x=self.x,y=self.y})
			if not(checkdeath(self)) then
				self.x = self.x-(self.dx)*odx*3.85
				self.y = self.y-(self.dy)*ody*3.85

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
	return false
end

function draw_bullet(self)
	draw_centered(self.spr, self.x, self.y, 0, self.scale, self.scale)
	--circ_color("fill", self.x, self.y, 3, {0, 1, 0})
	--rect_color("line", self.x-self.w, self.y-self.h, 2*self.w, 2*self.h, {1,0,0})
end

function draw_laser(self)
	--if not(self.laser_spr==nil) then
	--for i,v in pairs(self.laser_spr) do
	--draw_centered(self.spr, v.x, v.y, self.rot+pi/2, 2, 2)
	----circ_color("fill", self.x, self.y, 3, {0, 1, 0})
	--end
	--end
	--self.length = self.length or 0
	--for i,v in ipairs(self.length) do
	--	local x = v.x + (v.dx*(v.length/self.spd))/2
	--	local y = v.y + (v.dy*(v.length/self.spd))/2
--
	--	love.graphics.draw(self.spr, x, y, v.rot + pi2*0.25, 1, 2*(v.length/2))
	--end
	for i,v in ipairs(self.length) do
		--love.graphics.draw(self.spr, v.x , v.y, v.rot + pi2*0.25, 1*self.scale, v.length,spr:getWidth()/2.3)
		--love.graphics.line( v.x1, v.y1, v.x, v.y)
		draw_line_spr(v.x1,v.y1,v.x,v.y,self.spr,self.scale)
	end
end

function interact_map(self, map, x, y)
	local tile = map:get_tile(x, y)
	if tile.is_destructible then
		map:set_tile(x, y, 0)
	end
end

function checkdeath(self)
	-- bullet
	if self.life <= 0 then
		self.delete = true
		return true
	end

	local mapx, mapy = self.x / block_width, self.y / block_width
	if map:is_solid(mapx, mapy) then
		self.delete = true
		interact_map(self, map, mapx, mapy)
		return true
	end

	return false
end