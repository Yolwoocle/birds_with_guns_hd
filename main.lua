require "scripts/utility"
require "scripts/settings"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"
require "scripts/map_generation"
require "scripts/gun"
require "scripts/gun_list"
require "scripts/mob"
require "scripts/mob_list"
require "scripts/camera"
require "scripts/screenshot"
require "scripts/ui"
require "scripts/damage_zone_list"
require "scripts/damage_zone"
require "scripts/game_main"
require "scripts/game_menu_main"
require "scripts/pickup"

function love.load()
	game = make_game_main()
	prevray = {}

	love.window.setMode(0, 0, {fullscreen = true, resizable=false, vsync=true, minwidth=400, minheight=300})	
	screen_w, screen_h = love.graphics.getDimensions()
	love.graphics.setDefaultFilter("nearest", "nearest")

	window_w, window_h = 480, 270 --rename to canvas_w, canvas_h
	screen_sx = screen_w/window_w or screen_w
	screen_sy = screen_h/window_h or screen_h --FIXME this won't work well in non 9:16 screens
	screen_scale = min(screen_sx, screen_sy)
	screen_ox = max(0, (screen_w - window_w*screen_scale)/2)
	screen_oy = max(0, (screen_h - window_h*screen_scale)/2)

	canvas = love.graphics.newCanvas(window_w, window_h)

--	font_def = love.graphics.getFont()
	font_small = love.graphics.newFont("assets/fonts/Kenney Mini.ttf", 8)
	font_normal = love.graphics.newFont("assets/fonts/Kenney Pixel.ttf", 16)
	font_thick = love.graphics.newFont("assets/fonts/Kenney Thick.ttf", 8)
	love.graphics.setFont(font_thick)

	gui = make_gui()
	gui:make_bar("life_bar", 2,2, 10,10, spr_hp_bar,   spr_hp_bar_empty)
	gui:make_bar("ammo_bar", 2,24,nil,nil, spr_ammo_bar, spr_hp_bar_empty)

	notification = ""
	
	init_keybinds()
	camera = init_camera()
	camera.lock_y = false

	map = init_map(600, 100)
	map:generate_map(love.math.random()*40000)
	map:update_sprite_map()

	nb_joueurs = 1
	player_list = {}
	for i =1,nb_joueurs do
		local ply = init_player(20+random_float(0, 0), 16*20+random_float(0, 100))
		table.insert(player_list, ply)
	end

	bullets = {}
	_shot = {}
	zones = {}
	mobs = {}
	for i = 1,10 do
		table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	end
	pickups = make_pickups()
	pickups:spawn("ammo", 2, player_list[1].x, player_list[1].y)
	
	prevfire = button_down("fire")

	perf = {}

	g = 0

	set_debug_canvas(map)
end

function love.update(dt)
	--TODO: camera for all players
	camera:set_target(player_list[1].x-window_w/2, player_list[1].y-window_h/2)
	camera:update(dt)
	
	game:update(dt)

	table.insert(perf, dt)
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.translate(0, 0)
	
	game:draw()
	
	-- Canvas for that sweet pixel art
	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.scale(1, 1)
	love.graphics.draw(canvas, screen_ox, screen_oy, 0, screen_scale, screen_scale)

	love.graphics.setColor({1,0,0})
	for i=2,#perf do
		--love.graphics.line(i, perf[i-1]*10000, i+1, perf[i]*10000)
	end
	love.graphics.setColor({1,1,1})
end

function love.keypressed(key)
	if key == "f5" then
		--remove for release
		love.event.quit("restart")
	elseif key == "escape" then
		--remove for release
		love.event.quit()
	
	elseif key == "f2" then
		if canvas then
			screenshot()
		else
			notification = "Could not save screenshot: no canvas"
		end
	end
end

