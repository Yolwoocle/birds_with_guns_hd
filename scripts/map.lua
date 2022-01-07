function init_map(w, h)
	local map = {}
	for i=1,h do
		table.insert(map, {})
		for j=1,w do
			table.insert(map[i], 0)
		end
	end

	map.draw = draw_map
	return map
end

function set_map(self, x, y)

end	
function get_map(self, x, y)

end	

function draw_map(self)
	for i,row in ipairs(self) do 
		
	end
end

function load_map_from_string(str)
	--TODO: implement
end