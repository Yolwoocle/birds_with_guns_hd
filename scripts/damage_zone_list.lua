require "scripts/damage_zone"

zone = {

    fire = make_zone({
        
        name           		= "fire",
        spr 	       		= spr_revolver,
        life	       		= 10,
        rayon               = 100 ,    	
        damge_tick          = .1,
        damage              = .1,
        --ondamage            = function(m)
        --    m.dx = m.dx/2
        --    m.dy = m.dx/2
        --end
     }),
}