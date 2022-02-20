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
	--print("iy", y1, y2, bw*sgn_y)
	--print("ix", x1, x2, bw*sgn_x)
	for iy = y1, y2, bw*sgn_y do
	for ix = x1, x2, bw*sgn_x do
		--print("", "loop", ix, iy)
		if map:is_solid(ix/bw, iy/bw) then
			local b = {
				x = floor(ix/bw)*bw, 
				y = floor(iy/bw)*bw,
				w = bw, h = bw,
			}

			rect_color("line",b.x,b.y,b.w,b.h, {1,0,0})
			local entry_time, normal_x, normal_y = swept_aabb(o,b)
			if entry_time then
				if math.abs(normal_x) > 0 then
					o.dx = o.dx * entry_time 
				end
				if math.abs(normal_y) > 0 then
					o.dy = o.dy * entry_time 
				end
			end
		end
	end
	end
	obj.x = o.x + obj.w
	obj.y = o.y + obj.h 
	obj.dx = o.dx
	obj.dy = o.dy
end

--[[
	moves rectangle A by (dx, dy) and checks for a collision
	with rectangle B.
	if no collision occurs, returns false.
	if a collision does occur, returns:
	- the time within the movement when the collision occurs (from 0-1)
	- the x component of the normal vector
	- the y component of the normal vector
	the goal is to find the time range in which rectangle A
	is overlapping rectangle B on the X axis, and the time range
	in which they overlap on the Y axis. when they're overlapping
	on both axes, that's when there's a collision, and the beginning
	of that time range is when the collision starts, which is
	what we want to return.
]]
function swept_aabb(a, b)
	------------------------------------------------------------------------------------------------------
	-- !!! I didn't write this
	-- Thanks to https://gist.github.com/tesselode/e1bcf22f2c47baaedcfc472e78cac55e#file-swept-aabb-lua --
	------------------------------------------------------------------------------------------------------
	local entry_time_x, exit_time_x, entry_time_y, exit_time_y
	--[[
		first let's find out when the rectangles start and stop overlapping
		on the X axis.
	]]
	local dt = love.timer.getDelta()
	local dx = a.dx
	local dy = a.dy
	if dx == 0 then
		--[[
			if rectangle A isn't moving on the X axis and it's already overlapping
			rectangle B on the X axis, then we'll just say it started overlappnig
			forever ago and will never stop overlapping.
		]]
		if a.x < b.x + b.w and b.x < a.x + a.w then
			entry_time_x = -math.huge
			exit_time_x = math.huge
		--[[
			if rectangle A isn't moving on the X axis *and* it's not already
			overlapping, then A will never collide with B, so we can just stop now.
		]]
		else
			return false
		end
	else
		--[[
			otherwise, we know that the amount of distance rectangle
			A has travel to overlap rectangle B on this axis is the
			distance between the near sides of the boxes.
			if A is moving right, then the distance is the left edge of
			B minus the right edge of A. if A is moving left, then it's
			the left edge of A minus the right edge of B.
		]]
		local entry_distance_x
		if dx*dt > 0 then
			entry_distance_x = b.x - (a.x + a.w)
		else
			entry_distance_x = a.x - (b.x + b.w)
		end
		--[[
			once we have the distance rectangle A has to travel to overlap
			with rectangle B on the X axis, we can figure out the time it
			takes to overlap, which is distance / speed. in this case,
			speed is the amount we're travelling on the X axis in this
			movement, which is the absolute value of dx.
		]]
		entry_time_x = entry_distance_x / math.abs(dx*dt)
		--[[
			as you might guess, the exit distance is the distance between the
			far sides of the rectangles.
		]]
		local exitDistanceX
		if dx*dt > 0 then
			exitDistanceX = b.x + b.w - a.x
		else
			exitDistanceX = a.x + a.w - b.x
		end
		-- and the exit time is just distance / speed again
		exit_time_x = exitDistanceX / math.abs(dx*dt)
	end
	-- now we'll do the same for the y-axis.
	if dy*dt == 0 then
		if a.y < b.y + b.h and b.y < a.y + a.h then
			entry_time_y = -math.huge
			exit_time_y = math.huge
		else
			return false
		end
	else
		local entry_distance_y
		if dy*dt > 0 then
			entry_distance_y = b.y - (a.y + a.h)
		else
			entry_distance_y = a.y - (b.y + b.h)
		end
		entry_time_y = entry_distance_y / math.abs(dy*dt)
		local exit_distance_y
		if dy*dt > 0 then
			exit_distance_y = b.y + b.h - a.y
		else
			exit_distance_y = a.y + a.h - b.y
		end
		exit_time_y = exit_distance_y / math.abs(dy*dt)
	end
	--[[
		now we have the separate time ranges when rectangles A and B
		overlap on each axis. the time range when they're actually colliding
		is when both time ranges overlap. if the time ranges never overlap,
		there's no collision. we can check this the same way we check
		for overlapping boxes.
	]]
	if entry_time_x > exit_time_y or entry_time_y > exit_time_x then return false end
	--[[
		if they do collide, then the time when they start colliding must be
		the later of the two entry times. after all, upon the first entry time,
		the rectangles are only overlapping on one axis.
	]]
	local entry_time = math.max(entry_time_x, entry_time_y)
	--[[
		if the entry time is outside of the range 0-1, that means no collision
		happens within this span of movement.
	]]
	if entry_time < 0 or entry_time > 1 then return false end
	--[[
		the last step is to get the normal vector. the normal vector is a
		unit vector pointing left, right, up, or down that represents which
		way rectangle B would push rectangle A to stop it from moving.
		we know whether the collision is horizontal or vertical from which
		entry happens last, and we know the sign of the vector from the
		direction rectangle A moved.
	]]
	local normal_x, normal_y = 0, 0
	if entry_time_x > entry_time_y then
		normal_x = dx*dt > 0 and -1 or 1
	else
		normal_y = dy*dt > 0 and -1 or 1
	end
	return entry_time, normal_x, normal_y
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
	local blk_w = block_width or 16
	x = x / blk_w
	y = y / blk_w
	w = w / blk_w
	h = h / blk_w

    local collision_positions = { 
		{x-w, y-h}, --A
        {x+w, y-h}, --B
        {x-w, y+h}, --C
        {x+w, y+h}, --D

		-- Remove lower half if optimisation needed
        {x,   y-h}, --i
        {x-w, y  }, --j
        {x+w, y  }, --k
        {x,   y+h}, --l
	}
	
	local collision_happened = false
	local collision_coordinates = {nil, nil}
	for i,pos in pairs(collision_positions) do
		local is_solid = map:is_solid(pos[1], pos[2])
		collision_happened = collision_happened or is_solid
		if collision_happened then
			collision_coordinates = {x=floor(pos[1]), y=floor(pos[2])}
		end
	end

	return collision_happened, collision_coordinates
end

function collide_object(o,bounce)
	--TODO: replace with Swept AABB collisions
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
	local coll_x, x_block = is_solid_rect(map, nextx, o.y, o.w, o.h)
	local coll_y, y_block = is_solid_rect(map, o.x, nexty, o.w, o.h)
	local coll_xy, xy_block = is_solid_rect(map, nextx, nexty, o.w, o.h)
	
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
	return coll_x or coll_y or coll_xy, {x_block, y_block, xy_block}
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


--[[function collision_response(obj, map)
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
	] ]
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
--]]