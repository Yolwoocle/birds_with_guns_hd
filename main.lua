-- 21-09-30 Box collision test
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

function love.load()
	prevray = {}

	love.window.setMode(0, 0, {fullscreen = true, resizable=false, vsync=true, minwidth=400, minheight=300})	
	screen_w, screen_h = love.graphics.getDimensions()
	love.graphics.setDefaultFilter("nearest", "nearest")

	window_w, window_h = 480, 270
	ratio_w = screen_w/window_w or screen_w
	ratio_h = screen_h/window_h or screen_h --FIXME this won't work well in non 9:16 screens
	canvas = love.graphics.newCanvas(window_w, window_h)

--	font_def = love.graphics.getFont()
	font_small = love.graphics.newFont("assets/fonts/Kenney Mini.ttf", 8)
	font_normal = love.graphics.newFont("assets/fonts/Kenney Pixel.ttf", 16)
	font_thick = love.graphics.newFont("assets/fonts/Kenney Thick.ttf", 8)
	love.graphics.setFont(font_thick)

	gui = make_gui()
	gui:make_bar("life_bar", 2,2,10,10, spr_hp_bar, spr_hp_bar_empty)

	notification = ""
	
	init_keybinds()
	camera = init_camera()
	camera.lock_y = false

	map = init_map(600, 100)
	map:generate_map()
	map:update_sprite_map()

	nb_joueurs = 1
	player_list = {}
	for i =1,nb_joueurs do
		local ply = init_player(20+random_float(0, 0), 16*20+random_float(0, 100))
		table.insert(player_list, ply)
	end

	bullets = {}
	_shot = {}
	mobs = {}
	zones = {}
	for i = 1,10 do
		table.insert(mobs, mob_list.Leo_renome:spawn(100,100))
	end
	
	prevfire = button_down("fire")

	perf = {}

	g = 0
end

function love.update(dt)
	--TODO: camera for all players
	camera:set_target(player_list[1].x-window_w/2, player_list[1].y-window_h/2)
	camera:update(dt)
	camera.aim_offset = player_list[1].gun.camera_offset

	map:update()

	for _,p in ipairs(player_list) do
		p:update(dt, camera)
		if p.shoot then
			--_shot = player.gun:make_bullet(player,player.rot)
			append_list(_shot, p.gun:make_shot(p))
		end
	end
	camera.aim_offset = player_list[1].gun.camera_offset

	for i,v in ipairs(_shot) do
		if v.time <= 0 then
			table.insert(bullets,make_bullet(v.gun,v.player,v.player.rot,v.offset))
			table.remove(_shot, i)
		else
			v.time=v.time-dt
		end
	end

	for i,b in ipairs(bullets) do
		b:update(dt,i)
		damage_everyone(b,i)
	end
	

	for i,m in ipairs(mobs) do
		m:update(dt)
	end

	for i,z in ipairs(zones) do
		z:update(dt,i)
		damageinzone(z,i) 

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

	for i,z in ipairs(zones) do
		z:draw()
	end
	
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
	
	for _,p in ipairs(player_list) do
		p:draw()
	end

	gui:draw()

	-- Debug
	debug_y = 10
	debug_print(notification)
	debug_print(#bullets)
	if prevray.dist then debug_print(prevray.dist,1,1) end
	debug_print("FPS:",tostr(love.timer.getFPS()))
	circ_color("fill", camera.x+window_w, camera.y+window_h, 1, {1,0,0})
	
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

