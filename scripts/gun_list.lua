require "scripts/sprites"
require "scripts/gun"

guns={
    --                  name       sprite        spd  cd     maxammo  ofdist    ofangle  
    revolver = make_gun("revolver",spr_revolver, 30  ,.25    ,100      ,100     ,.1     ,
    -- shoot
    --function (g,p)
        make_bullet--(g,p)
    --end,
),
}