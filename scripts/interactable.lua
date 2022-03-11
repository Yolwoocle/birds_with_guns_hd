function make_interactable(a)
    local interactable = {
        name           		= a.name                or "interactable",
        spr 	       		= a.spr 	            or spr_revolver,

        condition           = a.condition           or function (self, dt)
                                                            for i,p in ipairs(players) do
                                                                if p.fire then
                                                                    return true
                                                                end
                                                            end
                                                        end,

        on_interaction      = a.on_interaction      or function (self, dt)
                                                        print("activated")
                                                        end,
        
        spawn               = 

        function (self, x, y)
            local c = copy(self)
            x = x or 0 
            y = y or 0
            c.x = x
            c.y = y
            table.insert(interactables , c)
        end,

        draw = 

            function (self)
                draw_centered(self.spr, self.x, self.y)
            end,

        update = 

            function (self, dt , i)
                if self:condition(dt) then
                    self:on_interaction(dt)
                end
            end,

    }

    return interactable
end

