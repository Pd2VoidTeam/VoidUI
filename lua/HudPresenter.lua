if RequiredScript == "lib/managers/hud/hudpresenter" then
	function HUDPresenter:init(hud)
		self._hud_panel = hud.panel
		self._id = 0
		self._active = 0
	end
	function HUDPresenter:present(params)
		self._present_queue = self._present_queue or {}
		if self._active > 5 then
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
		local h = 40
		local w = 100
		local x = self._hud_panel:w() - 200
		local y = self._hud_panel:h() / 2 - (h / 2)
		
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
			w = 35,
			h = h,
			rotation = 360,
			alpha = 1
		})
		local present_bg = present_panel:bitmap({
			name = "present_bg",
			texture = weapons_texture,
			texture_rect = {69,0,416,150},
			layer = 1,
			w = w,
			h = h,
			x = 35,
			y = 0,
			rotation = 360,
			alpha = 1
		})	
		local present_bg_right = present_panel:bitmap({
			name = "present_bg_right",
			texture = weapons_texture,
			texture_rect = {485,0,43,150},
			layer = 1,
			y = 0,
			w = 35,
			h = h,
			rotation = 360,
			alpha = 1
		})
		present_bg_right:set_left(present_bg:right())
		
		local title = present_panel:text({
			name = "title",
			text = params.title or "ERROR",
			vertical = "top",
			valign = "left",
			layer = 2,
			x = 15,
			color = Color.white:with_alpha(1),
			rotation = 360,
			font = tweak_data.hud_present.title_font,
			font_size = tweak_data.hud_present.title_size / 1.5
		})
		local _, _, title_w, title_h = title:text_rect()
		title:set_h(title_h)
		local text = present_panel:text({
			name = "text",
			text = params.text,
			vertical = "top",
			valign = "top",
			layer = 2,
			x = 9,
			color = Color.white,
			rotation = 360,
			font = tweak_data.hud_present.text_font,
			font_size = tweak_data.hud_present.text_size / 1.5
		})
		local _, _, text_w, text_h = text:text_rect()
		text:set_top(title:bottom())
		text:set_h(text_h)
		w = math.max(title_w, text_w)
		present_bg:set_w(w - 35)
		present_bg_right:set_left(present_bg:right())
		present_panel:set_w(present_bg_left:w() + present_bg:w() + present_bg_right:w())
		present_panel:set_right(self._hud_panel:right())
		

		present_panel:animate(callback(self, self, "_animate_present_information"))
		
		if params.event then
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
				local slot = present_panel:child("slot")
				slot:set_text(slot:text()+1)
				present_panel:animate(callback(self, self, "_animate_move_queue"), tonumber(slot:text()))
			end
		end
		self:_present_information(queued)
	end
	function HUDPresenter:_animate_move_queue(present_panel, goal)
		local y = present_panel:y()
		local y2 = (self._hud_panel:h() / 2 - (40 / 2)) - (goal * 45)
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
	end
	function HUDPresenter:_animate_hide_panel(present_panel)
		local x = present_panel:x()
		local x2 = present_panel:x()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			present_panel:set_alpha(math.lerp(1,0, t / TOTAL_T))
			present_panel:set_x(math.lerp(x,x2, t / TOTAL_T))
			x2 = x2 + 5
		end
	end
elseif RequiredScript == "lib/managers/customsafehousemanager" then
	
	--[[
	function CustomSafehouseManager:_update_trophy_progress(trophy, key, id, amount, complete_func)
		for obj_idx, objective in ipairs(trophy.objectives) do
			if not objective.completed and objective[key] == id then
				local pass = true
				if objective.verify then
					pass = tweak_data.safehouse[objective.verify](tweak_data.safehouse, objective)
				end
				if pass then
					objective.progress = math.floor(math.min((objective.progress or 0) + amount, objective.max_progress))
					objective.completed = objective.progress >= objective.max_progress
					for _, objective in ipairs(trophy.objectives) do
						if not objective.completed then
							pass = false
						else
							local name = objective.name_id
						end
					end
					if pass then
						complete_func(self, trophy)
						if managers.hud then
							managers.hud:post_event("Achievement_challenge")
							managers.hud:present({present_mid_text = true, title = "LEL", text = name})
						end
					end
				end
			else
			end
		end
	end
	]]--
	
end