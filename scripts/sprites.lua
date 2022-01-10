function load_pixel_image(name)
    local img = love.graphics.newImage("assets/textures/"..name..".png")
    img:setFilter("linear", "nearest")
    return img 
end

spr_pigeon = {
    load_pixel_image("pigeon_walk_1"),
    load_pixel_image("pigeon_walk_2"),
}
spr_pigeon = {
    load_pixel_image("crow_walk_1"),
    load_pixel_image("pigeon_walk_2"),
}

spr_bullet = load_pixel_image("bullet_1")
spr_laser = load_pixel_image("laser")

spr_revolver = load_pixel_image("gun_revolver")

spr_ground_dum = load_pixel_image("dummy_ground")
sprs_floor_wood = {
    load_pixel_image("floor_wood_1"),
    load_pixel_image("floor_wood_2"),
    load_pixel_image("floor_wood_3"),
    load_pixel_image("floor_wood_4"),
}
spr_floor_wood_detail = load_pixel_image("floor_wood_detail")
spr_wall_dum = load_pixel_image("dummy_wall")
spr_box = load_pixel_image("box")