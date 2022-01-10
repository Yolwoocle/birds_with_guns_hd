require "scripts/sprites"
require "scripts/settings"
require "scripts/files"

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
		spr_box,
	}
	map.width = w
	map.height = h
	map.tile_size = map.palette[0]:getWidth() * pixel_scale

	map.get_tile = get_tile
	map.set_tile = set_tile
	map.is_solid = is_solid
	map.load_from_string = load_from_string
	return map
end

function set_tile(self, x, y, elt)
	self.data[y][x] = elt
end	
function get_tile(self, x, y)
	if x < 0            then return 0 end
	if x >= self.width  then return 0 end
	if y < 0            then return 0 end
	if y >= self.height then return 0 end

	return self.data[y][x]
end	

function is_solid(self, x, y)
	return self:get_tile(floor(x), floor(y)) == 1
end

function draw_map(self)
	local w = self.tile_size
	for y=0, self.height-1 do 
		for x=0, self.width-1 do
			local tile = self:get_tile(x, y)
			love.graphics.draw(self.palette[tile], x*w, y*w, 0, pixel_scale)
		end
	end
end

function load_from_string(self, str)
	--TODO: implement
	-- . ground
	-- # wall
	-- b box
	--[[ example:
		# # # # # # # # #
		# . . . b b . . #
		# . . . . . . . #
		# . . . . . . . #
		# # # # # # # # #
	]]
	local y = 0
	for line in love.filesystem.lines("assets/chunks/chunk_1.txt") do
		local x = 0
		for i=1, #line, 2 do
			local chr = string.sub(line, i, i)
			local tile = 0
			if     chr == "." then tile = 0 
			elseif chr == "#" then tile = 1
			elseif chr == "b" then tile = 2
			end

			self:set_tile(x, y, tile)
			x = x + 1
		end
		y = y + 1
	end
end