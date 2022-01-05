function init_keybinds()
	keybinds = {
		left  = {"left", "a", "q"}, 
		right = {"right", "d"}, 
		up    = {"up", "w", "z"},
		down  = {"down", "s"},
		fire  = {"c"},
		alt   = {"x"},
	}
end

function button_down(command)
	-- TODO: use scancode for compatibility with all keyboards
	keybinds = {
		left  = {"left", "a", "q"}, 
		right = {"right", "d"}, 
		up    = {"up", "w", "z"},
		down  = {"down", "s"},
		fire  = {"c"},
		alt   = {"x"},
	}
	local keys = keybinds[command]
	for _,k in pairs(keys) do
		if love.keyboard.isDown(k) then
			return true
		end
	end
	return false
end