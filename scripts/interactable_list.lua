require "scripts.sprites"
require "scripts.interactable"
require "scripts.utility"

interactable_liste = {

    end_of_level = make_interactable({
        on_interaction = 
        function (self, dt, i)
            game:create_new_level()
        end,
    }),

    chest = make_interactable({
        name = "chest",
        on_interaction = 
        function (self, dt, i)
            pickups:spawn("gun", guns.machinegun, self.x, self.y)
            table.remove(interactables,i)
        end,
    }),


}