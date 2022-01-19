require "scripts/utility"

----------- Map Generation ------------
function generate_map(self, rooms, seed)
	-- The default seed in LÖVE 11.x is the following low/high pair: 0xCBBF7A44, 0x0139408D
	local rng
	if seed then
		rng = love.math.newRandomGenerator(seed)  
	else 
		rng = love.math.newRandomGenerator()
	end

	self:generate_path(rng, self.lvl1_main_rooms, 0, 16)
end

function generate_path(self, rng, rooms, x, y)
	-- Start by generating a random layout for the main path
	-- We get all possible rooms and shuffle them 
	local room_ids = {} 
	for i=1, #rooms do
		table.insert(room_ids, i)
	end
	shuffle(room_ids, rng)
	
	local len_wagon = rng:random(5, 8)
	len_wagon = min(len_wagon, #rooms)

	local ix = 0
	for i=1, len_wagon do
		local room = rooms[room_ids[i]]
		self:write_room(room, x+ix, y)
		ix = ix + self:get_room_width(room)
	end
end

function load_from_file(self, file)
	-- . ground
	-- # wall
	-- b box 
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
				local tile = 0
				if	 chr == "`" then tile = 0
				elseif chr == "." then tile = 1
				elseif chr == "#" then tile = 2
				elseif chr == "b" then tile = 3
				elseif chr == "c" then tile = 4
				elseif chr == "," then tile = 5
				end
				
				rooms[room][y][x] = tile
				x = x + 1
			end
			y = y + 1
		end
	end
	return rooms
end
function get_room_tile(self, room, x, y)
	return room[y][x]
end
function write_room(self, room, x, y)
	x = x or 0
	y = y or 0
	for iy = 0, #room do
		for ix = 0, #room[0] do
			self:set_tile(x+ix, y+iy, self:get_room_tile(room,ix,iy))
		end
	end
end

function get_room_width(self, room)
	return #room[0] + 1
end
function get_room_height(self, room)
	return #room + 1
end
