function make_game_main()
    local game = {
        init = init_game_main,
		update = udpate_game_main,
        draw = draw_game_main,
    } 
    return game
end

function init_game_main(self)
	--todo
end

function udpate_game_main(self, dt)
	gf = 0
    camera.aim_offset = player_list[1].gun.camera_offset
	map:update()
	pickups:update()

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
	for i,v in ipairs(_shot) do
		-- Summon shots
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.player.rot,v.offset,nil,v.spr))
			table.insert(toremove , i)
		else
			v.time=v.time-dt
		end
	end

	for i,v in ipairs(toremove) do
		table.remove(_shot, v-i+1)
	end

	for i,b in ipairs(bullets) do
		b:update(dt,i)
		damage_everyone(b,i)
	end
	for i,m in ipairs(mobs) do
		m:update(dt)
	end
	for i,z in ipairs(zones) do
		z:update(dt,i)
		damageinzone(z,i) 
	end
	--for i,m in pairs(mobs) do
	--	if m.life<=0 then
	--		table.remove(mobs , i)
	--	end
	--end
	prevfire = button_down("fire")
	gui:update()

	particles:update(dt)
end

function draw_game_main(self)
    camera:draw()
	-- TODO: y-sorting
	map:draw()
	pickups:draw()

	for i,z in ipairs(zones) do
		z:draw()
	end
	for i,m in pairs(mobs) do
		if m.life<=0 then
			table.remove(mobs , i)
		end
	end
	
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
	particles:draw()

	gui:draw()

	-- Debug
	debug_y = 30
	debug_print(notification)
	--debug_print(joystick.x)
	--debug_print(joystick.joy:getGamepadAxis("triggerleft"))
	debug_print(#bullets)
	debug_print(#_shot)
	--if prevray.dist then debug_print(prevray.dist,1,1) end
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	circ_color("fill", camera.x+window_w, camera.y+window_h, 1, {1,0,0})
	--map:debug_draw(camera.x+5, camera.y+30)
end