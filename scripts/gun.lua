
require "scripts/utility"

function make_gun(a)
	--name, spr, bullet_spd, cooldown, max_ammo, ofbuld,bofbula,mkbullet
	spr = a.spr or spr_revolver
	local gun = {
		              name = a.name       or "null",
		               spr = a.spr        or spr,
		        bullet_spd = a.bullet_spd or 80,
		          cooldown = a.cooldown   or 0.2,
		              ammo = a.max_ammo   or 100,
		           maxammo = a.max_ammo   or 100,
		         angle_var = a.angle_var  or 0,
		bullet_offset_dist = a.bullet_offset_dist or spr:getWidth(),
		
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
	self.flip = 1 -- -sgn( (p.rot + pi/2) % (pi*2) - pi)
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

function make_bullet(self, p)
	local bullet = {
		x = p.x + math.cos(p.rot + self.angle_var * self.flip) * self.bullet_offset_dist,
		y = p.y + math.sin(p.rot + self.angle_var * self.flip) * self.bullet_offset_dist,
		dx = math.cos(p.rot) * self.bullet_spd,
		dy = math.sin(p.rot) * self.bullet_spd,
		rot = p.rot,

		spr = spr_bullet,
		
		life = 2,
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