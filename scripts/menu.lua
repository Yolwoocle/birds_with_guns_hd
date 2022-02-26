require "scripts/utility"
require "scripts/menus/menu_main"
require "scripts/menus/menu_pause"

function init_menu_manager()
	local m = {}
	m.menus = {
		main = make_menu({
			{"PLAY", on_click},
			{"OPTIONS", on_click},
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.5})
		end),

		pause = make_menu({
			{"RESUME", on_click},
			{"RETRY", on_click},
			{"does this even work", on_click},
			{"I love video games", on_click},
			{"can i has hamburger", on_click},
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.5})
		end),
	}
	m.curmenu_name = "none"
	m.curmenu = m.menus.main

	m.update = function(self, dt)
		if self.curmenu ~= "none" then
			self.curmenu = self.menus[self.curmenu_name]
		end
	end	

	m.draw = function(self)
		if self.curmenu_name ~= "none" and self.curmenu then
			self.curmenu:draw()
		end
	end

	m.keypressed = function(self, key, scancode)
		if scancode == "escape" then  
			if self.curmenu_name == "pause" then
				self.curmenu_name = "none"
			else
				self.curmenu_name = "pause"
			end
		end
	end

	menu_manager = m  
end

function make_menu(items, custom_bg)
	local m = {}
	m.items = {}
	for i=1, #items do
		m.items[i] = make_menu_item(i, unpack(items[i]))
	end

	m.cursel = 1
	m.spacing_items = 16

	m.update = function(self, dt)
		--
	end
	m.draw = function(self)
		if custom_bg then  custom_bg()  end

		print("#self.items", #self.items)
		local x = floor(window_w / 2)
		local h = (#self.items * m.spacing_items)
		local y = (window_h - h)/2
		for i=1, #self.items do
			local item = self.items[i]
			local ox = item.center_x
			y = y + self.spacing_items
			camera_print(item.text, x, y, 0,1,1, ox)
		end
	end

	return m
end

function make_menu_item(n, text, on_click, font)
	font = font or font_default
	local i = {}
	i.n = n
	i.text = text
	i.text_obj = love.graphics.newText(font, text)
	i.center_x = floor(i.text_obj:getWidth() / 2)
		
	i.on_click = on_click
	i.set_text = function(self, newtext)
		self.text = newtext
		self.text_obj:set(newtext)
		self.center_x = floor(self.text_obj:getWidth() / 2)
	end
	return i
end