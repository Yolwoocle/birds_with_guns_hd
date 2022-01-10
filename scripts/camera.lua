function init_camera()
	local camera = {
		x = 0,
		y = 0,
		target_x = 0,
		target_y = 0,
		sx = 1,
		sy = 1,

		smoothing = 0.7,

		update = update_camera,
		draw = draw_camera,
		set_pos = camera_set_pos,
		set_target = camera_set_target,
		set_scale = camera_set_scale,
	}
	return camera
end

function update_camera(self, dt)
	self.x = self.x + (self.target_x - self.x) * self.smoothing * dt
	self.y = self.y + (self.target_y - self.y) * self.smoothing * dt
end

function draw_camera(self, dt)
	-- Put this in love.draw, while update_camera should be in update. 
	love.graphics.translate(-self.x, -self.y)
	love.graphics.scale(self.sx, self.sy)
end

function camera_set_pos(self, x, y)
	self.x = x
	self.y = y
end

function camera_set_target(self, x, y)
	self.target_x = x
	self.target_y = y
end

function camera_set_scale(self, sx, sy)
	self.sx = sx
	self.sy = sy
end