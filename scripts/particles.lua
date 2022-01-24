function init_particles()
	local ptc = {
		table = {}
		
		make = make_particle,
		update = update_particles,
		draw = draw_particles,
	}
	return ptc
end

function make_particle(self, type, x, y, r)
	local ptc = {
		type = type,
		x = x, 
		y = y,
		dx = 0,
		dy = 0,
		fric = 20,

		r = r or 16,
	}
	table.insert(self.table, ptc)
end

function update_particles(self)
	for i,ptc in ipairs(self.table) do
		ptc.x = 
	end
end

function draw_particles(self)

end