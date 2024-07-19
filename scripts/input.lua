------ Aiming methods ------
local function aim_mouse(self, player)
	local mx, my = input:get_mouse_pos()
	return mx + camera.x, my + camera.y
end
local function aim_keyboard(self, player)
	return player:get_autoaim()
end
local function aim_controller(self, player)
	
end

BUTTONS = {
	'left', 'right', 'up', 'down', 'fire', 'alt', 'middle'
}
SCHEME_P1_REGULAR = {
	type = "keyboard",
	left  = {"a", "left"},
	right = {"d", "right"}, 
	up    = {"w", "up"},
	down  = {"s", "down"},
	fire  = {"c", "rshift"},
	alt   = {"x", "v"},
	middle = {"z"},
}
SCHEME_P1_SPLIT = {
	type = "keyboard",
	left  = {"a"},
	right = {"d"}, 
	up    = {"w"},
	down  = {"s"},
	fire  = {"c", "z"},
	alt   = {"v", "x"},
	middle = {"t"},
}
SCHEME_P2_SPLIT = {
	type = "keyboard",
	left  = {"left"},  
	right = {"right"}, 
	up    = {"up"},
	down  = {"down"},
	fire  = {"l"},
	alt   = {"k"},
	middle = {"."},
}
SCHEME_CONTROLLER = {
	type = "controller",
	left  = {"dpleft"}, 
	right = {"dpright"}, 
	up    = {"dpup"},
	down  = {"dpdown"},
	fire  = {"triggerleft"},
	alt   = {"triggerright"},
	middlems = {},
}

------------------------
------ INPUT USER ------
------------------------ 

local function make_input_user(n, type, aim_method, keybinds)
	local user = {}
	user.n = n
	user.type = type
	user.aim_method = aim_method
	user.keybinds = keybinds 
	
	user.button_states = {}
	for _,v in pairs(BUTTONS) do
		user.button_states[v] = 0
	end

	user.button_down = function(self, btn)
		error("button_down not implemented")
	end

	user.update_button_states = function(self)
		for button, state in pairs(self.button_states) do
			-- 0: Button not down
			-- 1: Button just pressed
			-- 2: Button down
			-- 3: Button just released
			if input:button_down(button) then
				if state == 0 then 
					self:set_button_state(button, 1)
				elseif state == 1 then 
					self:set_button_state(button, 2)
				end
			else
				if state == 1 or state == 2 then 
					self:set_button_state(button, 3)
				elseif state == 3 then
					self:set_button_state(button, 0)
				end
			end
		end
	end

	user.get_button_state = function(self, btn)
		return self.button_states[btn]
	end
	user.set_button_state = function(self, btn, val)
		self.button_states[btn] = val
	end

	user.get_keybinds = function(self, btn)
		return self.keybinds[btn]
	end

	return user
end

---- Keyboard ----

local function make_kb_input_user(n, keybinds, aim_method)
	aim_method = aim_method or "keyboard"
	local ip = make_input_user(n, "keyboard", aim_method, keybinds)

	ip.get_movement_axis = function(self)
		local x, y = 0, 0
		if self:button_down("left", n)  then  x = x-1  end
		if self:button_down("right", n) then  x = x+1  end
		if self:button_down("up", n)    then  y = y-1  end
		if self:button_down("down", n)  then  y = y+1  end
		x, y = normalize_vect(x, y)
		return x, y
	end

	ip.button_down = function(self, btn)
		local keys = self:get_keybinds(btn)
		for _,k in pairs(keys) do 
			if love.keyboard.isScancodeDown(k) then
				return true
			end 
		end
		return false
	end

	-- Aim method
	ip.get_world_cursor_pos = aim_keyboard
	if aim_method == "keyboard" then
		ip.get_world_cursor_pos = aim_keyboard
		
	elseif aim_method == "mouse" then
		ip.get_world_cursor_pos = aim_mouse

	end

	return ip
end

---------------------------
------ INPUT MANAGER ------
---------------------------

