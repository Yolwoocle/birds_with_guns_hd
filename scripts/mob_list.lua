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
		shoot_dist = 80,
		see_dist = 310,

		closest_p = 70,
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
}