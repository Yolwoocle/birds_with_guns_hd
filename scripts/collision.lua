require "scripts/utility"

function swept_aabb(o1, o2)
	-- https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/swept-aabb-collision-detection-and-response-r3084/
end

--https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
function sqr(x) 
	return x * x
end
function dist_sq(u, v) 
	return sqr(u.x - v.x) + sqr(u.y - v.y)
end
function dist_to_segment_squared(p, u, v) 
	local l2 = dist_sq(u, v)
  	if l2 == 0 then 
  		return dist_sq(p, u) 
	end
	--[[

	  u |---x--------------->| v 
		\           L
		 \
		D \
		   V  p
		    x
	]]
	-- Helpful: https://mathinsight.org/dot_product#:~:text=The%20dot%20product%20as%20projection,projection%20of%20a%20onto%20b.&text=The%20formula%20demonstrates%20that%20the,%E2%8B%85b%3Db%E2%8B%85a.
	-- D = p-u: vector from u to p
	-- L = v-u: vector from u to v, the vector of the segment 
	--
	-- t = (D · L)/|D|² is how far on the 
	-- line the point falls when projected.
	local t = ((p.x - u.x) * (v.x - u.x) + (p.y - u.y) * (v.y - u.y)) / l2;
	-- We clamp because we're working with a segment, not a line.
	t = max(0, min(1, t))
	-- Next, we calculate where this projection would be. We simply
	-- add t*D to u.
	-- Now that we have this point all that rests to do is compute
	-- its distance to p. Tada! 
	return dist_sq(p, { 
		x = u.x + t * (v.x - u.x),
        y = u.y + t * (v.y - u.y) })
end
function dist_to_segment(p, u, v) 
	return math.sqrt(dist_to_segment_squared(p, u, v))
end

function coll_rect(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 + w1 > x2 - h2
	   and x1 - w1 < x2 + w2 
	   and y1 - h1 < y2 + h2 
	   and y1 + h1 > y2 - h2
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

function collide_object(o,bounce)
	--TODO: Swept AABB or Raycast to all tiles in the path
	local dt = love.timer.getDelta() 
	local nextx = o.x + o.dx * dt
	local nexty = o.y + o.dy * dt
	local bounce = bounce or 0.2

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
	return coll_x or coll_y or coll_xy
end

function raycast_coll(x, y, dx, dy)
	-- returns if a point moving from (x,y) to (x+dx,y+dy) will hit a wall.
	-- assumes `map` is the map. Maybe put it as argument instead, idk
	local nx = x + dx
	local ny = y + dy

	if abs(dy) > abs(dx) then
		local slope = dy/dx
	else
		local invslope = dx/dy
	end
end	