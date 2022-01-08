-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"

function love.load()
	love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
	init_keybinds()
	
	map = init_map(20, 20)
	map:load_from_string(str)

	player = init_player()
	bullets = {}
	_shot={}
end

function love.update(dt)
	player:update(dt)
	if player.shoot then
		_shot = player.gun:make_shot(player, player.rot)
	end

	for i,v in ipairs(_shot) do
		if v[5] <= 0 then
			v[3] = player.rot
			table.insert(bullets, make_bullet(v[1],v[2],v[3],v[4],v[5]))
			table.remove(_shot, i)
		else
			v[5] = v[5] - dt
		end
	end

	for i,b in ipairs(bullets) do
		b:update(dt)
		if b.delete then
			table.remove(bullets, i)
		end
	end
end

function love.draw()
	-- TODO: y-sorting
	map:draw()
	player:draw()
	for _,b in pairs(bullets) do
		b:draw()
	end 

	love.graphics.print(#bullets,20,20)

end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

