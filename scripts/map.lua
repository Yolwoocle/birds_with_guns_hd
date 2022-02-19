require "scripts/sprites"
require "scripts/settings"
require "scripts/files"
require "scripts/utility"

function init_map(w, h)
	local map = {grid = {}}
	for i=0, h-1 do
		map.grid[i] = {}
		for j=0, w-1 do
			map.grid[i][j] = {0, 0}
		end
	end
	map.width = w
	map.height = h
	
	map.update = update_map
	map.draw = draw_map
	map.draw_with_y_sorted_objs = draw_with_y_sorted_objs
	map.palette = {
		[0] = make_tile(0, ' ', spr_ground_dum, {
			is_solid=true, is_destructible=false, is_transparent=false
		}),
		make_tile(1, '.', sprs_floor_concrete, {
			is_solid=false, is_destructible=false, is_transparent=false, 
			type="multi_tile", random_var = {30, 2, 2, 1, 1}
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
			type="multi_tile" 
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
		make_tile(10, '_', spr_ground_wood, {
			is_solid=false, is_destructible=false, is_transparent=false,
		})
	}
	map.tile_size = map.palette[0].spr:getWidth() * pixel_scale

	map.get_tile = get_tile
	map.set_tile = set_tile
	map.is_solid = is_solid
	map.valid_tile = valid_tile
	map.generate_map = generate_map
	
	map.rooms = {}
	map.write_room = write_room
	map.get_room_tile = get_room_tile
	map.get_room_width = get_room_width
	map.get_room_height = get_room_height
	map.load_from_file = load_from_file
	map.generate_path = generate_path
	map.spawn_mob = tile_spawn_mob
	
	map.lvl1_rooms = map:load_from_file("lvl1_rooms_1.txt")
	map.lvl1_rooms_branch = map:load_from_file("lvl1_rooms_branch.txt")
	--map.lvl_arena = map:load_from_file("arena.txt")
	
	return map
end
function update_map(self)
	set_debug_canvas(self)
end
function draw_map(self)
	-- Compute the area on screen needed to be covered
	local x1 = floor(camera.x / block_width)
	local x2 = floor((camera.x + window_w) / block_width )
	local y1 = floor(camera.y / block_width)
	local y2 = floor((camera.y + window_h + 16) / block_width )
	
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
	local x1 = floor(camera.x / block_width)
	local x2 = floor((camera.x + window_w) / block_width )
	local y1 = floor(camera.y / block_width)
	local y2 = floor((camera.y + window_h + 16) / block_width )
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

		local next_y = (y+1)*46
		while i <= #objs and objs[i].y <= next_y do
			objs[i]:draw()
			i=i+1
		end
	end
end


function make_tile(n, symb, spr, a)
	local tile = {
		n = n,
		symb = symb,
		type = a.type,
		spr = spr or spr_missing,
		is_solid = a.is_solid,
		is_destructible = a.is_destructible,
		is_transparent  = a.is_transparent,
		random_var = a.random_var,
		ox = a.ox or 0, 
		oy = a.oy or 0, 

		draw = draw_tile,
		get_random_var = get_random_var,
	}
	return tile
end
function draw_tile(self, x, y, var, is_background_layer, floor_spr)
	-- self refers to tile
	local spr
	local floor_spr = floor_spr or sprs_floor_concrete[1]
	if type(self.spr) == "table" then 
		spr = self.spr[var]
	else
		spr = self.spr
	end
	if spr == nil then  spr = spr_missing  end
	
	if self.is_transparent and is_background_layer then
		love.graphics.draw(floor_spr, x*block_width, y*block_width, 0,1,1)
	end
	-- TODO: optimise map by baking into canvas & update on change
	love.graphics.draw(spr, x*block_width, y*block_width, 0,1,1, self.ox, self.oy)
end

function get_random_var(self)
	if not self.random_var then
		return nil
	end
	-- Compute sum of weights
	local sum = 0
	for _,w in pairs(self.random_var) do   sum = sum + w   end

	for i=1, #self.random_var do
		if love.math.random() <= self.random_var[i]/sum then
			return i
		end
	end
	return 1
end

function set_tile(self, x, y, elt, var)
	self.grid[floor(y)][floor(x)][1] = elt
	if var then
		self.grid[floor(y)][floor(x)][2] = var
	end
end 
function get_tile(self, x, y)
	local default = self.palette[0]
	if x == nil or y == nil 
		or x < 0 or x >= self.width 
		or y < 0 or y >= self.height
	then 
		return default 
	end
	
	local tile = self.grid[floor(y)][floor(x)][1]
	tile = self.palette[tile]

	if tile == nil then return default end --error(tostr(a)) end
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
	-- The default seed in LÖVE 11.x is the following low/high pair: 0xCBBF7A44, 0x0139408D
	local rng
	if seed then
		rng = love.math.newRandomGenerator(seed)  
	else 
		rng = love.math.newRandomGenerator()
	end

	self:write_room(self.lvl1_rooms[1], 0, 0, rng)
	self:generate_path(rng, self.lvl1_rooms, 30, 0, 2,2, 2)
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
	local bw = block_width 
	if not self:get_tile(x, y).is_solid and rng:random(100)==1 then
		table.insert(mobs, mob_list.fox:spawn(x*bw + bw/2, y*bw + bw/2))
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
				self:spawn_mob(rng, x+ix, y+iy)
			end
		end
	end
end

function get_room_width(self, room)
	return #room[0] + 1
end
function get_room_height(self, room)
	return #room + 1
end

function load_from_file(self, file)
	-- . ground   # wall
	-- b box      c chain
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

				local tile = 0
				if	 chr == " " then tile = 0
				elseif chr == "." then tile = 1 --floor
				elseif chr == "#" then tile = 2 --wall
				elseif chr == "b" then tile = 3 --box
				elseif chr == "c" then tile = 4 --chain
				elseif chr == "," then tile = 5 --floor metal
				elseif chr == "H" then tile = 6 --shelf
				elseif chr == "+" then tile = 7 --door
				elseif chr == "p" then tile = 8 --potted cactus
				elseif chr == "s" then tile = 9 --seats
				elseif chr == "_" then tile = 10 --wooden floor
				end
				
				tile_obj = self.palette[tile]
				local rnd_var = tile_obj:get_random_var()
				if rnd_var then   var = rnd_var   end

				rooms[room][y][x] = {tile, var}
				x = x + 1
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