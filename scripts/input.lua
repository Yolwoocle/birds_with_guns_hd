function init_keybinds() --TODO: use scancodes instead
	keybinds = {
		left  = {"left",  "a"}, 
		right = {"right", "d"}, 
		up    = {"up",    "w"},
		down  = {"down",  "s"},
		fire  = {"c"},
		alt   = {"x"},
	}
end

function button_down(command)
	if command == "fire" and love.mouse.isDown(1) then
		return true
	end
	if command == "alt" and love.mouse.isDown(2) then
		return true
	end
	-- TODO: use scancode for compatibility with all keyboards
	local keys = keybinds[command]
	for _,k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
end