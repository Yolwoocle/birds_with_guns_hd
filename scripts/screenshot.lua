require "scripts/utility"
require "scripts/settings"

function screenshot()
	--TODO: option to use love.graphics.captureScreenshot( filename )
	--TODO: setting to set pixel scale (2 or 3) by default
	--TODO: paste screenshot into pastebin
	--TODO: capture GIFs: https://love2d.org/forums/viewtopic.php?t=81543 + lua-gd lib
	--These features are important as it provides an easy way 
	--for players to share the game with others (GIF especially)
	local filename = os.date('birds_with_guns_%Y-%m-%d_%H-%M-%S.png') 
	
	local buffer_canvas = love.graphics.newCanvas(window_w * screenshot_scale, window_h * screenshot_scale)
	love.graphics.setCanvas(buffer_canvas)
	love.graphics.clear()
	love.graphics.draw(canvas, 0, 0, 0, screenshot_scale)
	love.graphics.setCanvas()

	buffer_canvas:newImageData():encode("png", filename)
	local filepath = love.filesystem.getSaveDirectory().."/"..filename
	notification = "Image saved at: "..filepath
	print(notification)

	return filepath
end

function screenshot_clip()
	local path = screenshot()
	local cmd = io.popen('clip','w')
	cmd:write(path)
	cmd:close()
end