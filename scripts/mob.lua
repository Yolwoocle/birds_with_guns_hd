require "scripts/utility"

function make_mob(a)
	spr 	   = a.spr or spr_revolver
	local mob = {
		name           		= a.name       		or "null",
		spr 	       		= a.spr        		or spr_revolver,
		life	       		= a.life			or 2,	
		cooldown_timer 		= 0,		

		spd 				= a.spd				or 10,
		x        			= a.x		   		or 30,
		y        			= a.y          		or 30,
		w        			= a.w          		or 6,
		h        			= a.h          		or 6,
		dx       			= a.dx         		or 0,
		dy       			= a.dy         		or 0,
		speed    			= a.speed      		or 20,
		friction 			= a.friction   		or 0.95,
		bounce   			= a.bounce     		or 0.6,
		mv_pause			= a.mv_pause		or .25,
		mv_mouvement		= a.mv_mouvement	or .5,
		closest_p 			= a.closest_p 		or 50,
		gun_dist 			= a.gun_dist 		or 14,

		spawn = spawn_mob,
		shoot = shoot_gun,

		update = update_mob,
		draw = draw_mob,
	}

	mob.gun = copy(guns.jsp)

	return mob
end

function spawn_mob(self, x, y)
	self.dtmovement = 0
	local c = copy(self)
	x = x or 0 
	y = y or 0
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

	local rayc = raycast(self.x, self.y,
self.dxplayer, self.dyplayer, self.distplayer, 3)

	if rayc.hit then
		-- If hit player
		if self.distplayer > self.closest_p then
			self.dx =  self.dxplayer * self.spd
			self.dy =  self.dyplayer * self.spd
			mv = true
		elseif self.distplayer < self.closest_p - 3 then
			self.dx =  -self.dxplayer * self.spd
			self.dy =  -self.dyplayer * self.spd
			mv = true
		else
			mv = false
		end

		if self.gun.cooldown_timer <= 0 then
			self.gun:shoot()
			self.gun.dt = 0
			append_list(_shot, self.gun:make_shot(self))
		end

	else
		self.dtmovement = max(self.dtmovement-dt, 0)

		if 0 < self.dtmovement and self.dtmovement < self.mv_mouvement then
			--self.x = self.x + self.dx * dt
			--self.y = self.y + self.dy * dt
			--collide_object(self, 1)
		elseif self.dtmovement == 0 then
			self.dtmovement = self.mv_mouvement + self.mv_pause
			rndmovement(self,self.spd)
		end
	end
	collide_object(self,.2)
	self.x = self.x + self.dx  * dt
	self.y = self.y + self.dy  * dt
end

function draw_mob(self)
	if     self.looking_up then self.gun:draw(self) end
	draw_centered(self.spr, self.x, self.y, 0, pixel_scale*self.gun.flip, pixel_scale)
	if not self.looking_up then self.gun:draw(self) end
	rect_color("line", floor(self.x-self.w), floor(self.y-self.h), floor(2*self.w), floor(2*self.h), {1,0,0})
end

function rndmovement(self,spd)
	local angle = random_pos_neg(pi2)
	self.dx = math.cos(angle)*spd
	self.dy = math.sin(angle)*spd
end