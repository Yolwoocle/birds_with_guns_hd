require "scripts/utility"
require "scripts/settings"
require "scripts/damage_zone_list"
require "scripts/damage_zone"
require "scripts/bullet"

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
		spr_bullet = a.spr_bullet or spr_bullet,
		--spr_bullet
		--spr_laser 
		--spr_rocket
		--spr_bullet
		damage 		  = a.damage		or 1,
		category	  = a.category		or "instant",
		bounce 		  = a.bounce		or 0,
		bullet_spd    = a.bullet_spd    or 600,
		offset_spd    = a.offset_spd	or 0,
		cooldown      = a.cooldown      or 0.2,
		ammo	      = a.max_ammo      or 100,
		max_ammo      = a.max_ammo      or 100,
		spawn_x	      = a.spawn_x	    or spr:getWidth(),
		spawn_y	      = a.spawn_y	    or 0,--spr:getHeight()/2,
		burst	      = a.burst	    or 1, 
		burstdt      = a.burstdt	    or .5, 
		bullet_life	  = a.bullet_life   or 2,	--bullet_life
		laser_length  = a.laser_length  or 100,
		nbshot 	      = a.nbshot	    or 1, --??????
		scattering    = a.scattering    or 0.3,
		spread 	      = a.spread	    or pi/5, 
		spdslow	      = a.spdslow	    or 1,
		
		scale 		  = a.scale			or 1,
		oscale 		  = a.oscale        or 0,
		on_death 	  = a.on_death		or kill,

		knockback = a.knockback or 300,

		charge				= a.charge 				or false,
		charge_curve		= a.charge_curve		or 2,
		charge_time 		= a.charge_time 		or 1,
		charge_nbburst 	= a.charge_nbburst 	or 0,
		charge_bullet_spd 	= a.charge_bullet_spd 	or 0,
		charge_laser_length = a.charge_laser_length or 0,
		charge_nbshot 		= a.charge_nbshot 		or 0,
		charge_spread 		= a.charge_spread 		or 0,
		charge_scattering	= a.charge_scattering 	or 0,
		charge_scale 		= a.charge_scale 		or 0,
		charge_oscale		= a.charge_oscale		or 0,
		charge_ospd 		= a.charge_ospd 		or 0,
		charge_life 		= a.charge_life 		or 0,
		charge_burstdt		= a.charge_burstdt 	or 0,
		charge_spdslow 		= a.charge_spdslow 		or 0,
		charge_damage		= a.charge_damage		or 0,

		cooldown_timer = 0,
		dt 			   = 0,
		speed_max	   = a.speed_max				or 600,

		make_shot = a.make_shot or default_shoot,

		update_option = a.update_option,
		
		screenkick = a.screenkick or 5,
		screenkick_shake = a.screenkick_shake or 1,
		screenshake = a.screenshake or 6,
		camera_offset = a.camera_offset or 0.3,

		ptc_type = a.ptc_type or "none",  
		ptc_size = a.ptc_size or 10,

		toshot = {},
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
		for k=0,g.burst-1 do
		if nbshot==0 then
			table.insert(shot,{gun=g,player=p,angle=p.rot,offset=0,time=k*g.burstdt})
		else
			for i=0,nbshot do
				local o=((i/g.nbshot)-(g.nbshot/2/g.nbshot)+(1/g.nbshot/2))*g.spread
				table.insert(shot,{
					gun = g,
					player = p,
					angle = p.rot,
					offset = o,
					time = k*g.burstdt
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
	--/!\ THIS IS A METHOD OF GUN /!\
	--`p`: player or entity shooting
	local spread = spread or 0
	local offsetangle = math.atan2(-self.spawn_y,self.spawn_x)
	local dist = dist(self.spawn_x+p.x,self.spawn_y+p.y,p.x,p.y)
	local scatter = random_float(-self.scattering/2,self.scattering/2)
	local spd = (self.bullet_spd + random_pos_neg(self.offset_spd/2))
	local oscale = random_float(0, self.oscale)

	local bullet = {
		category = self.category,
		x = p.x + math.cos(angle + offsetangle * self.flip) * dist,
		y = p.y + math.sin(angle + offsetangle * self.flip) * dist,
		spr = spr,
		dx = math.cos(angle+scatter+spread) * spd,
		dy = math.sin(angle+scatter+spread) * spd,
		sx = 1, 
		sy = 1,
		rot = angle+scatter+spread,
		delete = false,
		time_since_creation = 0,

		spdslow = self.spdslow,
		life = self.bullet_life,
		maxlife = self.bullet_life,
		
		type = self.type,
		spr = self.spr_bullet or spr_bullet,
		gun = self,

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
		knockback = self.knockback,

		is_enemy = p.is_enemy,

		speed_max = self.speed_max,
		ptc_timer = 0,

		update_option = self.update_option,

		w=1,--(self.scale + oscale ),
		h=1,--(self.scale + oscale ),
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

