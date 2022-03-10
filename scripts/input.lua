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
	fire  = {"c"},
	alt   = {"v", "x"},
	middle = {"t"},
}
SCHEME_P2_SPLIT = {
	type = "keyboard",
	left  = {"left"},  
	right = {"right"}, 
	up    = {"up"},
	down  = {"down"},
	fire  = {"m"},
	alt   = {","},
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

local function make_input_user(type, aim_method, keybinds)
	return {
		type = type,
		aim_method = aim_method,
		keybinds = keybinds,
	}
end

---- Keyboard ----

local function make_kb_input_user(keybinds, aim_method)
	aim_method = aim_method or "keyboard"
	local ip = make_input_user("keyboard", aim_method, keybinds)

	ip.get_movement_axis = function(self)
		local x, y = 0, 0
		if self:button_down("left", n)  then  x = x-1  end
		if self:button_down("right", n) then  x = x+1  end
		if self:button_down("up", n)    then  y = y-1  end
		if self:button_down("down", n)  then  y = y+1  end
		x, y = normalize_vect(x, y)
		return x, y
	end

	ip.button_down = function(self, cmd)
		local keys = self.keybinds[cmd]
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

--------------------------
------ INPUT PLAYER ------
--------------------------

function make_input_manager()
	local i = {}
	i.init = function(self)
		self:init_users()
		self:init_last_button_state_table()
--		self:init_joystickbinds()
	end

	i.update = function(self)
	end

	i.init_users = function(self) 
		self.users = {
			[1] = make_kb_input_user(SCHEME_P1_SPLIT, "mouse"),
			[2] = make_kb_input_user(SCHEME_P2_SPLIT, "keyboard"),
			[3] = make_kb_input_user(SCHEME_CONTROLLER),
			[4] = make_kb_input_user(SCHEME_CONTROLLER),
		}
	end

	i.get_keybinds = function(self, n)
		return self.users[n].keybinds
	end

	i.get_input_type = function(self, n)
		return self.users[n].type
	end

	i.init_last_button_state_table = function(self)
		self.last_button_state = {}
		for n=1,4 do
			self.last_button_state[n] = {}
			for key,_ in pairs(self:get_keybinds(n)) do
				self.last_button_state[n][key] = false
			end 
		end
	end

	i.button_down = function(self, cmd, n)
		n = n or 1

		-- Mouse 
		if cmd == "fire" and n == 1 and love.mouse.isDown(1) then  return true  end
		if cmd == "alt"  and n == 1 and love.mouse.isDown(2) then  return true  end

		return self.users[n]:button_down(cmd)
	end

	i.button_pressed = function(self, cmd, n)
		local btnd = self:button_down(cmd, n)
		local last_btnd = self.last_button_state[n][cmd]
		if btnd then 
			if not last_btnd then 
				self.last_button_state[n][cmd] = true
				return true 
			end
		else
			self.last_button_state[n][cmd] = false
		end
		return false
	end

	i.get_movement_axis = function(self, n)
		return self.users[n]:get_movement_axis()
	end

	i.get_world_cursor_pos = function(self, n, player)
		return self.users[n]:get_world_cursor_pos(player)
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
