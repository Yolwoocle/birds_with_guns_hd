require "scripts.sfx"

function make_audio_manager()
	local a = {}	

	a.music_tracks = {
		level_1 = music_level_1,
	}
	a.curmusic_name = "level_1"
	a.curmusic = a.music_tracks[a.curmusic_name]

	a.update = function(self)
		
	end

	a.on_pause = function(self)

	end

	a.play = function(self, sound)
		if get_setting("sound_on") then
			local source = sound:clone()
			source:play()
		end
	end

	a.set_music = function(self, name)
		local track = self.music_tracks[name]
		if track then
			self.curmusic_name = name
			self.curmusic = track
		end
	end
	a.play_music = function(self)
		if get_setting("music_on") then
			self.curmusic:play()
		end
	end
	a.pause_music = function(self)
		self.curmusic:pause()
	end

	a.on_leave_start_area = function(self)
		self:play_music()
	end
	a.on_pause = function(self)
		self:pause_music()
	end
	a.on_unpause = function(self)
		self:play_music()
	end

	return a
end