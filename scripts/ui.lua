require "scripts/utility"
require "scripts/collision"

function make_hud()
	return {
		elements = {},
		update = update_hud,
		draw = draw_hud,

		insert_element = insert_element,

		make_bar = make_bar,
		make_button = make_button,
		make_img = make_img,
	}
end
function update_hud(self)
	for k,el in pairs(self.elements) do
		el:update()
	end
end
function draw_hud(self)
	for k,el in pairs(self.elements) do
		el:draw()
	end
end
function insert_element(self, el, name)
	if name then
		self.elements[name] = el
	else
		table.insert(self.elements, el)
	end
end

------------- BUTTON -------------
function make_button(self, x, y, spr, spr_hover, spr_click, on_click, on_hover)
	local btn = {
		type = "button",
		x = x,
		y = y,
		w = spr:getWidth(),
		h = spr:getHeight(),

		spr = spr,
		spr_hover = spr_hover,
		spr_click = spr_click,
		
		hovered = false,
		clicked = false,

		on_click = on_click,
		on_hover = on_hover,
		update = update_button,
		draw = draw_button,
	}
	return btn
end

function update_button(self, dt)
	
end

function draw_button(self)

end

------------- BAR -------------

function make_bar(self, name, x, y, max_val, val, spr, spr_empty, icon)
	spr = spr or spr_hp_bar
	local bar = {
		type = "bar",
		x = x, 
		y = y, 
		w = spr:getWidth(), 
		h = spr:getHeight(), 
		spr = spr, 
		spr_empty = spr_empty or spr_hp_bar_empty,
		spr_icon = icon,
		val = 10,--val or max_val,
		max_val = max_val or 10,

		update = update_bar,
		draw = draw_bar,
	}
	self:insert_element(bar, name)
end
function update_bar(self)
end
function draw_bar(self)
	local x = camera.x+self.x
	local y = camera.y+self.y
	local w = floor(self.w*(self.val/self.max_val))
	local h = floor(self.h)
	
	love.graphics.draw(self.spr_empty, camera.x+self.x, camera.y+self.y)
	local buffer_quad = love.graphics.newQuad(0, 0, w, self.h, self.spr:getDimensions())
	love.graphics.draw(self.spr, buffer_quad, x, y)

	local fonth = love.graphics.getFont():getHeight()
	x = floor(x+5)
	icon_y = floor(y + h/2 - self.spr_icon:getHeight()/2)
	if self.spr_icon then
		love.graphics.draw(self.spr_icon, x, icon_y, 0, 1, 1)
		x = x + self.spr_icon:getWidth() + 3
	end

	y = floor(y+h/2 - fonth/2)
	local txt = tostr(self.val).."_"..tostr(self.max_val)
	love.graphics.print(txt, x, y)
end
function get_val(self)
	return self.val
end
function set_val(self, val)
	self.val = val
end

------

function make_img(self, name, x, y, spr)
	local img = {
		type = "image",
		x = x, 
		y = y, 
		rot = 0, 
		spr = spr, 

		update = update_img,
		draw = draw_img,
	}
	self:insert_element(img, name)
end
function update_img(self)

end
function draw_img(self)
	love.graphics.draw(self.spr, camera.x+self.x, camera.y+self.y, self.rot)
end