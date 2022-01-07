require "scripts/sprites"
require "scripts/gun"

guns={
    --                  name       sprite        spd  cd     maxammo  ofdist    ofangle  
    revolver = make_gun("revolver",spr_revolver, 300  ,.25    ,100      ,100     ,.1     ,
    -- shoot
    --function (g,p)
        --return
        make_bullet--(g,p)
        --return
    --end,
    ),
}