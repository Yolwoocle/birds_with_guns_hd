require "scripts.waves"
require "scripts.utility"
local CameraManager = require "scripts/camera_manager"

function make_game()
    local game = {
        init = init_game,
		begin = begin_game,
		-- PLEASE REMOVE, TEMPORARY :
		begin_1p = begin_game_1p,
		begin_2p_mouse = begin_game_2p_mouse,
		begin_2p_kb = begin_game_2p_kb,
		begin_3p = begin_game_3p,
		begin_4p = begin_game_4p,
		------

		update = update_game,
        draw = draw_game,
		keypressed = game_keypressed,
		focus = game_focus,
		create_new_level = game_create_new_level,
    } 
	game:init()
    return game
end

function init_game(self)
	spawn_time = inf
	nbwave = 0
	_shot_ = {}
	sp_mark = {}

	camera = init_camera()
	camera:set_target(0, MAIN_PATH_PIXEL_Y)
	camera.lock_x = true
	camera.lock_y = true
	camera.fake_y = MAIN_PATH_PIXEL_Y 
	
	map = init_map(600, 300)

	zones = {}
	mobs = {}
	interactables = {}

	for i = 0,10 do
	interactable_liste.end_of_level:spawn(100+32*i,MAIN_PATH_PIXEL_Y+100) --chest
	end

	pickups = make_pickups()

	bullets = {}
	_shot = {}
	
	particles = init_particles()
	
	prevfire = false
	perf = {}
	g = 0

	players = {}
end

function begin_game_1p(self)
	self:begin(1)
	input:init_users_1p()
end
function begin_game_2p_kb(self)
	self:begin(2)
	input:init_users_2p_kb()
end
function begin_game_2p_mouse(self)
	self:begin(2)
	input:init_users_2p_mouse()
end

function game_create_new_level(self)
	
	map = init_map(600, 300)
	map:generate_map(seed)

	--mobs = {}
	--pickups = {}

	--map = init_map(600, 300)
	--seed = love.math.random()*40000
	--map:generate_map(seed)

	--local x = 84
	--local y = MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H/2
--
	--for i,p in ipairs(players) do
	--	p.x = x + 32*(i-1)
	--	p.y = y
	--end

end

function begin_game(self, nb_ply)
	seed = love.math.random()*40000
	map:generate_map(seed)

	number_of_players = nb_ply or 1

	players = {}
	for i = 1,number_of_players do
		local nbcontroller = 1
		
		birds_spr = {anim_pigeon_walk, anim_duck_walk, {spr_penguin}, anim_duck_walk,}
		
		local x = 84+i*32
		local y = MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H/2
		local ply = init_player(i, x, y, birds_spr[i])
		ply.anim_walk = birds_spr[i]
		ply.anim_idle = birds_spr[i]
		
		table.insert(players, ply)
	end
--	camera_manager = CameraManager:new(camera, players)

	hud = make_hud()
	hud:make_bar("life_bar", 6,6, 10,10, spr_hp_bar, spr_hp_bar_empty, spr_icon_heart)
	hud:make_bar("ammo_bar", 6,26, nil,nil, spr_ammo_bar, spr_hp_bar_empty, spr_icon_ammo)
	hud:make_img("gun_1", 78,6, spr_missing)
	hud:make_img("gun_2", 78,6, spr_missing)
	hud:make_imgs("gun_list", 78,40, {spr_missing})--]]
	spawn_location = {}
end

local y_sort_buffer = {}

function update_game(self, dt)
	--debugg Zone

	--make_interactable({})

	-- Compute camera offset (e.g. from aiming)
	local ox, oy = 0, 0
	for i,p in ipairs(players) do
		local o = 0.1--p.gun.camera_offset or 0
		local cx = p.cu_x - p.x
		local cy = p.cu_y - p.y
		ox = ox + cx * o
		oy = oy + cy * o
	end
	camera:set_offset(ox, oy)
	
	--Set camera target
    local avg_pos = {x=0, y=0}
	for _,p in pairs(players) do
		avg_pos.x = avg_pos.x + p.x
		avg_pos.y = avg_pos.y + p.y
	end
	avg_pos.x = avg_pos.x / number_of_players
	avg_pos.y = avg_pos.y / number_of_players
	camera:set_target(avg_pos.x - window_w/2, avg_pos.y - window_h/2)
	camera:update(dt)

	map:update()
	pickups:update()
	--update_waves(dt)

	for i = #zones , 1 , -1 do
		z = zones[i]
		z:update(dt,i)
		damageinzone(z,i) 
	end

	local number_alive_players = 0
	for _,p in ipairs(players) do
		p:update(dt, camera)
		if p.shoot then
			--_shot = player.gun:make_bullet(player,player.rot)
			local bullet = p.gun:make_shot(p)
			if bullet then
				append_list(_shot, bullet)
			end
		end

		if p.alive then
			number_alive_players = number_alive_players + 1
		end
	end
	if number_alive_players == 0 then
		notification = "Game over lololololol"
	end

	for i = #_shot , 1 , -1 do
		local v = _shot[i]
		-- Summon shots
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.player.rot,v.offset,nil,v.spr))
			--table.insert(toremove , i)
			if not v.player.is_enemy then
				camera:kick(v.player.rot + pi, v.gun.screenkick)
			end
			table.remove(_shot, i)
		else
			v.time=v.time-dt
		end
	end
	for i = #bullets, 1, -1 do
		local b = bullets[i]
		b:update(dt,i)
		damage_everyone(b,i)
	end

	for i = #mobs, 1, -1 do
		local m = mobs[i]
		m:update(dt)
		if m.life<=0 and camera:within_mob_loading_zone(m) then
			table.remove(mobs , i)
		end
	end

	--for i,z in ipairs(zones) do
	--"zone" means "damage zone"
	for i = #zones , 1 , -1 do
		z = zones[i]
		z:update(dt,i)
		damageinzone(z,i) 
	end

	for i = #interactables , 1 , -1 do
		int = interactables[i]
		int:update(dt,i)
	end

	prevfire = false
	hud:update()

	particles:update(dt)

	y_sort_buffer = y_sort_merge{pickups, mobs, bullets, players, interactables}
end

function draw_game(self)
    camera:draw()

	--for i,int in ipairs(interactables) do
	--	int:draw()
	--end
	
	map:draw_with_y_sorted_objs(y_sort_buffer)
	pickups:draw()

	draw_waves()
	
	for i,z in ipairs(zones) do
		z:draw()
	end
	particles:draw()

	for _,p in pairs(players) do
		p:draw_hud()
	end
	--hud:draw()

	-- Debug
	debug_y = 0
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	debug_print(notification)
	debug_print(debugg)
end

function game_keypressed(self, key, scancode)
	if key == "m" then
		if love.keyboard.isDown("lctrl") then
			set_setting("sound_on", not get_setting(sound_on))
			notification = "Sound on: "..tostring(settings.sound_on)
		end
	end
end
function game_focus(self, focus)
	if focus then

	else
		menu_manager:pause()
	end
end

function y_sort_merge(all_objs)
	-- Concatenate all tables
	local t = {}
	for _,objs in pairs(all_objs) do
		for i=1, #objs do
			local o = objs[i]
			table.insert(t, o)
		end
	end 

	-- Sort the table 
	table.sort(t, function(a,b) return a.y < b.y end)
	return t
end

function y_sort_draw(map, objs)
end