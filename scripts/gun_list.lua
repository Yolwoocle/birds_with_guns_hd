require "scripts/sprites"
require "scripts/gun"

guns = {
    revolver = make_gun({
        name = "revolver",
        spr = spr_revolver, 
        bullet_spd = 300,
        cooldown = 0,
        max_ammo = math.huge,

        spawn_x =  70,
        spawn_y =  0,

        life	= 4,

        make_bullet = make_bullet,
    }),
}

function my_func(g,p)
    make_bullet(g,p)
end

