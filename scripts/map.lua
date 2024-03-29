require "scripts.sprites"
require "scripts.constants"
require "scripts.files"
require "scripts.utility"

function init_map(w, h)
	local map = {}
	map.width = w
	map.height = h
	
	map.update = update_map
	map.draw = draw_map
	map.draw_with_y_sorted_objs = draw_with_y_sorted_objs
	map.chr_to_tile_number = chr_to_tile_number
	map.palette = {
		[0] = make_tile(0, ' ', spr_empty_16x16, {
			is_solid=false, is_destructible=false, is_transparent=false
		}),
		make_tile(1, '.', spr_floor_carpet, {
			is_solid=false, is_destructible=false, is_transparent=false, 
		}),
		make_tile(2, '#', spr_wall_1, {
			is_solid=true, is_destructible=false, is_transparent=false, 
			oy = 9,
		}),
		make_tile(3, 'b', sprs_box, {
			is_solid=true, is_destructible=true, is_transparent=true,
			type="multi_tile",
		}),
		make_tile(4, 'c', spr_chain, {
			is_solid=false, is_destructible=false, is_transparent=false
		}),
		make_tile(5, ',', spr_floor_metal, {
			is_solid=false, is_destructible=false, is_transparent=false 
		}),
		make_tile(6, 'H', sprs_shelf, {
			is_solid=true, is_destructible=false, is_transparent=true,
			type="multi_tile", oy=8,
		}),
		make_tile(7, '+', spr_door, {
			is_solid=true, is_destructible=true, is_transparent=true, 
		}),
		make_tile(8, 'p', spr_pot_cactus, {
			is_solid=true, is_destructible=true, is_transparent=true, 
			oy = 8,
		}),
		make_tile(9, 's', sprs_seat, {
			is_solid=true, is_destructible=false, is_transparent=true,
			oy=7,
		}),
		make_tile(10, '_', sprs_floor_concrete[1], {
			is_solid=false, is_destructible=false, is_transparent=false,
		}),
		make_tile(11, '=', spr_missing, { --Opening
			is_solid=false, is_destructible=false, is_transparent=false,
			tile_to_write_when_placed=2,
		}),
		make_tile(12, '$', spr_missing, { --Treasure
			is_solid=false, is_destructible=false, is_transparent=false,
			on_placed = function(self, map, x, y)
				map:set_tile(x, y, 1)
				interactable_list.chest:spawn((x+.5)*BLOCK_WIDTH, (y+.5)*BLOCK_WIDTH)
			end,
		}),
	}
	map.tile_size = map.palette[0]:get_spr():getWidth() * PIXEL_SCALE

	-- Initialize map grid
	map.grid = {}
	for i=0, h-1 do
		map.grid[i] = {}
		for j=0, w-1 do
			map.grid[i][j] = {
				type = TYPE_GRID_TILE,
				tile_obj = map.palette[0],
				[1] = 0, 
				[2] = 0
			}
		end
	end

	-- Tile management methods
	map.get_tile = get_tile
	map.get_grid_tile = get_grid_tile
	map.set_tile = set_tile
	map.is_solid = is_solid
	map.valid_tile = valid_tile
	map.generate_map = generate_map
	map.draw_room = draw_room
	
	-- Rooms
	map.rooms = {}
	map.write_room = write_room
	map.get_room_tile = get_room_tile
	map.get_room_width = get_room_width
	map.get_room_height = get_room_height
	map.load_from_file = load_from_file
	map.generate_path = generate_path
	map.spawn_mob = tile_spawn_mob
	map.generate_object = generate_object
	
	map.room_connector = map:load_from_file("connector_wagon.txt")[1]
	map.lvl1_rooms = map:load_from_file("lvl1_rooms.txt")
	map.lvl1_rooms_branch = map:load_from_file("lvl1_rooms_branch.txt")
	--map.lvl_arena = map:load_from_file("arena.txt")
	
	return map
end
function update_map(self)
	set_debug_canvas(self)
end
function draw_map(self)
	-- Compute the area on screen needed to be covered
	local x1 = floor(camera.x / BLOCK_WIDTH)
	local x2 = floor((camera.x + window_w) / BLOCK_WIDTH )
	local y1 = floor(camera.y / BLOCK_WIDTH)
	local y2 = floor((camera.y + window_h + 16) / BLOCK_WIDTH )
	
	x1 = clamp(0, x1, self.width-1)
	x2 = clamp(0, x2, self.width-1)
	y1 = clamp(0, y1, self.height-1)
	y2 = clamp(0, y2, self.height-1)
	
	for y = y1, y2 do
		for x = x1, x2 do
			local tile = self.grid[y][x][1]
			local var  = self.grid[y][x][2]
			
			tile = self.palette[tile]
			if tile then
				tile:draw(x, y, var, true)
			end
		end
	end
