function load_image(name)
	local img = love.graphics.newImage("assets/textures/"..name..".png")
	img:setFilter("nearest", "nearest")
	return img 
end
function load_image_table(name, n, w, h)
	if not n then  error("number of images `n` not defined")  end
	local t = {}
	for i=1,n do 
		t[i] = load_image(name..tostr(i))
	end
	t.w = w
	t.h = h
	return t
end

spr_missing = load_image("missing")
spr_empty = load_image("empty")

-- UI
spr_cursor = load_image("cursor")
spr_hp_bar = load_image("hp_bar")
spr_ammo_bar = load_image("ammo_bar")
spr_hp_bar_empty = load_image("hp_bar_empty")
spr_heart = load_image("ui/heart_small_1")
spr_heart_empty = load_image("ui/heart_small_1_empty")
spr_ammo = load_image("ui/ammo_small_1")
spr_icon_heart = load_image("icon_heart")
spr_icon_ammo = load_image("icon_ammo")
sprs_icon_ply = load_image_table("ui/player_icons/p", 8)

spr_bar_small_ammo = load_image("ui/small_ammo_bar") 
spr_bar_small_life = load_image("ui/small_life_bar") 
spr_bar_small_empty = load_image("ui/small_empty_bar") 

-- Players
anim_pigeon_idle = {
	load_image("players/pigeon/pigeon_idle_1"),
}
anim_pigeon_walk = load_image_table("players/pigeon/pigeon_walk_", 10)
spr_pigeon_dead = load_image("players/pigeon/pigeon_dead")

anim_duck_walk = load_image_table("players/duck/duck_", 1)
spr_penguin = load_image("players/penguin/penguin_1")
spr_crow = load_image("players/crow_walk_1")
anim_duck_walk = load_image_table("players/duck/duck_walk_bad_",8)


-- Enemies
spr_fox = {
	load_image("fox_1")
}
spr_fox_hit = load_image("enemies/fox_1_hit")
spr_robot = load_image("enemies/robot/robot_1")

-- Pickups
spr_pick_ammo = load_image("pickups/ammo")
spr_pick_life = load_image("pickups/life")

-- Projectiles
spr_muzzle_flash = load_image("projectiles/muzzle_flash_1")
spr_bullet = load_image("projectiles/bullet_flat_1")
spr_bullet_pink = load_image("projectiles/bullet_flat_pink_1")
spr_bullet_red = load_image("projectiles/bullet_flat_red_1")
spr_laser = load_image("projectiles/laser")
spr_rocket = load_image("projectiles/rocket")
spr_paper_plane = load_image("projectiles/paper_plane")
spr_fire_extinguisher_smoke = load_image("projectiles/fire_extinguisher_smoke")

-- Guns
spr_revolver = load_image("guns/gun_revolver_small")
spr_shotgun = load_image("guns/shotgun")
spr_firework_launcher = load_image("guns/firework_launcher")
spr_fire_extinguisher = load_image("guns/fire_extinguisher")
spr_assault_rifle = load_image("guns/assault_rifle")
spr_paper_plane_gun = load_image("guns/paper_plane_gun")
spr_water_gun = load_image("guns/water_gun")

spr_revolver_big = load_image("guns/gun_revolver")
spr_firework_launcher_big = load_image("guns/firework_launcher_big")

-- Tiles
spr_ground_dum = load_image("dummy_ground")
spr_wall_1 = load_image("tiles/wall_1")
sprs_floor_wood = {
	load_image("tiles/floor_wood_1"),
	load_image("tiles/floor_wood_2"),
	load_image("tiles/floor_wood_3"),
	load_image("tiles/floor_wood_4"),
	w = 2, h = 2,
}
spr_ground_1 = load_image("tiles/floor_plain_1")
spr_ground_wood = load_image("tiles/floor_wood_single")
sprs_floor_wood_detail = load_image_table("scrapped/floor_wood_detail", 4, 2,2)
sprs_shelf = load_image_table("tiles/shelf2_", 4)
spr_door = load_image("tiles/door")
spr_pot_cactus = load_image("tiles/pot_cactus")
sprs_seat = load_image_table("tiles/seat_", 4)

--spr_wall_dum = load_image("scrapped/dummy_wall")
sprs_box = load_image_table("tiles/box_", 3)
sprs_floor_concrete = load_image_table("tiles/tile_concrete_", 5)

spr_chain = load_image("tiles/chain")
spr_floor_metal = load_image("tiles/floor_metal")

-- Misc
spr_shadow = load_image("misc/shadow")