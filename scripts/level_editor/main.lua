require "scripts/utility"

map_edit_mode = false
local wheel = 0
function toggle_map_edit()
    map_edit_mode = not map_edit_mode 
    camera = init_camera()
    prevmx,prevmy = get_mouse_pos()
    tile_n = 4
    nb_variente = 1
    --map.palette symb
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

    --if not wheel==0 then--love.wheelmoved(mx, my)==1 then
    tile_n = mod_plus_1(tile_n + wheel, #map.palette)
    if not (wheel == 0) then
        nb_variente=1
    end

    if button_pressed("middlems", 1,input_device) then --"middlems"
        if map.palette[tile_n].spr[1] then
            nb_variente = mod_plus_1(nb_variente + 1, #map.palette[tile_n].spr)
        end
    end

    --place block with left click
    if button_pressed("fire", 1,input_device) then
        local tile = map.palette[tile_n].n
        map:set_tile(floor(mx/block_width), floor(my/block_width), tile_n, nb_variente)
        --tile_n = tile_n+1
    end

end

function draw_map_edit()
    camera:draw()
    map:draw()

    for i,z in ipairs(map.lvl1_rooms) do
        map:write_room(map.lvl1_rooms[i], 0 , 20+(i-1)*map:get_room_height(z), rng)
    end

    love.graphics.rectangle("line", mapmx,mapmy ,block_width ,block_width)
    draw_centered(spr_cursor, mx, my)
    if map.palette[tile_n].spr[1] then
        love.graphics.draw(map.palette[tile_n].spr[nb_variente], mx+12, my+12)
    else
        love.graphics.draw(map.palette[tile_n].spr, mx+12, my+12)
        --draw_centered(spr_ground_dum, mx+12, my+12)
    end
    --love.graphics.print(wheel, 10, 10)
    wheel = 0
end

function love.wheelmoved(x, y)
    if y > 0 then
        wheel = 1
    elseif y < 0 then
        wheel = -1
    end
end