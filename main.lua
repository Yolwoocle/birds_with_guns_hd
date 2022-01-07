-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"

function love.load()
	love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
	init_keybinds()
	
	map = init_map(20, 20)
	map:set_tile(2,2,1)
	map:set_tile(1,1,1)
	local l = {[0]=3,1,2,3,4, r="azerty"}
	for i,v in ipairs(l) do
		print("i="..i.." v="..v)
	end

	player = init_player()
	bullets = {}
end

function love.update(dt)
	player:update(dt)
	if player.shoot then
		table.insert(bullets, player.gun:make_bullet(player))
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
end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