function make_input_manager()
	local i = {}
	i.init = function(self)
		self:init_users()
		--self:init_joystickbinds()
	end

	i.init_users = function(self) 
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_SPLIT, "mouse"),
			[2] = make_kb_input_user(2, SCHEME_P2_SPLIT, "keyboard"),
			[3] = make_kb_input_user(3, SCHEME_P1_REGULAR),--SCHEME_CONTROLLER),
			[4] = make_kb_input_user(4, SCHEME_P1_REGULAR),--SCHEME_CONTROLLER),
		}
	end

	i.update = function(self)
		for i,user in pairs(self.users) do
			user:update_button_states()
		end
	end

	i.init_users_1p = function(self)
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_REGULAR, "mouse"),
		}
	end
	i.init_users_2p_mouse = function(self)
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_SPLIT, "mouse"),
			[2] = make_kb_input_user(2, SCHEME_P2_SPLIT, "keyboard"),
		}
	end
	i.init_users_2p_kb = function(self)
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_SPLIT, "keyboard"),
			[2] = make_kb_input_user(2, SCHEME_P2_SPLIT, "keyboard"),
		}
	end
	i.init_users_3p = function(self)
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_SPLIT, "keyboard"),
			[2] = make_kb_input_user(2, SCHEME_P2_SPLIT, "keyboard"),
			[3] = make_kb_input_user(3, SCHEME_P2_SPLIT, "keyboard"),
		}
	end
	i.init_users_4p = function(self)
		self.users = {
			[1] = make_kb_input_user(1, SCHEME_P1_SPLIT, "keyboard"),
			[2] = make_kb_input_user(2, SCHEME_P2_SPLIT, "keyboard"),
			[3] = make_kb_input_user(3, SCHEME_P2_SPLIT, "keyboard"),
			[4] = make_kb_input_user(4, SCHEME_P2_SPLIT, "keyboard"),
		}
	end

	i.configure_user = function(self, n, val)
		self.users[n] = val
	end

	i.get_user = function(self, n)
		if not n then  return  end
		return self.users[n]
	end

	i.get_keybinds = function(self, n)
		return self:get_user(n).keybinds
	end

	i.get_input_type = function(self, n)
		return self:get_user(n).type
	end

	i.button_down = function(self, btn, n)
		n = n or 1

		-- Mouse 
		if btn == "fire" 	and n == 1 and love.mouse.isDown(1) then  return true  end
		if btn == "alt"  	and n == 1 and love.mouse.isDown(2) then  return true  end
		if btn == "middle"  and n == 1 and love.mouse.isDown(3) then  return true  end

		return self:get_user(n):button_down(btn)
	end

	i.button_pressed = function(self, btn, n)
		n = n or 1
		
		local btnstate = self:get_user(n):get_button_state(btn)
		return (btnstate == 1)
	end

	i.get_movement_axis = function(self, n)
		return self:get_user(n):get_movement_axis()
	end

	i.get_world_cursor_pos = function(self, n, player)
		return self:get_user(n):get_world_cursor_pos(player)
	end

	i.get_mouse_pos = function(self)
		local mx, my = love.mouse.getPosition()
		mx, my = floor(mx/screen_sx), floor(my/screen_sy)
		mx, my = mx + screen_ox, my + screen_oy
		return mx, my
	end

	i.get_world_mouse_pos = function(self)
		local mx, my = self:get_mouse_pos()
		return mx + camera.x, my + camera.y
	end

	i:init()

	return i
end

--[[
function button_down(command, user_n, input_device)
	if not(input_device[2] == "joystick" and not(joysticks[input_device[3] ])) then
		user_n = user_n or 1

		local mouse_fire = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(1))
		local joy_fire = (input_device[2] == "joystick" and joysticks[input_device[3] ]:isGamepadDown("rightshoulder"))
		if command == "fire" and (mouse_fire or joy_fire)then
			if joystick and joysticks[input_device[3] ]:isGamepadDown("rightshoulder") then
				keymode = "joystick"
			else
				keymode = "keyboard"
			end
			--joystick.joy:setVibration(10, 10)
			
			return true
		end
		
		local mouse_alt = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(2))
		local joy_alt = (input_device[2] == "joystick" and joysticks[input_device[3] ]:isGamepadDown("leftshoulder"))
		if command == "alt" and (mouse_alt or joy_alt) then
			return true
		end

		local mouse_mid = (input_device[2] == "keyboard+mouse" and love.mouse.isDown(3))
		if command == "middlems" and mouse_mid then
			return true
		end

		if input_device[2] == "keyboard+mouse" or input_device[2] == "keyboard" then--and not (command == "middlems") then --FI XME: and not command == "middlems" ajouter ca de facon propre
			local keys = input_device[1][command][user_n]
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
					if  joysticks[input_device[3] ]:isGamepadDown(d) then -- joysticks[input_device[3] ]:getAxis(1)
						return true
					end
				end
			end
		end

		return false
	end
end

function button_pressed(btn, n, input_device)
	local btnd = button_down(btn, n, input_device)
	local last_btnd = button_last_state[btn][n]
	if btnd then 
		if not last_btnd then
			button_last_state[btn][n] = true
			return true 
		end
	else
		button_last_state[btn][n] = false
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
	local mx, my = love.mouse.getPosition()
	mx, my = floor(mx/screen_sx), floor(my/screen_sy)
	mx, my = mx + screen_ox, my + screen_oy
	return mx, my
end

function get_joystick_cursor_pos(input_device,ply,dt)
	--??????
	if not(input_device[2] == "joystick" and not(joysticks[input_device[3] ])) then
		local joyx = joysticks[input_device[3] ]:getAxis(3)
		local joyy = joysticks[input_device[3] ]:getAxis(4)

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
--]]
