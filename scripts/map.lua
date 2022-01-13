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
	map.width = w
	map.height = h
	
	map.draw = draw_map
	map.tiles = {
		[0] = make_tile(0, spr_ground_dum, {is_solid = false, is_destructible = false, is_transparent = true}),
		make_tile(1, sprs_floor_wood, {is_solid = false, is_destructible = false, is_transparent = false}),
		make_tile(2, spr_wall_dum, {is_solid = true, is_destructible = false, is_transparent = false}),
		make_tile(3, spr_box,      {is_solid = true, is_destructible = true, is_transparent = true}),
	}
	map.tile_size = map.tiles[0].spr:getWidth() * pixel_scale
	
	map.chunks = {}
	map.write_chunk = write_chunk
	map.get_chunk_tile = get_chunk_tile
	map.get_chunk_width = get_chunk_width
	map.get_chunk_height = get_chunk_height

	map.get_tile = get_tile
	map.set_tile = set_tile
	map.is_solid = is_solid
	map.load_from_file = load_from_file
	map.generate_map = generate_map
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
	local x1 = floor(camera.x / block_width)
	local x2 = floor((camera.x + window_w) / block_width )
	for y=0, self.height-1 do 
		for x=x1, x2 do
			local tile = self:get_tile(x, y)
			
			if tile.is_transparent then
				draw_tile(self.tiles[1], x, y, w)
			end
			draw_tile(tile, x*w, y*w)
		end
	end
end

function draw_tile(tile, x, y, w)
	if type(tile.spr) == "table" then
		--print(type(tile))
		local sprs = tile.spr_size
		local spr = tile.spr[ (y%sprs)*sprs + x%sprs + 1 ]
		if spr == nil then spr = spr_wall_dum end
		love.graphics.draw(spr, x, y)
	else
		love.graphics.draw(tile.spr, x, y)
	end
end

function load_from_file(self, file)
	--TODO:Optimize if needed? This seems to add a lot to the loading time 
	--but maybe it's just because my laptop is crap
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
	self.chunks = {{}}
	local chunk = 1
	local y = 0
	for line in love.filesystem.lines("assets/chunks/"..file) do
		if #line == 0 then 
			chunk = chunk + 1 
			y = 0
			self.chunks[chunk] = {}
		else
			self.chunks[chunk][y] = {}
			local x = 0
			for i=1, #line, 2 do
				local chr = string.sub(line, i, i)
				local tile = 0
				if     chr == "." then tile = 1
				elseif chr == "#" then tile = 2
				elseif chr == "b" then tile = 3
				end
				
				self.chunks[chunk][y][x] = tile
				x = x + 1
			end
			y = y + 1
		end
	end
end

function get_chunk_tile(self, n, x, y)
	return self.chunks[n][y][x]
end

function write_chunk(self, n, x, y)
	x = x or 0
	y = y or 0
	local chunk = self.chunks[n]
	for iy = 0, #chunk do
		for ix = 0, #chunk[0] do
			self:set_tile(x+ix, y+iy, self:get_chunk_tile(n,ix,iy))
		end
	end
end

function get_chunk(self, n)
	return self.chunks[n]
end
function get_chunk_width(self, n)
	return #self.chunks[n][0]+1
end
function get_chunk_height(self, n)
	return #self.chunks[n]+1
end

function generate_map(self, wagon, seed)
	local chunk_ids = {} 
	for i=1, #self.chunks do
		table.insert(chunk_ids, i)
	end

	local rng = seed and love.math.newRandomGenerator(seed) or nil
	shuffle(chunk_ids, rng)
	
	local len_wagon = 5
	len_wagon = min(#chunk_ids, len_wagon)
	local x = 0
	for i=1, len_wagon do
		local chunk = chunk_ids[i]
		self:write_chunk(chunk, x)
		x = x + self:get_chunk_width(chunk)
	end
end

------
function make_tile(n, spr, a)
	local tile = {
		n = n,
		spr = spr,
		is_solid = a.is_solid,
		is_destructible = a.is_destructible,
		is_transparent = a.is_transparent,
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