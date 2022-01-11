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
	map.tiles = {
		[0] = make_tile(0, spr_ground_dum, false, false),
		make_tile(1, sprs_floor_wood, false, false),
		make_tile(2, spr_wall_dum, true, false),
		make_tile(3, spr_box,      true, true),
	}
	map.width = w
	map.height = h
	map.tile_size = map.tiles[0].spr:getWidth() * pixel_scale

	map.get_tile = get_tile
	map.set_tile = set_tile
	map.is_solid = is_solid
	map.load_from_string = load_from_string
	return map
end

function set_tile(self, x, y, elt)
	self.data[floor(y)][floor(x)] = elt
end	
function get_tile(self, x, y)
	local default = self.tiles[0]
	if x == nil or y == nil then return default end
	if x < 0            then return default end
	if x >= self.width  then return default end
	if y < 0            then return default end
	if y >= self.height then return default end
	
	local tile = self.data[floor(y)][floor(x)]
	if tile == nil then return default end
	return self.tiles[tile]
end	

function is_solid(self, x, y)
	return self:get_tile(floor(x), floor(y)).is_solid
end
function is_destructible(self, x, y)
	return self:get_tile(floor(x), floor(y)).is_destructible
end

function draw_map(self)
	local w = self.tile_size
	for y=0, self.height-1 do 
		for x=0, self.width-1 do
			local tile = self:get_tile(x, y)
			if type(tile.spr) == "table" then
				--print(type(tile))
				local sprs = tile.spr_size
				local spr = tile.spr[ (y%sprs)*sprs + x%sprs + 1 ]
				if spr == nil then spr = spr_wall_dum end
				love.graphics.draw(spr, x*w, y*w, 0, pixel_scale)
			else
				love.graphics.draw(tile.spr, x*w, y*w, 0, pixel_scale)
			end
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
			if     chr == "." then tile = 1
			elseif chr == "#" then tile = 2
			elseif chr == "b" then tile = 3
			end

			self:set_tile(x, y, tile)
			x = x + 1
		end
		y = y + 1
	end
end

------
function make_tile(n, spr, is_solid, is_destructible)
	local tile = {
		n = n,
		spr = spr,
		is_solid = is_solid,
		is_destructible = is_destructible,
	}
	if type(spr) == "table" then
		if #spr == 4 then      tile.spr_size = 2 
		elseif #spr == 9 then  tile.spr_size = 3 
		elseif #spr == 16 then tile.spr_size = 4 
		else tile.spr_size = floor(math.sqrt(#spr))
		end
	end 
	return tile
end