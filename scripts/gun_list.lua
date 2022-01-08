require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {
    revolver = make_gun({
        name = "revolver",
        spr = spr_revolver, 

        bullet_spd = 1000,
        ospd = 100,
        cooldown = 1,

        max_ammo = inf,
        scattering = 0.1,

        spawn_x =  70,
        spawn_y =  0,

        life	= 1.25,

        rafale  = 5,
        rafaledt  = .1,

        nbshot = 10,
        spread  = pi/4,

        spdslow = .995,

        make_bullet = 
        function (g,p)
            return normaleshoot(g,p)
        end,
    }),
    pistolet = make_gun({
        name = "pistolet", 

        spawn_x =  70,
        spawn_y =  0,

        max_ammo = inf,
    
    }),
}



function normaleshoot(g,p)
    local shot = {}
      nbshot = g.nbshot-1
      for k=0,g.rafale-1 do
        if nbshot==0 then
            table.insert(shot,{g,p,p.rot,0,k*g.rafaledt})
        else
          for i=0,nbshot do
              local o=((i/g.nbshot)-(g.nbshot/2/g.nbshot))*g.spred
              table.insert(shot,{g,p, p.rot, o, k*g.rafaledt})
          end
        end
      end
      return shot
end

