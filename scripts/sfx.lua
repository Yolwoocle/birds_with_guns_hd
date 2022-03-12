require "scripts.settings"

local function new_source(path, type, args)
	local source = love.audio.newSource("assets/sfx/"..path, type)
	if not args then  return source  end
	
	if args.looping then
		source:setLooping(true)
	end
	return source
end

sfx_shot_1 = new_source("shot_1.wav", "static")
sfx_shot_2 = new_source("shot_2.wav", "static")

music_level_1 = new_source("music/level_1.mp3", "stream", {looping = true})
