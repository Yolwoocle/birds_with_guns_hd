require "scripts/utility"

function make_zone(a)
    local zone = {
        name           		= a.name                or "zone",
        spr 	       		= a.spr 	            or spr_revolver,
        life	       		= a.life	            or 3,
        rayon               = a.rayon               or 20,
        on_death 	        = a.on_death		    or killzone,
        damage              = a.damage              or 1,
        damge_tick          = a.damge_tick          or .1,
        ondamage            = a.ondamage            or nil,
        damageloop          = 0,
        spawn_zone          = spawn_zone,
        update              = update_zone,
        draw                = draw_zone,
    }

    return zone
end

function spawn_zone(self, x, y)

	local c = copy(self)
	x = x or 0 
	y = y or 0
	c.x = x
	c.y = y
	return c
end

function update_zone(self, dt , i)

    self.life = max(self.life-dt,0)
    self.damageloop = max(self.damageloop-dt,0)


    if self.life <= 0 then
        self:on_death(i)
    end

    if self.damageloop <= 0 then
        self.damageloop = self.damge_tick
        self.active = true
    else self.active = false
    end
end

function draw_zone(self)
    --circ_color(mode,x,y,radius,col)
    circ_color("fill", self.x, self.y, self.rayon , {1,0,0})
end

function killzone(self,i)
    table.remove(zones, i)
end

function damageinzone(self,l) 

    if self.active then
        for i,m in pairs(mobs) do
            gf = gf + 1

            if dist(self.x,self.y,m.x,m.y) < self.rayon then

                m.life = m.life - self.damage

                if self.ondamage then
                    self.ondamage(m)
                end

            end

        end

        for _,p in ipairs(player_list) do
	        local coll = dist(self.x,self.y,p.x,p.y) < self.rayon
	        if coll then
	        	p.life = p.life - self.damage
                --p:damage(self.damage)

                if self.ondamage then
                    self.ondamage(p)
                end

	        end

        end
    end
    
end