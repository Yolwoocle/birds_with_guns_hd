require "scripts/utility"


waves = {
    {--
       {mob_list.fox,10},
       {mob_list.shotgunboy,10},
    },

    {
        {mob_list.fox,5},
    },

    {
        {mob_list.shotgunboy,1},
    },

    {
        {mob_list.fox,2},
        {mob_list.shotgunboy,2},
    },

    {
        {mob_list.fox,4},
        {mob_list.shotgunboy2,1},
    },

    {
        {mob_list.shotgunboy,2},
        {mob_list.shotgunboy2,2},
    },

    {
        {mob_list.fox,4},
        {mob_list.shotgunboy,1},
        {mob_list.shotgunboy2,3},
    },

    {
        {mob_list.fox,4},
        {mob_list.knight,1},
    },

    {
        {mob_list.fox,13},
    },

    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    
    ----------------------------

    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },
    {
        {mob_list.fox,8},
        {mob_list.knight,5},
    },

}

function update_waves(dt)
    bw = block_width
    spawn_time = max(spawn_time - dt,0)
    if #mobs == 0 and spawn_time==inf then
        spawn_time = 3
        nbwave = nbwave+1
        for _,k in pairs(waves[nbwave]) do 
            for w = 1,k[2] do
                local x=300+math.random(16*60)
                local y=100+math.random(16*60)
                local i=0
                while  map:is_solid(x/bw, y/bw) or i>100000 do
                    x=300+math.random(16*50) 
                    y=100+math.random(16*50)
                    i=i+1
                end
                table.insert(spawn_location, {x=x,y=y})
                table.insert(sp_mark,{x=x,y=y})
            end
        end
        
    end

    if spawn_time==0 then
        spawn_time = inf
        nb_iteration = 0
        for _,k in pairs(waves[nbwave]) do 
            for w = 1,k[2] do
                nb_iteration = nb_iteration+1 --spawn_location
                table.insert(mobs, k[1]:spawn(spawn_location[nb_iteration].x,spawn_location[nb_iteration].y))
            end
        end
        spawn_location = {}
        sp_mark = {}
    end
end

function draw_waves()
    for i,k in pairs(sp_mark) do
        draw_centered(spr_floor_metal, k.x,k.y)
    end
end


