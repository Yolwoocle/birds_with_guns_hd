require "scripts.utility"
require "scripts.collision"
require "scripts.constants"
require "scripts.settings"
require "scripts.ui"

local donothing = function() return end --For debugging

local function callback_set_menu(menu_name)
	return function(self)
		menu_manager:set_menu(menu_name)
	end
end

function init_menu_manager()
	local m = {}
	m.menus = {
		title = make_menu({
			{"new super birds with guns bros 2 HD ultra 3D"},
			{"featuring dante from devil may cry series"},
			{""},
			{"PLAY", callback_set_menu('none')},
			{"OPTIONS", callback_set_menu('options')},
			{"Quit", function() love.event.quit() end},
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.5})
		end),

		pause = make_menu({
			{"--- PAUSED ---"},
			{""},
			{"RESUME", toggle_pause},
			{"RETRY", donothing},
			{"OPTIONS", callback_set_menu('options')},
			{"CREDITS (pls remove)", callback_set_menu('credits')},
			{"EXIT", callback_set_menu('title')}, 
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.7})
		end),

		win = make_menu({
			{"You win!"},
		}, function()
			--camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.7})
		end),

		options = make_menu({
			{"< Back", callback_set_menu('pause')},
			{"Wowowow options???", toggle_pause},
			{"so cool!!!", donothing},
			{"cool button:", function(self) 
				set_setting('mouse_visible',false)
				self:update_display_val(set_setting('screenshot_scale',3000))
			end, 34},
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.85})
		end),

		credits = make_menu({
			{"< Back", callback_set_menu('pause')},
			{""},
			{"--- Code and Design ---"},
			{"Léo Bernard (@yolwoocle_)"},
			{"Gaspard Delpiano-Manfrini"},
			{""},
			{"--- Music ---"},
			{"Simon T."},
			{""},
			{"--- Art and Animations ---"},
			{"some sentients birds probably"},
			{"love2d.org", function()
				love.system.openURL("http://love2d.org/")
			end}
		}, function()
			camera_rect_color("fill", 0, 0, window_w, window_h, {0,0,0,0.85})
		end),
	}
	m.curmenu_name = "title"
	m.curmenu = m.menus.title

	m.update = function(self, dt)
		if self.curmenu then  self.curmenu:update(dt)  end

		-- Update current menu
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
			self:toggle_pause()
		end
	end

	m.set_menu = function(self, menuname)
		if menuname == "none" then
			self.curmenu_name = 'none'
		end
		if self.menus[menuname] then
			self.curmenu_name = menuname
			self.curmenu = self.menus[menuname]
		end
	end

	m.toggle_pause = function(self)
		if self.curmenu_name == "pause" then
			self.curmenu_name = "none"
			mouse_visible = false --TODO: should be settings.mouse_visible
			love.mouse.setVisible(false)
		else
			self.curmenu_name = "pause"
			mouse_visible = true
			love.mouse.setVisible(true)
		end
	end

	menu_manager = m  
end

--------------------------

function make_menu(items, custom_bg)
	local m = {}
	m.cursel = 1
	m.spacing_items = 16
	
	m.items = {}
	local x = floor(window_w / 2)
	local height_of_items = (#items - 1) * m.spacing_items --classic fence post problem
	local y = floor((window_h - height_of_items)/ 2)
	for i=1, #items do
		m.items[i] = make_menu_item(i, x, y, unpack(items[i]))
		y = y + m.spacing_items
	end

	m.update = function(self, dt)
		for i,item in ipairs(self.items) do
			if item:touches_mouse() and love.mouse.isDown(1) then--and button_pressed("fire") then
				item:on_click()
			end
		end
	end

	m.draw = function(self)
		if custom_bg then  custom_bg()  end
		for i=1, #self.items do
			local item = self.items[i]
			item:draw()
		end
	end

	return m
end
function toggle_pause()
	menu_manager:toggle_pause()
end

------------------------

function make_menu_item(n, x, y, text, on_click, display_val, is_hoverable)
	font = font or font_default
	local it = {}
	it.n = n
	it.text = text
	it.caption_text = text
	it.display_val = display_val
	it.text_obj = love.graphics.newText(font, text)

	it.x = x
	it.y = y

	it.set_text = function(self, newtext)
		self.text = newtext
		self.text_obj:set(newtext)

		self.width = self.text_obj:getWidth()
		self.height = self.text_obj:getHeight()
		self.ox = floor(self.width / 2)
		self.oy = floor(it.height / 2)
	end
	
	it.update_text = function(self)  
		if self.display_val then  self:update_display_val(self.display_val)  end
		self:set_text(self.text)
	end

	it.update_display_val = function(self, val)
		self.display_val = val
		self:set_text(self.caption_text.." "..tostring(val))
	end

	it:update_text(text)

	if on_click then
		it.on_click = on_click
		it.is_hoverable = true
	else
		it.on_click = function() return end
		it.is_hoverable = false 
	end
	it.is_selected = false

	it.draw = function(self)
		local text = self.text
		if self.is_hoverable then
			if self.is_selected then 
				-- White bar on selection
				local bar_border_w = 7
				draw_3_slice(self.x-self.ox-bar_border_w, self.y-self.oy, self.width, sprs_white_bar)
				love.graphics.setColor(black)
			end
		else -- If this is just display text
			local v = 0.6
			love.graphics.setColor(v,v,v)
		end
		camera_print(text, self.x, self.y, 0,1,1, self.ox, self.oy)
		love.graphics.setColor(white)
	end

	it.touches_mouse = function(self)
		local mx, my = get_mouse_pos()
		local coll = coll_rect_point(self.x, self.y, self.ox, self.oy, mx, my)
		self.is_selected = coll 
		return coll
	end
	return it
end

------
