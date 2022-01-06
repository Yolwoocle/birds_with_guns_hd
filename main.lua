-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"

function love.load()
	init_keybinds()

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

	love.graphics.print(str())
end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

