require "scripts.utility"

map_edit_mode = false
local wheel = 0
function toggle_map_edit()
	map_edit_mode = not map_edit_mode 

	if map_edit_mode==true then
		room_files_n = 1
		room_files = {"lvl1_rooms.txt","lvl1_rooms_branch.txt","lvl1_rooms_branch_old.txt"}

		init_room_map(room_files[room_files_n])

    else
        mobs = {}
        map = init_map(600, 300)
        map:generate_map(seed)
    end

end

function update_map_edit(dt)
	local mid_screen = {x=camera.x - window_w/2, y=camera.y - window_h/2}
	local input_device = {keybinds,"keyboard+mouse",1}
	 prevmx,prevmy = mx,my
	 mx,my=input:get_world_mouse_pos(mid_screen, input_device,dt, camera) -- get_world_cursor_pos
	 mapmx,mapmy = floor(mx/BLOCK_WIDTH)*BLOCK_WIDTH, floor(my/BLOCK_WIDTH)*BLOCK_WIDTH,BLOCK_WIDTH,BLOCK_WIDTH

	 --moove camera with right click
	if input:button_down("alt") then
		camera_set_pos(camera, camera.x+prevmx - mx, camera.y+prevmy - my)
		mx,my=input:get_world_mouse_pos(mid_screen, input_device,dt, camera)
	end

	--switch betwin tiles
	if not(input:button_down("alt")) then
		tile_n = mod_plus_1(tile_n + wheel, #map.palette)
		if not (wheel == 0) then
			nb_variant=1
		end
	end

	--switch betwin varients of tiles
	if input:button_down("alt") then
		if map.palette[tile_n].spr[1] then
			nb_variant = mod_plus_1(nb_variant + wheel, #map.palette[tile_n].spr)
		end
	end

	local bx,by=floor(mx/BLOCK_WIDTH), floor(my/BLOCK_WIDTH)
	local ongrid = map.grid[by] and map.grid[by][bx]
	local notvoid = ongrid and not(map.grid[by][bx][1]==0)

	--fast select 
	if input:button_down("middle") and ongrid and notvoid then
		tile_n = map.grid[by][bx][1]
		nb_variant = map.grid[by][bx][2]
	end

	--place block with left click
	if input:button_down("fire") and ongrid and notvoid then --not(floor((by+1)/19) == (by+1)/19)
		local tile = map.palette[tile_n].n
		map:set_tile(bx,by, tile_n, nb_variant)

		local file = io.open(chemin, "r")
		local line
		local doc1 = ""
		--read the docs
		io.input(file)

		txtline = by+1
		local num_line = 0

		for _line in io.lines(chemin) do
			num_line = num_line+1

			if not(num_line == txtline) then
				doc1 = doc1.._line.."\n"
			else
				line = _line
			end

			if num_line == txtline then
				break 
			end
		end

		--for l=1,txtline do
		--	local linetxt = io.read("*line")
		--	if not(l==txtline) then
		--		doc1 = doc1..linetxt.."\n"
		--	else
		--		line = linetxt
		--	end
		--end

		local num_line = 0
		local doc2 = ""

		for _line in io.lines(chemin) do
			num_line = num_line+1
			if num_line > txtline then
				doc2 = doc2.."\n".._line
			end
		end

		--local doc2 = "\n"..io.read("*all")

		line_start = string.sub(line, 1 ,bx*2) 
		line_end = string.sub(line, bx*2+3 ,#line) 

		local variant
		if nb_variant == 1 then variant=" " else variant = nb_variant end
		line_middle = map.palette[tile_n].symb..variant

		line = line_start..line_middle..line_end
		io.close(file)

		--write in doc
		file = io.open(chemin, "w")
		io.output(file)
		io.write(doc1)
		io.write(line)
		io.write(doc2)
		io.close(file)
		--]]
	end

	local next = nil

	if input:button_pressed("up") then --self:button_down("up"
        next = 1
    elseif input:button_pressed("down") then
        next = -1
    end

	if next then
	room_files_n = mod_plus_1(room_files_n+next, #room_files)
	init_room_map(room_files[room_files_n])
	end


end

function draw_map_edit()
	camera:draw()
	map:draw()

	love.graphics.rectangle("line", mapmx,mapmy ,BLOCK_WIDTH ,BLOCK_WIDTH)
	draw_centered(spr_cursor, mx, my)
	if map.palette[tile_n].spr[1] then

		draw_centered_outline(map.palette[tile_n].spr[nb_variant], mx+12, my+12,0,1,1,2,black)
		draw_centered(map.palette[tile_n].spr[nb_variant], mx+12, my+12)

	else

		draw_centered_outline(map.palette[tile_n].spr, mx+12, my+12,0,1,1,2,black)
		draw_centered(map.palette[tile_n].spr, mx+12, my+12)

	end
	--love.graphics.print(wheel, 10, 10)
	wheel = 0
	love.graphics.print(tostring(debugg),camera.x,camera.y)
	love.graphics.print("debugg",10,10)
end

function love.wheelmoved(x, y)
	if y > 0 then
		wheel = 1
	elseif y < 0 then
		wheel = -1
	end
end

function init_room_map(room_file)

	camera = init_camera()
	prevmx,prevmy = input:get_mouse_pos()
	tile_n = 1
	nb_variant = 1
	--map.palette symb
	--room_file = "lvl1_rooms_branch.txt" -- "lvl1_rooms_1.txt" "lvl1_rooms_branch.txt"

	room_load = map:load_from_file(room_file)
	chemin = love.filesystem.getSourceBaseDirectory( ).."/birds_with_guns_hd/assets/rooms/"..room_file

	map = init_map(600, 1000)
	for i,z in ipairs(room_load) do
		map:write_room(room_load[i], 0 , (i-1)*map:get_room_height(z)+(i-1), rng)

	end
end 