end

function draw_with_y_sorted_objs(self, objs)
	-- Draw non-solid floor
	self:draw()

	-- Draw solid walls with y-sorting
	local x1, x2, y1, y2 = camera:get_bounds()
	x1 = clamp(0, x1, self.width-1)
	x2 = clamp(0, x2, self.width-1)
	y1 = clamp(0, y1, self.height-1)
	y2 = clamp(0, y2, self.height-1)

	local i = 1
	for y = y1, y2 do
		for x = x1, x2 do
			local tile = self.grid[y][x][1]
			local var  = self.grid[y][x][2]
			
			tile = self.palette[tile]
			if tile and tile.is_solid then
				tile:draw(x, y, var)
			end
		end

		local next_y = (y+1)*BLOCK_WIDTH
		while i <= #objs and objs[i].y <= next_y do
			objs[i]:draw()
			i=i+1
		end
	end
end

function make_tile(n, symb, spr, a)
	if type(spr) ~= "table" then   spr = {spr}   end
 
	spr = spr or spr_missing
	local tile = {}
	tile.n = n
	tile.symb = symb
	tile.type = a.type
	tile.spr = spr or spr_missing
	tile.is_solid = a.is_solid
	tile.is_destructible = a.is_destructible
	tile.is_transparent  = a.is_transparent
	tile.random_var = a.random_var

	-- Offsets
	tile.ox = a.ox or 0
	tile.oy = a.oy or 0
	if not a.ox then 
		tile.ox = spr[1]:getWidth() - BLOCK_WIDTH
	end
	if not a.oy then 
		tile.oy = spr[1]:getHeight() - BLOCK_WIDTH 
	end

	-- Methods
	tile.on_placed = a.on_placed

	tile.draw = function(self, x, y, var, is_background_layer, floor_spr)
		local floor_spr = floor_spr or spr_floor_carpet
		
		local spr = self:get_spr(var)
		if spr == nil then  spr = spr_missing  end
		
		-- Floor tile if transparent
		if self.is_transparent and is_background_layer then
			love.graphics.draw(floor_spr, x*BLOCK_WIDTH, y*BLOCK_WIDTH, 0,1,1)
		end

		love.graphics.draw(spr, x*BLOCK_WIDTH, y*BLOCK_WIDTH, 0,1,1, self.ox, self.oy)
	end

	tile.get_random_var = function(self)
		if not self.random_var then
			return nil
		end
		return random_weighted(self.random_var)
	end
		
	tile.get_spr = function(self, var)
		var = var or 1
		var = max(var, 1)
		local spr = self.spr[var]
		if spr then	
			return spr
		end
		return spr_missing
	end
	
	return tile
end

function chr_to_tile_number(self,chr)
	for i,tile in pairs(self.palette) do
		if tile.symb == chr then
			return tile.n
		end
	end
	return 0
end

function set_tile(self, x, y, elt, var)
	-- Sanitize inputs
	x = floor(x)
	y = floor(y)	
	var = var or 1
	if elt == 11 then   elt = 2   end -- Doors between rooms
	if x<0 or self.width<x or y<0 or self.height<y then
		warn(concat("set_tile coordinates outside map bounds: (",x,",",y,")"))
	end

	local new_tileobj = self.palette[elt]
	local old_tileobj = self:get_tile(x,y)
	local old_gridtile = self:get_grid_tile(x,y)

	-- Update collision world
	if new_tileobj.is_solid and not old_tileobj.is_solid then
		collision:join_world(old_gridtile, x*BLOCK_WIDTH, y*BLOCK_WIDTH, BLOCK_WIDTH, BLOCK_WIDTH)
	end
	if not new_tileobj.is_solid and old_tileobj.is_solid then
		collision:leave_world(old_gridtile)
	end 

	-- Write to table
	self.grid[y][x][1] = elt
	self.grid[y][x][2] = var
	self.grid[y][x].tileobj = self.palette[elt]

	-- Run custom function if defined
	if new_tileobj.on_placed then   new_tileobj:on_placed(self, x, y)   end
end

