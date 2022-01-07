-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"

function love.load()
	init_keybinds()
	
	map = init_map(20, 20)
	local l = {1,2,3,4, r="azerty"}
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
	player:draw()
	for _,b in pairs(bullets) do
		b:draw()
	end 
	--love.graphics.print()
end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

