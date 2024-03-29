require "scripts.mob"
require "scripts.gun_list"

mob_list = {
	fox = make_mob({
		name = "fox",
		anim_idle = {spr_fox},
		anim_walk = {spr_fox},
		spr_hit = spr_fox_hit,
		life = 4,	
		spd = 40,--50,
		w = 4,
		h = 4,
		hit_x = 8,
		hit_y = 8,
		gun = guns.fox_revolver,

		friction = 0.95,
		bounce = 0.6,
		mv_pause = 1,
		mv_mouvement = 3,
		gun_dist = 14,
		close_mv = false,
		shoot_dist = 200,
		see_dist = 300,

		closest_p = 0,
		far_p	  = 200,
	}),
	robot = make_mob{
		name = "robot",
		spr = spr_robot,
		spr_hit = spr_robot_hit,
		anim_walk = {spr_robot},
		life = 30,
		gun = guns.robot_shotgun,
	},
	cactus = make_mob{
		name = "cactus",
		spr_hit = spr_robot_hit,
		anim_walk = {spr_cactus},
		life = 20,
		gun = guns.cactus_machinegun,
		shoot_dist = 8*16,
		see_dist = 10000,
	},

	knight = make_mob({
		name = "knight",
		spr = spr_crow,
		life = 30,	
		spd = 10,
		w = 5,
		h = 4,
		hit_x = 13,
		hit_y = 13,
		gun = guns.knight_gun,

		friction = 0.95,
		bounce = 0.6,
		mv_pause = 1.5,
		mv_mouvement = 3,
		gun_dist = 14,
		close_mv = false,
		shoot_dist = 150,
		see_dist = 310,

		closest_p = 30,
		far_p	  = 30,
	}),

	shotgunboy = make_mob({
		name = "shotgunboy",
		spr_hit = spr_robot_hit,
		anim_walk = {spr_penguin},
		spr = spr_penguin,
		life = 10,	
		spd = 50,
		w = 4,
		h = 4,
		hit_x = 8,
		hit_y = 8,
		gun = guns.shotgunregular,

		friction = 0.95,
		bounce = 0.6,
		mv_pause = 1,
		mv_mouvement = 3,
		gun_dist = 14,
		close_mv = false,
		shoot_dist = 200,
		see_dist = 310,

		closest_p = 190,
		far_p	  = 200,
	}),

	shotgunboy2 = make_mob({
		name = "shotgunboy2",
		spr = spr_water_gun,
		life = 15,	
		spd = 50,
		w = 4,
		h = 4,
		hit_x = 8,
		hit_y = 8,
		gun = guns.shotgunregular2,

		friction = 0.95,
		bounce = 0.6,
		mv_pause = 1,
		mv_mouvement = 3,
		gun_dist = 14,
		close_mv = false,
		shoot_dist = 120,
		see_dist = 310,

		closest_p = 70,
		far_p	  = 80,
		kill_mob = function (self, mobs, i)

			obj = copy(self)
			obj.rot = math.atan2(self.dy,self.dx)
			obj.x = self.x
			obj.y = self.y
			obj.gun = copy(guns.death_explosion)
			--table.insert(_shot_, obj.gun:make_shot(obj))
			append_list(_shot, obj.gun:make_shot(obj))

			self:loot(pickups)
			table.remove(mobs, i)
		end,
	}),
}