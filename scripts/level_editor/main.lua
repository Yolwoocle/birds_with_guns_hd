require "scripts/utility"

map_edit_mode = false
local wheel = 0
function toggle_map_edit()
    map_edit_mode = not map_edit_mode 

    if map_edit_mode==true then
        room_files_n = 1
        room_files = {"lvl1_rooms_1.txt","lvl1_rooms_branch.txt"}

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
     mx,my=get_world_cursor_pos(mid_screen, input_device,dt, camera)
     mapmx,mapmy = floor(mx/block_width)*block_width, floor(my/block_width)*block_width,block_width,block_width

     --moove camera with right click
    if button_down("alt", 1,input_device) then
        camera_set_pos(camera, camera.x+prevmx - mx, camera.y+prevmy - my)
        mx,my=get_world_cursor_pos(mid_screen, input_device,dt, camera)
    end

    --switch betwin tiles
    if not(button_down("alt", 1,input_device)) then
        tile_n = mod_plus_1(tile_n + wheel, #map.palette)
        if not (wheel == 0) then
            nb_variente=1
        end
    end

    --switch betwin varients of tiles
    if button_down("alt", 1,input_device) then
        if map.palette[tile_n].spr[1] then
            nb_variente = mod_plus_1(nb_variente + wheel, #map.palette[tile_n].spr)
        end
    end

    local bx,by=floor(mx/block_width), floor(my/block_width)
    local ongrid = map.grid[by] and map.grid[by][bx]
    local notvoid = ongrid and not(map.grid[by][bx][1]==0)

    --fast select 
    if button_down("middlems", 1,input_device) and ongrid and notvoid then
        tile_n = map.grid[by][bx][1]
        nb_variente = map.grid[by][bx][2]
    end

    --place block with left click
    
    if button_down("fire", 1,input_device) and ongrid and notvoid then --not(floor((by+1)/19) == (by+1)/19)
        local tile = map.palette[tile_n].n
        map:set_tile(bx,by, tile_n, nb_variente)

        local file = io.open(chemin, "r")
        local line
        local doc1 = ""
        --reed the doc
        io.input(file)
        
        txtline = by+1

        for l=1,txtline do
            local linetxt = io.read("*line")
            if not(l==txtline) then
                doc1 = doc1..linetxt.."\n"
            else
                line = linetxt
            end
        end
        local doc2 = "\n"..io.read("*all")
        line_start = string.sub(line, 1 ,bx*2) 
        line_end = string.sub(line, bx*2+3 ,#line) 

        local variente
        if nb_variente == 1 then variente=" " else variente = nb_variente end
        line_middle = map.palette[tile_n].symb..variente

        line = line_start..line_middle..line_end
        io.close(file)

        --write in doc
        file = io.open(chemin, "w")
        io.output(file)
        io.write(doc1)
        io.write(line)
        io.write(doc2)
        io.close(file)
        
    end

    if button_pressed("up", 1, input_device) or button_pressed("down", 1, input_device) then 
        local next
        if button_pressed("up", 1, input_device) then next=1 else next = -1 end
    room_files_n = mod_plus_1(room_files_n+next, #room_files)
        room_files = {"lvl1_rooms_1.txt","lvl1_rooms_branch.txt"}
    init_room_map(room_files[room_files_n])
    end

end

function draw_map_edit()
    camera:draw()
    map:draw()

    love.graphics.rectangle("line", mapmx,mapmy ,block_width ,block_width)
    draw_centered(spr_cursor, mx, my)
    if map.palette[tile_n].spr[1] then

        draw_centered_outline(map.palette[tile_n].spr[nb_variente], mx+12, my+12,0,1,1,2,black)
        draw_centered(map.palette[tile_n].spr[nb_variente], mx+12, my+12)

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
        prevmx,prevmy = get_mouse_pos()
        tile_n = 1
        nb_variente = 1
        --map.palette symb
        --room_file = "lvl1_rooms_branch.txt" -- "lvl1_rooms_1.txt" "lvl1_rooms_branch.txt"

        room_load = map:load_from_file(room_file)
        chemin = love.filesystem.getSourceBaseDirectory( ).."/birds_with_guns_hd/assets/rooms/"..room_file

        map = init_map(600, 1000)
        for i,z in ipairs(room_load) do
            map:write_room(room_load[i], 0 , (i-1)*map:get_room_height(z)+(i-1), rng)

        end
end 