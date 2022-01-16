-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/settings"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"
require "scripts/gun"
require "scripts/gun_list"
require "scripts/mob"
require "scripts/mob_list"
require "scripts/camera"
require "scripts/screenshot"
require "scripts/ui"

function love.load()
	prevray = {}

	love.window.setMode(0, 0, {fullscreen = true, resizable=false, vsync=true, minwidth=400, minheight=300})	
	screen_w, screen_h = love.graphics.getDimensions()
	love.graphics.setDefaultFilter("nearest", "nearest")

	window_w, window_h = 512, 18*16
	ratio_w = screen_w/window_w or screen_w
	ratio_h = screen_h/window_h or screen_h
	canvas = love.graphics.newCanvas(window_w, window_h)

	font_def = love.graphics.getFont()
	font_def = love.graphics.setNewFont(10)
	
	gui = make_gui()
	gui:make_bar("life_bar", 2,2,10,10, spr_hp_bar, spr_hp_bar_empty)

	notification = ""
	
	init_keybinds()
	camera = init_camera()

	map = init_map(400, 20)
	map:load_from_file("chunks_wag_1.txt")
	map:generate_map()

	player = init_player()
	bullets = {}
	_shot = {}
	mobs = {}
	table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	
	prevfire = button_down("fire")

	perf = {}
end

function love.update(dt)
	camera:set_target(player.x-window_w/2, 0)--player.y-window_h/2)
	camera:update(dt)

	player:update(dt, camera)

	if player.shoot then
		--_shot = player.gun:make_bullet(player,player.rot)
		append_list(_shot, player.gun:make_shot(player))
	end

	for i,v in ipairs(_shot) do
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.angle,v.offset))
			table.remove(_shot, i)
		else
			v.time=v.time-dt
		end
	end

	for i,b in ipairs(bullets) do
		b:update(dt)
		damage_everyone(b,i)
		if b.delete then
			table.remove(bullets, i)
		end
	end

	for i,m in ipairs(mobs) do
		m:update(dt)
	end
	prevfire = button_down("fire")
	
	gui:update()

	table.insert(perf, dt)
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.translate(0, 0)
	camera:draw()
	-- TODO: y-sorting
	map:draw()
	
	for _,m in pairs(mobs) do
		m:draw()
		--draw_mob(m)
	end
	
	for i,m in ipairs(debug) do
		circ_color("fill", m.x, m.y, 3, {1,0,0})
	end

	for _,b in pairs(bullets) do
		b:draw()
	end 
	
	player:draw()

	gui:draw()

	-- Debug
	debug_y = 10
	debug_print(notification)
	if prevray.dist then debug_print(prevray.dist,1,1) end
	debug_print("FPS: "..tostr(love.timer.getFPS()))
	
	love.graphics.setCanvas()
	love.graphics.origin()
	love.graphics.scale(1, 1)
	love.graphics.draw(canvas, 0, 0, 0, ratio_w, ratio_h)

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

