require "scripts/utility"
require "scripts/settings"
local ffi = require "ffi"

function screenshot()
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
	notification = "Screenshot path pasted to clipboard"
	love.system.setClipboardText(filepath)
	print(notification)

	return filepath, imgdata, imgpng
end

function screenshot_clip()
	curgif = gifcat.newGif(os.time()..".gif",window_w*gif_scale, window_h*gif_scale)

	-- Optional method to just print out the progress of the gif
	-- Thanks to https://github.com/maxiy01/gifcat 
	curgif:onUpdate(function(gif,curframes,totalframes)
		print(string.format("Progress: %.2f%% (%d/%d)",gif:progress()*100,curframes,totalframes))
	end)
	curgif:onFinish(function(gif,totalframes)
		print(totalframes.." frames written")
	end)
end

function capture_clip_frame()
	if curgif then
		-- Save a frame to our gif.
		love.graphics.captureScreenshot(function(screenshot) curgif:frame(screenshot) end)

		-- Show a little recording icon in the upper right hand corner. This will
		--   not get shown in the gif because it is displayed after the call to
	end
end