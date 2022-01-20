require "scripts/mob"

mob_list = {
    Leo_renome = make_mob({
		name = "place_older",
		spr = spr_fox[1],
		life = 10,	
		cooldown_timer = 0,
		spd = 50,
		w = 4,
		h = 4,
		hit_x = 8,
		hit_y = 8,

		dx = 0,
		dy = 0,
		speed = 20,
		friction = 0.95,
		bounce = 0.6,
		mv_pause = 1,
		mv_mouvement = 3,
		gun_dist = 14,
		close_mv = false,
		shoot_dist = 80,
		see_dist = 110,

		closest_p = 0,
		far_p	  = 80,
    }),
}