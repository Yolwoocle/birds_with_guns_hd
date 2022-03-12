require "scripts.utility"
require "scripts.constants"
require "scripts.player"
require "scripts.sprites"
require "scripts.map"
require "scripts.gun"
require "scripts.gun_list"
require "scripts.mob"
require "scripts.mob_list"
require "scripts.camera_manager"
require "scripts.screenshot"
require "scripts.ui"
require "scripts.damage_zone_list"
require "scripts.damage_zone"
require "scripts.game_main"
require "scripts.pickup"
require "scripts.particles"
require "scripts.waves"
require "scripts.level_editor.main"
require "scripts.menu"
require "scripts.interactable"
require "scripts.interactable_list"
require "scripts.audio"
gifcat = require("gifcat")

function love.load()
	-- I am deeply sorry for these globals
	keymode = "keyboard"
	prevray = {}

	love.window.setMode(0, 0, {fullscreen = true, resizable=false, vsync=true, minwidth=400, minheight=300})	
	screen_w, screen_h = love.graphics.getDimensions()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	input = make_input_manager()
	audio = make_audio_manager()

	gifcat.init()

	res_1080p_4 = 480, 270
	res_1080p_3 = 640, 360
	window_w, window_h = 480, 270 --rename to canvas_w, canvas_h
	screen_sx = screen_w/window_w or screen_w
	screen_sy = screen_h/window_h or screen_h
	screen_scale = min(screen_sx, screen_sy)
	screen_ox = max(0, (screen_w - window_w*screen_scale)/2)
	screen_oy = max(0, (screen_h - window_h*screen_scale)/2)

	canvas = love.graphics.newCanvas(window_w, window_h)

--	font_def = love.graphics.getFont()
	font_kenney_mini = love.graphics.newFont("assets/fonts/Kenney Mini.ttf", 8)
	font_kenney_pixel = love.graphics.newFont("assets/fonts/Kenney Pixel.ttf", 16)
	font_kenney_thick = love.graphics.newFont("assets/fonts/Kenney Thick.ttf", 8)
	
	font_compass = love.graphics.newFont("assets/fonts/somepx/CompassPro.ttf", 16) 
	font_equipment = love.graphics.newFont("assets/fonts/somepx/EquipmentPro.ttf", 16) 
	font_expression = love.graphics.newFont("assets/fonts/somepx/ExpressionPro.ttf", 16) 
	font_futile = love.graphics.newFont("assets/fonts/somepx/FutilePro.ttf", 16) 
	font_matchup = love.graphics.newFont("assets/fonts/somepx/MatchupPro.ttf", 16)
	
	font_small = font_kenney_mini
	font_normal = font_matchup
	font_thick = font_futile

	font_default = font_futile--font_matchup
	love.graphics.setFont(font_default)

	love.mouse.setVisible(mouse_visible)

	notification = ""

	init_menu_manager()
	game = make_game()
end

function love.update(dt)
	input:update(dt)
	gifcat.update(dt)
	if map_edit_mode then
		update_map_edit(dt)
	else
		if menu_manager.curmenu_name == "none" then
			game:update(dt)
		else
			menu_manager:update(dt)
		end
	end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0,0,0)
    love.graphics.translate(0, 0)
    
	if map_edit_mode then
		draw_map_edit()
	else
		game:draw()
	end
	menu_manager:draw()

	local text = love.graphics.newText(font_normal, "Development version - "..os.date('%a %d-%b-%Y'))
	love.graphics.draw(text, camera.x+window_w-text:getWidth(), camera.y)
	
    -- Canvas for that sweet pixel art
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.scale(1, 1)
    love.graphics.draw(canvas, screen_ox, screen_oy, 0, screen_scale, screen_scale)

	-- Catpure GIFs
	capture_clip_frame()

--[[ debug print map
	local cols = {[0]={0,0,0,0}, [1]=black, [2]=white, [3]=brown, [4]=magenta,
	[5]=grey, [6]=cyan, [7]=orange, [8]=green, [9]=red, [10]={0.1,0.1,0.1},
	[11]=magenta}
	for iy = 0, map.height-1 do
	for ix = 0, map.width-1 do
		local n = map:get_tile(ix,iy).n
		local s = 3
		if n~= 0 then 
			rect_color("fill",ix*s,iy*s,s,s, cols[n])
		end
	end
	end
--]]
end

function love.keypressed(key, scancode, isrepeat)
	game:keypressed(key, scancode)
	menu_manager:keypressed(key, scancode)

	if key == "f1" then
		-- ...
	elseif key == "f2" then
		if canvas then
			screenshot()
		else
			notification = "Could not save screenshot: no canvas"
		end
	
	elseif key == "f3" then
		screenshot_clip()
		notification = "Recording GIF..."

	--remove for release
	elseif key == "f4" then
		love.event.quit()
	
	elseif key == "f5" then
		love.event.quit("restart")

	elseif key == "f6" then
		toggle_map_edit()
	end
end

function love.keyreleased(key)
	if key == "f3" then
		notification = "Finished recording GIF."
		-- Stop writing to the gif. This finalizes the file and closes it.
		curgif:close()
		-- Set to nil so our program knows we aren't writing a gif.
		curgif = nil
	end
end

function love.focus(focus)
	if game then  game:focus(focus)  end
end



function love.quit()
	gifcat.close()
end

function love.threaderror(thread, errorstr)
	print("Thread error!\n"..errorstr)
end