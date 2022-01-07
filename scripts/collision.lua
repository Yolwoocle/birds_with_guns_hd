require "scripts/utility"

function coll_rect(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1 + w1 > x2 
		and x1 < x2 + w2 
		and y1 < y2 + h2 
		and y1 + h1 > y2
end

function draw_coll(x,y,w,h)--{{{2
	love.graphics.rectangle("line",x,y,w,h)
end

function is_solid(map, x, y)
	y = y - DeletedMapBlock
    if (x < 0) or (nb_block_x < x) or (y < 0) or (nb_block_y < y) then
        return true
    end
	return get_map(map, x, y) == 1
end

function is_solid_rect(map, x, y, w, h)
    --[[
        A - i - B
        |       |
        j   ×   k
        |       |
        C - l - D
    ]]
    return 
        map:is_solid(x,     y) or   --A
        map:is_solid(x+w,   y) or   --B
        map:is_solid(x,     y+h) or --C
        map:is_solid(x+w,   y+h) or --D

        map:is_solid(x+w/2, y) or     --i
        map:is_solid(x,     y+h/2) or --j
        map:is_solid(x+w,   y+h/2) or --k
        map:is_solid(x+w/2, y+h/2)    --l
end
