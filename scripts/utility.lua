pi = math.pi
pi2 = 2 * math.pi
inf = math.huge

tostr = tostring
floor = math.floor
ceil = math.ceil

function draw_centered(spr, x, y, r, sx, sy, ox, oy)
	x = floor(x)
	y = floor(y)
	r = r or 0
	sx = sx or pixel_scale
	sy = sy or sx
	ox = ox or 0
	oy = oy or 0

	ox = ox + spr:getWidth()/2
	oy = oy + spr:getHeight()/2

	love.graphics.draw(spr, x, y, r, sx, sy, ox, oy)
end

function circ_color(mode,x,y,radius,col)
	love.graphics.setColor(col)
	love.graphics.circle(mode, x, y, radius)
	love.graphics.setColor(1,1,1)
end

function rect_color(mode, x, y, w, h, col)
	love.graphics.setColor(col)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setColor(1,1,1)

end

function setColor(hex)
	love.graphics.setColor(color(hex))
end

function color(hex)
	local r = bit.rshift(hex, 16)
	local g = bit.rshift(hex, 8) % 256
	local b =            hex     % 256 
	return {r/255, g/255, b/255}
end

function sgn(hex)
	if hex >= 0 then
		return 1
	end
	return -1
end

function dist(x1,y1,x2,y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function random_float(min, max)
	local range = max - min
	local offset = range * math.random()
	local num = min + offset
	return num
end

function copy(t)
	local new_t = {}
	for k,v in pairs(t) do
		new_t[k] = v
	end
	return new_t
end


function append_list(ls1,ls2)
	for i,v in pairs(ls2) do
		table.insert(ls1,v)
	end
	return ls1
end

function random_pos_neg(n)
	-- Random number between -n and n
	return math.random(2*n) - n
end

function raycast(x,y,dx,dy,distmax,pas)
	local pas = pas or 1
	local dist = 0
	local continue = true
	while continue do
		local length = distmax-dist
		nextx = x+(dx*dist)
		nexty = y+(dy*dist)
		local newelt = {x=nextx , y=nexty ,life = length}
		continue = not(checkdeath(newelt))
		dist=dist+pas
	end

	if distmax-(dist-pas) <= 0 then
		hit = false
	else
		hit = true
	end

	return {dist = dist - pas,hit = hit,y = nexty,x = nextx}
end

function debug_print(txt)
	love.graphics.print(tostr(txt), camera.x + 10, camera.y + debug_y)
	debug_y = debug_y + 20
end

function draw_line_spr(x1,y1,x2,y2,spr,scale)
	xmidd = x2-x1
	ymidd = y2-y1
	local rota = math.atan2(ymidd,xmidd)
	local dist = dist(x1,y1,x2,y2)
	love.graphics.draw(spr, x1,y1 , rota-pi/2 , scale , dist , spr:getWidth()/2)
end