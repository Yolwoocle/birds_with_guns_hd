require "scripts.settings"

local function new_source(path, ...)
	return love.audio.newSource("assets/sfx/"..path, ...)
end

function play_sfx(sfx)
	if settings.sound_on then
		local source = sfx:clone()
		source:play()
	end
end

sfx_shot_1 = new_source("shot_1.wav", "static")
sfx_shot_2 = new_source("shot_2.wav", "static")
