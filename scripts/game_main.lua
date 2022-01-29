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


	nb_joueurs = 4

	player_list = {}
	for i =1,nb_joueurs do
		if i == 1 then --"keyboard+mouse" "keyboard" "joystick"
			--controle = "keyboard+mouse"
			--controle = "keyboard"

			--controle = "keyboard+mouse"
			controle = "keyboard+mouse"
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

		birds_spr = {anim_pigeon_walk, anim_duck_walk,anim_pigeon_walk, anim_duck_walk,}--TODO: fix
		local ply = init_player(i, 90+i*32, 90, birds_spr[i],controle,nbcontroller)
		table.insert(player_list, ply)
		player_list[i].anim_walk = birds_spr[i]
		player_list[i].anim_idle = birds_spr[i]
	end

	zones = {}
	mobs = {}
	pickups = make_pickups()
	
	map = init_map(600, 100)
	map:generate_map(love.math.random()*40000)
	map:update_sprite_map()

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
	spawn_location = {}
	
end

function udpate_game_main(self, dt)
	gf = 0
	
    camera.aim_offset = player_list[1].gun.camera_offset
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

	for _,p in ipairs(player_list) do
		p:update(dt, camera)
		if p.shoot then
			--_shot = player.gun:make_bullet(player,player.rot)
			local bullet = p.gun:make_shot(p)
			if bullet then
				append_list(_shot, bullet)
			end
		end
	end

	toremove = {}
	--for i,v in ipairs(_shot) do
	for i = #_shot , 1 , -1 do
		v = _shot[i]
		-- Summon shots
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.player.rot,v.offset,nil,v.spr))
			--table.insert(toremove , i)
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

	hud:draw()

	-- Debug
	debug_y = 30
	--rect_color("line", 158, 128, block_width, block_width, {1,0,0})

	debug_print(notification)
	--debug_print(joystick.x)
	--debug_print(joystick.joy:getGamepadAxis("triggerleft"))
	--debug_print(spawn_time)
	--debug_print(#_shot)
	--if prevray.dist then debug_print(prevray.dist,1,1) end
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	--circ_color("fill", camera.x+window_w, camera.y+window_h, 1, {1,0,0})
	--map:debug_draw(camera.x+5, camera.y+30)
end