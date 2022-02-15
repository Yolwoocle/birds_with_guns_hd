require "scripts/utility"
require "scripts/map"
require "scripts/mob_list"

----------- Map Generation ------------
function generate_map(self, seed)
	-- The default seed in LÖVE 11.x is the following low/high pair: 0xCBBF7A44, 0x0139408D
	local rng
	if seed then
		rng = love.math.newRandomGenerator(seed)  
	else 
		rng = love.math.newRandomGenerator()
	end

	self:write_room(self.lvl_arena[1], 0, 0, rng)
end

function generate_path(self, rng, rooms, x, y, n_room_min, n_room_max)
	-- Start by generating a random layout for the main path
	-- We get all possible rooms and shuffle them 
	local room_ids = {} 
	for i=1, #rooms do
		table.insert(room_ids, i)
	end
	shuffle(room_ids, rng)
	
	local len_path = rng:random(n_room_min, n_room_max)
	len_path = min(len_path, #rooms)

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
			local tile = self:get_room_tile(room,ix,iy)
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
			for i=1, self.width*2, 2 do
				local chr = string.sub(line, i, i)
				local var = tonumber(string.sub(line, i+1, i+1))
				if not var then  var = 1  end

				local tile = 0
				if	 chr == " " then tile = 0
				elseif chr == "." then tile = 1
				elseif chr == "#" then tile = 2
				elseif chr == "b" then tile = 3
				elseif chr == "c" then tile = 4
				elseif chr == "," then tile = 5
				elseif chr == "H" then tile = 6
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