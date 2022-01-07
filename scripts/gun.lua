
require "scripts/utility"

function make_gun(a)

	spr = a.spr or spr_revolver
	local gun = {

		name       = a.name       or "null",
		spr 	   = a.spr        or spr,
		bullet_spd = a.bullet_spd or 80,
		cooldown   = a.cooldown   or 0.2,
		ammo       = a.max_ammo   or 100,
		maxammo    = a.max_ammo   or 100,
		scattering = a.scattering or 0,
		spawn_x    = a.spawn_x    or spr:getWidth(),
		spawn_y    = a.spawn_y    or spr:getHeight(),
		rafale     = a.rafale	  or 1,
        rafaledt   = a.rafaledt	  or .5,
		life	   = a.life		  or 2,	
		nbshot 	   = a.nbshot	  or 1,
        spred 	   = a.spred	  or pi/5,

		cooldown_timer = 0,

		make_bullet = a.make_bullet,
		shoot = shoot_gun,
		update = update_gun,
		draw = draw_gun,
	}
	return gun
end

function update_gun(self, dt, p)
	self.cooldown_timer = math.max(0, self.cooldown_timer - dt) 
	self.flip = -sgn( (p.rot + pi/2) % (pi*2) - pi)
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

--------------
--- BULLET ---
--------------

function make_bullet(self, p,angle,_spred)
	local spred = _spred or 0
	local offsetangle = math.atan2(-self.spawn_y,self.spawn_x)
	local dist = dist(self.spawn_x+p.x,self.spawn_y+p.y,p.x,p.y)
	local scatter = randomFloat(-self.scattering/2,self.scattering/2)
	local bullet = {

		x = p.x + math.cos(angle + offsetangle * self.flip) * dist,
		y = p.y + math.sin(angle + offsetangle * self.flip) * dist,

		dx = math.cos(angle+scatter+spred) * self.bullet_spd,
		dy = math.sin(angle+scatter+spred) * self.bullet_spd,
		rot = angle,

		spr = spr_bullet,
		
		life = self.life,
		delete = false,
		update = update_bullet,
		draw = draw_bullet,
	}
	return bullet
end

function update_bullet(self, dt)
	self.life = self.life - dt
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt 

	if self.life < 0 then
		self.delete = true
	end
end

function draw_bullet(self)
	draw_centered(self.spr, self.x, self.y, 1, 2, 2)
	circ_color("fill", self.x, self.y, 3, {0, 1, 0})
end