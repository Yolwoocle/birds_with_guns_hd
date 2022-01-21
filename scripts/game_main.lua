function init_game_main()
    local game = {
        update = udpate_game_main,
        draw = draw_game_main,
    } 
    return game
end

function udpate_game_main(self, dt)
    camera.aim_offset = player_list[1].gun.camera_offset
	map:update()
	for _,p in ipairs(player_list) do
		p:update(dt, camera)
		if p.shoot then
			--_shot = player.gun:make_bullet(player,player.rot)
			append_list(_shot, p.gun:make_shot(p))
		end
	end
	camera.aim_offset = player_list[1].gun.camera_offset
	for i,v in ipairs(_shot) do
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.player.rot,v.offset))
			table.remove(_shot, i)
		else
			v.time=v.time-dt
		end
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
	prevfire = button_down("fire")
	gui:update()
end

function draw_game_main(self)
    camera:draw()
	-- TODO: y-sorting
	map:draw()

	for i,z in ipairs(zones) do
		z:draw()
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

	gui:draw()

	-- Debug
	debug_y = 30
	debug_print(notification)
	debug_print(#bullets)
	--if prevray.dist then debug_print(prevray.dist,1,1) end
	debug_print("FPS. "..tostr(love.timer.getFPS()))
	circ_color("fill", camera.x+window_w, camera.y+window_h, 1, {1,0,0})
	map:debug_draw(camera.x+5, camera.y+30)
end