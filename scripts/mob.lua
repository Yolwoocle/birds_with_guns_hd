require "scripts/utility"

function make_mob(a)
	spr 	   = a.spr or spr_revolver
	local mob = {
		name           		= a.name       		or "null",
		spr 	       		= a.spr        		or spr_revolver,
		life	       		= a.life			or 2,	
		cooldown_timer 		= 0,		
		is_enemy = true,

		spd 	= a.spd	or 10,
		x       = a.x	or 30,
		y       = a.y   or 30,
		w       = a.w   or 6,
		h       = a.h   or 6,
		dx      = a.dx  or 0,
		dy      = a.dy  or 0,
		speed   = a.speed or 20,
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

		spawn = spawn_mob,
		shoot = shoot_gun,

		update = update_mob,
		draw = draw_mob,
	}

	mob.gun = guns.jsp

	return mob
end

function spawn_mob(self, x, y)

	local c = copy(self)
	c.gun = copy(c.gun)
	x = x or 0 
	y = y or 0
	c.dtmouvement = 0
	c.x = x
	c.y = y
	return c
end

function update_mob(self, dt)
	self.rot = math.atan2(player.y-self.y, player.x-self.x)

	self.gun:update(dt, self)

	self.looking_up = self.rot > pi

	self.dxplayer = math.cos(self.rot)
	self.dyplayer = math.sin(self.rot)
	self.distplayer = dist(player.x,player.y,self.x,self.y)

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

			self.dxidel = self.dx
			self.dyidel = self.dy

			mv = true
		elseif self.distplayer< self.closest_p then
			self.dx =  -self.dxplayer * self.spd
			self.dy =  -self.dyplayer * self.spd

			self.dxidel = self.dx
			self.dyidel = self.dy

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
			self.dx  = 0
			self.dy  = 0
		end

	else
		self.dtmouvement = max(self.dtmouvement-dt,0)

		if self.dtmouvement > 0 and self.dtmouvement <self.mv_mouvement then
			self.dx = self.dxidel
			self.dy = self.dyidel
		elseif self.dtmouvement == 0 then

			self.dtmouvement = self.mv_mouvement + self.mv_pause
			rndmouvement(self,self.spd)
		elseif self.dtmouvement >self.mv_mouvement then
			self.dx = 0
			self.dy	= 0
		end
	end

	if collide_object(self,1) then
		if not( sgn(self.dx) == sgn(self.dxidel)) then
			self.dxidel = -self.dxidel
		end
		if not( sgn(self.dy) == sgn(self.dyidel)) then
			self.dyidel = -self.dyidel
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
	
end

function rndmouvement(self,spd)
	local angle = random_pos_neg(pi2)
	self.dxidel = math.cos(angle)*spd
	self.dyidel = math.sin(angle)*spd
end
