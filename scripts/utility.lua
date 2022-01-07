pi = math.pi
pi2 = 2 * math.pi
inf = math.huge

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

function tostr(s)
	return tostring(s)
end