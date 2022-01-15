require "scripts/utility"

function make_gui()
	return {
		elements = {},
		update = update_gui,
		draw = draw_gui,

		make_bar = make_bar,
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

-------------

function make_bar(self, name, x, y, w, h, col, maxval, val)
	local bar = {
		x = x, 
		y = y, 
		w = w, 
		h = h, 
		col = col,
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
	local w = floor(self.w*(self.val/self.maxval))
	rect_color("fill", camera.x+self.x, camera.y+self.y, w, self.h, self.col)
end
function get_val(self)
	return self.val
end
function set_val(self, val)
	self.val = val
end

------
