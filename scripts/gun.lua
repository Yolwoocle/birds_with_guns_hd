
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
	draw_centered(p.gun.spr, x, y, p.rot, 1.75, 1.75 * p.gun.flip, pixel_scale)
end

function shoot_gun(self)
	self.ammo = self.ammo - 1
	self.cooldown_timer = self.cooldown
end

--default_shoot

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
	
	checkdeath(self)
end

function update_laser(self, dt)
	if self.category == "persistant" and button_down("fire") then
		self.life = self.life + dt
		self.x = self.player.x + math.cos(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		self.y = self.player.y + math.sin(self.player.rot + self.offsetangle * self.gun.flip) * self.dist
		
		self.dx = math.cos(self.player.rot + self.scatter + self.spread) * self.spd
		self.dy = math.sin(self.player.rot + self.scatter + self.spread) * self.spd
		self.rot = self.player.rot + self.scatter + self.spread

		shoot_gun(self.gun)
	end
	self.life = self.life - dt 

	local ray = raycast(self.x,self.y,self.dx/self.spd,self.dy/self.spd,self.laser_length,3)
	self.length = ray.dist
	if self.life < 0 then
		self.delete = true
	end
end

function draw_bullet(self)
	draw_centered(self.spr, self.x, self.y, 0, self.scale, self.scale)
	circ_color("fill", self.x, self.y, 3, {0, 1, 0})
	rect_color("line", self.x-self.w, self.y-self.h, 2*self.w, 2*self.h, {1,0,0})
end

function draw_laser(self)
	--if not(self.laser_spr==nil) then
	--for i,v in pairs(self.laser_spr) do
	--draw_centered(self.spr, v.x, v.y, self.rot+pi/2, 2, 2)
	----circ_color("fill", self.x, self.y, 3, {0, 1, 0})
	--end
	--end
	self.length = self.length or 0
	local x = self.x + (self.dx*(self.length/self.spd)*1.1)/2
	local y = self.y + (self.dy*(self.length/self.spd)*1.1)/2

	draw_centered(self.spr, x, y, self.rot + pi2*0.25, 1, 2*(self.length/1.8186))
end

function interact_map(self, map, x, y)
	local tile = map:get_tile(x, y)
	if tile.is_destructible then
		map:set_tile(x, y, 0)
	end
end

function checkdeath(self)
	-- bullet
	if self.life < 0 then
		self.delete = true
		return true
	end

	local mapx, mapy = self.x / block_width, self.y / block_width
	if map:is_solid(mapx, mapy) then

		self.delete = true
		interact_map(self, map, mapx, mapy)
		return true
	end

	if self.bounce then
		collide_object(self,1)
	end
	return false
end