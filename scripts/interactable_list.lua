require "scripts.sprites"
require "scripts.interactable"
require "scripts.utility"

interactable_list = {

    end_of_level = make_interactable({
        on_interaction = 
        function (self, dt, i)
            game:create_new_level()
        end,
    }),

    chest = make_interactable({
        name = "chest",
        spr = spr_chest,
        on_interaction = 
        function (self, dt, i)
            --pickups:spawn("gun", guns.machinegun, self.x, self.y)
            pickups:spawn("gun", get_random_gun(), self.x, self.y)
            table.remove(interactables,i)
        end,
    }),


}