require "scripts/sprites"
require "scripts/settings"
require "scripts/files"
require "scripts/utility"

function init_map(w, h)
	local map = {grid = {}}
	for i=0, h-1 do
		map.grid[i] = {}
		for j=0, w-1 do
			map.grid[i][j] = {0,0}
		end
	end
	map.width = w
	map.height = h
	
	map.update = update_map
	map.draw = draw_map
	map.debug_draw = debug_draw_map
	map.palette = {
		[0] = make_tile(0, spr_ground_dum, {
			is_solid=true, is_destructible=false, is_transparent=false
		}),
		make_tile(1, sprs_floor_wood, {
			is_solid=false, is_destructible=false, is_transparent=false, 
			type="multi_tile", 
		}),
		make_tile(2, spr_wall_1, {
			is_solid=true, is_destructible=false, is_transparent=false, 
			oy=44-16
		}),
		make_tile(3, sprs_box, {
			is_solid=true, is_destructible=true, is_transparent=true,
			ox=1, oy=1, 
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
	map.update_sprite_map = update_sprite_map
	
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
function update_map(self)

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
			local tile = self:get_tile(x,y)[0]
			local var  = self:get_tile(x,y)[1]
            tile = self.palette[tile]

			local spr
			if tile then
                if var == 0 then
                    spr = tile.spr
                else
                    spr = tile.spr[var]
                end
            end
			if spr == nil then  spr = spr_missing  end
			
			-- TODO: optimise map by baking into canvas & update on change
			love.graphics.draw(spr, x*block_width, y*block_width)
		end
	end
end
