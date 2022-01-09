-- 21-09-30 Box collision test
require "scripts/utility"
require "scripts/player"
require "scripts/sprites"
require "scripts/map"
require "scripts/gun"
require "scripts/gun_list"
require "scripts/mob_list"
require "scripts/mob"

function love.load()
	love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
	init_keybinds()
	
	map = init_map(20, 20)
	map:load_from_string(str)

	player = init_player()
	bullets = {}
	_shot={}
	mobs = {}
	table.insert(mobs,mob_list.Leo_renome)

end

function love.update(dt)
	dta=dt
	player:update(dt)
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

end

function love.draw()
	-- TODO: y-sorting
	map:draw()
	player:draw()

	for i,m in ipairs(mobs) do
		m:draw()
	end

	for _,b in pairs(bullets) do
		b:draw()
	end 

	love.graphics.print(#bullets,20,20)
	love.graphics.print(dta,30,30)

end


function love.keypressed(key)
	if key == "f5" then
		love.event.quit("restart")
	elseif key == "escape" then
		love.event.quit()
	end
end

