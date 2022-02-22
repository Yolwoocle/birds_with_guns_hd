require "scripts/utility"

map_edit_mode = false

function toggle_map_edit()
    map_edit_mode = not map_edit_mode 
    camera = init_camera()
    prevmx,prevmy = get_mouse_pos()
    tile_n = 4
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

    --place block with left click
    if button_pressed("fire", 1,input_device) then
        --self:get_tile(floor(x), floor(y)).is_solid

        local tile = map.palette[tile_n].n
        map:set_tile(mapmx, mapmy, tile_n, 1)
        
        --local tile = map.grid[floor(mapmy)][floor(mapmx)][1]
	    --tile = map.palette[tile]
--
        --map.palette[tile] = map.palette[tile_n].symb
    end

end

function draw_map_edit()
    camera:draw()
    map:draw()
    love.graphics.rectangle("line", mapmx,mapmy ,block_width ,block_width)
    draw_centered(spr_cursor, mx, my)
    draw_centered(map.palette[tile_n].spr, mx+12, my+12)
    --print(map.grid[mapmx][mapmy])
end