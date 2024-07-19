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
		-->  

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

	camera = make_camera()
	
	collision = make_collision_manager()
	map = init_map(600, 300)

	zones = {}
	mobs = {}
	interactables = {}

	for i = 0, 10 do
		--interactable_list.chest:spawn(100+32*i,MAIN_PATH_PIXEL_Y+100) --chest
	end 

	pickups = make_pickups() 
	
	bullets = {}
	_shot = {}
	
	particles = init_particles()
	
	prevfire = false
	perf = {}
	g = 0

	players = {}

	debug_mode = false
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

	mobs = {}
	pickups.table = {}

	map = init_map(600, 300)
	seed = love.math.random()*40000
	map:generate_map(seed)

	local x = 84
	local y = MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H/2
	pickups:spawn("modifier", math.random(1,3), x+64, y+32)

	for i,p in ipairs(players) do
		p.x = x + 32*(i-1)
		p.y = y
	end

end

function begin_game(self, nb_ply)
	local seed = love.math.random()*40000
	map:generate_map(seed)

	number_of_players = nb_ply or 1

	players = {}
	--TODO: move this to some player_list.lua file
	local removeme_bird_presets = {
		[1] = {
			spr_idle = spr_pigeon_idle,
			spr_jump = spr_pigeon_jump,
			spr_dead = spr_pigeon_dead,
		},
		[2] = {
			spr_idle = spr_duck_idle,
			spr_jump = spr_duck_jump,
			spr_dead = spr_duck_dead,
		},
		[3] = {
			spr_idle = spr_penguin,
			spr_jump = spr_penguin,
			spr_dead = spr_penguin,
		},
		[4] = {
			spr_idle = spr_crow,
			spr_jump = spr_crow,
			spr_dead = spr_crow,
		},
	}
	for i = 1,number_of_players do
		local x = 84+i*32
		local y = MAIN_PATH_PIXEL_Y+ROOM_PIXEL_H/2
		local ply = make_player(i, x, y, removeme_bird_presets[i])
		print("create", ply)

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
		local o = 0.2/number_of_players --p.gun.camera_offset or 0
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
	for _,p in pairs(players) do
		-- sCursor is *always* above everything else
		p:draw_cursor()
	end
	--hud:draw()

	-- Debug
	debug_y = 0
	if debug_mode then
		-- collision boxes
		local items, len = collision.world:getItems()
		for k,v in pairs(items) do
			local x,y,w,h = collision.world:getRect(v)
			rect_color("fill",x,y,w,h, {1,0,0, 0.5})
		end 
		--info
		debug_print("FPS. "..tostr(love.timer.getFPS()))
		debug_print(notification)
		if players[1] then debug_print(players[1].bounce_a) end
		debug_print('Memory used (in kB): ' .. collectgarbage('count'))
	end
end

function game_keypressed(self, key, scancode)
	if key == "f12" then
		debug_mode = not debug_mode
	elseif key == "m" then
		if love.keyboard.isDown("lctrl") then
			set_setting("sound_on", not get_setting("sound_on"))
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