function get_tile(self, x, y)
	local default = self.palette[0]
	if x == nil or y == nil 
		or x < 0 or x >= self.width 
		or y < 0 or y >= self.height
	then 
		return default 
	end
	
	-- Get the tile object from the palette
	local tile = self.grid[floor(y)][floor(x)][1]
	tile = self.palette[tile]

	if tile == nil then  return default  end --error(tostr(a)) end
	return tile
end	
function get_grid_tile(self, x, y)
	-- Returns a table in the form {num, var}: 
	-- num: ID of the tile
	-- var: variation number
	local default = self.palette[0]
	if x == nil or y == nil 
		or x < 0 or x >= self.width 
		or y < 0 or y >= self.height
	then 
		return default
	end
	
	local tile = self.grid[floor(y)][floor(x)]
	return tile
end	
function is_solid(self, x, y)
	return self:get_tile(floor(x), floor(y)).is_solid
end
function is_destructible(self, x, y)
	return self:get_tile(floor(x), floor(y)).is_destructible
end
function valid_tile(self, tile)
	if tile == nil then  return false  end 
	return 1 <= tile and tile <= #self.palette 
end

function update_map(self)

end

-------------------------------------------------------------------------
---------------------------- Map Generation -----------------------------
-------------------------------------------------------------------------

function generate_map(self, seed)
	local rooms_source = self.lvl1_rooms
	local layout_width = 12
	local layout_height = 12

	self.seed = seed

	-- Init random number generator
	local rng
	if seed then
		rng = love.math.newRandomGenerator(seed)  
	else 
		-- The default seed in LÖVE 11.x is the following low/high pair: 0xCBBF7A44, 0x0139408D
		rng = love.math.newRandomGenerator()
	end
	--generate_path(self, rng, self.lvl1_rooms, 0, 0, 5, 5)

	local layout = table_2d_0(layout_width, layout_height, 0)

	-- Generate randomly shuffled list of all rooms
	local rooms = {}
	for i=2, #rooms_source do --We don't include 1 bc it's the starting area
		table.insert(rooms, rooms_source[i]) 
	end
	shuffle(rooms)

	-- Write main path
	local room_id = 1
	local cur_x = 0
	local w,h = ROOM_W, ROOM_H
	for ix=1,layout_width-1 do
		layout[MAIN_PATH_Y][ix] = 1  
		self:write_room(rooms[room_id], ix*w, MAIN_PATH_Y*h, rng)
		
		room_id = room_id + 1
		cur_x = cur_x + self:get_room_width(rooms[room_id])
	end
	-- Connector wagon
	local x, y = cur_x, MAIN_PATH_Y*h
	self:write_room(self.room_connector, x, y)
	interactable_list.end_of_level:spawn(x*BLOCK_WIDTH, y*BLOCK_WIDTH + ROOM_PIXEL_H/2)

	-- Starting area
	self:write_room(rooms_source[1], 0, MAIN_PATH_Y*h, rng)

	--					Branch   + Dead end
	--				  +-------+	 |
	--	Main path ====+=======+=====+=======
	--
	-- Generate branches below and above
	for dir = -1, 1, 2 do 
		local branch_y = MAIN_PATH_Y + dir

		local ix = rng:random(1,4)
		while ix < layout_width do
			if layout[branch_y][ix] and false --[[←←← REVOME THIS TO ENABLE BRANCHES]] then
				local pathlen = rng:random(2,5)

				-- Generate a branch
				for i=0, pathlen-1 do
					layout[branch_y][ix+i] = 1
					self:write_room(rooms[room_id], (ix+i)*w, branch_y*h, rng)

					-- Re-shuffle rooms if all of them have been used
					room_id = room_id + 1
					if room_id > #rooms then
						room_id = 1
						shuffle(rooms)
					end
				end

				-- Openings
				--(upper_x, upper_y)
				--  X---------
				--  |        |
				--  X---==----
				--(upper_x, bottom_y)
				---- Entrance
				local entr_x = ix*w 
				local upper_y = branch_y*h
				local bottom_y = branch_y*h + h - 1 
				if dir == -1 then
					self:set_tile(entr_x+14, bottom_y,   1)
					self:set_tile(entr_x+14, bottom_y+1, 1)
					self:set_tile(entr_x+15, bottom_y,   1)
					self:set_tile(entr_x+15, bottom_y+1, 1)
				else
					self:set_tile(entr_x+14, upper_y,   1)
					self:set_tile(entr_x+14, upper_y-1, 1)
					self:set_tile(entr_x+15, upper_y,   1)
					self:set_tile(entr_x+15, upper_y-1, 1)
				end
				---- Exit 
				local exit_x = (ix+pathlen-1)*w
				if dir == -1 then
					self:set_tile(exit_x+14, bottom_y,   1)
					self:set_tile(exit_x+14, bottom_y+1, 1)
					self:set_tile(exit_x+15, bottom_y,   1)
					self:set_tile(exit_x+15, bottom_y+1, 1)
				else
					self:set_tile(exit_x+14, upper_y,   1)
					self:set_tile(exit_x+14, upper_y-1, 1)
					self:set_tile(exit_x+15, upper_y,   1)
					self:set_tile(exit_x+15, upper_y-1, 1)
				end

				ix = ix + pathlen
			end
			ix = ix + rng:random(1,4)
		end
	end
