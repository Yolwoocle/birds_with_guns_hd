require "scripts/utility"
require "scripts/settings"

function screenshot()
	local filename = os.date('birds_with_guns_%Y-%m-%d_%H-%M-%S.png') 
	
	local buffer_canvas = love.graphics.newCanvas(window_w * screenshot_scale, window_h * screenshot_scale)
	love.graphics.setCanvas(buffer_canvas)
	love.graphics.clear()
	love.graphics.draw(canvas, 0, 0, 0, screenshot_scale)
	love.graphics.setCanvas()

	buffer_canvas:newImageData():encode("png", filename)
	notification = "Image saved at: "..love.filesystem.getSaveDirectory().."/"..filename
end