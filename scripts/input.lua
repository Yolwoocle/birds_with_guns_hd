function init_keybinds() 
	keybinds = {
		left  = {{"a"},{"left"}}, 
		right = {{"d"},{"right"}}, 
		up    = {{"w"},{"up"}},
		down  = {{"s"},{"down"}},
		fire  = {{"c"},{"m"}},
		alt   = {{"v"},{","}},
		middlems = {{"t"},{"p"}},
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
		middlems = {{},{}},
	}
end

--TODO: IMPORTANT: completely rework this fucking mess, use an input_manager object.
function init_button_last_state_table()
	button_last_state = {}
	for key,_ in pairs(keybinds) do
		button_last_state[key] = {}
		for i=1,4 do
			button_last_state[key][i] = false
		end 
	end
end


function button_down(command, player_n, input_device)
	if not(input_device[2] == "joystick" and not(joysticks[input_device[3]])) then
		player_n = player_n or 1

		local mouse_fire = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(1))
		local joy_fire = (input_device[2] == "joystick" and joysticks[input_device[3]]:isGamepadDown("rightshoulder"))
		if command == "fire" and (mouse_fire or joy_fire)then
			if joystick and joysticks[input_device[3]]:isGamepadDown("rightshoulder") then
				keymode = "joystick"
			else
				keymode = "keyboard"
			end
			--joystick.joy:setVibration(10, 10)
			
			return true
		end
		
		local mouse_alt = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(2))
		local joy_alt = (input_device[2] == "joystick" and joysticks[input_device[3]]:isGamepadDown("leftshoulder"))
		if command == "alt" and (mouse_alt or joy_alt) then
			return true
		end

		local mouse_mid = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(3))
		if command == "middlems" and mouse_mid then
			return true
		end

		if input_device[2] == "keyboard+mouse" or input_device[2] == "keyboard" then--and not (command == "middlems") then --FI XME: and not command == "middlems" ajouter ca de facon propre
			local keys = input_device[1][command][player_n]
			for _,k in pairs(keys) do
				if love.keyboard.isScancodeDown(k) then
					return true
				end
			end
		end -- love.mouse.isDown(3)

		if input_device[2] == "joystick" then
			local dp = joystickbinds[command][1]
			for _,d in pairs(dp) do
				if not(command == "fire" or command == "alt" or command == "middlems") then
					if  joysticks[input_device[3]]:isGamepadDown(d) then -- joysticks[input_device[3]]:getAxis(1)
						return true
					end
				end
			end
		end

		return false
	end
end

function button_pressed(cmd, n, input_device)
	local btnd = button_down(cmd, n, input_device)
	local last_btnd = button_last_state[cmd][n]
	if btnd then 
		if not last_btnd then
			button_last_state[cmd][n] = true
			return true 
		end
	else
		button_last_state[cmd][n] = false
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

function get_cursor_pos(ply, input_device,dt)
	-- Abstraction of mouse, autoaim and controller aiming.
	if input_device[2] == "keyboard+mouse" then
		return get_mouse_pos()
	elseif input_device[2] == "keyboard" then
		return get_autoaim(ply)
	elseif input_device[2] == "joystick" then 
		return get_joystick_cursor_pos(input_device,ply,dt)
	end
	error("invalid input device")
end

function get_world_cursor_pos(ply, input_device,dt, camera)
	local x, y = get_cursor_pos(ply, input_device,dt)
	if  not(x) then  x, y = ply.x-camera.x , ply.y-camera.y end
	return x + camera.x, y + camera.y
end

function get_mouse_pos()
	--FIXME: won't work if the screen has borders
	local mx, my = love.mouse.getPosition()
	mx, my = floor(mx/screen_sx), floor(my/screen_sy)
	return mx, my
end

function get_joystick_cursor_pos(input_device,ply,dt)
	--??????
	if not(input_device[2] == "joystick" and not(joysticks[input_device[3]])) then
		local joyx = joysticks[input_device[3]]:getAxis(3)
		local joyy = joysticks[input_device[3]]:getAxis(4)

		local qdsf = dist(joyy,joyx,0,0)
		if qdsf > joystick_deadzone2 then
			local a = math.atan2(joyy,joyx)
			return lerp(ply.cu_x,ply.x+math.cos(a)*100,.2)-camera.x, lerp(ply.cu_y,ply.y+math.sin(a)*100,.2)-camera.y
		elseif dist((ply.cu_x-camera.x)+ply.dx*dt,(ply.cu_y-camera.y)+ply.dy*dt,ply.x-camera.x,ply.y-camera.y)>10 then
			local x,y = lerp(ply.cu_x+ply.dx*dt, ply.x, .1)-camera.x ,  lerp(ply.cu_y+ply.dy*dt, ply.y,0.1)-camera.y
			return x,y

		else
			return (ply.cu_x-camera.x)+ply.dx*dt,  (ply.cu_y-camera.y)+ply.dy*dt
		end
	end
	
end
