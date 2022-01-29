require "scripts/utility"
require "scripts/settings"
local ffi = require "ffi"

function screenshot()
	--TODO: option to use love.graphics.captureScreenshot( filename )
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

	local imgdata = buffer_canvas:newImageData()
	local imgpng = imgdata:encode("png", filename)
	local filepath = love.filesystem.getSaveDirectory().."/"..filename
	notification = "Image saved at: "..filepathsd
	print(notification)

	return filepath, imgdata, imgpng
end

function screenshot_clip()
	--[[
	local cmd = io.popen('clip-copyfile','w')
	cmd:write(path)
	cmd:close()--]] 
	
	--echo "<img src='data:image/png;base64,"$(base64 -w0 "$TMP")"' />" | \
	--xclip -selection clipboard -t text/html || screenshotfail

	--local filepath, imgdata, imgpng = screenshot()

	--local img_str = imgdata:getString()
	--local txt = love.system.getClipboardText( )

	--local encoded_img = love.data.encode("string", "base64", img_str)
	--love.system.setClipboardText(encoded_img)
end