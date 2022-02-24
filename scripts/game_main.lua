require "scripts/waves"
require "scripts/utility"

function make_game_main()
    local game = {
        init = init_game_main,
		update = update_game_main,
        draw = draw_game_main,
    } 
	game:init()
    return game
end

function init_game_main(self)
	spawn_time = inf
	nbwave = 0
	_shot_ = {}
	sp_mark = {}
	camera = init_camera()
	camera.lock_x = false
	camera.lock_y = false

	number_of_players = 1

	player_list = {}
	for i =1,number_of_players do
		if i == 1 then --"keyboard+mouse" "keyboard" "joystick"
			controle = "keyboard+mouse"
			nbcontroller = 1
		elseif i == 2 then
			controle = "keyboard"

		elseif i == 3 then 
			controle = "joystick"
			nbcontroller=1
			
		elseif i == 4 then 
			controle = "joystick"
			nbcontroller=2
		end

		birds_spr = {anim_pigeon_walk, anim_duck_walk, {spr_penguin}, anim_duck_walk,}
		local ply = init_player(i, 84, 90+i*16, birds_spr[i], controle, nbcontroller)
		table.insert(player_list, ply)
		player_list[i].anim_walk = birds_spr[i]
		player_list[i].anim_idle = birds_spr[i]
	end

	zones = {}
	mobs = {}
	pickups = make_pickups()
	
	map = init_map(600, 300)
	seed = love.math.random()*40000
	map:generate_map(seed)

	bullets = {}
	_shot = {}
	
	particles = init_particles()

	perf = {}

	g = 0

	hud = make_hud()
	hud:make_bar("life_bar", 6,6, 10,10, spr_hp_bar, spr_hp_bar_empty, spr_icon_heart)
	hud:make_bar("ammo_bar", 6,26, nil,nil, spr_ammo_bar, spr_hp_bar_empty, spr_icon_ammo)
	hud:make_img("gun_1", 78,6, spr_missing)
	hud:make_img("gun_2", 78,6, spr_missing)
	hud:make_imgs("gun_list", 78,40, {spr_missing})
	spawn_location = {}
end

local y_sort_buffer = {}

function update_game_main(self, dt)
	-- Compute camera offset
	local ox, oy = 0, 0
	for i,p in ipairs(player_list) do
		local o = p.gun.camera_offset or 0
		local cx = p.cu_x - p.x
		local cy = p.cu_y - p.y
		ox = ox + cx * o
		oy = oy + cy * o
	end
	ox = ox
	oy = oy
    camera.offset_x = ox
    camera.offset_y = oy
	
	--Set camera target
    local avg_pos = {x=0, y=0}
	for _,p in pairs(player_list) do
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
	for _,p in ipairs(player_list) do
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
		v = _shot[i]
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
	--for i,v in ipairs(toremove) do
	--	table.remove(_shot, v-i+1)
	--end
	nb_delet = 0
	--for i,b in ipairs(bullets) do
	for i = #bullets, 1, -1 do
		b = bullets[i]
		b:update(dt,i)
		damage_everyone(b,i)
	end

	--for i,m in ipairs(mobs) do
	for i = #mobs, 1, -1 do
		m = mobs[i]
		m:update(dt)
		if m.life<=0 then
			table.remove(mobs , i)
		end
	end

	--for i,z in ipairs(zones) do
	for i = #zones , 1 , -1 do
		z = zones[i]
		z:update(dt,i)
		damageinzone(z,i) 
	end

	prevfire = false
	hud:update()

	particles:update(dt)

	y_sort_buffer = y_sort_merge{pickups, mobs, bullets, player_list}
end

function draw_game_main(self)
    camera:draw()
	
	map:draw_with_y_sorted_objs(y_sort_buffer)
	pickups:draw()
	draw_waves()
	
	for i,z in ipairs(zones) do
		z:draw()
	end
	particles:draw()

	for _,p in pairs(player_list) do
		p:draw_hud()
	end
	--hud:draw()

	-- Debug
	debug_y = 0
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	debug_print(notification)
	debug_print("target_x"..tostr(camera.target_x))
	debug_print(debugg)
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