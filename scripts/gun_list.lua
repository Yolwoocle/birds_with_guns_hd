require "scripts/sprites"
require "scripts/gun"
require "scripts/utility"

guns = {

    revolver = make_gun({
        name = "revolver",
        spr = spr_revolver, 
        bullet_spd = 600,
        cooldown = 0.5,
        max_ammo = math.huge,
        scattering = 0,

        spawn_x =  70,
        spawn_y =  0,

        life	= 4,

        rafale  = 10,
        rafaledt  = 0,

        nbshot = 10,
        spred  = pi/5,

        make_bullet = 
        function (g,p)
            return normaleshoot(g,p)
        end,
    }),
}



function normaleshoot(g,p)
    local shot = {}
      nbshot = g.nbshot-1
      for k=0,g.rafale-1 do
          for i=0,nbshot do
              local o=((i/g.nbshot)-(g.nbshot/2/g.nbshot))*g.spred
              table.insert(shot,{g,p,p.rot,o,k*g.rafaledt})
          end
      end
      if nbshot==0 then
          table.insert(shot,{g,p,p.rot,0,nbraf,0})
      end
      return shot
end

