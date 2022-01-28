require "scripts/utility"

function collision_response(obj, map)
	-- Reference: https://www.amanotes.com/post/using-swept-aabb-to-detect-and-process-collision
	-- Other helpful article: https://www.gamedev.net/tutorials/programming/general-and-gameplay-programming/swept-aabb-collision-detection-and-response-r3084/
	
	-- We convert from centered to corner
	local dt = love.timer.getDelta()
	local o = {
		x = obj.x-obj.w, 
		y = obj.y-obj.h,
		w = obj.w*2,
		h = obj.h*2,
		dx = obj.dx,
		dy = obj.dy,
	} 
	local x1, y1 = floor(o.x), floor(o.y)
	local x2, y2 = floor(o.x+o.dx*dt), floor(o.y+o.dy*dt)

	obj.is_coll = false
	local bw = block_width
	local sgn_x = sign(x2-x1)
	local sgn_y = sign(y2-y1)
	
	rect_color("line", o.x, o.y, o.w, o.h, {0,1,0})
	--for iy = y1, y2+(bw*sgn_y), bw*sgn_y do
	--for ix = x1, x2+(bw*sgn_x), bw*sgn_x do
		--if map:is_solid(ix/bw, iy/bw) then
			local b = {
				--x = floor(ix/bw)*bw, 
				--y = floor(iy/bw)*bw,
				--w = bw, h = bw,
				x = 158, y = 128,
				w = 16, h=16,--bw, h = bw,
			}
			local coll_time = swept_aabb(o,b)
			print(coll_time)
			-- Apply movement
			o.dx = o.dx --* coll_time
			o.dy = o.dy --* coll_time
			local remaining_time = 1 - coll_time

		--end
	--end
	--end
	obj.dx = o.dx
	obj.dy = o.dy
	obj.x = o.x + o.dx*dt + obj.w
	obj.y = o.y + o.dy*dt + obj.h
	obj.is_coll = o.is_coll
end

function swept_aabb(o, b)
	-- Returns if an object o hits a block
	-- this might cause lag if the zone is big enough
	--[[
			lx_exit
	<-------------->
	+---+           ^
	|   |           |
	| o |           |
	+---+           |
		<-->        | ly_exit
		lx_entry    |
			+-----+ |
			|     | |
			| b   | |
			+-----+ v	
	]]
	local bw = block_width
	local dt = love.timer.getDelta()

	rect_color("line", b.x, b.y, b.w, b.h, {1,0,0})

	local lx_entry, ly_entry
	local lx_exit, ly_exitw
	if o.dx > 0 then
		lx_entry = b.x - (o.x + o.w)
		lx_exit = (b.x + b.w) - o.x 
	else
		lx_entry = (b.x + b.w) - o.x 
		lx_exit = b.x - (o.x + o.w)
	end

	if o.dy > 0 then
		ly_entry = b.y - (o.y + o.h)
		ly_exit = (b.y + b.h) - o.y 
	else
		ly_entry = (b.y + b.h) - o.y 
		ly_exit = b.y - (o.y + o.h)
	end

	local tx_entry, ty_entry
	local tx_exit, ty_exit

	if o.dx == 0 then
		tx_entry = -math.huge
		tx_exit = math.huge
	else
		tx_entry = lx_entry / o.dx*dt
		tx_exit = lx_exit / o.dx*dt
	end

	if o.dy == 0 then
		ty_entry = -math.huge
		ty_exit = math.huge
	else
		ty_entry = ly_entry / o.dy*dt
		ty_exit = ly_exit / o.dy*dt
	end

	local entry_time = max(tx_entry, ty_entry)
	local exit_time = min(tx_exit, ty_exit)
	
	local normal_x, normal_y

	if entry_time > exit_time 
	or tx_entry < 0 and ty_entry < 0 
	or tx_entry > 1 or ty_entry > 1 then
		-- if there is no collision
		o.is_coll = false
		return 1
	else
		-- if there is collision
		if tx_entry > ty_entry then
			if lx_entry < 0 then
				normal_x = 1
				normal_y = 0
			else 
				normal_x = -1
				normal_y = 0
			end
		else
			if ly_entry < 0 then
				normal_x = 0
				normal_y = 1
			else 
				normal_x = 0
				normal_y = -1
			end
		end

		o.is_coll = true
		return entry_time
	end
end



function dist_to_segment_squared(p, u, v) 
	--https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
	local l2 = dist_sq(u.x, u.y, v.x, v.y)
  	if l2 == 0 then 
	  	-- if len is 0 then just return the distance to u
  		return dist_sq(p.x, p.y, u.x, u.y) 
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
	-- Now that we have this point, all that rests to do is to
	-- compute its distance to p. Tada! 
	local proj = { 
		x = u.x + t * (v.x - u.x),
        y = u.y + t * (v.y - u.y) }
	return dist_sq(p.x, p.y, proj.x, proj.y)
end
function dist_to_segment(p, u, v) 
	return math.sqrt(dist_to_segment_squared(p, u, v))
end

function coll_rect_objects(o1, o2)
	return coll_rect(o1.x, o1.y, o1.w, o1.h, o2.x, o2.y, o2.w, o2.h)
end

function coll_rect(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 + w1 > x2 - h2
	   and x1 - w1 < x2 + w2 
	   and y1 - h1 < y2 + h2 
	   and y1 + h1 > y2 - h2
end

function draw_coll(x,y,w,h)
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