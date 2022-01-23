require "scripts/utility"

function make_mob(a)
	spr 	   = a.spr or spr_revolver
	local mob = {
		name           		= a.name       		or "enemy",
		spr 	       		= a.spr        		or spr_revolver,
		life	       		= a.life			or 2,	
		is_enemy = true,

		spd 	= a.spd	or 10,
		x       = a.x	or 30,
		y       = a.y   or 30,
		w       = a.w   or 6,
		h       = a.h   or 6,
		dx      = a.dx  or 0,
		dy      = a.dy  or 0,
		dx_idle = 0,
		dy_idle = 0,
		friction 	 = a.friction   	or 0.95,
		bounce   	 = a.bounce     	or 0.6,
		mv_pause	 = a.mv_pause		or .25,
		mv_mouvement = a.mv_mouvement	or .5,
		closest_p 	 = a.closest_p 		or 50,
		far_p		 = a.far_p			or 60,
		shoot_dist	 = a.shoot_dist		or 60,
		see_dist 	 = a.see_dist 		or 80,
		
		hit_w = a.hit_w or 12,
		hit_h = a.hit_h or 12,

		gun_dist 			= a.gun_dist 		or 14,
		close_mv			= a.close_mv		or false,

		gun = a.gun or guns.boum,

		spawn = spawn_mob,
		shoot = shoot_gun,
		kill = kill_mob,
		damage = damage_mob,
		loot = loot_mob,

		update = update_mob,
		draw = draw_mob,
		cooldown_timer = 0,
	}

	return mob
end

function spawn_mob(self, x, y)
	-- add randome pause et mouvement avec un offset 
	--self = mob_list.jspr
	local c = copy(self)
	c.gun = copy(c.gun)
	x = x or 0 
	y = y or 0
	c.dtmouvement = 0
	c.mv_pause = c.mv_pause+random_float(0,c.mv_pause)
	c.x = x
	c.y = y
	return c
end

function damage_mob(self, dmg)
	self.life = self.life - dmg
end

function kill_mob(self, mobs, i)
	self:loot(pickups)
	table.remove(mobs, i)
end

function loot_mob(self, pickups)
	pickups:spawn_random_loot(self.x, self.y)
end

function update_mob(self, dt)
	self.distplayer = inf
	for _,p in ipairs(player_list) do
		nwd =  dist(p.x,p.y,self.x,self.y)
		if nwd < self.distplayer then
			self.distplayer = nwd
			self.player = p
		end
	end

	self.rot = math.atan2(self.player.y-self.y, self.player.x-self.x)

	self.gun:update(dt, self)

	self.looking_up = self.rot > pi

	self.dxplayer = math.cos(self.rot)
	self.dyplayer = math.sin(self.rot)

	local rayc = {}

	if self.see_dist >= self.distplayer then
		rayc = raycast(self.x,self.y,
		self.dxplayer, self.dyplayer, self.distplayer,3)
	else
		rayc.hit = false
	end

	if rayc.hit then
		if self.distplayer> self.far_p then
			self.dx =  self.dxplayer * self.spd
			self.dy =  self.dyplayer * self.spd

			self.dx_idle = self.dx
			self.dy_idle = self.dy

			mv = true
		elseif self.distplayer< self.closest_p then
			self.dx =  -self.dxplayer * self.spd
			self.dy =  -self.dyplayer * self.spd

			self.dx_idle = self.dx
			self.dy_idle = self.dy

			mv = true
		else
			mv = false
		end

		if self.gun.cooldown_timer <= 0 and self.shoot_dist >= self.distplayer then
			self.gun:shoot()
			self.gun.dt = 0
			append_list(_shot, self.gun:make_shot(self))
		end

		if not(mv or self.close_mv) then
			self.dx = 0
			self.dy = 0
		end

	else
		self.dtmouvement = max(self.dtmouvement-dt,0)

		if self.dtmouvement > 0 and self.dtmouvement <self.mv_mouvement then
			self.dx = self.dx_idle
			self.dy = self.dy_idle
		elseif self.dtmouvement == 0 then

			self.dtmouvement = self.mv_mouvement + self.mv_pause
			rndmouvement(self,self.spd)
		elseif self.dtmouvement >self.mv_mouvement then
			self.dx = 0
			self.dy	= 0
		end
	end

	if collide_object(self,1) then
		if not( sgn(self.dx) == sgn(self.dx_idle)) then
			self.dx_idle = -self.dx_idle
		end
		if not( sgn(self.dy) == sgn(self.dy_idle)) then
			self.dy_idle = -self.dy_idle
		end
	end
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

function draw_mob(self)
	if     self.looking_up then self.gun:draw(self) end
	draw_centered(self.spr, self.x, self.y, 0, pixel_scale*self.gun.flip, pixel_scale)
	if not self.looking_up then self.gun:draw(self) end
	--rect_color("line", floor(self.x-self.w), floor(self.y-self.h), floor(2*self.w), floor(2*self.h), {1,0,0})
	--love.graphics.print(self.life,self.x,self.y)
	--love.graphics.print(self.gun.scale,self.x+10,self.y+10)
	--rect_color("line", floor(self.x-self.w*3), floor(self.y-self.h*3), floor(2*self.w*3), floor(2*self.h*3), {1,0,0})
	--rect_color("line", floor(self.x-self.w*8), floor(self.y-self.h*8), floor(2*self.w*8), floor(2*self.h*8), {1,0,0})

	if self.print then love.graphics.print(self.print,self.x,self.y) end
	love.graphics.print(self.life,self.x,self.y)
end

function rndmouvement(self,spd)
	local angle = random_float(0,pi2)
	self.dx_idle = math.cos(angle)*spd
	self.dy_idle = math.sin(angle)*spd
end
