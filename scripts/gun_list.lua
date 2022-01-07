require "scripts/sprites"
require "scripts/gun"

guns = {
    --                  name       sprite        spd  cd     maxammo  ofdist    ofangle  
    revolver = make_gun({
        name = "revolver",
        spr = spr_revolver, 
        bullet_spd = 0,
        cooldown = 0,
        max_ammo = math.huge,
        bullet_offset_dist = 100,
        angle_var = 0.1,
        make_bullet = make_bullet,
    }),
}

function my_func(g,p)
    make_bullet(g,p)
end