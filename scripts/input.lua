function init_keybinds() 
	keybinds = {
		left  = {{"left",  "a"}}, 
		right = {{"right", "d"}}, 
		up    = {{"up",    "w"}},
		down  = {{"down",  "s"}},
		fire  = {{"c"}},
		alt   = {{"x"}},
	}
end

function button_down(command, player_n)
	player_n = player_n or 1
	if command == "fire" and love.mouse.isDown(1) then
		return true
	end
	if command == "alt" and love.mouse.isDown(2) then
		return true
	end
	local keys = keybinds[command][player_n]
	for _,k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
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
	local mx, my = love.mouse.getPosition()
	return mx/screen_sx + camera.x, my/screen_sy + camera.y
end 

function get_canvas_mouse_pos()
	-- TODO add screen offset
	local mx, my = love.mouse.getPosition()
	return mx/screen_sx, my/screen_sy
end