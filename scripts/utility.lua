pi = math.pi
pi2 = 2 * math.pi
inf = math.huge

tostr = tostring
floor = math.floor
ceil = math.ceil
max = math.max
min = math.min

function color(hex)
	if not hex then  return white  end
	if type(hex) ~= "number" then  return white  end

	local b = hex % 256;  hex = (hex - b) / 256
	local g = hex % 256;  hex = (hex - b) / 256
	local r = hex % 256
	return {r/255, g/255, b/255}
end
red = {1,0,0}
orange = {1,0.5,0}
yellow = {1,1,0}
green = {0,1,0}
cyan = {0,1,1}
blue = {0,0,1}
magenta = {1,0,1}
white = {1,1,1}
black = {0,0,0}
grey = {0.5,0.5,0.5}   
gray = grey --<o/ dab on the haters
brown = {0.5,0.2,0}

blue_bullet = color(0x0095e9)
red_heart = color(0xff0044)

function draw_centered(spr, x, y, r, sx, sy, ox, oy, color)
	local w = spr:getWidth() or 0
	local h = spr:getHeight() or 0
	local col = color or {1,1,1}
	if spr == nil then spr = spr_missing end 

	if (camera.x-w < x) and (x < camera.x+window_w+w) 
	and (camera.y-h < y) and (y < camera.y+window_h+h) then
		x = floor(x)
		y = floor(y)
		r = r or 0
		sx = sx or PIXEL_SCALE
		sy = sy or sx
		ox = ox or 0
		oy = oy or 0

		ox = floor(ox + spr:getWidth()/2)
		oy = floor(oy + spr:getHeight()/2)
		love.graphics.setColor(col)
		love.graphics.draw(spr, x, y, r, sx, sy, ox, oy)
		love.graphics.setColor(1,1,1)
	end
end

function draw_centered_outline(spr, x, y, r, sx, sy, thiccness, color)

	draw_centered(spr, x, y, r, sx, sy, thiccness ,0, color)
	draw_centered(spr, x, y, r, sx, sy, -thiccness,0, color)
	draw_centered(spr, x, y, r, sx, sy, 0, thiccness, color)
	draw_centered(spr, x, y, r, sx, sy, 0,-thiccness, color)

	draw_centered(spr, x, y, r, sx, sy, thiccness ,thiccness , color)
	draw_centered(spr, x, y, r, sx, sy,-thiccness ,thiccness , color)
	draw_centered(spr, x, y, r, sx, sy, thiccness ,-thiccness, color)
	draw_centered(spr, x, y, r, sx, sy,-thiccness ,-thiccness, color)

end


function rect_color(mode, x, y, w, h, col)
	--[[mode, x, y, w, h, col]]
	love.graphics.setColor(col)
	love.graphics.rectangle(mode, x, y, w, h)
	love.graphics.setColor(1,1,1)
end

function line_color(col, ...)
	--[[x1, y1, x2, y2, ...]]
	love.graphics.setColor(col)
	love.graphics.line(...)
	love.graphics.setColor(1,1,1)
end
function circ_color(mode,x,y,radius,col)
	love.graphics.setColor(col)
	love.graphics.circle(mode, x, y, radius)
	love.graphics.setColor(1,1,1)
end

