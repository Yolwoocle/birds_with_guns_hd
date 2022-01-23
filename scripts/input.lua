function init_keybinds() 
	keybinds = {
		left  = {{"left",  "a"}}, 
		right = {{"right", "d"}}, 
		up    = {{"up",    "w" }},
		down  = {{"down",  "s"}},
		fire  = {{"c" }},
		alt   = {{"x" }},
	}
end

function init_joystickbinds()
	joystickbinds = {
		left  = {{"dpleft"}}, 
		right = {{"dpright"}}, 
		up    = {{"dpup"   }},
		down  = {{"dpdown"}},
		fire  = {{"triggerleft"}},
		alt   = {{"triggerright"}},
	}
end


function button_down(command, player_n)
	player_n = player_n or 1
	if command == "fire" and (love.mouse.isDown(1) or (joystick and joystick.joy:isGamepadDown("rightshoulder"))) then
		if joystick and joystick.joy:isGamepadDown("rightshoulder") then
			keymode = "joystick"
		else
			keymode = "keyboard"
		end
		--joystick.joy:setVibration(10, 10)
		
		return true
	end
	if command == "alt" and (love.mouse.isDown(2) or (joystick and joystick.joy:isGamepadDown("leftshoulder"))) then
		return true
	end



	local keys = keybinds[command][player_n]
	for _,k in pairs(keys) do
		--if not(k=="c" or k=="x") then joy = joystick.joy:isGamepadDown(keys[#keys]) else joy = joystick.joy:getGamepadAxis(keys[#keys]) end
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end

	local dp = joystickbinds[command][player_n]
	for _,d in pairs(dp) do
		if not(command == "fire" or command == "alt") then
			if  joystick and joystick.joy:isGamepadDown(d) then
				return true
			end
		end
		--else
			--if joystick.joy:getGamepadAxis(d) then
			--	return true
			--end
		--end
	end

	return false
end

function updatejoystick()
	joystick = {x=0,y=0}
	local joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		joystick.x = joysticks[1]:getAxis(1)
		joystick.y = joysticks[1]:getAxis(2)
		joystick.x2 = joysticks[1]:getAxis(3)
		joystick.y2 = joysticks[1]:getAxis(4)
		joystick.joy = joysticks[1]
	else
		joystick = nil
	end
end

function get_cursor_pos(camera)
	--TODO: support controllers 
	if camera then
		return get_mouse_pos(camera)  
	else
		return get_canvas_mouse_pos()
	end 
end

function get_mouse_pos(camera)
	
	if joystick and keymode == "joystick" then
		if (joystick.x2<-joystick_deadzone2 or joystick.x2>joystick_deadzone2 or joystick.y2<-joystick_deadzone2 or joystick.y2>joystick_deadzone2) or not(mx) then
			mx, my = joystick.x2*10000 + player_list[1].x, joystick.y2*10000 + player_list[1].y
		end
	else
		mx, my = love.mouse.getPosition()
	end
	return mx/screen_sx + camera.x, my/screen_sy + camera.y
end 

function get_canvas_mouse_pos()
	-- TODO add screen offset
	local mx, my = love.mouse.getPosition()
	return mx/screen_sx, my/screen_sy
end