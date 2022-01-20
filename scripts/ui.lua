require "scripts/utility"
require "scripts/collision"

function make_gui()
	return {
		elements = {},
		update = update_gui,
		draw = draw_gui,

		make_bar = make_bar,
		make_button = make_button,
	}
end
function update_gui(self)
	for k,el in pairs(self.elements) do
		el:update()
	end
end
function draw_gui(self)
	for k,el in pairs(self.elements) do
		el:draw()
	end
end

------------- BUTTON -------------
function make_button(self, x, y, spr, spr_hover, spr_click, on_click, on_hover)
	local btn = {
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

function make_bar(self, name, x, y, maxval, val, spr, spr_empty)
	spr = spr or spr_hp_bar
	local bar = {
		x = x, 
		y = y, 
		w = spr:getWidth(), 
		h = spr:getHeight(), 
		spr = spr,
		spr_empty = spr_empty or spr_hp_bar_empty,
		val = 10,--val or maxval,
		maxval = maxval or 10,

		update = update_bar,
		draw = draw_bar,
	}
	if name then
		self.elements[name] = bar
	else
		table.insert(self.elements, bar)
	end
end
function update_bar(self)
end
function draw_bar(self)
	local x = camera.x+self.x
	local y = camera.y+self.y
	local w = floor(self.w*(self.val/self.maxval))
	love.graphics.draw(self.spr_empty, camera.x+self.x, camera.y+self.y)
	local buffer_quad = love.graphics.newQuad(0, 0, w, self.h, self.spr:getDimensions())
	love.graphics.draw(self.spr, buffer_quad, x, y)
end
function get_val(self)
	return self.val
end
function set_val(self, val)
	self.val = val
end

------
