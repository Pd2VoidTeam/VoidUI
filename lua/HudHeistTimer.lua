if VoidUI.options.enable_timer then
	function HUDHeistTimer:init(hud, tweak_hud)
		self._hud_panel = hud.panel
		if self._hud_panel:child("heist_timer_panel") then
			self._hud_panel:remove(self._hud_panel:child("heist_timer_panel"))
		end
		self._scale = VoidUI.options.hud_objectives_scale
		local visible = VoidUI.options.show_timer
			
		self._heist_timer_panel = self._hud_panel:panel({
			visible = visible == 3,
			alpha = visible and 1 or 0,
			name = "heist_timer_panel",
			h = 150 * self._scale,
			y = 0,
			valign = "top",
			layer = 0
		})
		self._timer_text = self._heist_timer_panel:text({
			name = "timer_text",
			text = "00:00",
			font_size = tweak_data.hud.active_objective_title_font_size * self._scale,
			font = "fonts/font_large_mf",
			color = Color.white,
			align = "left",
			vertical = "center",
			layer = 3,
			wrap = false,
			word_wrap = false,
			rotation = 360,
			x = VoidUI.options.show_levelname and 25 * self._scale or 30 * self._scale,
			y = 7 * self._scale,
			h = 25 * self._scale
		})
		
		local level_data = managers.job:current_level_data()
		if level_data then
			local level_name = self._heist_timer_panel:text({
				name = "level_name",
				visible = true,
				layer = 2,
				color = Color.white,
				text = VoidUI.options.show_levelname and managers.localization:text(level_data.name_id) or " ",
				font_size = tweak_data.hud.active_objective_title_font_size * 1.2 * self._scale,
				font = "fonts/font_large_mf",
				x = 70 * self._scale,
				y = 4 * self._scale,
				align = "left",
				vertical = "top"
			})
			local _, _, name_w, name_h = level_name:text_rect()
			name_w = VoidUI.options.show_levelname and name_w or 0
			local is_level_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id())
			local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
			local ghost_icon = self._heist_timer_panel:bitmap({
				name = "ghost_icon",
				texture = "guis/textures/pd2/cn_minighost",
				w = 16 * self._scale,
				h = 16 * self._scale,
				layer = 2,
				blend_mode = "add",
			})	
			ghost_icon:set_left(71 * self._scale + name_w)
			ghost_icon:set_center_y(6 * self._scale + name_h / 2)
			ghost_icon:set_visible(is_level_ghostable and VoidUI.options.show_ghost_icon)
			ghost_icon:set_color(is_whisper_mode and Color.white or tweak_data.screen_colors.important_1)
			local ghost_w = VoidUI.options.show_ghost_icon and 15 * self._scale or 0
			name_w = is_level_ghostable and name_w + ghost_w or name_w
			local weapons_texture = "guis/textures/VoidUI/hud_weapons"
			local level_name_bg_left = self._heist_timer_panel:bitmap({
				name = "level_name_bg_left",
				texture = weapons_texture,
				texture_rect = {26,0,43,150},
				layer = 1,
				x = 9 * self._scale,
				w = 35 * self._scale,
				h = name_h + 8 * self._scale,
				color = Color.black,
				alpha = 1
			})
			local level_name_bg = self._heist_timer_panel:bitmap({
				name = "level_name_bg",
				texture = weapons_texture,
				texture_rect = {69,0,416,150},
				layer = 1,
				w = name_w + 12 * self._scale,
				h = name_h + 8 * self._scale,
				x = 44 * self._scale,
				y = 0,
				alpha = 1
			})	
			
			local level_name_bg_right = self._heist_timer_panel:bitmap({
				name = "level_name_bg_right",
				texture = weapons_texture,
				texture_rect = {485,0,43,150},
				layer = 1,
				w = 35 * self._scale,
				h = name_h + 8 * self._scale,
				color = Color.black,
				alpha = 1
			})
			level_name_bg_right:set_left(level_name_bg:right())
			
			if managers.groupai:state() and not self._whisper_listener then
				self._whisper_listener = "HUDHeistTimer_whisper_mode"
				managers.groupai:state():add_listener(self._whisper_listener, {
					"whisper_mode"
				}, callback(self, self, "whisper_mode_changed"))
			end
			
			local bags_panel = self._heist_timer_panel:panel({
				visible = false,
				name = "bags_panel",
				w = 70 * self._scale,
				h = name_h + 8 * self._scale,
			})
			bags_panel:set_left(level_name_bg_right:right() - 5)
			
			local bags_bg_left = bags_panel:bitmap({
				name = "bags_bg_left",
				texture = weapons_texture,
				texture_rect = {26,0,43,150},
				layer = 1,
				w = bags_panel:w() / 2,
				h = bags_panel:h(),
				color = Color.black,
				alpha = 1
			})
			
			local bags_bg_right = bags_panel:bitmap({
				name = "bags_bg_right",
				texture = weapons_texture,
				texture_rect = {485,0,43,150},
				layer = 1,
				w = bags_panel:w() / 2,
				h = bags_panel:h(),
				color = Color.black,
				alpha = 1
			})
			bags_bg_right:set_left(bags_bg_left:right())
			local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
			local bags_icon = bags_panel:bitmap({
				name = "bags_icon",
				texture = bag_texture,
				texture_rect = bag_rect,
				alpha = 0.6,
				y = 8 * self._scale,
				w = 25 * self._scale,
				h = 20 * self._scale,
				layer = 2
			})
			bags_icon:set_center_x(bags_bg_left:right())
			
			local bags_count = bags_panel:text({
				name = "bags_count",
				w = bags_panel:w() / 1.3,
				h = bags_panel:h(),
				font_size = bags_panel:h() / 1.7 * self._scale,
				text = managers.loot:get_secured_mandatory_bags_amount() + managers.loot:get_secured_bonus_bags_amount() * self._scale,
				vertical = "bottom",
				align = "right",
				font = "fonts/font_medium_shadow_mf",
				layer = 3,
				alpha = 1,
			})
		end	
		
		self._last_time = 0
		self._enabled = not tweak_hud.no_timer
		if not self._enabled then
			self._heist_timer_panel:hide()
			
		end
		
	end


	function HUDHeistTimer:whisper_mode_changed()
		local ghost_icon = self._heist_timer_panel:child("ghost_icon")
		local is_level_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id()) and managers.groupai and managers.groupai:state():whisper_mode()
		local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
		if alive(ghost_icon) then
			ghost_icon:set_color(is_whisper_mode and Color.white or tweak_data.screen_colors.important_1)
		end
	end
	function HUDHeistTimer:loot_value_changed()
			local bags_panel = self._heist_timer_panel:child("bags_panel")
			local bags_count = bags_panel:child("bags_count")
		if VoidUI.options.show_loot then
			local secured_value = managers.loot:get_secured_mandatory_bags_amount() + managers.loot:get_secured_bonus_bags_amount()
			if bags_panel:visible() == false and secured_value ~= 0 then
				bags_panel:animate(callback(self, self, "_animate_bags_enable"))
				bags_count:set_text("x"..secured_value)
			else
				bags_count:animate(callback(self, self, "_animate_bags_count"), secured_value)
			end
		else
			bags_panel:set_visible(false)
		end
	end

	function HUDHeistTimer:_animate_bags_enable(bags_panel)
		local bags_bg_left = bags_panel:child("bags_bg_left")
		local bags_bg_right = bags_panel:child("bags_bg_right")
		local bags_icon = bags_panel:child("bags_icon")
		local bags_count = bags_panel:child("bags_count")
		local x = bags_bg_left:x()
		local TOTAL_T = 0.2
		local t = 0
		bags_bg_left:set_x(-bags_panel:w())
		bags_panel:set_visible(true)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			bags_panel:set_alpha(math.lerp(0, 1, t / TOTAL_T))
			bags_bg_left:set_x(math.lerp(-bags_panel:w(), x - 2, t / TOTAL_T))
			bags_bg_right:set_left(bags_bg_left:right())
			bags_icon:set_center_x(bags_bg_left:right())
			bags_count:set_left(bags_bg_left:left())	
		end
		bags_bg_left:set_x(x)
		bags_bg_right:set_left(bags_bg_left:right())
		bags_icon:set_center_x(bags_bg_left:right())
		bags_count:set_left(bags_bg_left:left())	
	end

	function HUDHeistTimer:_animate_bags_count(bags_count, secured_value)
		local bags_panel = self._heist_timer_panel:child("bags_panel")
		local size = bags_panel:h() / 1.7
		local TOTAL_T = 0.2
		local t = 0
		bags_count:set_text("x"..secured_value)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			bags_count:set_font_size(math.lerp(size * 1.5, size, t / TOTAL_T))
		end
	end

	local timer_set_time = HUDHeistTimer.set_time
	function HUDHeistTimer:set_time(time)
		timer_set_time(self, time)
		self._timer_text:set_font_size(tweak_data.hud.active_objective_title_font_size * self._scale)
		local w = select(3, self._timer_text:text_rect())
		if w > 40 * self._scale then
			self._timer_text:set_font_size((tweak_data.hud.active_objective_title_font_size * self._scale) * (40 * self._scale) / w)
		end
	end
	
	local modify_time = HUDHeistTimer.modify_time
	function HUDHeistTimer:modify_time(time)
		modify_time(self, time)
		self._timer_text:stop()
		self._timer_text:animate(function(o)
			local s = self._timer_text:font_size()
			over(0.3, function(p)
				if time ~=0 and alive(self._timer_text) then
					self._timer_text:set_font_size(math.lerp(s*1.5, s, p))
					self._timer_text:set_color(math.lerp(time > 0 and Color.green or Color.red, Color.white, p))
				end
			end)
		end)
	end
end