function camera_print(text, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.print(text, x+camera.x, y+camera.y, r, sx, sy, ox, oy, kx, ky)
end
function camera_rect_color(mode, x, y, w, h, col)
	rect_color(mode, x+camera.x, y+camera.y, w, h, col)
end
function camera_line_color(col, x1, y1, x2, y2)
	--does not support polyline
	line_color(col, x1+camera.x, y1+camera.y, x2+camera.x, y2+camera.y)
end
function camera_circ_color(mode,x,y,...)
	circ_color(made, x+camera.x, y+camera.y, ...)
end

function setColor(hex)
	love.graphics.setColor(color(hex))
end


function sgn(n)
	if n >= 0 then
		return 1
	end
	return -1
end
sign = sgn

function sign0(n)
	if n == 0 then
		return 0
	elseif n > 0 then
		return 1
	end
	return -1
end

function round_if_near_zero(val, thr)
	thr = thr or 0.1
	if math.abs(val) < thr then
		return 0
	end
	return thr
end

function dist(x1,y1,x2,y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
function dist_sq(x1,y1,x2,y2) 
	return sqr(x2 - x1) + sqr(y2 - y1)
end
function sqr(x) 
	return x * x
end

function random_float(min, max)
	local range = max - min
	local offset = range * math.random()
	local num = min + offset
	return num
end

function random_polar(rad)
	local rnd_ang = love.math.random() * pi2
	local rnd_rad = love.math.random() * rad
	local x = math.cos(rnd_ang) * rnd_rad
	local y = math.sin(rnd_ang) * rnd_rad
	return x, y
end

function random_pos_neg(n)
	-- Random number between -n and n
	return math.random()*2*n - n
end
random_neighbor = random_pos_neg 

function random_sample(t)
	return t[love.math.random(1,#t)]
end

function random_weighted(tab)
	if not tab then  return nil  end

	local sum = 0
	for k,v in pairs(tab) do
		sum = sum + v
	end

	for k,v in pairs(tab) do
		if love.math.random() <= v/sum then
			return k
		end
		sum = sum - v
	end
	return tab[1]
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

--FIXME: AdD GoOd RaYcASt !
--[[function raycast(x,y,dx,dy,distmax,step)
	local angle = math.atan2(dy,dx)
	local invangle = -1/math.tan(angle)
	local ry
	local rx
	local y0
	local x0
	local dof
	local mx
	local my
	local mp
	local dof = 0

	if angle>pi then
		ry = (y/64) * 64 -.0001
		rx = (y-ry)*invangle+x
		y0 = -64
		x0 = -y0*invangle
	end
	if angle<pi then
		ry = (y/64) * 64 + 64
		rx = (y-ry)*invangle+x
		y0 = 64
		x0 = -y0*invangle
	end
	if angle==0 or angle == pi then
		rx = x
		ry = y
		dof = 8
	end
	while dof<8 do
		mx = rx / 64
		my = ry / 64
		mp = my * BLOCK_WIDTH + mx
		if mp < BLOCK_WIDTH*BLOCK_WIDTH and  map:is_solid(mx, my) then
			dof = 8
			return {dist = dist(x,y,rx,ry) , hit = dist(x,y,rx,ry)>=distmax , y = ry , x = rx}
		else
			rx = rx+x0
			ry = ry+y0
			dof = dof + 1
		end
		return {dist = dist(x,y,rx,ry) , hit = dist(x,y,rx,ry)>=distmax , y = ry , x = rx}
	end
end]]

function debug_print(txt)
	love.graphics.print(tostr(txt), camera.x + 10, camera.y + debug_y)
	debug_y = debug_y + 16
end


function draw_line_spr(x1,y1,x2,y2,spr,scale)
	xmidd = x2-x1
	ymidd = y2-y1
	local rota = math.atan2(ymidd,xmidd)
	local dist = dist(x1,y1,x2,y2)
	love.graphics.draw(spr, x1,y1 , rota-pi/2 , scale , dist , spr:getWidth()/2)
end

function shuffle(t, rng)
	--Fisher–Yates shuffle: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	for i=#t, 1, -1 do
		local j 
		if rng then
			j = rng:random(i)
		else
			j = love.math.random(i)
		end
		t[j], t[i] = t[i], t[j]
	end
end

function ternary(cond, T, F)
	--opti: T and F are always evaluated, unlike `cond and T or F` 
	if cond then return T else return F end
end

function clamp(a, b, c)
	return min(max(a, b), c)
end

function round(n)
	return math.floor(n + 0.5)
end

function inv_dt(val, a)
	-- Takes a value that's normally multiplied every frame (ie 60fps),
	-- i.e. `speed_x = speed_x * friction`
	-- but makes it work regardless of framerate.
	-- Idk why this works, but thanks stackoverflow? I guess?
	-- https://gamedev.stackexchange.com/questions/80081/frame-rate-independent-friction-on-movement-in-2d-game
	local dt = love.timer.getDelta()
	return 1 / (1 + dt * val)
end

function mod_plus_1(val, mod)
	return ((val-1) % mod)+1
end

function lerp(a, b, t)
	return a + (b-a) * t
end

function draw_shadow(obj, alpha)
	alpha = alpha or 0.4
	love.graphics.setColor(0,0,0,alpha)
	local x, y = floor(obj.x), floor(obj.y + obj.spr:getHeight()/2)
	local r = floor(obj.spr:getWidth()/2)
	love.graphics.ellipse("fill", x, y, r*0.8, r*0.2)
	love.graphics.setColor(1,1,1,1)
end

function table_to_str(tab)
	if type(tab) ~= "table" then
		return tostring(tab)
	end
	
	local s = ""
	for k,v in pairs(tab) do
		if type(k) == "number" then
			s = s..table_to_str(v)..", "
		else
			s = s..tostr(k).." = "..table_to_str(v)..", "
		end
	end
	s = string.sub(s, 1, #s-2)
	s = "{"..s.."}"
	return s
end

function print_table(tab)
	print(table_to_str(tab))
end

function randint(a,b, rng)
	if rng then
		return math.floor(rng:random() * b-a) + a
	else
		return math.floor(love.math.random() * b-a) + a
	end
end

function table_2d(w,h,val)
	local t = {}
	for i=1,h do
		t[i] = {}
		for j=1,w do
			t[i][j] = val
		end
	end
	return t
end

function table_2d_0(w,h,val)
	local t = {}
	for i=0,h-1 do
		t[i] = {}
		for j=0,w-1 do
			t[i][j] = val
		end
	end
	return t
end

function normalize_vect(x, y)
	if x==0 and y==0 then  return 0,0  end
	local a = math.atan2(y, x)
	return math.cos(a), math.sin(a)
end

function concat(...)
	local args = {...}
	local s = ""
	for _,v in pairs(args) do
		s = s..tostring(v)
	end
	return s
end

function is_in_table(tab, val)
	for _,v in pairs(tab) do
		if val == v then
			return true
		end
	end
	return false
end

function cols_has_type_of(tab, typ)
	for _,item in pairs(tab) do
		if item.other.type == typ then
			return true
		end
	end
	return false
end