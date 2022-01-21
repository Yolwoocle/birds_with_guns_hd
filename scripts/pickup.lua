require "scripts/utility"
require "scripts/sprites"

function make_pickups()
    local p = {
        table = {},

        spawn = spawn_pickup,
        update = update_pickups,
        draw = draw_pickups,
    }
    return p 
end

function spawn_pickup(self, type, q, x, y)
    local pick = {
        type = type,
        x = floor(x),
        y = floor(y),

        q = 0,
        spr = spr_missing,
    }

    if type == "ammo" then
        pick.q = q
        pick.spr = spr_pick_ammo
    
    elseif type == "life" then
        pick.q = q
        pick.spr = spr_pick_life

    elseif type == "gun" then
        pick.gun = q

    end
    table.insert(self.table, pick)
end

function update_pickups(self, dt)
    for i,p in ipairs(self.table) do
        
    end
end

function draw_pickups(self)
    for i,pick in ipairs(self.table) do
        draw_centered(pick.spr, pick.x, pick.y)
    end
end