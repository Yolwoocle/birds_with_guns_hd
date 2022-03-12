require "scripts.utility"
local mob_distribution_table = require "probability_tables/mob_distribution"

function make_mob(a)
	spr = spr_missing--a.spr or spr_missing
	local mob = {
		name = a.name or "enemy",
		state = "walk",

		anim_idle = a.anim_idle or {spr_missing},
		anim_walk = a.anim_walk or {spr_missing},--spr_fox,
		spr_hit = a.spr_hit or spr_fox_hit,
		hit_flash_timer = 0,
		
		life = a.life or 2,	
		is_enemy = true,

		spd 	= a.spd	or 10,
		x       = a.x	or 30,
		y       = a.y   or 30,
		w       = a.w   or 6,
		h       = a.h   or 6,
		dx      = a.dx  or 0,
		dy      = a.dy  or 0,
		rot = 0,
		dx_idle = 0,
		dy_idle = 0,
		dx_col = 0,
		dy_col = 0,
		friction 	 = a.friction   	or 0.95,
		bounce   	 = a.bounce     	or 0.6,
		mv_pause	 = a.mv_pause		or .25,
		mv_mouvement = a.mv_mouvement	or .5,
		closest_p 	 = a.closest_p 		or 50,
		far_p		 = a.far_p			or 60,
		shoot_dist	 = a.shoot_dist		or 60,
		see_dist 	 = a.see_dist or math.huge, --or 80,
		escape_aftershoot = a.escape_aftershoot or false,
		
		hit_w = a.hit_w or 12,
		hit_h = a.hit_h or 12,

		knockback = knockback_mob,
		knockback_x = 0,
		knockback_y = 0,

		gun_dist = a.gun_dist or 14,
		close_mv = a.close_mv or false,

		gun = a.gun or guns.fox_revolver,

		spawn = spawn_mob,
		shoot = shoot_gun,
		kill = a.kill_mob or kill_mob,
		damage = a.damage_mob or damage_mob,
		loot = loot_mob,

		update = update_mob,
		draw = draw_mob,
		gun = a.gun or guns.boum,
	}
	mob.spr = mob.anim_idle[1]

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

function damage_mob(self, dmg , dx,dy)
	self.life = self.life - dmg
	self.hit_flash_timer = 0.1
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
	for _,p in ipairs(players) do
		local nwd =  dist(p.x,p.y,self.x,self.y)
		if nwd < self.distplayer then
			self.distplayer = nwd
			self.player = p
		end
	end

	self.rot = math.atan2(self.player.y-self.y, self.player.x-self.x)

	-- Update gun
	self.gun:update(dt, self)

	self.looking_up = self.rot > pi

	self.dxplayer = math.cos(self.rot)
	self.dyplayer = math.sin(self.rot)

	-- Raycast to player 
	local rayc = {}
	if self.see_dist >= self.distplayer then
		rayc = raycast(self.x,self.y,
		self.dxplayer, self.dyplayer, self.distplayer, 3)
	else
		rayc.hit = false
	end

	local can_shoot = self.gun.cooldown_timer <= 0 or (not self.escape_aftershoot)
	if rayc.hit and can_shoot then --
		if self.distplayer > self.far_p then
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
			if self.escape_aftershoot then
				self.dtmouvement = self.mv_mouvement --+ self.mv_pause --
				local of = random_float(-pi/2, pi/2)
				self.dx_idle = -math.cos(self.rot+of)*self.spd
				self.dy_idle = -math.sin(self.rot+of)*self.spd
			end
		end

		if not(mv or self.close_mv) then
			self.dx = 0
			self.dy = 0
		end

	else
		self.dtmouvement = max(self.dtmouvement-dt,0)

		if self.dtmouvement > 0 and self.dtmouvement < self.mv_mouvement then
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

	-- Collision between enemies
	for i,m in ipairs(mobs) do
		if m~=self and dist(m.x,m.y,self.x,self.y) < 15 then
			local anglecol = math.atan2(m.y-self.y, m.x-self.x)
			self.dx = self.dx + -math.cos(anglecol)*100
			self.dy = self.dy + -math.sin(anglecol)*100
		end
	end

	-- Apply knockback
	self.dx = self.dx + self.knockback_x
	self.dy = self.dy + self.knockback_y
	self.knockback_x = self.knockback_x * 0.6 --FIXME: dt mob kb
	self.knockback_y = self.knockback_y * 0.6

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

	-- Sprite
	if self.state == "walk" then
		self.spr = self.anim_walk[1]
	end
	if self.hit_flash_timer > 0 then
		self.spr = self.spr_hit
	end
	self.hit_flash_timer = self.hit_flash_timer - dt
end

function draw_mob(self)
	draw_shadow(self)

	if     self.looking_up then self.gun:draw(self) end
	draw_centered(self.spr, self.x, self.y, 0, PIXEL_SCALE*self.gun.flip, PIXEL_SCALE)
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

function knockback_mob(self, x, y, val)
	local a = math.atan2(y,x)
	local kx, ky = math.cos(a), math.sin(a)
	self.knockback_x = self.knockback_x + kx * val
	self.knockback_y = self.knockback_y + ky * val
end

---

function spawn_random_mob(x,y)
	local mob_name = random_weighted(mob_distribution_table)
	local mob = mob_list[mob_name]	

	if mob then
		local instance =  mob:spawn(x,y)
		table.insert(mobs, instance)
		--print(instance.name, instance.rot)
	end
end