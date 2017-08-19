function HUDSuspicion:init(hud, sound_source)
	self._hud_panel = hud.panel
	self._sound_source = sound_source
	if self._hud_panel:child("suspicion_panel") then
		self._hud_panel:remove(self._hud_panel:child("suspicion_panel"))
	end
	self._suspicion_panel = self._hud_panel:panel({
		visible = false,
		name = "suspicion_panel",
		valign = "center",
		w = 290,
		h = 25,
		layer = 1
	})
	self._misc_panel = self._suspicion_panel:panel({name = "misc_panel"})
	self._suspicion_panel:set_center(self._suspicion_panel:parent():w() / 2, self._suspicion_panel:parent():h() / 2 - 100)
	local scale = 1
	local suspicion_left = self._suspicion_panel:bitmap({
		name = "suspicion_left",
		visible = true,
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {648,26,-90,88},
		color = Color(0,0.47,1),
		alpha = 1,
		w = 35,
		h = 25,
		layer = 1
	})
	suspicion_left:set_right(self._suspicion_panel:w() / 2 - 20)
	local suspicion_right = self._suspicion_panel:bitmap({
		name = "suspicion_right",
		visible = true,
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {558,26,90,88},
		color = Color(0,0.47,1),
		alpha = 1,
		w = 35,
		h = 25,
		layer = 1
	})
	suspicion_right:set_x(self._suspicion_panel:w() / 2 + 20)
	local suspicion_rate = self._suspicion_panel:text({
		name = "suspicion_rate",
		text = " 0%",
		layer = 5,
		color = Color(0,0.47,1),
		align = "center",
		vertical = "center",
		font_size = 25,
		font = "fonts/font_medium_shadow_mf",
	})
	
	local left_blue = self._misc_panel:bitmap({
		name = "left_blue",
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {556,26, -177,88},
		color = Color(0,0.47,1),
		alpha = 0.3,
		layer = 0,
		w = 70,
		h = 25,
		blend_mode = "add"
	})
	left_blue:set_right(self._misc_panel:w() / 2 - 20)
	local left_red = self._misc_panel:bitmap({
		name = "left_red",
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {556,26, -177,88},
		color = Color(1,0.2,0),
		alpha = 0.3,
		layer = 0,
		w = 70,
		h = 25,
		blend_mode = "add"
	})
	left_red:set_right(left_blue:x() + 15)
	
	local right_blue = self._misc_panel:bitmap({
		name = "right_blue",
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {380,26,177,88},
		color = Color(0,0.47,1),
		alpha = 0.3,
		layer = 0,
		w = 70,
		h = 25,
		blend_mode = "add"
	})
	right_blue:set_x(self._misc_panel:w() / 2 + 20)
	local right_red = self._misc_panel:bitmap({
		name = "right_red",
		texture = "guis/textures/VoidUI/hud_extras",
		texture_rect = {380,26,177,88},
		color = Color(1,0.2,0),
		alpha = 0.3,
		layer = 0,
		w = 70,
		h = 25,
		blend_mode = "add"
	})
	right_red:set_x(right_blue:right() - 15)
	
	local suspicion_detected = self._suspicion_panel:bitmap({
		name = "suspicion_detected",
		visible = true,
		texture = "guis/textures/pd2/hud_stealth_exclam",
		alpha = 0,
		w = 32,
		h = 32,
		rotation = 360,
		valign = "center",
		blend_mode = "add",
		layer = 1
	})
	suspicion_detected:set_center(self._suspicion_panel:w() / 2, self._suspicion_panel:h() / 2)
	self._eye_animation = nil
	self._suspicion_value = 0
	self._hud_timeout = 0
