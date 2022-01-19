function load_pixel_image(name)
    local img = love.graphics.newImage("assets/textures/"..name..".png")
    img:setFilter("nearest", "nearest")
    return img 
end
function load_image_table(name, n, w, h)
    local t = {}
    for i=1,n do 
        t[i] = load_pixel_image(name..tostr(i))
    end
    t.w = w
    t.h = h
    return t
end

spr_missing = load_pixel_image("missing")

-- UI
spr_hp_bar = load_pixel_image("hp_bar")
spr_hp_bar_empty = load_pixel_image("hp_bar_empty")

spr_missing = load_pixel_image("missing")

-- UI
spr_hp_bar = load_pixel_image("hp_bar")
spr_hp_bar_empty = load_pixel_image("hp_bar_empty")

-- Players
anim_pigeon_idle = {
    load_pixel_image("pigeon/pigeon_idle_1"),
}
anim_pigeon_walk = {
    --TODO laod_pixel_anim function, just provide "pigeon/pigeon_walk_"
    --and it will generate the table
    load_pixel_image("pigeon/pigeon_walk_1"),
    load_pixel_image("pigeon/pigeon_walk_2"),
    load_pixel_image("pigeon/pigeon_walk_3"),
    load_pixel_image("pigeon/pigeon_walk_4"),
    load_pixel_image("pigeon/pigeon_walk_5"),
    load_pixel_image("pigeon/pigeon_walk_6"),
    load_pixel_image("pigeon/pigeon_walk_7"),
    load_pixel_image("pigeon/pigeon_walk_8"),
    load_pixel_image("pigeon/pigeon_walk_9"),
    load_pixel_image("pigeon/pigeon_walk_10"),
    --load_pixel_image("pigeon_walk_2"),
}
spr_crow = {
    load_pixel_image("crow_walk_1"),
    load_pixel_image("crow_walk_1"),
}

-- Enemies
spr_fox = {
    load_pixel_image("fox_1")
}

-- Projectiles
spr_bullet = load_pixel_image("bullet_flat_1")
spr_laser = load_pixel_image("laser")

-- Guns
spr_revolver_big = load_pixel_image("gun_revolver")
spr_revolver = load_pixel_image("gun_revolver_small")

-- Tiles
spr_ground_dum = load_pixel_image("dummy_ground")
spr_wall_1 = load_pixel_image("wall_1")
sprs_floor_wood = {
    load_pixel_image("floor_wood_1"),
    load_pixel_image("floor_wood_2"),
    load_pixel_image("floor_wood_3"),
    load_pixel_image("floor_wood_4"),
    w = 2, h = 2,
}

sprs_test = load_image_table("test_", 4, 2, 2) 

sprs_floor_wood_detail = {
    load_pixel_image("floor_wood_detail1"),
    load_pixel_image("floor_wood_detail2"),
    load_pixel_image("floor_wood_detail3"),
    load_pixel_image("floor_wood_detail4"),
    w = 2, h = 2,
}
spr_wall_dum = load_pixel_image("dummy_wall")
spr_wall_dum = {
    load_pixel_image("walls_sample1"),
    load_pixel_image("walls_sample1"),
    load_pixel_image("walls_sample1"),
    load_pixel_image("walls_sample1"),
    w = 2, h = 2,
}
spr_box = load_pixel_image("box")
spr_chain = load_pixel_image("chain")
spr_floor_metal = load_pixel_image("floor_metal")