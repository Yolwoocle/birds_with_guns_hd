
require "scripts/utility"
require "scripts/settings"

function make_gun(a)
	spr = a.spr or spr_revolver
	local type = a.type or "bullet"
	if type=="bullet" then
		local type_shoot = default_shoot
	elseif type=="laser" then
		local type_shoot = default_laser
	end

	local gun = {
		name          = a.name          or "null",
		type          = a.type          or "bullet",
		category	  = a.category		or "instant",
		spr 	      = a.spr           or spr_revolver,
		bullet_spd    = a.bullet_spd    or 600,
		offset_spd    = a.ospd	        or 0,
		cooldown      = a.cooldown      or 0.2,
		ammo	      = a.max_ammo      or 100,
		maxammo	      = a.max_ammo      or 100,
		scattering    = a.scattering    or 0,
		spawn_x	      = a.spawn_x	    or spr:getWidth(),
		spawn_y	      = a.spawn_y	    or spr:getHeight()/2,
		rafale	      = a.rafale	    or 1, --FIXME: burst pas rafale
		rafaledt      = a.rafaledt	    or .5, --FIXME: burst_spd ou jsp quoi
		life	      = a.life		    or 2,	--FIXME: bullet_life
		laser_length  = a.laser_length  or 100,
		nbshot 	      = a.nbshot	    or 1, --??????
		spread 	      = a.spread	    or pi/5, 
		spdslow	      = a.spdslow	    or 1, --FIXME: slowdown/speed_mult

		cooldown_timer = 0,

		make_shot = a.make_shot or type_shoot, 

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
	draw_centered(p.gun.spr, x, y, p.rot, 1.75, 1.75 * p.gun.flip)
end

function shoot_gun(self)
	self.ammo = self.ammo - 1
	self.cooldown_timer = self.cooldown
end

--default_shoot_bullet

function default_shoot(g,p)
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

--default_shoot_laser

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

--------------
--- BULLET ---
--------------

function make_bullet(self, p,angle,spread,type)
	local spread = spread or 0
	local offsetangle = math.atan2(-self.spawn_y,self.spawn_x)
	local dist = dist(self.spawn_x+p.x,self.spawn_y+p.y,p.x,p.y)
	local scatter = randomFloat(-self.scattering/2,self.scattering/2)
	local spd = (self.bullet_spd+math.random(self.offset_spd)-self.offset_spd/2)
	
	local bullet = {
		x = p.x + math.cos(angle + offsetangle * self.flip) * dist,
		y = p.y + math.sin(angle + offsetangle * self.flip) * dist,
		dx = math.cos(angle+scatter+spread) * spd,
		dy = math.sin(angle+scatter+spread) * spd,
		rot = angle+scatter+spread,
		spdslow = self.spdslow,
		life = self.life,
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
		
		self.dx = math.cos(self.player.rot+self.scatter+self.spread) * self.spd
		self.dy = math.sin(self.player.rot+self.scatter+self.spread) * self.spd
		self.rot = self.player.rot+self.scatter+self.spread

		shoot_gun(self.gun)
	end
	self.life = self.life - dt 

	local ray = raycast(self.x,self.y,self.dx/self.spd,self.dy/self.spd,self.laser_length,3)

	if self.life < 0 then
		self.delete = true
	end
	self.length = ray.dist
end

function draw_bullet(self)
	draw_centered(self.spr, self.x, self.y, 1, 2, 2)
	circ_color("fill", self.x, self.y, 3, {0, 1, 0})
end

function draw_laser(self)
	--if not(self.laser_spr==nil) then
	--for i,v in pairs(self.laser_spr) do
	--draw_centered(self.spr, v.x, v.y, self.rot+pi/2, 2, 2)
	----circ_color("fill", self.x, self.y, 3, {0, 1, 0})
	--end
	--end
	draw_centered(self.spr, self.x+(self.dx*(self.length/self.spd)*1.1)/2, self.y+(self.dy*(self.length/self.spd)*1.1)/2, self.rot+pi/2, 1, 2*(self.length/1.8186))
end

function checkdeath(self)
	if map:is_solid(self.x / block_width, self.y / block_width) then
		self.delete = true
		return true
	end
	if self.life < 0 then
		self.delete = true
		return true
	end
	return false
end