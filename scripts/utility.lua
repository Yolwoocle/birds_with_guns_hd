pi = math.pi
pi2 = 2 * math.pi
inf = math.huge

tostr = tostring
floor = math.floor
ceil = math.ceil

function draw_centered(spr, x, y, r, sx, sy, ox, oy)
	r = r or 0
	sx = sx or 1
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

function randomFloat(min, max)
	local range = max - min
	local offset = range * math.random()
	local num = min + offset
	return num
end

function copy(ls)
	local newls = {}
	for i,v in ipairs(ls) do
		table.insert(newls,v) 
	end
	return newls
end


function addend(ls1,ls2)
	for i,v in pairs(ls2) do
		table.insert(ls1,v)
	end
	return ls1
end

function random_pos_neg(n)
	return math.random(2*n) - n
end