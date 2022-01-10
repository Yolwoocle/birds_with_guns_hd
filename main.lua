-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"
require "scripts/gun"
require "scripts/gun_list"
require "scripts/mob"
require "scripts/mob_list"
require "scripts/camera"

function love.load()
	love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
	init_keybinds()
	camera = init_camera()

	map = init_map(20, 20)
	map:load_from_string(str)

	player = init_player()
	bullets = {}
	_shot = {}
	mobs = {}
	table.insert(mobs,mob_list.Leo_renome)
	prevfire = button_down("fire")
end

function love.update(dt)
	camera:set_target(player.x-400, player.y-300)
	camera:update(dt)

	player:update(dt, camera)
	if player.shoot then
		--_shot = player.gun:make_bullet(player,player.rot)
		append_list(_shot, player.gun:make_shot(player,player.rot))
	end

	for i,v in ipairs(_shot) do
		if v.time<=0 then
			v.angle=player.rot
			table.insert(bullets,make_bullet(v.gun,v.player,v.angle,v.offset))
			table.remove(_shot, i)
		else
			v.time=v.time-dt
		end
	end

	for i,b in ipairs(bullets) do
		b:update(dt)
		if b.delete then
			table.remove(bullets, i)
		end
	end

	for i,m in ipairs(mobs) do
		--m:update(dt)
	end
	prevfire = button_down("fire")
end

function love.draw()
	camera:draw()
	-- TODO: y-sorting
	map:draw()
	
	for i,m in ipairs(mobs) do
		--m:draw()
		--draw_mob(m)
	end
	
	for _,b in pairs(bullets) do
		b:draw()
	end 
	
	player:draw()

	debug_y = 10
	debug_print("FPS: "..tostr(love.timer.getFPS()))
end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

