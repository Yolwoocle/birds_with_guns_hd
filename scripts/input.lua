function init_keybinds() 
	keybinds = {
		left  = {{"a"},{"left"}}, 
		right = {{"d"},{"right"}}, 
		up    = {{"w"},{"up"}},
		down  = {{"s"},{"down"}},
		fire  = {{"c"},{"l"}},
		alt   = {{"x"},{";"}},
	}
end
function init_joystickbinds()
	joystickbinds = {
		left  = {{"dpleft"}, {"dpleft"}}, 
		right = {{"dpright"}, {"dpright"}}, 
		up    = {{"dpup"}, {"dpup"}},
		down  = {{"dpdown"}, {"dpdown"}},
		fire  = {{"triggerleft"}, {"triggerleft"}},
		alt   = {{"triggerright"}, {"triggerright"}},
	}
end
function init_button_last_state_table()
	button_last_state = {}
	for key,_ in pairs(keybinds) do
		button_last_state[key] = false
	end
end


function button_down(command, player_n, input_device)
	player_n = player_n or 1
	if command == "fire" and ((input_device[2] == "keyboard+mouse" and love.mouse.isDown(1)) or (input_device[2] == "joystick" and joysticks[input_device[3]]:isGamepadDown("rightshoulder")))then
		if joystick and joysticks[input_device[3]]:isGamepadDown("rightshoulder") then
			keymode = "joystick"
		else
			keymode = "keyboard"
		end
		--joystick.joy:setVibration(10, 10)
		
		return true
	end
	if command == "alt" and ((input_device[2] == "keyboard+mouse" and love.mouse.isDown(2)) or (input_device[2] == "joystick" and joysticks[input_device[3]]:isGamepadDown("leftshoulder"))) then
		return true
	end

	if input_device[2] == "keyboard+mouse" or input_device[2] == "keyboard" then
		local keys = input_device[1][command][player_n]
		for _,k in pairs(keys) do
			if love.keyboard.isScancodeDown(k) then
				return true
			end
		end
	end

	if input_device[2] == "joystick" then
		local dp = joystickbinds[command][1]
		for _,d in pairs(dp) do
			if not(command == "fire" or command == "alt") then
				if  joysticks[input_device[3]]:isGamepadDown(d) then -- joysticks[input_device[3]]:getAxis(1)
					return true
				end
			end
		end
	end

	return false
end

function get_autoaim(ply)
	local ne = ply:get_nearest_enemy()
	local x, y
	if ne then
		x = ne.x
		y = ne.y 
		ply.show_cu = true
	else 
		if math.abs(ply.dx) + math.abs(ply.dy) > 0.5 then 
			ply.dircux, ply.dircuy = ply.dx, ply.dy
			ply.show_cu = true
		else 
			ply.show_cu = false
		end
		local dir = math.atan2(ply.dircuy, ply.dircux)
		local rad = 64
		x = ply.x + math.cos(dir) * rad
		y = ply.y + math.sin(dir) * rad
	end
	local dt = love.timer.getDelta()
	x = lerp(ply.cu_x, x, 0.3)
	y = lerp(ply.cu_y, y, 0.3)
	return x, y
end

function button_pressed(cmd, n , input_device)
	local btnd = button_down(cmd, n , input_device)
	local last_btnd = button_last_state[cmd]
	if btnd then 
		if not last_btnd then
			button_last_state[cmd] = true
			return true
		end
	else
		button_last_state[cmd] = fakse
	end
	return false
end

function updatejoystick()
	joystick = {x=0,y=0}
	joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		joystick = joysticks
		--joystick.x = joysticks[1]:getAxis(1)
		--joystick.y = joysticks[1]:getAxis(2)
		--joystick.x2 = joysticks[1]:getAxis(3)
		--joystick.y2 = joysticks[1]:getAxis(4)
		--joystick.joy = joysticks[1]
	else
		joystick = nil
	end
end

function get_cursor_pos(ply, camera)
	return get_autoaim(ply)

	--[[TODO: support controllers 
	if camera then
		return get_mouse_pos(camera)  
	else
		return get_canvas_mouse_pos()
	end ]]
end

function get_mouse_pos(input_device , camera , self)

	if input_device[2] == "joystick" then
		if (joysticks[input_device[3]]:getAxis(3)<-joystick_deadzone2 or joysticks[input_device[3]]:getAxis(3)>joystick_deadzone2 or
		joysticks[input_device[3]]:getAxis(4)<-joystick_deadzone2 or joysticks[input_device[3]]:getAxis(4)>joystick_deadzone2) or not(mx) then
			mx, my = joysticks[input_device[3]]:getAxis(3)*10000 + player_list[1].x, joysticks[input_device[3]]:getAxis(4)*10000 + player_list[1].y
		else 
			return self.cu_x,self.cu_y
		end
	elseif input_device[2] == "keyboard+mouse" then
		mx, my = love.mouse.getPosition()
	end
	return mx/screen_sx + camera.x, my/screen_sy + camera.y
end 

function get_canvas_mouse_pos()
	-- TODO add screen offset
	local mx, my = love.mouse.getPosition()
	return mx/screen_sx, my/screen_sy
end