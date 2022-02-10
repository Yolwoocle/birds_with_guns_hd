require "scripts/waves"
require "scripts/utility"

function make_game_main()
    local game = {
        init = init_game_main,
		update = udpate_game_main,
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


	number_of_players = 2

	player_list = {}
	for i =1,number_of_players do
		if i == 1 then --"keyboard+mouse" "keyboard" "joystick"
			controle = "keyboard"
			nbcontroller=1
			--nbcontroller = 1
		elseif i == 2 then
			controle = "keyboard"

		elseif i == 3 then 
			controle = "joystick"
			nbcontroller=1
			
		elseif i == 4 then 
			controle = "joystick"
			nbcontroller=2
		end

		birds_spr = {anim_pigeon_walk, anim_duck_walk,anim_pigeon_walk, anim_duck_walk,}
		local ply = init_player(i, 90+i*32, 200, birds_spr[i],controle,nbcontroller)
		table.insert(player_list, ply)
		player_list[i].anim_walk = birds_spr[i]
		player_list[i].anim_idle = birds_spr[i]
	end

	zones = {}
	mobs = {}
	pickups = make_pickups()
	
	map = init_map(600, 300)
	map:generate_map(love.math.random()*40000)

	bullets = {}
	_shot = {}
	
	particles = init_particles()

	perf = {}

	g = 0

	hud = make_hud()
	hud:make_bar("life_bar", 6,6, 10,10, spr_hp_bar, spr_hp_bar_empty, spr_icon_heart)
	hud:make_bar("ammo_bar", 6,26,nil,nil, spr_ammo_bar, spr_hp_bar_empty, spr_icon_ammo)
	hud:make_img("gun_1", 78,6, spr_missing)
	hud:make_img("gun_2", 78,6, spr_missing)
	hud:make_imgs("gun_list", 78,40, {spr_missing})
	spawn_location = {}
	
end

function udpate_game_main(self, dt)
	gf = 0
	
	local ox, oy = 0, 0
	for i,p in ipairs(player_list) do
		local o = p.gun.camera_offset or 0
		local cx = p.cu_x - p.x
		local cy = p.cu_y - p.y
		ox = ox + cx * o
		oy = oy + cy * o
	end
	ox = ox/#player_list
	oy = oy/#player_list
    camera.offset_x = ox
    camera.offset_y = oy
	
	camera:update(dt)
	--Set camera target
    local avg_pos = {x=0, y=0}
	for _,p in pairs(player_list)do
		avg_pos.x = avg_pos.x + p.x
		avg_pos.y = avg_pos.y + p.y
	end
	avg_pos.x = avg_pos.x / number_of_players
	avg_pos.y = avg_pos.y / number_of_players
	camera:set_target(avg_pos.x - window_w/2, avg_pos.y - window_h/2)

	map:update()
	pickups:update()
	update_waves(dt)

	--for i,z in ipairs(zones) do
	for i = #zones , 1 , -1 do
		z = zones[i]
		z:update(dt,i)
		damageinzone(z,i) 
	end

	--for i = #_shot_ , 1 , -1 do
	--	s = _shot_[i]
	--	append_list(_shot, s)
	--	table.remove(_shot_, i)
	--end

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
	for i = #bullets , 1 , -1 do
		b = bullets[i]
		b:update(dt,i)
		damage_everyone(b,i)
	end

	--for i,m in ipairs(mobs) do
	for i = #mobs , 1 , -1 do
		m = mobs[i]
		m:update(dt)
	end

	--for i,z in ipairs(zones) do
	for i = #zones , 1 , -1 do
		z = zones[i]
		z:update(dt,i)
		damageinzone(z,i) 
	end

	--for i,m in pairs(mobs) do
	--	if m.life<=0 then
	--		table.remove(mobs , i)
	--	end
	--end
	prevfire = false
	hud:update()

	particles:update(dt)

	--spawn_timer = spawn_timer - dt
	--if spawn_timer <= 0 then
	--	--table.insert(mobs, mob_list.fox:spawn(window_w/2, window_h/2))
	--	spawn_timer = 1
	--end
end

function draw_game_main(self)
    camera:draw()
	-- TODO: y-sorting
	map:draw()
	pickups:draw()
	draw_waves()

	for i,z in ipairs(zones) do
		z:draw()
	end
	for i,m in pairs(mobs) do
		if m.life<=0 then
			table.remove(mobs , i)
		end
	end
	
	particles:draw()
	for _,m in pairs(mobs) do
		m:draw()
		--draw_mob(m)
	end
	
	for i,m in ipairs(debug) do
		circ_color("fill", m.x, m.y, 3, {1,0,0})
	end

	for _,b in pairs(bullets) do
		b:draw()
	end 
	
	for _,p in ipairs(player_list) do
		p:draw()
	end

	--hud:draw()

	-- Debug
	debug_y = 0
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	debug_print(notification)
	--debug_print(joystick.x)
	--debug_print(joystick.joy:getGamepadAxis("triggerleft"))
	--debug_print(spawn_time)
	--debug_print(#_shot)
	--if prevray.dist then debug_print(prevray.dist,1,1) end
	--circ_color("fill", camera.x+window_w, camera.y+window_h, 1, {1,0,0})
	--map:debug_draw(camera.x+5, camera.y+30)
end