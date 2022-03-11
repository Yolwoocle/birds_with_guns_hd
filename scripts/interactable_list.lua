require "scripts.sprites"
require "scripts.interactable"
require "scripts.utility"

interactable_liste = {

    end_of_level = make_interactable({
        on_interaction = 
        function (self, dt)
            game:create_new_level()
        end,
    }),

}