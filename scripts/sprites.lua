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
spr_empty_16x16 = load_image("empty_16x16")

-- UI
spr_cursor = load_image("cursor")
sprs_cursor = load_image_table("ui/cursors/cursor_p", 4)
spr_hp_bar = load_image("hp_bar")
spr_ammo_bar = load_image("ammo_bar")
spr_hp_bar_empty = load_image("hp_bar_empty")
spr_heart = load_image("ui/heart_small_1")
spr_heart_empty = load_image("ui/heart_small_1_empty")
spr_ammo = load_image("ui/ammo_small_1")
spr_icon_heart = load_image("icon_heart")
spr_icon_ammo = load_image("icon_ammo")
sprs_icon_ply = load_image_table("ui/player_icons/p", 8)
sprs_white_bar = load_image_table("ui/white_bar_", 3)

spr_bar_small_ammo = load_image("ui/small_ammo_bar") 
spr_bar_small_life = load_image("ui/small_life_bar") 
spr_bar_small_empty = load_image("ui/small_empty_bar") 

spr_symb_walk = load_image("ui/symbol_walk")
spr_symb_aim = load_image("ui/symbol_aim")
spr_symb_shoot = load_image("ui/symbol_shoot")
spr_symb_switch_gun = load_image("ui/symbol_switch_gun")

-- Button prompts
sprs_buttons = {}
sprs_buttons.keyboard = {
	["a"] = load_image("ui/buttons/keyboard/a"),
	["b"] = load_image("ui/buttons/keyboard/b"),
	["c"] = load_image("ui/buttons/keyboard/c"),
	["d"] = load_image("ui/buttons/keyboard/d"),
	["e"] = load_image("ui/buttons/keyboard/e"),
	["f"] = load_image("ui/buttons/keyboard/f"),
	["g"] = load_image("ui/buttons/keyboard/g"),
	["h"] = load_image("ui/buttons/keyboard/h"),
	["i"] = load_image("ui/buttons/keyboard/i"),
	["j"] = load_image("ui/buttons/keyboard/j"),
	["k"] = load_image("ui/buttons/keyboard/k"),
	["l"] = load_image("ui/buttons/keyboard/l"),
	["m"] = load_image("ui/buttons/keyboard/m"),
	["n"] = load_image("ui/buttons/keyboard/n"),
	["o"] = load_image("ui/buttons/keyboard/o"),
	["p"] = load_image("ui/buttons/keyboard/p"),
	["q"] = load_image("ui/buttons/keyboard/q"),
	["r"] = load_image("ui/buttons/keyboard/r"),
	["s"] = load_image("ui/buttons/keyboard/s"),
	["t"] = load_image("ui/buttons/keyboard/t"),
	["u"] = load_image("ui/buttons/keyboard/u"),
	["v"] = load_image("ui/buttons/keyboard/v"),
	["w"] = load_image("ui/buttons/keyboard/w"),
	["x"] = load_image("ui/buttons/keyboard/x"),
	["y"] = load_image("ui/buttons/keyboard/y"),
	["z"] = load_image("ui/buttons/keyboard/z"),
	["0"] = load_image("ui/buttons/keyboard/0"),
	["1"] = load_image("ui/buttons/keyboard/1"),
	["2"] = load_image("ui/buttons/keyboard/2"),
	["3"] = load_image("ui/buttons/keyboard/3"),
	["4"] = load_image("ui/buttons/keyboard/4"),
	["5"] = load_image("ui/buttons/keyboard/5"),
	["6"] = load_image("ui/buttons/keyboard/6"),
	["7"] = load_image("ui/buttons/keyboard/7"),
	["8"] = load_image("ui/buttons/keyboard/8"),
	["9"] = load_image("ui/buttons/keyboard/9"),
	
	["space"] = load_image("ui/buttons/keyboard/space"),
	["!"] = load_image("ui/buttons/keyboard/exclamation"),
	["\""] = load_image("ui/buttons/keyboard/double_quote"),
	["#"] = load_image("ui/buttons/keyboard/hash"),
	["$"] = load_image("ui/buttons/keyboard/dollar"),
	["&"] = load_image("ui/buttons/keyboard/ampersand"),
	["'"] = load_image("ui/buttons/keyboard/apostrophe"),
	["("] = load_image("ui/buttons/keyboard/left_parenthesis"),
	[")"] = load_image("ui/buttons/keyboard/right_parenthesis"),
	["*"] = load_image("ui/buttons/keyboard/asterisk"),
	["+"] = load_image("ui/buttons/keyboard/plus"),
	[","] = load_image("ui/buttons/keyboard/comma"),
	["-"] = load_image("ui/buttons/keyboard/minus"),
	["."] = load_image("ui/buttons/keyboard/period"),
	["/"] = load_image("ui/buttons/keyboard/slash"),
	[":"] = load_image("ui/buttons/keyboard/colon"),
	[";"] = load_image("ui/buttons/keyboard/semicolon"),
	["<"] = load_image("ui/buttons/keyboard/left_angle_bracket"),
	["="] = load_image("ui/buttons/keyboard/equals"),
	[">"] = load_image("ui/buttons/keyboard/right_angle_bracket"),
	["?"] = load_image("ui/buttons/keyboard/question_mark"),
	["@"] = load_image("ui/buttons/keyboard/at"),
	["["] = load_image("ui/buttons/keyboard/left_bracket"),
	["]"] = load_image("ui/buttons/keyboard/right_bracket"),
	["\\"] = load_image("ui/buttons/keyboard/backslash"),
	["^"] = load_image("ui/buttons/keyboard/caret"),
	["_"] = load_image("ui/buttons/keyboard/underscore"),
	["`"] = load_image("ui/buttons/keyboard/backtick"),
	
	["f1"] = load_image("ui/buttons/keyboard/f1"),
	["f2"] = load_image("ui/buttons/keyboard/f2"),
	["f3"] = load_image("ui/buttons/keyboard/f3"),
	["f4"] = load_image("ui/buttons/keyboard/f4"),
	["f5"] = load_image("ui/buttons/keyboard/f5"),
	["f6"] = load_image("ui/buttons/keyboard/f6"),
	["f7"] = load_image("ui/buttons/keyboard/f7"),
	["f8"] = load_image("ui/buttons/keyboard/f8"),
	["f9"] = load_image("ui/buttons/keyboard/f9"),
	["f10"] = load_image("ui/buttons/keyboard/f10"),
	["f11"] = load_image("ui/buttons/keyboard/f11"),
	["f12"] = load_image("ui/buttons/keyboard/f12"),
	
	["return"] = load_image("ui/buttons/keyboard/return"),
	["escape"] = load_image("ui/buttons/keyboard/esc"),
	["backspace"] = load_image("ui/buttons/keyboard/backspace"),
	["tab"] = load_image("ui/buttons/keyboard/tab"),
	["capslock"] = load_image("ui/buttons/keyboard/capslock"),
	["lgui"] = load_image("ui/buttons/keyboard/win"),
	["rgui"] = load_image("ui/buttons/keyboard/win"),
	["lctrl"] = load_image("ui/buttons/keyboard/lctrl"),
	["rctrl"] = load_image("ui/buttons/keyboard/rctrl"),
	["lshift"] = load_image("ui/buttons/keyboard/lshift"),
	["rshift"] = load_image("ui/buttons/keyboard/rshift"),
	["lalt"] = load_image("ui/buttons/keyboard/lalt"),
	["ralt"] = load_image("ui/buttons/keyboard/ralt"),
	["return"] = load_image("ui/buttons/keyboard/return"),
	["delete"] = load_image("ui/buttons/keyboard/del"),
	["end"] = load_image("ui/buttons/keyboard/end"),
	
	["left"] = load_image("ui/buttons/keyboard/arrow_left"),
	["right"] = load_image("ui/buttons/keyboard/arrow_right"),
	["up"] = load_image("ui/buttons/keyboard/arrow_up"),
	["down"] = load_image("ui/buttons/keyboard/arrow_down"),
}
sprs_buttons.joystick = {}

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
spr_fox = load_image("fox_1")
anim_fox = {
	load_image("fox_1")
}
spr_fox_hit = load_image("enemies/fox_1_hit")

