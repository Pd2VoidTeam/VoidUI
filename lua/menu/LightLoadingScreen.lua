local function make_fine_text(text_obj)
	local x, y, w, h = text_obj:text_rect()

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))
end	

local init_orig = Hooks:GetFunction(LightLoadingScreenGuiScript, "init")
Hooks:OverrideFunction(LightLoadingScreenGuiScript, "init", function(self, scene_gui, res, progress, base_layer, is_win32)
	if base_layer == 1001 then
		self._base_layer = base_layer
		self._is_win32 = is_win32
		self._scene_gui = scene_gui
		self._res = res
		self._ws = scene_gui:create_screen_workspace()
		self._safe_rect_pixels = self:get_safe_rect_pixels(res)
		self._saferect = self._scene_gui:create_screen_workspace()
		self._void = true

		self:layout_saferect()

		local panel = self._ws:panel()
		self._panel = panel
		self._bg_gui = panel:rect({
			visible = true,
			color = Color.black,
			layer = base_layer
		})
		self._saferect_panel = self._saferect:panel()
		self._gui_tweak_data = {
			upper_saferect_border = 64,
			border_pad = 8
		}
		self._title_text = self._saferect_panel:text({
			y = 0,
			h = 24,
			text_id = "debug_loading_level",
			font_size = 30,
			align = "left",
			font = "fonts/font_large_mf",
			halign = "left",
			color = Color.white,
			layer = self._base_layer + 1
		})
		self._title_text:set_text(string.upper(self._title_text:text()))
		
		local extras = "guis/textures/VoidUI/hud_extras"
		self._indicator = self._saferect_panel:bitmap({
			texture = extras,
			name = "indicator",
			texture_rect = {
				875,
				0,
				55,
				54
			},
			layer = self._base_layer + 1
		})
		self._logo = self._saferect_panel:bitmap({
			texture = extras,
			name = "logo",
			texture_rect = {
				933,
				4,
				37,
				37
			},
			layer = self._base_layer + 2
		})
		self._dot_count = 0
		self._max_dot_count = 4
		self._init_progress = 0
		self._fake_progress = 0
		self._max_bar_width = 0
		self._t = 0

		self:setup(res, progress)
	else
		init_orig(self, scene_gui, res, progress, base_layer, is_win32)	
	end
end)

local setup_orig = Hooks:GetFunction(LightLoadingScreenGuiScript, "setup")
Hooks:OverrideFunction(LightLoadingScreenGuiScript, "setup", function(self, res, progress)
	if self._void then
		make_fine_text(self._title_text)
		self._indicator:set_rightbottom(self._indicator:parent():w(), self._indicator:parent():h())
		self._logo:set_center(self._indicator:center())
		self._title_text:set_right(self._indicator:left())
		self._title_text:set_center_y(self._indicator:center_y() + 2)
		self._bg_gui:set_size(res.x, res.y)
	else
		setup_orig(self, res, progress)
	end
end)

local update_orig = Hooks:GetFunction(LightLoadingScreenGuiScript, "update")
Hooks:OverrideFunction(LightLoadingScreenGuiScript, "update", function(self, progress, dt)
	if self._void then
		self._t = self._t + dt
		self._indicator:set_alpha(math.abs(math.sin(60 * self._t)))
	else
		update_orig(self, progress, dt)
	end
end)