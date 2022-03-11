function init_particles()
	local ptc = {
		table = {},
		
		make_circ = make_circ_particle,
		make_spr = make_spr_particle,
		update = update_particles,
		draw = draw_particles,
	}
	return ptc
end

function make_circ_particle(self, x, y, r, col, dx, dy, spd_fric, rad_fric)
	col = col or {1,1,1}
	spd_fric = spd_fric or 1
	rad_fric = rad_fric or spd_fric
	local ptc = {
		type = "circle",
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
function make_spr_particle(self, x, y, spr, life, dx, dy, spd_fric)
	spd_fric = spd_fric or 1
	life = life or 1
	local ptc = {
		type = "spr",
		x = x, 
		y = y, 
		spr = spr,
		life = life,

		dx = dx or 0,
		dy = dy or 0,
		spd_fric = spd_fric or 30,
	}
	table.insert(self.table, ptc)
end


function update_particles(self, dt)
	for i,ptc in ipairs(self.table) do
		ptc.x = ptc.x + ptc.dx 
		ptc.y = ptc.y + ptc.dx 

		if ptc.type == "circle" then
			ptc.r = ptc.r - ptc.rad_fric ^ dt --argh! friggin deltaTime!
			if ptc.r <= 0.01 then  ptc.delete = true  end
		elseif ptc.type == "spr" then
			ptc.life = ptc.life - dt
			if ptc.life <= 0 then  ptc.delete = true  end
		end

		if ptc.delete then
			table.remove(self.table, i)
		end
	end
end

function draw_particles(self)
	for i,ptc in ipairs(self.table) do
		if ptc.type == "circle" then
			circ_color("fill", ptc.x, ptc.y, ptc.r, {1,1,1})
		elseif ptc.type == "spr" then
			draw_centered(ptc.spr, ptc.x, ptc.y)
		end
	end
end