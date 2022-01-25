function init_particles()
	local ptc = {
		table = {},
		
		make = make_particle,
		update = update_particles,
		draw = draw_particles,
	}
	return ptc
end

function make_particle(self, type, x, y, r, dx, dy, spd_fric, rad_fric)
	if spd_fric == nil then  spd_fric = 1  end
	if rad_fric == nil then  rad_fric = spd_fric  end
	local ptc = {
		type = type,
		x = x, 
		y = y, 
		dx = dx or 0,
		dy = dy or 0,
		spd_fric = spd_fric or 30,
		rad_fric = rad_fric or 30,

		r = r or 16,
	}
	table.insert(self.table, ptc)
end

function update_particles(self, dt)
	for i,ptc in ipairs(self.table) do
		ptc.x = ptc.x + ptc.dx 
		ptc.y = ptc.y + ptc.dx 

		ptc.r = ptc.r - ptc.rad_fric ^ dt
		if ptc.delete or ptc.r <= 0 then
			table.remove(self.table, i)
		end
	end
end

function draw_particles(self)
	for i,ptc in ipairs(self.table) do
		circ_color("fill", ptc.x, ptc.y, ptc.r, {1,1,1})
	end
end