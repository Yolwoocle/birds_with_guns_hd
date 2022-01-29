require "scripts/mob"
require "scripts/gun_list"


mob_list = {
	fox = make_mob({
		name = "place_older",
		spr = spr_fox[1],
		life = 10,	
		spd = 50,
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
		shoot_dist = 150,
		see_dist = 310,

		closest_p = 100,
		far_p	  = 80,
	}),


	knight = make_mob({
		name = "knight",
		spr = spr_fox[1],
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
		shoot_dist = 1000,
		see_dist = 310,

		closest_p = 30,
		far_p	  = 30,
	}),

	shotgunboy = make_mob({
		name = "place_older",
		spr = spr_fox[1],
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
		shoot_dist = 100,
		see_dist = 310,

		closest_p = 70,
		far_p	  = 80,
	}),

	shotgunboy2 = make_mob({
		name = "place_older",
		spr = spr_fox[1],
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
			obj.gun = copy(guns.firework_explosion)
			--table.insert(_shot_, obj.gun:make_shot(obj))
			append_list(_shot, obj.gun:make_shot(obj))

			self:loot(pickups)
			table.remove(mobs, i)
		end,
	}),
}