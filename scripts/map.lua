require "scripts/sprites"
require "scripts/settings"
require "scripts/files"
require "scripts/utility"

function init_map(w, h)
	local map = {grid = {}}
	for i=0, h-1 do
		map.grid[i] = {}
		for j=0, w-1 do
			map.grid[i][j] = {0, 0}--TODO that probably uses a lot of memory? idk tbh
		end
	end
	map.width = w
	map.height = h
	
	map.update = update_map
	map.draw = draw_map
	map.palette = {
		[0] = make_tile(0, spr_ground_dum, {
			is_solid=true, is_destructible=false, is_transparent=false
		}),
		make_tile(1, spr_ground_1, {
			is_solid=false, is_destructible=false, is_transparent=false, 
			type="multi_tile", 
		}),
		make_tile(2, spr_wall_1, {
			is_solid=true, is_destructible=false, is_transparent=false, 
			oy=44-16
		}),
		make_tile(3, sprs_box, {
			is_solid=true, is_destructible=true, is_transparent=true,
			ox=1, oy=1, type="variation",
		}),
		make_tile(4, spr_chain, {
			is_solid=false, is_destructible=false, is_transparent=false
		}),
		make_tile(5, spr_floor_metal, {
			is_solid=false, is_destructible=false, is_transparent=false 
		}),
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
	
	map.lvl1_main_rooms = map:load_from_file("lvl1_rooms_1.txt")
	map.lvl1_branch_rooms = map:load_from_file("lvl1_rooms_branch.txt")
	map.lvl_arena = map:load_from_file("arena.txt")
	
	return map
end
function draw_map(self)
	--TODO y sorting
	local x1 = floor(camera.x / block_width)
	local x2 = floor((camera.x + window_w) / block_width )
	local y1 = floor(camera.y / block_width)
	local y2 = floor((camera.y + window_h) / block_width )
	
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
				tile:draw(x, y, var)
			end
		end
	end
end

function make_tile(n, spr, a)
	local tile = {
		n = n,
		type = a.type,
		spr = spr or spr_missing,
		is_solid = a.is_solid,
		is_destructible = a.is_destructible,
		is_transparent  = a.is_transparent,
		ox = a.ox or 0, 
		oy = a.oy or 0, 

		draw = draw_tile,
	}
	return tile
end
function draw_tile(self, x, y, var)
	-- self refers to tile (THANKS, lua, goddamnit)
	local spr
	if type(self.spr) == "table" then 
		spr = self.spr[var]
	else
		spr = self.spr
	end
	if spr == nil then  spr = spr_missing  end
	
	-- TODO: optimise map by baking into canvas & update on change
	love.graphics.draw(spr, x*block_width, y*block_width)
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
--[[
function set_debug_canvas(self)
	self.debug_canvas = love.graphics.newCanvas(self.width, self.height)
	love.graphics.setCanvas(self.debug_canvas)
	for y = 0, self.height-1 do
		for x = 0, self.width-1 do
			local tile = self:get_tile(x,y).n
			local col = {1,0,0} 
			if     tile == 0 then  col = {0,0,0,0} 
			elseif tile == 1 then  col = {.5, .2, 0}
			elseif tile == 2 then  col = {1, 1, 1}
			elseif tile == 3 then  col = {0, 1, 1}
			elseif tile == 4 then  col = {.5, .5, .5}
			elseif tile == 5 then  col = {.7, .7, .7}
			end
			rect_color("fill", x, y, 1, 1, col)
		end
	end
	love.graphics.setCanvas()
end

function debug_draw_map(self, px, py)
	px = px or 0
	py = py or 0
	--love.graphics.draw(self.debug_canvas, px, py)
end]]