end
function HUDSuspicion:animate_eye()
	if self._eye_animation then
		return
	end
	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil
	local animate_func = function(o, self)
		local wanted_value = 0
		local value = wanted_value
		local suspicion_left = o:child("suspicion_left")
		local suspicion_right = o:child("suspicion_right")
		local suspicion_rate = o:child("suspicion_rate")
		local suspicion_detected = o:child("suspicion_detected")
		local misc_panel = o:child("misc_panel")
		local animate_hide_misc = function(o)
			local start_alpha = o:alpha()
			wait(1.8)
			over(0.1, function(p)
				self._suspicion_panel:set_alpha(math.lerp(start_alpha, 0, p))
			end)
		end
		local animate_show_misc = function(o)
			local start_alpha = o:alpha()
			over(0.1, function(p)
				self._suspicion_panel:set_alpha(math.lerp(start_alpha, 1, p))
			end)
		end
		misc_panel:stop()
		misc_panel:animate(animate_show_misc)
		local color
		local dt
		local detect_me = false
		local time_to_end = 4
		while true do
			if not alive(o) then
				return
			end
			dt = coroutine.yield()
			self._hud_timeout = self._hud_timeout - dt
			if 0 > self._hud_timeout then
				self._back_to_stealth = true
			end
			if self._discovered then
				self._discovered = nil
				if not detect_me then
					detect_me = true
					wanted_value = 1
					self._suspicion_value = wanted_value
					self._sound_source:post_event("hud_suspicion_discovered")
					local animate_detect_text = function(o)
						local w, h = o:size()
						local suspicion_rate = o:parent():child("suspicion_rate")
						over(0.6, function(p)
							o:set_alpha(p)
							suspicion_rate:set_alpha(1 - p)
							o:set_size(w * p, h * p)
							o:set_center(o:parent():w() / 2, o:parent():h() / 2)
						end)
					end
					suspicion_detected:stop()
					suspicion_detected:animate(animate_detect_text)
				end
			end
			if not detect_me and wanted_value ~= self._suspicion_value then
				wanted_value = self._suspicion_value
			end
			if (not detect_me or time_to_end < 2) and self._back_to_stealth then
				self._back_to_stealth = nil
				suspicion_rate:set_alpha(1)
				suspicion_detected:set_alpha(0)
				detect_me = false
				wanted_value = 0
				self._suspicion_value = wanted_value
				misc_panel:stop()
				misc_panel:animate(animate_hide_misc)
			end
			value = math.lerp(value, wanted_value, 0.9)
			if math.abs(value - wanted_value) < 0.01 then
				value = wanted_value
			end
			color = math.lerp(Color(0,0.47,1), Color(1,0.2,0), math.clamp(value - 0.48, 0, 0.04) / 0.04)
			suspicion_rate:set_text(math.floor(value * 100) .."%")
			suspicion_right:set_x(math.lerp(self._suspicion_panel:w() / 2 + 20, self._suspicion_panel:w() - suspicion_right:w(), value))
			suspicion_left:set_x(math.lerp(self._suspicion_panel:w() / 2 - 20 - suspicion_left:w(), 0, value))
			suspicion_rate:set_color(color)
			suspicion_right:set_color(color)
			suspicion_left:set_color(color)
			local misc_panel = o:child("misc_panel")
			if value == 1 then
				time_to_end = time_to_end - dt
				if time_to_end <= 0 then
					self._eye_animation = nil
					self:hide()
					return
				end
			elseif value <= 0 then
				time_to_end = time_to_end - dt * 2
				if time_to_end <= 0 then
					self._eye_animation = nil
					self:hide()
					return
				end
			elseif time_to_end ~= 4 then
				time_to_end = 4
				misc_panel:stop()
				misc_panel:animate(animate_show_misc)
			end
		end
	end
	self._sound_source:post_event("hud_suspicion_start")
	self._eye_animation = self._suspicion_panel:animate(animate_func, self)
end

function HUDSuspicion:hide()
	if self._eye_animation then
		self._eye_animation:stop()
		self._eye_animation = nil
		self._sound_source:post_event("hud_suspicion_end")
	end
	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil
	if alive(self._misc_panel) then
		self._misc_panel:stop()
	end
	if alive(self._suspicion_panel) then
		self._suspicion_panel:set_visible(false)
		self._suspicion_panel:child("suspicion_rate"):set_alpha(1)
		self._suspicion_panel:child("suspicion_detected"):stop()
		self._suspicion_panel:child("suspicion_detected"):set_alpha(0)
	end
end
