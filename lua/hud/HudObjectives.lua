if VoidUI.options.enable_objectives then
	function HUDObjectives:init(hud)
		self._hud_panel = hud.panel
		self._objectives = {}
		if self._hud_panel:child("objectives_panel") then
			self._hud_panel:remove(self._hud_panel:child("objectives_panel"))
		end
		self._scale = VoidUI.options.hud_objectives_scale
		self._max_objectives = math.floor(VoidUI.options.hud_objective_history)
		
		local objectives_panel = self._hud_panel:panel({
			visible = VoidUI.options.show_objectives == 3,
			name = "objectives_panel",
			h = 200 * self._scale,
			w = 500 * self._scale,
			y = VoidUI.options.show_timer == 2 and VoidUI.options.show_objectives == 3 and -(32 * self._scale) or 0
		})
	end

	function HUDObjectives:create_objective(id , data)
		local objective_id = id
		local objectives_panel = self._hud_panel:child("objectives_panel")
		
		local objective_panel = objectives_panel:panel({
			visible = true,
			x = 0,
			y = 40 * self._scale + ((32 * self._scale) * #self._objectives),
			h = 30 * self._scale,
			w = 500 * self._scale,
		})
		
		local objective_text = objective_panel:text({
			name = "objective_text",
			visible = true,
			layer = 2,
			color = Color.white,
			text = data.text,
			font_size = tweak_data.hud.active_objective_title_font_size * self._scale,
			font = tweak_data.hud.medium_font_noshadow,
			x = 15 * self._scale,
			y = 2 * self._scale,
			h = 30 * self._scale,
			rotation = 360,
			align = "left",
		})
		objective_text:set_font_size(tweak_data.hud.active_objective_title_font_size * self._scale)
		local _, _, name_w, name_h = objective_text:text_rect()
		local weapons_texture = "guis/textures/VoidUI/hud_weapons"
		local objective_text_bg_left = objective_panel:bitmap({
			name = "objective_text_bg_left",
			texture = weapons_texture,
			texture_rect = {26,0,43,150},
			layer = 1,
			y = 0,
			w = 25 * self._scale,
			h = 30 * self._scale,
			rotation = 360,
			alpha = 1
		})
		local objective_text_bg = objective_panel:bitmap({
			name = "objective_text_bg",
			texture = weapons_texture,
			texture_rect = {69,0,416,150},
			layer = 1,
			w = name_w - 17 * self._scale,
			h = 30 * self._scale,
			x = 25 * self._scale,
			y = 0,
			rotation = 360,
			alpha = 1
		})	
		local objective_text_bg_right = objective_panel:bitmap({
			name = "objective_text_bg_right",
			texture = weapons_texture,
			texture_rect = {485,0,43,150},
			layer = 1,
			y = 0,
			w = 25 * self._scale,
			h = 30 * self._scale,
			rotation = 360,
			alpha = 1
		})
		objective_text_bg_right:set_left(objective_text_bg:right())
		
		local highlight_texture = "guis/textures/VoidUI/hud_highlights"
		local objective_border = objective_panel:bitmap({
			name = "objective_border",
			texture = highlight_texture,
			texture_rect = {0,158,460,157},
			layer = 2,
			x = -50 * self._scale,
			y = 0,
			w = name_w + 10 * self._scale,
			h = 30 * self._scale,
			rotation = 360,
			alpha = 0,
			color = Color(0, 0.5, 0)
		})
		
		local objective_border_right = objective_panel:bitmap({
			name = "objective_border_right",
			texture = highlight_texture,
			texture_rect = {460,158,43,157},
			layer = 2,
			y = 0,
			w = 25 * self._scale,
			h = 30 * self._scale,
			rotation = 360,
			alpha = 0,
			color = Color(0, 0.5, 0)
		})
		objective_border_right:set_left(objective_border:right())
		objective_panel:set_x(-500)
		table.insert(self._objectives, objective_panel)
		objective_panel:animate(callback(self, self, "_animate_spawn_objective"))
	end

	function HUDObjectives:_animate_spawn_objective(objective_panel)
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			objective_panel:set_x(math.lerp(-500, 0, t / TOTAL_T))
			objective_panel:set_alpha(math.lerp(0, 1, t / 0.4))
		end
		objective_panel:set_x(0)
	end

	function HUDObjectives:activate_objective(data)
		if data.id == self._active_objective_id then
			return
		end
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_panel = self._objectives[#self._objectives]
		self._active_objective_id = data.id	
		if objective_panel ~= nil and objective_panel:child("objective_border"):alpha() ~= 1 then
			objective_panel:animate(callback(self, self, "_animate_complete_objective"))
		end
		
		if #self._objectives > self._max_objectives then 
			self._objectives[1]:animate(callback(self, self, "_animate_remove_objective"))
			table.remove(self._objectives, 1)
			for i = 1, #self._objectives do
				self._objectives[i]:animate(callback(self, self, "_animate_objective_list"), i - 1)
			end
		end
		self:create_objective(data.id, data)
		if data.amount then
			self:update_amount_objective(data)
		end
	end

	function HUDObjectives:_animate_objective_list(objective_panel, spot)
		local TOTAL_T = 0.4
		local t = 0
		local y = objective_panel:y()
		local end_y = 40 * self._scale + ((32 * self._scale) * spot)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			objective_panel:set_y(math.lerp(y, end_y, t / TOTAL_T))
		end
	end

	function HUDObjectives:complete_objective(data)
		print("[HUDObjectives] complete_objective", data.id, self._active_objective_id)
		if data.id ~= self._active_objective_id then
			if self.current_objective_amount and self.total_objective_amount and self.current_objective_amount ~= self.total_objective_amount then
				self:fix_previous_objective({id = data.id, amount = self.total_objective_amount, text = data.text})
			end
			return
		end
		local objectives_panel = self._hud_panel:child("objectives_panel")
		local objective_panel = self._objectives[#self._objectives]
		objective_panel:animate(callback(self, self, "_animate_complete_objective"))
	end

	function HUDObjectives:fix_previous_objective(data)
		if #self._objectives > 1 and alive(self._objectives[#self._objectives - 1]) then
			local total_amount = data.amount
			local objective_panel = self._objectives[#self._objectives - 1]
			local objective_text = objective_panel:child("objective_text")
			objective_text:set_text(data.text..": ".. tostring(total_amount).."/"..tostring(total_amount))
		end
	end

	function HUDObjectives:_animate_complete_objective(objective_panel)
		local objective_border = objective_panel:child("objective_border")
		local objective_border_right = objective_panel:child("objective_border_right")
		local objective_text = objective_panel:child("objective_text")
		local x = objective_border:x()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			objective_border:set_x(math.lerp(x, 1, t / TOTAL_T))
			objective_border:set_alpha(math.lerp(0, 1, t / TOTAL_T))
			objective_border_right:set_left(objective_border:right() - 1)
			objective_border_right:set_alpha(objective_border:alpha())
			local rb = math.lerp(1, 0, t / TOTAL_T)
			local g = math.lerp(1, 0.5, t / TOTAL_T)
			objective_text:set_color(Color(rb,g,rb))
		end
		objective_border:set_x(1)
		objective_border:set_alpha(1)
		objective_border_right:set_left(objective_border:right() - 1)
		objective_border_right:set_alpha(objective_border:alpha())
		objective_text:set_color(Color(0,0.5,0))
		objective_text:set_font_size(tweak_data.hud.active_objective_title_font_size * self._scale)
	end

	function HUDObjectives:_animate_remove_objective(objective_panel)
		local x = objective_panel:x()
		local TOTAL_T = 0.5
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			objective_panel:set_x(math.lerp(x, -500, t / TOTAL_T))
			objective_panel:set_alpha(math.lerp(1, 0, t / TOTAL_T))
		end
		objectives_panel:remove(objective_panel)
	end

	function HUDObjectives:update_amount_objective(data)
		if data.id ~= self._active_objective_id then
			return
		end
		self.current_objective_amount = data.current_amount or 0
		self.total_objective_amount = data.amount
		local objective_panel = self._objectives[#self._objectives]
		local objective_text = objective_panel:child("objective_text")
		local objective_text_bg = objective_panel:child("objective_text_bg")
		local objective_border = objective_panel:child("objective_border")
		local objective_text_bg_right = objective_panel:child("objective_text_bg_right")
		objective_panel:child("objective_text"):set_text(data.text..": ".. self.current_objective_amount .. "/" .. self.total_objective_amount)
		objective_text:set_font_size(tweak_data.hud.active_objective_title_font_size * self._scale)
		if self.current_objective_amount > 0 then objective_panel:child("objective_text"):animate(callback(self, self, "_animate_objective_count")) end
		local _, y, w, h = objective_panel:child("objective_text"):text_rect()
		objective_text_bg:set_size(w - 17 * self._scale, 30 * self._scale)
		objective_text_bg_right:set_left(objective_text_bg:right())
		objective_border:set_w(w + 10 * self._scale)
	end
		
	function HUDObjectives:_animate_objective_count(objective_text)
		local size = objective_text:font_size()
		local TOTAL_T = 0.2
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			objective_text:set_font_size(math.lerp(size * 1.2, size, t / TOTAL_T))
		end
		objective_text:set_font_size(tweak_data.hud.active_objective_title_font_size * self._scale)
	end


	function HUDObjectives:remind_objective(id)
	end
else
	local init = HUDObjectives.init
	function HUDObjectives:init(hud)
		init(self, hud)
		if VoidUI.options.enable_timer then
			hud.panel:child("objectives_panel"):set_y(VoidUI.options.show_timer < 3 and 0 or 40 * VoidUI.options.hud_objectives_scale)
		end
	end
end
