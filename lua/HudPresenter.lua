if RequiredScript == "lib/managers/hud/hudpresenter" and VoidUI.options.enable_presenter then
	function HUDPresenter:init(hud)
		self._hud_panel = hud.panel
		self._id = 0
		self._active = 0
		self._scale = VoidUI.options.presenter_scale
	end
	function HUDPresenter:present(params)
		self._present_queue = self._present_queue or {}
		if self._active > (VoidUI.options.presenter_buffer-1) then
			table.insert(self._present_queue, params)
			return
		end
		
		if self._active > 0 then
			for i = self._id - 1, self._id - self._active, -1 
			do
				local present_panel = self._hud_panel:child("present_panel_"..i)
				local slot = present_panel:child("slot")
				slot:set_text(slot:text()+1)
				present_panel:animate(callback(self, self, "_animate_move_queue"), tonumber(slot:text()))
			end
		end
		if params.present_mid_text then
			self:_present_information(params)
		end
	end

	function HUDPresenter:_present_information(params)
		local id = self._id
		self._active = self._active + 1
		self._id = self._id + 1
		local h = 40 * self._scale
		local w = 100 * self._scale
		local x = self._hud_panel:w() - 200 * self._scale
		local y = self._hud_panel:h() / 2 - (h / 2)
		local color = params.color or Color.white
		local present_panel = self._hud_panel:panel({
			visible = false,
			name = "present_panel_"..id,
			layer = 10,
			x = x,
			y = y
		})
		local slot = present_panel:text({
			name = "slot",
			visible = false,
			text = "0",
			vertical = "top",
			valign = "center",
			layer = 0,
			font = tweak_data.hud_present.title_font,
			font_size = 10
		})
		local weapons_texture = "guis/textures/VoidUI/hud_weapons"
		local present_bg_left = present_panel:bitmap({
			name = "present_bg_left",
			texture = weapons_texture,
			texture_rect = {26,0,43,150},
			layer = 1,
			y = 0,
			w = 35 * self._scale,
			h = h,
			rotation = 360,
		})
		local present_border_left = present_panel:bitmap({
			name = "present_border_left",
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {0,0,23,157},
			layer = 2,
			y = 0,
			w = 15 * self._scale,
			h = h,
			rotation = 360,
			color = color,
			visible = params.border and true or false,
		})
		local present_bg = present_panel:bitmap({
			name = "present_bg",
			texture = weapons_texture,
			texture_rect = {69,0,416,150},
			layer = 1,
			w = w,
			h = h,
			x = 35 * self._scale,
			y = 0,
			rotation = 360,
		})	
		local present_border = present_panel:bitmap({
			name = "present_border",
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {23,0,480,157},
			layer = 2,
			w = w,
			h = h,
			x = 15 * self._scale,
			y = 0,
			rotation = 360,
			color = color,
			visible = params.border and true or false,
		})	
		local present_bg_right = present_panel:bitmap({
			name = "present_bg_right",
			texture = weapons_texture,
			texture_rect = {485,0,43,150},
			layer = 1,
			y = 0,
			w = 35 * self._scale,
			h = h,
			rotation = 360,
		})
		present_bg_right:set_left(present_bg:right())
		local title = present_panel:text({
			name = "title",
			text = params.title or "ERROR",
			vertical = "top",
			valign = "left",
			layer = 2,
			x = 15 * self._scale,
			color = color,
			rotation = 360,
			font = tweak_data.hud_present.title_font,
			font_size = tweak_data.hud_present.title_size / 1.5 * self._scale
		})
		local _, _, title_w, title_h = title:text_rect()
		title:set_h(title_h)
		local text = present_panel:text({
			name = "text",
			text = params.text,
			vertical = "top",
			valign = "top",
			layer = 2,
			x = 9 * self._scale,
			color = color,
			rotation = 360,
			font = tweak_data.hud_present.text_font,
			font_size = tweak_data.hud_present.text_size / 1.5 * self._scale
		})
		local _, _, text_w, text_h = text:text_rect()
		text:set_top(title:bottom())
		text:set_h(text_h)
		w = math.max(title_w, text_w)
		present_bg:set_w(w - 35 * self._scale)
		present_bg_right:set_left(present_bg:right())
		present_panel:set_w(present_bg_left:w() + present_bg:w() + present_bg_right:w())
		present_panel:set_right(self._hud_panel:right())
		

		present_panel:animate(callback(self, self, "_animate_present_information"))
		
		if params.event and not VoidUI.options.presenter_sound then
			managers.hud._sound_source:post_event(params.event)
		end
	end
	function HUDPresenter:_animate_present_information(present_panel)
		present_panel:set_visible(true)
		present_panel:animate(callback(self, self, "_animate_show_panel"))
		wait(4)
		present_panel:animate(callback(self, self, "_animate_hide_panel"))
		wait(0.5)
		self._hud_panel:remove(present_panel)
		self._active = self._active - 1
		self:_present_done()
	end

	function HUDPresenter:_present_done()
		local queued = table.remove(self._present_queue, 1)
		if queued then
			setup:add_end_frame_clbk(callback(self, self, "_do_it", queued))
		end
	end
	function HUDPresenter:_do_it(queued)
		self._present_queue = self._present_queue or {}
		if self._active > 5 then
			table.insert(self._present_queue, params)
			return
		end
		
		if self._active > 0 then
			for i = self._id - 1, self._id - self._active, -1 
			do
				local present_panel = self._hud_panel:child("present_panel_"..i)
				if presenter_panel then
					local slot = present_panel:child("slot")
					slot:set_text(slot:text()+1)
					present_panel:animate(callback(self, self, "_animate_move_queue"), tonumber(slot:text()))
				end
			end
		end
		self:_present_information(queued)
	end
	function HUDPresenter:_animate_move_queue(present_panel, goal)
		local y = present_panel:y()
		local y2 = (self._hud_panel:h() / 2 - ((40 * self._scale ) / 2)) - (goal * (45 * self._scale))
		local TOTAL_T = 0.2
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_y(math.lerp(y,y2, t / TOTAL_T))
		end
		present_panel:set_y(y2)
	end

	function HUDPresenter:_animate_show_panel(present_panel)
		local x = present_panel:x()
		local x2 = present_panel:x() + present_panel:w()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_alpha(math.lerp(0,1, t / TOTAL_T))
			present_panel:set_x(math.lerp(x2,x, t / TOTAL_T))
		end
		present_panel:set_alpha(1)
		present_panel:set_x(x)
	end
	function HUDPresenter:_animate_hide_panel(present_panel)
		local x = present_panel:x()
		local x2 = present_panel:x() + present_panel:w()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_alpha(math.lerp(1, 0, t / TOTAL_T))
			present_panel:set_x(math.lerp(x,x2, t / TOTAL_T))
			x2 = x2 + (dt > 0 and 0.1 or 0)
		end
		present_panel:set_alpha(0)
		present_panel:set_x(x2)
	end