end

function generate_path(self, rng, rooms, x, y, nb_room_min, nb_room_max, table_min_index, table_max_index)
	table_min_index = table_min_index or 1   
	table_max_index = table_max_index or #rooms   
	-- Start by generating a random layout for the main path
	-- We get all possible rooms and shuffle them 
	local room_ids = {}
	for i=table_min_index, table_max_index do
		table.insert(room_ids, i)
	end
	shuffle(room_ids, rng)
	
	local len_path = rng:random(nb_room_min, nb_room_max)
	len_path = clamp(0, len_path, #rooms)

	local ix = x
	for i=1, len_path do
		local room = rooms[room_ids[i]]
		self:write_room(room, ix, y, rng)
		ix = ix + self:get_room_width(room)
	end

	return {x=ix}
end

function tile_spawn_mob(self, rng, x, y)
	local bw = BLOCK_WIDTH 
	local valid_x = (x > ROOM_W*1.5)
	if not self:get_tile(x, y).is_solid and valid_x and rng:random(100)==1 then
		spawn_random_mob(x*bw + bw/2, y*bw + bw/2)
	end
end
function get_room_tile(self, room, x, y)
	return room[y][x]
end
function write_room(self, room, x, y, rng)
	x = x or 0
	y = y or 0 
	for iy = 0, #room do
		for ix = 0, #room[0] do 
			local tile = self:get_room_tile(room, ix, iy)
			self:set_tile(x+ix, y+iy, tile[1], tile[2])
			if rng then
				self:generate_object(rng, x+ix, y+iy)
			end
		end
	end
end
function generate_object(self, rng, x, y)
	--Generate monsters, loot, etc.
	if rng then
		self:spawn_mob(rng, x, y)
	end
end

function get_room_width(self, room)
	return #room[0] + 1
end
function get_room_height(self, room)
	return #room + 1
end

function draw_room(self, room, x, y)
	x = x or 0
	y = y or 0 
	for iy = 0, #room do
		for ix = 0, #room[0] do 
			local tile, var = self:get_room_tile(room, ix, iy)
			tile = self.palette[tile]
			
			if tile then
				tile:draw(x, y, var, true)
			end
		end
	end
end

function load_from_file(self, file)
	-- . ground   # wall
	-- b box	  c chain
	--[[ example:
		# # # # # # # # #
		# . . . b b . . #
		# . . . . . . . #
		# # # # # # # # #
	]]
	local rooms = {{}}
	local room = 1
	local y = 0
	for line in love.filesystem.lines("assets/rooms/"..file) do
		if #line == 0 then 
			room = room + 1 
			y = 0
			rooms[room] = {}
		else
			rooms[room][y] = {}
			local x = 0
			for i=1, #line, 2 do
				local chr = string.sub(line, i, i)
				local var = tonumber(string.sub(line, i+1, i+1))
				if not var then  var = 1  end

				local tile = self:chr_to_tile_number(chr)
				
				tile_obj = self.palette[tile]
				local rnd_var = tile_obj:get_random_var()
				if rnd_var then   var = rnd_var   end

				rooms[room][y][x] = {tile, var}
				x = x + 1

				-- Opening flags 
				if chr == "=" then
					if y == 0 then
						rooms[room].open_up = true
					else
						rooms[room].open_down = true
					end
				end
			end
			y = y + 1
		end
	end
	return rooms
end

function print_room(self, room)
	if room then
	for i,line in ipairs(room) do
		local s = ""
		if room[1] then
		for j,v in ipairs(room[i]) do
			local tile, var = v[1], v[2]
			s = s..self.palette[tile].symb
			if var > 1 then
				s = s..tostring(var)
			else 
				s = s.." "
			end
		end
		end
	end
	end
end