spr_robot = load_image("enemies/robot/robot_1")
spr_robot_hit = load_image("enemies/robot/robot_1_hit")

spr_cactus = load_image("enemies/cactus/cactus_1")

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

spr_bazooka = load_image("guns/bazooka") 
spr_boxing_glove = load_image("guns/boxing_glove") 
spr_flamethrower = load_image("guns/flamethrower") 
spr_minigun = load_image("guns/gatling_gun") 
spr_machinegun = load_image("guns/machinegun") 
spr_ring_cannon = load_image("guns/ring_cannon") 
spr_sniper = load_image("guns/sniper") 

-- Tiles
spr_wall_1 = load_image("tiles/wall_1")
spr_ground_wood = load_image("tiles/floor_wood_single")
sprs_floor_wood = load_image_table("tiles/floor_wood/floor_wood_1_", 5, 2,2)
sprs_floor_concrete = load_image_table("tiles/tile_concrete_", 5)
sprs_floor_carpet = load_image_table("tiles/carpet/tile_carpet_F_", 5)
spr_floor_carpet = load_image("tiles/carpet/tile_carpet_single")

sprs_shelf = load_image_table("tiles/shelf2_", 4)
spr_door = load_image("tiles/door_1")
spr_pot_cactus = load_image("tiles/pot_cactus")
sprs_seat = load_image_table("tiles/seat_", 4)

spr_chest = load_image("tiles/chest_1")
spr_end_of_level = load_image("end_of_level")

--spr_wall_dum = load_image("scrapped/dummy_wall")
sprs_box = load_image_table("tiles/box_", 3)

spr_chain = load_image("tiles/chain")
spr_floor_metal = load_image("tiles/floor_metal")

-- Misc
spr_shadow = load_image("misc/shadow")