elseif RequiredScript == "lib/managers/hud/hudchallengenotification" and VoidUI.options.enable_challanges then
	HudChallengeNotification.ICON_SIZE = 50
	HudChallengeNotification.BOX_MAX_W = 400
	function HudChallengeNotification:make_fine_text(text)
		local x, y, w, h = text:text_rect()

		text:set_size(w, h)
		text:set_position(math.round(text:x()), math.round(text:y()))
	end
	
	function HudChallengeNotification:_animate_show(title_panel, text_panel)
		local center = text_panel:center_x()
		local TOTAL_T = 0.3
		local t = 0
		while t < TOTAL_T do 
			coroutine.yield()
			local dt = TimerManager:main():delta_time()
			t = t + dt
			title_panel:set_x(math.lerp(-title_panel:w(), self._hud:w() / 2 + 35 - text_panel:w() / 2, t / TOTAL_T))
			text_panel:set_center_x(math.lerp(center, self._hud:w() / 2 + 35, t / TOTAL_T))
		end
		title_panel:set_x(self._hud:w() / 2 + 35 - text_panel:w() / 2)
		text_panel:set_center_x(self._hud:w() / 2 + 35)
		local title_x = title_panel:x()
		TOTAL_T = 2
		t = 0
		while t < TOTAL_T do 
			coroutine.yield()
			local dt = TimerManager:main():delta_time()
			t = t + dt
			title_panel:set_x(math.lerp(title_x, title_x + 35, t / TOTAL_T))
			text_panel:set_center_x(math.lerp(self._hud:w() / 2 + 35, self._hud:w() / 2, t / TOTAL_T))
		end
		title_x = title_panel:x()
		TOTAL_T = 0.3
		t = 0
		while t < TOTAL_T do 
			coroutine.yield()
			local dt = TimerManager:main():delta_time()
			t = t + dt
			title_panel:set_x(math.lerp(title_x, self._hud:w(), t / TOTAL_T))
			text_panel:set_center_x(math.lerp(self._hud:w() / 2, -text_panel:w() / 2, t / TOTAL_T))
		end
		self:close()
	end
	
	function HudChallengeNotification:init(title, text, icon, rewards, queue)
		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._scale = VoidUI.options.challanges_scale

		HudChallengeNotification.super.init(self, self._ws:panel())
		self._queue = queue or {}
		self._hud = self._ws:panel()
		self._hud:set_layer(1000)
		local text_panel = self._hud:panel({})
		local noti_text = text_panel:text({
			text = utf8.to_lower(text):gsub("^%l", string.upper) or "Blame overkill!",
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size * self._scale,
			vertical = "center",
			x = 20 * self._scale,
			w = self.BOX_MAX_W * self._scale,
			wrap = true,
			word_wrap = true,
			layer = 2
		})
		self:make_fine_text(noti_text)
		noti_text:set_h(noti_text:h() + 6 * self._scale)
		local icon_texture, icon_texture_rect = tweak_data.hud_icons:get_icon_or(icon, nil)
		if icon_texture then
			local icon = text_panel:bitmap({
				texture = icon_texture,
				texture_rect = icon_texture_rect,
				layer = 2,
				x = 10 * self._scale,
				y = 3 * self._scale,
				w = self.ICON_SIZE * self._scale,
				h = self.ICON_SIZE * self._scale
			})
			noti_text:set_x(icon:right() + 5)
			noti_text:set_h(math.max(icon:h() + 6 * self._scale, noti_text:h()))
			icon:set_center_y(noti_text:center_y())
		end
		local box_height = noti_text:h()
		
		for i, reward in ipairs(rewards or {}) do
			local reward_panel = text_panel:panel({
				h = 20,
				x = 25,
				y = noti_text:bottom() + (i - 1) * 22,
				layer = 2
			})
			local reward_icon = reward_panel:bitmap({
				w = 20,
				h = 20,
				texture = reward.texture
			})
			local reward_text = managers.localization:text(reward.name_id)
	
			if reward.amount then
				reward_text = reward.amount .. "x " .. reward_text
			end
			local reward_text = reward_panel:text({
				text = reward_text,
				font = tweak_data.menu.pd2_medium_font,
				x = reward_icon:right() + 2,
				layer = 2,
				font_size = 20 * self._scale
			})
			local reward_text_bg = reward_panel:text({
				text = reward_text:text(),
				font = tweak_data.menu.pd2_medium_font,
				color = Color.black,
				layer = 1,
				x = reward_icon:right() + 3,
				font_size = 20 * self._scale
			})
			reward_text:set_center_y(reward_icon:center_y())
			reward_text_bg:set_center_y(reward_icon:center_y() + 1)
			reward_panel:set_w(reward_text_bg:right())
	
			box_height = math.max(box_height, reward_panel:bottom() + 8)
		end
		
		local weapons_texture = "guis/textures/VoidUI/hud_weapons"
		local text_bg_left = text_panel:bitmap({
			name = "objective_text_bg_left",
			texture = weapons_texture,
			texture_rect = {26,0,43,150},
			layer = 1,
			w = 25 * self._scale,
			h = noti_text:h(),
			alpha = 1
		})
		local text_bg = text_panel:bitmap({
			name = "text_bg",
			texture = weapons_texture,
			texture_rect = {69,0,416,150},
			layer = 1,
			w = noti_text:right() - 25 * self._scale,
			h = noti_text:h(),
			x = text_bg_left:right(),
			alpha = 1
		})	
		local text_bg_right = text_panel:bitmap({
			name = "text_bg_right",
			texture = weapons_texture,
			texture_rect = {485,0,43,150},
			layer = 1,
			w = 25 * self._scale,
			h = noti_text:h(),
			alpha = 1
		})
		text_bg_right:set_left(text_bg:right())
		text_panel:set_size(text_bg_right:right(), box_height)
		text_panel:set_left(self._hud:w())
		local title_panel = self._hud:panel({})
		local title_shadow = title_panel:text({
			text = utf8.to_lower(title):gsub("^%l", string.upper) or "Achievement unlocked!",
			x = 1,
			y = 1,
			font = tweak_data.menu.pd2_large_font,
			font_size = 20 * self._scale,
			color = Color.black
		})
		self:make_fine_text(title_shadow)
		local title = title_panel:text({
			layer = 2,
			text = title_shadow:text(),
			font = tweak_data.menu.pd2_large_font,
			font_size = 20 * self._scale
		})
		self:make_fine_text(title)
		
		title_panel:set_size(title_shadow:right(), title_shadow:bottom())
		title_panel:set_bottom(self._hud:h() / 1.5)
		title_panel:set_right(0)
		text_panel:set_top(title_panel:bottom())
		
		title_panel:animate(callback(self, self, "_animate_show"), text_panel)
	end
end