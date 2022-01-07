require "scripts/sprites"
require "scripts/settings"

function init_map(w, h)
	local map = {data = {}}
	for i=0, h-1 do
		map.data[i] = {}
		for j=0, w-1 do
			map.data[i][j] = 0
		end
	end

	map.draw = draw_map
	map.palette = {
		[0] = spr_ground_dum,
		spr_wall_dum,
	}
	map.width = w
	map.height = h
	map.tile_size = map.palette[0]:getWidth() * pixel_scale

	map.get_tile = get_map
	map.set_tile = set_map
	return map
end

function set_map(self, x, y, elt)
	self.data[y][x] = elt
end	
function get_map(self, x, y)
	if x < 0            then return 0 end
	if x >= self.width  then return 0 end
	if y < 0            then return 0 end
	if y >= self.height then return 0 end

	return self.data[y][x]
end	

function draw_map(self)
	local w = self.tile_size
	for i=0, self.height-1 do 
		for j=0, self.width-1 do
			local tile = self:get_tile(j, i)
			love.graphics.draw(self.palette[tile], i*w, j*w, 0, pixel_scale)
		end
	end
end

function load_map_from_string(str)
	--TODO: implement
	-- . ground
	-- # wall
	-- c crate
	--[[ example:
		# # # # # # # # #
		# . . . c c . . #
		# . . . . . . . #
		# . . . . . . . #
		# # # # # # # # #
	]]
end