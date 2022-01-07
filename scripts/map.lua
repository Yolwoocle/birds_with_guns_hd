require "scripts/sprites"

function init_map(w, h)
	local map = {data = {}}
	for i=1,h do
		table.insert(map.data, {})
		for j=1,w do
			table.insert(map.data[i], 0)
		end
	end

	map.draw = draw_map
	map.palette = {
		[0] = spr_ground_dum,
	}
	return map
end

function set_map(self, x, y, elt)
	self.data[y][x] = elt
end	
function get_map(self, x, y)
	return self.data[y][x]
end	

function draw_map(self)
	for i,row in ipairs(self.data) do 
		for j,tile in ipairs(row) do 
			love.graphics.draw(self.palette[tile])
		end
	end
end

function load_map_from_string(str)
	--TODO: implement
end