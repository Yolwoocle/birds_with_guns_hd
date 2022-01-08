-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"
require "scripts/gun"
require "scripts/gun_list"

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
	_shot={}
end

function love.update(dt)
	player:update(dt)
	if player.shoot then
		--_shot = player.gun:make_bullet(player,player.rot)
		addend(_shot,player.gun:make_bullet(player,player.rot))
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

