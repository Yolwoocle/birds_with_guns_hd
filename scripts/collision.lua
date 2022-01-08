require "scripts/utility"

function swept_aabb(o1, o2)
	-- https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/swept-aabb-collision-detection-and-response-r3084/
end

----------
function coll_rect(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 + w1 > x2 
		and x1 < x2 + w2 
		and y1 < y2 + h2 
		and y1 + h1 > y2
end

function draw_coll(x,y,w,h)--{{{2
	love.graphics.rectangle("line",x,y,w,h)
end

function is_solid_rect(map, x, y, w, h)
    --[[
        A - i - B
        |       |
        j   ×   k
        |       |
        C - l - D
    ]]
	local blk_w = block_width
	x = x / blk_w
	y = y / blk_w
	w = w / blk_w
	h = h / blk_w

    return 
        map:is_solid(x-w, y-h) or --A
        map:is_solid(x+w, y-h) or --B
        map:is_solid(x-w, y+h) or --C
        map:is_solid(x+w, y+h) or --D

		-- Remove lower half if optimisation needed
        map:is_solid(x,   y-h) or --i
        map:is_solid(x-w, y) or   --j
        map:is_solid(x+w, y) or   --k
        map:is_solid(x,   y+h)    --l
end

function collide_object(o)
	--TODO: Swept AABB
	local dt = love.timer.getDelta() 
	local nextx = o.x + o.dx * dt
	local nexty = o.y + o.dy * dt
	local bounce = 0.2

	if nextx < 0 then
		o.dx = 0
	end
	if nexty < 0 then
		o.dy = 0
	end

	local bw = block_width
	local coll_x = is_solid_rect(map, nextx, o.y, o.w, o.h)
	local coll_y = is_solid_rect(map, o.x, nexty, o.w, o.h)
	local coll_xy = is_solid_rect(map, nextx, nexty, o.w, o.h)
	
	if coll_x then 
		o.dx = -o.dx * bounce 
	end
	if coll_y then
		o.dy = -o.dy * bounce
	end
	if coll_xy and not coll_x and not coll_y then
		o.dx = -o.dx * bounce
		o.dy = -o.dy * bounce
	end
end