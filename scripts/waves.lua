waves = {
    {
        {mob_list.fox,1},
    },

    {
        {mob_list.fox,5},
    },

    {
        {mob_list.fox,8},
    },

    {
        {mob_list.knight,1},
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

}

function update_waves()
    if #mobs == 0 then
        nbwave = nbwave+1
        for _,k in pairs(waves[nbwave]) do 
            for w = 1,k[2] do
                table.insert(mobs, k[1]:spawn(5*16+math.random(300),4*16+math.random(160)))
            end
        end
    end
end