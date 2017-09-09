if RequiredScript == "lib/managers/hud/hudassaultcorner" then
	local init = HUDAssaultCorner.init
	function HUDAssaultCorner:init(hud, full_hud, tweak_hud)
		init(self, hud, full_hud, tweak_hud)
		hud.panel:child("assault_panel"):set_alpha(0)
		hud.panel:child("hostages_panel"):set_alpha(0)
		if hud.panel:child("wave_panel") then hud.panel:child("wave_panel"):set_alpha(0) end
		hud.panel:child("point_of_no_return_panel"):set_alpha(0)
		hud.panel:child("casing_panel"):set_alpha(0)
		hud.panel:child("buffs_panel"):set_alpha(0)
		self._hud_panel = hud.panel:panel({name = "custom_assault_panel"})
		self._full_hud_panel = full_hud.panel
		self._pagers = 4
		self._noreturn_time = 0
		self._noreturn_time_current = 0
		self._assault_phase = 0
		self._scale = VoidUI.options.hud_assault_scale
		if managers.job:current_difficulty_stars() % 2 == 0 then
			self._skulls_position = {
				{6, -5},
				{-6, -5},
				{-15, -13},
				{15, -13},
				{-21, -25},
				{21, -25}
			}
		else
			self._skulls_position = {
				{0, -2},
				{11, -9},
				{-11, -9},
				{19, -20},
				{-19, -20}
			}
		end
		if self._hud_panel:child("assault_panel") then
			self._hud_panel:remove(self._hud_panel:child("assault_panel"))
		end
		local assault_panel = self._hud_panel:panel({
			visible = false,
			name = "assault_panel",
			w = 400 * self._scale,
			h = 100 * self._scale
		})
		assault_panel:set_top(0)
		assault_panel:set_right(self._hud_panel:w())
		self._assault_mode = "normal"
		self._assault_color = Color(1, 1, 1, 0)
		self._vip_assault_color = Color(1, 1, 0.5019608, 0)
		if managers.mutators:are_mutators_active() then
			self._assault_color = Color(255, 211, 133, 255) / 255
			self._vip_assault_color = Color(255, 255, 133, 225) / 255
		end
		self._assault_survived_color = Color(1, 0.1254902, 0.9019608, 0.1254902)
		self._current_assault_color = self._assault_color
		local extras_texture = "guis/textures/VoidUI/hud_extras"
		local icon_assaultbox = assault_panel:bitmap({
			halign = "right",
			valign = "top",
			name = "icon_assaultbox",
			visible = VoidUI.options.show_badge,
			layer = 3,
			texture = extras_texture,
			texture_rect = {111, 8, 116, 140},
			x = 0,
			y = 10 * self._scale,
			w = 60 * self._scale,
			h = 70 * self._scale
		})
		icon_assaultbox:set_right(icon_assaultbox:parent():w() - 10)
		
		local difficulty = managers.job:current_difficulty_stars()
		if managers.crime_spree:is_active() then 
			local skull = assault_panel:text({
					name = "skull_1",
					align = "center",
					vertical = "center",
					color = self._assault_color,
					text = managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")}),
					font_size =	12,
					font = tweak_data.hud_corner.assault_font,
					w = 100 * self._scale,
					h = 14 * self._scale,
					alpha = 0,
					layer = 4
				})
				local position = self._skulls_position[1]
				if position then
					skull:set_center_x(icon_assaultbox:center_x() + position[1])
					skull:set_bottom(icon_assaultbox:bottom() + position[2]) 
				end
		elseif difficulty > 0 then
			for i = 1, difficulty do
				local skull = assault_panel:text({
					name = "skull_"..i,
					align = "center",
					vertical = "center",
					color = self._assault_color,
					text = managers.localization:get_default_macro("BTN_SKULL"),
					font_size =	12,
					font = tweak_data.hud_corner.assault_font,
					w = 12 * self._scale,
					h = 12 * self._scale,
					alpha = 0,
					layer = 4,
					visible = VoidUI.options.show_badge
				})
				local position = self._skulls_position[i]
				if position then
					skull:set_center_x(icon_assaultbox:center_x() + position[1] * self._scale)
					skull:set_bottom(icon_assaultbox:bottom() + position[2] * self._scale) 
				end
			end
		end
		local weapons_texture = "guis/textures/VoidUI/hud_weapons"
		local assaultbox_panel = assault_panel:panel({
			visible = false,
			name = "assaultbox_panel",
			w = 240 * self._scale,
			h = 30 * self._scale,
			y = 15,
			layer = -1
		})
		assaultbox_panel:set_right(VoidUI.options.show_badge and assault_panel:w() + 20 or icon_assaultbox:left() + 20)
		local background = assaultbox_panel:bitmap({
				name = "background",
				texture = weapons_texture,
				texture_rect = {0,0,528,150},
				layer = -2,
				x = 1 * self._scale,
				w = 240 * self._scale,
				h = 30 * self._scale,
				alpha = 1
		})	
		local highlight_texture = "guis/textures/VoidUI/hud_highlights"
		local border = assaultbox_panel:bitmap({
				name = "border",
				texture = highlight_texture,
				texture_rect = {0,0,503,157},
				layer = -1,
				w = 240 * self._scale,
				h = 30 * self._scale,
				color = self._assault_color,
				alpha = 1
		})
		assault_panel:panel({
			name = "text_panel",
			layer = 1,
			w = VoidUI.options.show_badge and background:w() or background:w() - 20 * self._scale
		}):set_center(background:center())
		
		local icons_panel = self._hud_panel:panel({
			name = "icons_panel",
			w = 240 * self._scale,
			h = 64 * self._scale,
		})
		icons_panel:set_right(self._hud_panel:w())
			
		local panel_w, panel_h = 44 * self._scale, 38 * self._scale
		local hostages_panel = icons_panel:panel({
			name = "hostages_panel",
			w = panel_w,
			h = panel_h,
		})
		hostages_panel:set_right(icons_panel:w() - 5) 
		local hostages_background = hostages_panel:bitmap({
			name = "hostages_background",
			texture = highlight_texture,
			texture_rect = {0,316,171,150},
			layer = 1,
			w = panel_w,
			h = panel_h,
			color = Color.black
		})
		local hostages_border = hostages_panel:bitmap({
			name = "hostages_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
			layer = 2,
			w = panel_w,
			h = panel_h,
		})
		local hostages_icon = hostages_panel:bitmap({
			name = "hostages_icon",
			texture = "guis/textures/pd2/hud_icon_hostage",
			valign = "top",
			alpha = 0.6,
			layer = 2,
			w = panel_w / 1.7,
			h = panel_h / 1.3,
			x = 0,
			y = 0
		})
		hostages_icon:set_center(hostages_border:center())
		local num_hostages = hostages_panel:text({
			name = "num_hostages",
			text = "x0",
			valign = "center",
			vertical = "bottom",
			align = "right",
			w = panel_w / 1.2,
			h = panel_h,
			layer = 3,
			x = 0,
			y = 0,
			color = Color.white,
			font = "fonts/font_medium_shadow_mf",
			font_size = panel_h / 2
		})
		local is_level_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id()) and managers.groupai and managers.groupai:state():whisper_mode()
		local cuffed_panel = icons_panel:panel({
			name = "cuffed_panel",
			w = panel_w,
			h = panel_h,
			alpha = is_level_ghostable and 0 or 1,
			visible = VoidUI.options.hostages
		})
		cuffed_panel:set_right(hostages_panel:left()) 
		local cuffed_background = cuffed_panel:bitmap({
			name = "cuffed_background",
			texture = highlight_texture,
			texture_rect = {0,316,171,150},
			layer = 1,
			w = panel_w,
			h = panel_h,
			color = Color.black
		})
		local cuffed_border = cuffed_panel:bitmap({
			name = "cuffed_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
			layer = 2,
			w = panel_w,
			h = panel_h,
		})
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_cuffed")
		local cuffed_icon = cuffed_panel:bitmap({
			name = "cuffed_icon",
			texture = icon,
			texture_rect = texture_rect,
			valign = "top",
			alpha = 0.6,
			layer = 2,
			w = panel_w / 1.7,
			h = panel_h / 1.3,
			x = 0,
			y = 0
		})
		cuffed_icon:set_center(cuffed_border:center())
		local num_cuffed = cuffed_panel:text({
			name = "num_cuffed",
			text = "x0",
			valign = "center",
			vertical = "bottom",
			align = "right",
			w = panel_w / 1.2,
			h = panel_h,
			layer = 3,
			x = 0,
			y = 0,
			color = Color.white,
			font = "fonts/font_medium_shadow_mf",
			font_size = panel_h / 2
		})
		
		local pagers_panel = icons_panel:panel({
			name = "pagers_panel",
			w = panel_w,
			h = panel_h,
			alpha = is_level_ghostable and 1 or 0,
			visible = VoidUI.options.pagers
		})
		pagers_panel:set_right(hostages_panel:left()) 
		local pagers_background = pagers_panel:bitmap({
			name = "pagers_background",
			texture = highlight_texture,
			texture_rect = {0,316,171,150},
			layer = 1,
			w = panel_w,
			h = panel_h,
			color = Color.black
		})
		local pagers_border = pagers_panel:bitmap({
			name = "pagers_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
			layer = 2,
			w = panel_w,
			h = panel_h,
		})
		local pagers_icon = pagers_panel:bitmap({
			name = "pagers_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = {65,259,60,60},
			valign = "top",
			alpha = 0.6,
			layer = 2,
			w = panel_w / 1.7,
			h = panel_h / 1.3,
			x = 0,
			y = 0
		})
		pagers_icon:set_center(pagers_border:center())
		local ecm_icon = pagers_panel:bitmap({
			name = "ecm_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = {385,129,60,60},
			valign = "top",
			alpha = 0.6,
			layer = 2,
			w = panel_w / 1.7,
			h = panel_h / 1.3,
			x = 0,
			y = 0,
			visible = false
		})
		ecm_icon:set_center(pagers_border:center())
		local ecm_time = pagers_panel:text({
			name = "ecm_time",
			text = "35s",
			valign = "center",
			vertical = "bottom",
			align = "right",
			w = panel_w / 1.2,
			h = panel_h,
			layer = 3,
			x = 0,
			y = 0,
			color = Color.white,
			font = "fonts/font_medium_shadow_mf",
			font_size = panel_h / 2.2,
			visible = false
		})
		local num_pagers = pagers_panel:text({
			name = "num_pagers",
			text = "x4",
			valign = "center",
			vertical = "bottom",
			align = "right",
			w = panel_w / 1.2,
			h = panel_h,
			layer = 3,
			x = 0,
			y = 0,
			color = Color.white,
			font = "fonts/font_medium_shadow_mf",
			font_size = panel_h / 2
		})
		
		if self._hud_panel:child("wave_panel") then
			self._hud_panel:remove(self._hud_panel:child("wave_panel"))
		end
		self._max_waves = tweak_data.safehouse.combat.waves[Global.game_settings.difficulty or "normal"]
		self._wave_number = 0
		if self:is_safehouse_raid() then
			hostages_panel:hide()
			local wave_panel = self._hud_panel:panel({
				name = "wave_panel",
				w = panel_w,
				h = panel_h
			})
			wave_panel:set_right(self._hud_panel:w() - 5)
			local waves_background = wave_panel:bitmap({
				name = "waves_background",
				texture = highlight_texture,
				texture_rect = {0,316,171,150},
				layer = 1,
				color = Color.black,
				w = panel_w,
				h = panel_h,
			})
			local waves_border = wave_panel:bitmap({
				name = "waves_border",
				texture = highlight_texture,
				texture_rect = {172,316,171,150},
				layer = 2,
				w = panel_w,
				h = panel_h,
			})
			local waves_icon = wave_panel:bitmap({
				name = "waves_icon",
				texture = "guis/textures/pd2/specialization/icons_atlas",
				texture_rect = {192,64,64,64},
				valign = "top",
				alpha = 0.6,
				layer = 2,
				w = panel_w / 1.7,
				h = panel_h / 1.3,
				x = 0,
				y = 0
			})
			waves_icon:set_center(waves_border:center())
			local num_waves = wave_panel:text({
				name = "num_waves",
				text = "0/3",
				valign = "center",
				vertical = "bottom",
				align = "right",
				w = panel_w / 1.2,
				h = panel_h,
				layer = 3,
				x = 0,
				y = 0,
				color = Color.white,
				font = "fonts/font_medium_shadow_mf",
				font_size = panel_h / 2
			})
		end
		
		if self._hud_panel:child("point_of_no_return_panel") then
			self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
		end
		local point_of_no_return_panel = self._hud_panel:panel({
			visible = false,
			name = "point_of_no_return_panel",
			w = 300 * self._scale,
			h = 60 * self._scale,
			x = self._hud_panel:w() - 300 * self._scale
		})
		self._noreturn_color = Color(1, 1, 0, 0)
		local noreturnbox_panel = point_of_no_return_panel:panel({
			visible = true,
			name = "noreturnbox_panel",
			w = 260 * self._scale,
			h = 30 * self._scale,
			y = 13,
			layer = 0
		})
		noreturnbox_panel:set_right(point_of_no_return_panel:w() - 10)
		local background = noreturnbox_panel:bitmap({
				name = "background",
				texture = weapons_texture,
				texture_rect = {0,0,528,150},
				layer = -2,
				x = 1 * self._scale,
				w = 240 * self._scale,
				h = 30 * self._scale,
				alpha = 1
		})	
		
		local border = noreturnbox_panel:bitmap({
				name = "border",
				texture = highlight_texture,
				texture_rect = {0,0,503,157},
				layer = -1,
				w = 240 * self._scale,
				h = 30 * self._scale,
				color = self._noreturn_color,
				alpha = 1
		})
		
		local timer_panel = point_of_no_return_panel:panel({
			name = "timer_panel",
			layer = 4,
		})
		self._timer_noreturnbox = CircleBitmapGuiObject:new(timer_panel, {
			use_bg = false,
			radius = 28 * self._scale,
			sides = 28 * self._scale,
			current = 64 * self._scale,
			total = 64 * self._scale,
			layer = 4,

		})
		self._timer_noreturnbox:set_position(point_of_no_return_panel:w() - 56 * self._scale, 0)
		self._timer_noreturnbox:set_current(0)
		local icon_noreturnbox = point_of_no_return_panel:bitmap({
			halign = "center",
			valign = "center",
			name = "icon_noreturnbox",
			visible = true,
			layer = 2,
			texture = extras_texture,
			texture_rect = {231,0,148,148},
			x = 0,
			y = 2 * self._scale,
			w = 56 * self._scale,
			h = 56 * self._scale
		})
		icon_noreturnbox:set_right(point_of_no_return_panel:w() - 3)
		
		local point_of_no_return_timer = point_of_no_return_panel:text({
			name = "point_of_no_return_timer",
			text = "0:00",
			layer = 3,
			valign = "center",
			align = "center",
			vertical = "center",
			x = 0,
			y = 0,
			w = 56 * self._scale,
			h = 56 * self._scale,
			color = self._noreturn_color,
			font_size = 20 * self._scale,
			font = tweak_data.hud_corner.assault_font
		})
		point_of_no_return_timer:set_right(point_of_no_return_panel:w())
		
		point_of_no_return_panel:panel({
			name = "text_panel",
			layer = 1,
			w = 240 * self._scale
		})
		
		if self._hud_panel:child("casing_panel") then
			self._hud_panel:remove(self._hud_panel:child("casing_panel"))
		end
		local casing_panel = self._hud_panel:panel({
			visible = false,
			name = "casing_panel",
			w = 300 * self._scale,
			h = 40 * self._scale,
			x = self._hud_panel:w() - 300 * self._scale
		})
		local casingbox_panel = casing_panel:panel({
			visible = false,
			name = "casingbox_panel",
			w = 261 * self._scale,
			h = 30 * self._scale,
			layer = -1
		})
		casingbox_panel:set_right(casing_panel:w())
		local background = casingbox_panel:bitmap({
				name = "background",
				texture = weapons_texture,
				texture_rect = {0,0,528,150},
				layer = -2,
				x = 1 * self._scale,
				w = 260 * self._scale,
				h = 30 * self._scale,
				alpha = 1
		})	
		
		local border = casingbox_panel:bitmap({
				name = "border",
				texture = highlight_texture,
				texture_rect = {0,0,503,157},
				layer = -1,
				w = 260 * self._scale,
				h = 30 * self._scale,
				alpha = 1
		})
		self._casing_color = Color.white
		local icon_casingbox = casing_panel:bitmap({
			halign = "right",
			valign = "top",
			color = self._casing_color,
			name = "icon_casingbox",
			visible = true,
			layer = 0,
			texture = "guis/textures/pd2/icon_detection",
			x = 0,
			y = 0,
			w = 30 * self._scale,
			h = 30 * self._scale
		})
		icon_casingbox:set_right(casingbox_panel:right() - 8)
		casing_panel:panel({
			name = "text_panel",
			layer = 1,
			w = 260 * self._scale
		})
		if self._hud_panel:child("buffs_panel") then
			self._hud_panel:remove(self._hud_panel:child("buffs_panel"))
		end
		local width = 200 * self._scale
		local buffs_panel = self._hud_panel:panel({
			visible = false,
			name = "buffs_panel",
			w = 200 * self._scale,
			h = 100 * self._scale,
		})
		buffs_panel:set_right(self._hud_panel:w())
		
		local vip_icon = buffs_panel:bitmap({
			name = "vip_icon",
			visible = true,
			layer = 5,
			texture = extras_texture,
			texture_rect = {0, 0, 110, 149},
			x = 0,
			y = 10 * self._scale,
			w = 60 * self._scale,
			rotation = 360,
			h = 70 * self._scale
		})
		vip_icon:set_right(vip_icon:parent():w() - 10 * self._scale)
		self._vip_bg_box_bg_color = Color(1, 0, 0.6666667, 1)
		self._vip_bg_box = HUDBGBox_create(buffs_panel, {
			w = 0,
			h = 0,
			x = 0,
			y = 0,
			visible = false,
			alpha = 0
		}, {
			color = Color.white,
			bg_color = self._vip_bg_box_bg_color
		})
		local vip_icon = self._vip_bg_box:bitmap({
			halign = "center",
			valign = "center",
			color = Color.white,
			name = "vip_icon",
			blend_mode = "add",
			visible = true,
			layer = 0,
			texture = "guis/textures/pd2/hud_buff_shield",
			x = 0,
			y = 0,
			w = 38 * self._scale,
			h = 38 * self._scale
		})
		vip_icon:set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2)
		
		if managers.groupai:state() and not self._whisper_listener then
			self._whisper_listener = "HUDAssaultCorner_whisper_mode"
			managers.groupai:state():add_listener(self._whisper_listener, {
				"whisper_mode"
			}, callback(self, self, "whisper_mode_changed"))
		end
	end

	function HUDAssaultCorner:_animate_text(text_panel, bg_box, color, color_function)
		local assault_panel = self._hud_panel:child("assault_panel")
		local text = assault_panel:child("text_panel")
		local text_list = bg_box or text:script().text_list
		local text_index = 0
		local texts = {}
		local padding = 5 * self._scale
		local speed = 290 * self._scale
		local easter = 100
		local function create_new_text(text_panel, text_list, text_index, texts)
			if texts[text_index] and texts[text_index].text then
				text_panel:remove(texts[text_index].text)
				texts[text_index] = nil
			end
			local text_id = text_list[text_index]
			local text_string = ""
			if type(text_id) == "string" then
				if text_id == "hud_assault_assault" then
					easter = math.random(1,10000)
					if easter < 22 then
						text_id = "VoidUI_assault_" .. easter
					end
				end
				text_string = managers.localization:to_upper_text(text_id)
			elseif text_id == Idstring("mask-up") then
				text_string = utf8.to_upper(managers.localization:text("hud_instruct_mask_on", {BTN_USE_ITEM = managers.localization:btn_macro("use_item")}))
			elseif text_id == Idstring("risk") then
				local use_stars = true
				if managers.crime_spree:is_active() then
					text_string = text_string .. managers.localization:to_upper_text("menu_cs_level", {
						level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
					})
					use_stars = false
				end
				if use_stars then
					for i = 1, managers.job:current_difficulty_stars() do
						text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
					end
				end
			end
			local mod_color = color_function and color_function() or color or self._assault_color
			local text = text_panel:text({
				text = text_string,
				layer = 1,
				align = "center",
				vertical = "center",
				blend_mode = "add",
				color = mod_color,
				font_size = 20 * self._scale,
				font = tweak_data.hud_corner.assault_font,
				w = 10 * self._scale,
				h = 10 * self._scale,
			})
			local _, _, w, h = text:text_rect()
			text:set_size(w, h)
			texts[text_index] = {
				x = text_panel:w() + w * 0.5 + padding * 2,
				text = text
			}
		end
		while true do
			local dt = coroutine.yield()
			local last_text = texts[text_index]
			if last_text and last_text.text then
				if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
					text_index = text_index % #text_list + 1
					create_new_text(text_panel, text_list, text_index, texts)
				end
			else
				text_index = text_index % #text_list + 1
				create_new_text(text_panel, text_list, text_index, texts)
			end
			if speed > 90 * self._scale then speed = speed - 2 * self._scale end
			for i, data in pairs(texts) do
				if data.text then
					data.x = data.x - dt * speed
					data.text:set_center_x(data.x)
					data.text:set_center_y(text_panel:h() * 0.5)
					if 0 > data.x + data.text:w() * 0.5 then
						text_panel:remove(data.text)
						data.text = nil
					elseif color_function then
						data.text:set_color(color_function())
					end
				end
			end
		end
	end
	function HUDAssaultCorner:sync_start_assault(assault_number)
		if self._point_of_no_return or self._casing then
			return
		end
		local color = self._assault_color
		if self._assault_mode == "phalanx" then
			color = self._vip_assault_color
		end
		self:_update_assault_hud_color(color)
		self._start_assault_after_hostage_offset = true
		self:_set_hostage_offseted(true, true)
		self:set_assault_wave_number(assault_number)
	end
	function HUDAssaultCorner:set_assault_wave_number(assault_number)
		self._wave_number = assault_number
		local panel = self._hud_panel:child("wave_panel")
		local current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number
		local max = self._max_waves or 0
		if panel then
			local wave_text = panel:child("num_waves")
			if wave_text then
				wave_text:set_text(current.."/"..max)
			end
		end
	end
	function HUDAssaultCorner:_update_assault_hud_color(color)
		self._current_assault_color = color
		local assault_panel = self._hud_panel:child("assault_panel")
		local assaultbox_border = assault_panel:child("assaultbox_panel"):child("border")
		assaultbox_border:set_color(color)
	end
	function HUDAssaultCorner:set_buff_enabled(buff_name, enabled)
		local vip_icon = self._hud_panel:child("buffs_panel"):child("vip_icon")
		local size_w = VoidUI.options.show_badge and 60 * self._scale or 30 * self._scale
		local size_h = VoidUI.options.show_badge and 70 * self._scale or 35 * self._scale
		if enabled == true then 
			self._hud_panel:child("buffs_panel"):set_visible(true)
		else
			self._hud_panel:child("assault_panel"):child("icon_assaultbox"):set_visible(true) 
		end
		vip_icon:set_size(size_w, size_h)
		vip_icon:set_right(VoidUI.options.show_badge and vip_icon:parent():w() - 10 * self._scale or - 40 * self._scale)
		vip_icon:set_y(VoidUI.options.show_badge and 10 * self._scale or -2 * self._scale)
		vip_icon:stop()
		vip_icon:animate(function(o)
			local centerx = vip_icon:center_x()
			local centery = vip_icon:center_y()
			over(0.4, function(p)
				if alive(vip_icon) then
					vip_icon:set_size(math.lerp(enabled and 150 * self._scale or size_w, enabled and size_w or 150 * self._scale, p), math.lerp(enabled and 160 * self._scale or size_h, enabled and size_h or 160 * self._scale, p))
					vip_icon:set_alpha(math.lerp(enabled and 0 or 1, enabled and 1 or 0, p))
					vip_icon:set_center_x(centerx) vip_icon:set_center_y(centery)
				end
			end)
			if VoidUI.options.show_badge and VoidUI.options.anim_badge then vip_icon:animate(callback(self, self, "_animate_icon"), false) end
			if enabled == false then 
				self._hud_panel:child("buffs_panel"):set_visible(false)
			else
				self._hud_panel:child("assault_panel"):child("icon_assaultbox"):set_visible(false) 
			end
		end)
	end
	function HUDAssaultCorner:sync_set_assault_mode(mode)
		if self._assault_mode == mode then
			return
		end
		self._assault_mode = mode
		local color = mode == "phalanx" and self._vip_assault_color or self._assault_color
		self:_update_assault_hud_color(color)
		self:_set_text_list(self:_get_assault_strings())
	end
	function HUDAssaultCorner:_get_assault_strings()
		if self._assault_mode == "normal" then
			if not VoidUI.options.show_badge and managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")
				return {
					"hud_assault_assault",
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
					"hud_assault_assault",
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line"
				}
			else
				return {
					"hud_assault_assault",
					"hud_assault_end_line",
					"hud_assault_assault",
					"hud_assault_end_line",
					"hud_assault_assault",
					"hud_assault_end_line"
				}
			end
		elseif self._assault_mode == "endless" then
			if not VoidUI.options.show_badge and managers.job:current_difficulty_stars() > 0 then
				local ids_risk = Idstring("risk")
				return {
					"VoidUI_endless_assault",
					"hud_assault_padlock",
					ids_risk,
					"hud_assault_padlock",
					"VoidUI_endless_assault",
					"hud_assault_padlock",
					ids_risk,
					"hud_assault_padlock",
				}
			else
				return {
					"VoidUI_endless_assault",
					"hud_assault_padlock",
					"VoidUI_endless_assault",
					"hud_assault_padlock",
					"VoidUI_endless_assault",
					"hud_assault_padlock",
				}
			end
		elseif self._assault_mode == "phalanx" then
			if not VoidUI.options.show_badge and managers.job:current_difficulty_stars() > 0 then
				local ids_risk = Idstring("risk")
				return {
					"hud_assault_vip",
					"hud_assault_padlock",
					ids_risk,
					"hud_assault_padlock",
					"hud_assault_vip",
					"hud_assault_padlock",
					ids_risk,
					"hud_assault_padlock"
				}
			else
				return {
					"hud_assault_vip",
					"hud_assault_padlock",
					"hud_assault_vip",
					"hud_assault_padlock",
					"hud_assault_vip",
					"hud_assault_padlock"
				}
			end
		end
	end

	function HUDAssaultCorner:_get_survived_assault_strings()
		if not VoidUI.options.show_badge and managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")
			return {
				"hud_assault_survived",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_survived",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_survived",
				"hud_assault_end_line",
				"hud_assault_survived",
				"hud_assault_end_line",
				"hud_assault_survived",
				"hud_assault_end_line"
			}
		end
	end
	function HUDAssaultCorner:_set_text_list(text_list)
		local assault_panel = self._hud_panel:child("assault_panel")
		local text_panel = assault_panel:child("text_panel")
		text_panel:script().text_list = text_panel:script().text_list or {}
		while #text_panel:script().text_list > 0 do
			table.remove(text_panel:script().text_list)
		end
		for _, text_id in ipairs(text_list) do
			table.insert(text_panel:script().text_list, text_id)
		end
	end
	function HUDAssaultCorner:_start_assault(text_list)
		text_list = text_list or {""}
		local assault_panel = self._hud_panel:child("assault_panel")
		local assaultbox_panel = assault_panel:child("assaultbox_panel")
		local icon_assaultbox = assault_panel:child("icon_assaultbox")
		
		self:_set_text_list(text_list)
		if self._assault == true then 
			self:sync_set_assault_mode("endless")
		else
			self._assault = true
		end
		
		if Network:is_server() and managers.groupai:state():get_hunt_mode() then self:sync_set_assault_mode("endless") end
		
		if self._assault_phase == 1 then 
			--self:sync_set_assault_mode("phalanx")
			self._assault_phase = 2
		end
		if assaultbox_panel:child("text_panel") then
			assaultbox_panel:child("text_panel"):stop()
			assaultbox_panel:child("text_panel"):clear()
			assaultbox_panel:child("text_panel"):set_w(VoidUI.options.show_badge and assaultbox_panel:w() or assaultbox_panel:w() - 26 * self._scale)
		else
			assaultbox_panel:panel({name = "text_panel", w = VoidUI.options.show_badge and assaultbox_panel:w() or assaultbox_panel:w() - 30 * self._scale})
		end
		local text_panel = assaultbox_panel:child("text_panel")
		
		assault_panel:set_visible(true)
		icon_assaultbox:set_visible(VoidUI.options.show_badge)
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"), true)
		assaultbox_panel:stop()
		assaultbox_panel:animate(callback(self, self, "_show_assaultbox"), 0.5, true)
		
		local config = {
			attention_color = self._assault_color,
			attention_forever = true,
			attention_color_function = callback(self, self, "assault_attention_color_function")
		}
		text_panel:stop()
		text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
		self:_set_feedback_color(self._assault_color)
	end
	function HUDAssaultCorner:_end_assault()
		if not self._assault then
			self._start_assault_after_hostage_offset = nil
			return
		end
		
		local assault_panel = self._hud_panel:child("assault_panel")
		local assaultbox_panel = assault_panel:child("assaultbox_panel")
		local text_panel = assaultbox_panel:child("text_panel")
		local icon_assaultbox = assault_panel:child("icon_assaultbox")
		self:_set_feedback_color(nil)
		self._assault = false
		
		self._remove_hostage_offset = true
		self._start_assault_after_hostage_offset = nil
		local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
		icon_assaultbox:stop()
		if self:is_safehouse_raid() then
			self:_update_assault_hud_color(self._assault_survived_color)
			self:_set_text_list(self:_get_survived_assault_strings())
			text_panel:stop()
			text_panel:clear()
			text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
		else
			self:_close_assault_box()
		end
	end
	function HUDAssaultCorner:_close_assault_box()
		local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
		local assaultbox_panel = self._hud_panel:child("assault_panel"):child("assaultbox_panel")
		assaultbox_panel:stop()
		assaultbox_panel:animate(callback(self, self, "_hide_assaultbox"))
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"), true)
	end
	function HUDAssaultCorner:_show_assaultbox(assaultbox, delay_time, offsetted)
		local TOTAL_T = 0.4
		local t = 0
		local background = assaultbox:child("background")
		local border = assaultbox:child("border")
		local text_panel = assaultbox:child("text_panel")
		local assault_panel = self._hud_panel:child("assault_panel")
		local icon_assaultbox = assault_panel:child("icon_assaultbox")
		
		assaultbox:set_right(offsetted and (VoidUI.options.show_badge and icon_assaultbox:left() + 20 * self._scale or assaultbox:parent():w()) or assaultbox:parent():w())
		assaultbox:set_y(offsetted and (VoidUI.options.show_badge and 15 * self._scale or 0) or 0)
		background:set_x(assaultbox:w())
		border:set_x(background:x() + 11 * self._scale)
		if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
		
		wait(delay_time)
		assaultbox:set_visible(true)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			background:set_x(math.lerp(assaultbox:w(), 1 * self._scale, t / TOTAL_T))
			border:set_x(background:x() + 11 * self._scale)
			if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
		end
		
		background:set_x(1)
		border:set_x(background:x() + 11 * self._scale)
		if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
	end
	function HUDAssaultCorner:_hide_assaultbox(assaultbox)
		local TOTAL_T = 0.4
		local t = 0
		local background = assaultbox:child("background")
		local border = assaultbox:child("border")
		local text_panel = assaultbox:child("text_panel")
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			background:set_x(math.lerp(1 * self._scale, assaultbox:w(), t / TOTAL_T))
			border:set_x(background:x() + 11 * self._scale)
			if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
		end
		
		assaultbox:set_visible(false)
		background:set_x(assaultbox:w())
		border:set_x(background:x() + 11 * self._scale)
		if text_panel then 
			text_panel:set_x(background:x() + 17 * self._scale)
			text_panel:stop()
			text_panel:clear()
		end
		self:sync_set_assault_mode("normal")
	end
	function HUDAssaultCorner:_animate_skull(skull, show, delay, i)
		skull:set_alpha(show and 0 or 1)
		wait(delay)
		local TOTAL_T = 0.2
		local t = 0
		local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
		skull:set_visible(VoidUI.options.show_badge)
		local position = self._skulls_position[i]
		if position then
			skull:set_center_x(icon_assaultbox:center_x() + position[1] * self._scale)
			skull:set_bottom(icon_assaultbox:bottom() + position[2] * self._scale) 
		end
		if show then skull:set_font_size(12 * self._scale) end
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			skull:set_alpha(math.lerp(show and 0 or 1, show and 1 or 0, t / TOTAL_T))
		end
	end
	function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox, big_logo)
		local TOTAL_T = 0.5
		local t = 0
		local assault_panel = self._hud_panel:child("assault_panel")
		icon_assaultbox:set_size(big_logo and 60 * self._scale or 30 * self._scale,big_logo and 70 * self._scale or 30 * self._scale)
		icon_assaultbox:set_right(big_logo and (icon_assaultbox:parent():w() - 10 * self._scale) or (icon_assaultbox:parent():w() - 8 * self._scale))
		icon_assaultbox:set_y(big_logo and 10 * self._scale or 0)
		local center_x = icon_assaultbox:center_x()
		local center_y = icon_assaultbox:center_y()
		icon_assaultbox:set_alpha(1)
		local difficulty = managers.crime_spree:is_active() and 1 or managers.job:current_difficulty_stars()
		
		if VoidUI.options.show_badge and big_logo then
			for i = 1, difficulty do
				assault_panel:child("skull_"..i):stop()
				assault_panel:child("skull_"..i):animate(callback(self, self, "_animate_skull"), true, 0.8 + ((i - 1) / 20), i) 
			end
		end
		
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			icon_assaultbox:set_size(math.lerp(0, big_logo and 70 * self._scale or 35 * self._scale, t / TOTAL_T), math.lerp(0, big_logo and 80 * self._scale or 35 * self._scale, t / TOTAL_T))
			icon_assaultbox:set_center_x(center_x)
			icon_assaultbox:set_center_y(center_y)
		end
		local TOTAL_T = 0.3
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			icon_assaultbox:set_size(math.lerp(big_logo and 70 * self._scale or 35 * self._scale, big_logo and 60 * self._scale or 30 * self._scale, t / TOTAL_T), math.lerp(big_logo and 80 * self._scale or 35 * self._scale, big_logo and 70 * self._scale or 30 * self._scale, t / TOTAL_T))
			icon_assaultbox:set_center_x(center_x)
			icon_assaultbox:set_center_y(center_y)
		end
		if VoidUI.options.show_badge and VoidUI.options.anim_badge and big_logo then
			icon_assaultbox:animate(callback(self, self, "_animate_icon"), true) 
		end
	end
	function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox, big_logo)
		local TOTAL_T = 0.4
		local t = 0
		
		local assault_panel = self._hud_panel:child("assault_panel")
		local w = icon_assaultbox:w()
		local h = icon_assaultbox:h()
		local center_x = icon_assaultbox:center_x()
		local center_y = icon_assaultbox:center_y()
		local difficulty = managers.crime_spree:is_active() and 1 or managers.job:current_difficulty_stars()
		
		if VoidUI.options.show_badge and big_logo then
		
			for i = 1, difficulty do
				assault_panel:child("skull_"..i):stop()
				assault_panel:child("skull_"..i):animate(callback(self, self, "_animate_skull"), false, 0.1, i) 
			end
			
			while TOTAL_T > t do
				local dt = coroutine.yield()
				t = t + dt
				icon_assaultbox:set_w(math.lerp(w, 60 * self._scale, t / TOTAL_T))
				icon_assaultbox:set_h(math.lerp(h, 70 * self._scale, t / TOTAL_T))
				icon_assaultbox:set_center_x(center_x)
				icon_assaultbox:set_center_y(center_y)
			end
		end
		
		local TOTAL_T = 0.2
		local t = 0
		icon_assaultbox:set_alpha(1)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			icon_assaultbox:set_w(math.lerp(big_logo and 60 * self._scale or 30 * self._scale, big_logo and 70 * self._scale or 35 * self._scale, t / TOTAL_T))
			icon_assaultbox:set_h(math.lerp(big_logo and 70 * self._scale or 30 * self._scale, big_logo and 80 * self._scale or 35 * self._scale, t / TOTAL_T))
			icon_assaultbox:set_center_x(center_x)
			icon_assaultbox:set_center_y(center_y)
		end
		self:_set_hostage_offseted(false, false)
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			icon_assaultbox:set_w(math.lerp(big_logo and 70 * self._scale or 35 * self._scale, 0, t / TOTAL_T))
			icon_assaultbox:set_h(math.lerp(big_logo and 80 * self._scale or 35 * self._scale, 0, t / TOTAL_T))
			icon_assaultbox:set_center_x(center_x)
			icon_assaultbox:set_center_y(center_y)
		end
		
		icon_assaultbox:set_alpha(0)
		if not self._casing then
			self:_show_hostages()
		end
	end
	function HUDAssaultCorner:_animate_icon(icon_assaultbox, skulls)
		local TOTAL_T = 1
		local t = 0
		local d = true
		local center_x = icon_assaultbox:center_x()
		local center_y = icon_assaultbox:center_y()
		local assault_panel = self._hud_panel:child("assault_panel")
		local difficulty = managers.crime_spree:is_active() and 1 or managers.job:current_difficulty_stars()
		wait(0.5)
		while true do
			local dt = coroutine.yield()
			t = t + dt
			icon_assaultbox:set_size(math.lerp(d and 60 * self._scale or 70 * self._scale, d and 70 * self._scale or 60 * self._scale, t / TOTAL_T), math.lerp(d and 70 * self._scale or 80 * self._scale, d and 80 * self._scale or 70 * self._scale, t / TOTAL_T))
			icon_assaultbox:set_center_x(center_x)
			icon_assaultbox:set_center_y(center_y)
			if skulls then
				for i = 1, difficulty do
					local skull = assault_panel:child("skull_"..i)
					local position = self._skulls_position[i]
					skull:set_font_size(math.lerp(d and 12 * self._scale or 14 * self._scale, d and 14 * self._scale or 12 * self._scale, t / TOTAL_T))
					skull:set_visible(icon_assaultbox:visible() and VoidUI.options.show_badge or false)
					if position then
						skull:set_center_x(math.lerp(d and icon_assaultbox:center_x() + position[1] * self._scale or icon_assaultbox:center_x() + position[1] * self._scale * 1.16, d and icon_assaultbox:center_x() + position[1] * self._scale * 1.16 or icon_assaultbox:center_x() + position[1] * self._scale, t / TOTAL_T))
						skull:set_bottom(math.lerp(d and icon_assaultbox:bottom() + position[2] * self._scale or icon_assaultbox:bottom() + position[2] * self._scale * 1.16, d and icon_assaultbox:bottom() + position[2] * self._scale * 1.16 or icon_assaultbox:bottom() + position[2] * self._scale, t / TOTAL_T)) 
					end
				end
			end
			
			if 
				t >= TOTAL_T then t = 0 
				d = not d
			end
		end
	end
	function HUDAssaultCorner:_show_hostages()
		self._hud_panel:child("icons_panel"):animate(function(o)
			local alpha = self._hud_panel:child("icons_panel"):alpha()
			over(0.2, function(p)
				if alive(self._hud_panel:child("icons_panel")) then
					self._hud_panel:child("icons_panel"):set_alpha(math.lerp(alpha, 1, p))
				end
			end)
		end)
	end
	function HUDAssaultCorner:_hide_hostages()
		self._hud_panel:child("icons_panel"):animate(function(o)
			local alpha = self._hud_panel:child("icons_panel"):alpha()
			over(0.2, function(p)
				if alive(self._hud_panel:child("icons_panel")) then
					self._hud_panel:child("icons_panel"):set_alpha(math.lerp(alpha, 0, p))
				end
			end)
		end)
	end
	function HUDAssaultCorner:_set_hostage_offseted(is_offseted, big_logo)
		local hostage_panel = self._hud_panel:child("icons_panel"):child("hostages_panel")
		self._remove_hostage_offset = nil
		hostage_panel:stop()
		self._hud_panel:child("icons_panel"):stop()
		hostage_panel:animate(callback(self, self, "_offset_hostage", is_offseted), VoidUI.options.show_badge and big_logo or false)
		local wave_panel = self._hud_panel:child("wave_panel")
	end
	function HUDAssaultCorner:_offset_hostage(is_offseted, hostage_panel, big_logo)
		local TOTAL_T = 0.18
		local icons_panel = self._hud_panel:child("icons_panel")
		local wave_panel = self._hud_panel:child("wave_panel")
		local cuffed_panel = icons_panel:child("cuffed_panel")
		local pagers_panel = icons_panel:child("pagers_panel")
		local panel_right = icons_panel:right()
		local panel_y = icons_panel:y()
		local t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = math.min(t + dt, TOTAL_T)
			local lerp = t / TOTAL_T
			if is_offseted then 
				icons_panel:set_alpha(math.lerp(1,0,lerp))
				if wave_panel then wave_panel:set_alpha(math.lerp(1,0,lerp)) end
			else
				icons_panel:set_right(math.lerp(panel_right, self._hud_panel:w(),lerp))
				icons_panel:set_y(math.lerp(panel_y, 0, lerp))
				hostage_panel:set_y(0)
				cuffed_panel:set_y(0)
				pagers_panel:set_y(0)
				if wave_panel then 
					wave_panel:set_right(math.lerp(self._hud_panel:w() - 75 * self._scale, self._hud_panel:w() - 5 * self._scale,lerp))
					wave_panel:set_y(math.lerp(47 * self._scale, 0, lerp))
				end
			end
			if self._start_assault_after_hostage_offset and lerp > 0.4 then
				self._start_assault_after_hostage_offset = nil
				self:start_assault_callback()
			end
		end	
		if is_offseted then
			if big_logo then wait(0.6) end
			TOTAL_T = 0.3
			t = 0
			icons_panel:set_right(big_logo and self._hud_panel:w() - 70 * self._scale or self._hud_panel:w() - 2 * self._scale)
			icons_panel:set_y(big_logo and 47 * self._scale or 32 * self._scale)
			hostage_panel:set_y(-hostage_panel:h())
			cuffed_panel:set_y(-cuffed_panel:h() * 2 * self._scale)
			pagers_panel:set_y(-pagers_panel:h() * 2 * self._scale)
			if wave_panel then 
				wave_panel:set_right(self._hud_panel:w() - 75 * self._scale)
				wave_panel:set_y(47 * self._scale)
			end
			icons_panel:set_alpha(1)
			while TOTAL_T > t do
				local dt = coroutine.yield()
				t = math.min(t + dt, TOTAL_T)
				local lerp = t / TOTAL_T
				hostage_panel:set_y(math.lerp(-hostage_panel:h(),0,lerp))
				cuffed_panel:set_y(math.lerp(-cuffed_panel:h() * 2,0,lerp))
				pagers_panel:set_y(math.lerp(-pagers_panel:h() * 2,0,lerp))
				if wave_panel then wave_panel:set_alpha(math.lerp(0,1,lerp)) end
			end
		end
		icons_panel:set_alpha(1)
		self:whisper_mode_changed()
		if self._start_assault_after_hostage_offset then
			self._start_assault_after_hostage_offset = nil
			self:start_assault_callback()
		end
	end
	function HUDAssaultCorner:show_casing(mode)
		self:_end_assault()
		local casing_panel = self._hud_panel:child("casing_panel")
		local casingbox_panel = casing_panel:child("casingbox_panel")
		local icon_casingbox = casing_panel:child("icon_casingbox")
		local text_panel = casing_panel:child("text_panel")
		text_panel:script().text_list = {}
		local msg
		if mode == "civilian" then
			icon_casingbox:set_image("guis/textures/pd2/skilltree/icons_atlas")
			icon_casingbox:set_texture_rect(390,72,50,50)
			msg = {
				"hud_casing_mode_ticker_clean",
				"hud_assault_end_line",
				"hud_casing_mode_ticker_clean",
				"hud_assault_end_line"
			}
		else
			icon_casingbox:set_image("guis/textures/pd2/icon_detection")
			local ids_maskup = Idstring("mask-up")
			msg = {
				"hud_casing_mode_ticker",
				ids_maskup,
				"hud_assault_end_line",
				"hud_casing_mode_ticker",
				ids_maskup,
				"hud_assault_end_line"
			}
		end
		for _, text_id in ipairs(msg) do
			table.insert(text_panel:script().text_list, text_id)
		end
		if casingbox_panel:child("text_panel") then
			casingbox_panel:child("text_panel"):stop()
			casingbox_panel:child("text_panel"):clear()
		else
			casingbox_panel:panel({name = "text_panel", w = 200 * self._scale})
		end
		
		casing_panel:set_visible(true)
		icon_casingbox:stop()
		icon_casingbox:animate(callback(self, self, "_show_icon_assaultbox"), false)
		casingbox_panel:stop()
		casingbox_panel:animate(callback(self, self, "_show_assaultbox"), 0, false)
		casingbox_panel:child("text_panel"):stop()
		casingbox_panel:child("text_panel"):animate(callback(self, self, "_animate_text"), text_panel:script().text_list, Color.white)
		self:_set_hostage_offseted(true, false)
		self._casing = true
	end
	function HUDAssaultCorner:hide_casing()
		local casing_panel = self._hud_panel:child("casing_panel")
		local casingbox_panel = casing_panel:child("casingbox_panel")
		local icon_casingbox = casing_panel:child("icon_casingbox")
		
		icon_casingbox:stop()
		icon_casingbox:animate(callback(self, self, "_hide_icon_assaultbox"))
		casingbox_panel:stop()
		casingbox_panel:animate(callback(self, self, "_hide_assaultbox"))
		if casingbox_panel:child("text_panel") then casingbox_panel:child("text_panel"):stop() end
		self._casing = false
	end
	function HUDAssaultCorner:set_control_info(data)
		local hostages_panel = self._hud_panel:child("icons_panel"):child("hostages_panel")
		local cuffed_panel = self._hud_panel:child("icons_panel"):child("cuffed_panel")
		local pagers_panel = self._hud_panel:child("icons_panel"):child("pagers_panel")
		local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
		local hostages = string.sub(hostages_panel:child("num_hostages"):text(), 2)
		local cuffed = string.sub(cuffed_panel:child("num_cuffed"):text(), 2)
		cuffed_panel:set_visible(VoidUI.options.hostages)
		pagers_panel:set_visible(VoidUI.options.pagers)
		if self:is_safehouse_raid() then
			cuffed_panel:set_visible(true)
			cuffed_panel:child("num_cuffed"):set_text("x".. data.nr_hostages)
		elseif is_whisper_mode or VoidUI.options.hostages == false then
			hostages_panel:child("num_hostages"):set_text("x".. data.nr_hostages)
		elseif VoidUI.options.hostages then
			local police = 0
			
			for _, unit in pairs(managers.enemy:all_enemies()) do
				if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
					police = police + 1
				end
			end
			
			hostages_panel:child("num_hostages"):set_text("x" .. math.clamp(data.nr_hostages - police, 0, data.nr_hostages))
			cuffed_panel:child("num_cuffed"):set_text("x".. police)
		end
		if string.sub(hostages_panel:child("num_hostages"):text(), 2) ~= hostages then hostages_panel:child("hostages_background"):stop() hostages_panel:child("hostages_background"):animate(callback(self, self, "_blink_background")) end
		if string.sub(cuffed_panel:child("num_cuffed"):text(), 2) ~= cuffed then cuffed_panel:child("cuffed_background"):stop() cuffed_panel:child("cuffed_background"):animate(callback(self, self, "_blink_background")) end
	end
	
	function HUDAssaultCorner:_blink_background(background)
		local TOTAL_T = 0.4
		local t = 0
		local color = 1
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			color = math.lerp(1, 0, t / TOTAL_T)
			background:set_color(Color(color,color,color))
		end
	end
	
	function HUDAssaultCorner:feed_point_of_no_return_timer(time, is_inside)
		time = math.floor(time)
		if self._noreturn_time == 0 then self._noreturn_time = time end
		local minutes = math.floor(time / 60)
		local seconds = math.round(time - minutes * 60)
		local text = (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
		self._hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_timer"):set_text(text)
		self._noreturn_time_current = time
	end

	function HUDAssaultCorner:_animate_noreturn_timer(timer_panel)
		local time = self._noreturn_time_current
		while time > 0 do
			local dt = coroutine.yield()
			time = time - dt
			self._timer_noreturnbox:set_current(time / self._noreturn_time)
		end
	end
	function HUDAssaultCorner:show_point_of_no_return_timer()
		local delay_time = self._assault and 1.2 or 0
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		local noreturnbox_panel = point_of_no_return_panel:child("noreturnbox_panel")
		local text_panel = point_of_no_return_panel:child("text_panel")
		text_panel:script().text_list = {}
		local msg = {
			"hud_assault_point_no_return_in",
			"hud_assault_end_line",
			"hud_assault_point_no_return_in",
			"hud_assault_end_line"
		}
		for _, text_id in ipairs(msg) do
			table.insert(text_panel:script().text_list, text_id)
		end
		if noreturnbox_panel:child("text_panel") then
			noreturnbox_panel:child("text_panel"):stop()
			noreturnbox_panel:child("text_panel"):clear()
		else
			noreturnbox_panel:panel({name = "text_panel", x = 19 * self._scale, w = 200 * self._scale})
		end
		
		noreturnbox_panel:child("text_panel"):stop()
		noreturnbox_panel:child("text_panel"):animate(callback(self, self, "_animate_text"), text_panel:script().text_list, self._noreturn_color)
		
		self:_end_assault()
		self:_hide_hostages()
		point_of_no_return_panel:stop()
		point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
		self:_set_feedback_color(self._noreturn_color)
		self._point_of_no_return = true
	end
	function HUDAssaultCorner:hide_point_of_no_return_timer()
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		local noreturnbox_panel = point_of_no_return_panel:child("noreturnbox_panel")
		if noreturnbox_panel:child("text_panel") then
			noreturnbox_panel:child("text_panel"):stop()
			noreturnbox_panel:child("text_panel"):clear()
		end
		self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
		self._point_of_no_return = false
		self:_show_hostages()
		self:_set_feedback_color(nil)
	end
	function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
		local function flash_timer(o)
			local t = 0
			while t < 0.5 do
				t = t + coroutine.yield()
				local n = 1 - math.sin(t * 180)
				local r = math.lerp(1 or self._point_of_no_return_color.r, 1, n)
				local g = math.lerp(0 or self._point_of_no_return_color.g, 0.8, n)
				local b = math.lerp(0 or self._point_of_no_return_color.b, 0.2, n)
				o:set_color(Color(r, g, b))
				o:set_font_size(math.lerp(20 * self._scale, 25 * self._scale, n))
			end
		end
		local point_of_no_return_timer = self._hud_panel:child("point_of_no_return_panel"):child("point_of_no_return_timer")
		point_of_no_return_timer:animate(flash_timer)
	end
	function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
		local noreturnbox_panel = point_of_no_return_panel:child("noreturnbox_panel")
		local background = noreturnbox_panel:child("background")
		local border = noreturnbox_panel:child("border")
		local text_panel = noreturnbox_panel:child("text_panel")
		local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
		local point_of_no_return_timer = point_of_no_return_panel:child("point_of_no_return_timer")
		wait(delay_time)
		self:_hide_hostages()
		
		background:set_x(noreturnbox_panel:w())
		border:set_x(background:x() - 1 * self._scale)
		if text_panel then text_panel:set_x(background:x() + 19 * self._scale) end
		icon_noreturnbox:set_right(point_of_no_return_panel:w())
		icon_noreturnbox:set_y(0)
		local TOTAL_T = 0.4
		local t = 0
		local center_x = icon_noreturnbox:center_x()
		local center_y = icon_noreturnbox:center_y()
		point_of_no_return_panel:set_visible(true)
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			icon_noreturnbox:set_size(math.lerp(0, 53 * self._scale, t / TOTAL_T), math.lerp(0, 52 * self._scale, t / TOTAL_T))
			icon_noreturnbox:set_center_x(center_x)
			icon_noreturnbox:set_center_y(center_y)
			point_of_no_return_timer:set_alpha(math.lerp(0, 1, t / TOTAL_T))
			background:set_x(math.lerp(noreturnbox_panel:w(), 1, t / TOTAL_T))
			border:set_x(background:x() + 11 * self._scale)
			if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
			self._timer_noreturnbox:set_current(0)
		end
		background:set_x(1)
		border:set_x(background:x() + 11 * self._scale)
		if text_panel then text_panel:set_x(background:x() + 17 * self._scale) end
		TOTAL_T = 0.2
		t = 0
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			self._timer_noreturnbox:set_current(t / TOTAL_T)
		end
		self._hud_panel:child("point_of_no_return_panel"):child("timer_panel"):animate(callback(self, self, "_animate_noreturn_timer"))
	end

	function HUDAssaultCorner:whisper_mode_changed()
		local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
		local cuffed_panel = self._hud_panel:child("icons_panel"):child("cuffed_panel")
		local pagers_panel = self._hud_panel:child("icons_panel"):child("pagers_panel")
		cuffed_panel:stop()
		cuffed_panel:animate(function(o)
			local cuffed_alpha = cuffed_panel:alpha()
			local pager_alpha = pagers_panel:alpha()
			over(0.5, function(p)
				if alive(cuffed_panel) then
					cuffed_panel:set_alpha(math.lerp(cuffed_alpha, is_whisper_mode and 0 or 1, p))
					pagers_panel:set_alpha(math.lerp(pager_alpha, is_whisper_mode and 1 or 0, p))
				end
			end)
		end)
		self:set_control_info({nr_hostages = managers.groupai:state():hostage_count()})
	end

	function HUDAssaultCorner:pager_used()
		local pagers_count = self._hud_panel:child("icons_panel"):child("pagers_panel"):child("num_pagers")
		self._pagers = self._pagers - 1
		if self._pagers < 2 then 
			self._hud_panel:child("icons_panel"):child("pagers_panel"):child("pagers_border"):set_color(Color(1,0,0))
			self._hud_panel:child("icons_panel"):child("pagers_panel"):child("pagers_icon"):set_color(Color(1,0,0))
			pagers_count:set_color(Color(1,0,0))
		end
		pagers_count:set_text("x".. self._pagers)
	end

	function HUDAssaultCorner:ecm_timer(time)
		if managers.hud and managers.hud._jammers then
			self._hud_panel:child("icons_panel"):child("pagers_panel"):child("ecm_icon"):stop()
			self._hud_panel:child("icons_panel"):child("pagers_panel"):child("ecm_icon"):animate(callback(self, self, "_animate_jammer"), time, self._hud_panel:child("icons_panel"):child("pagers_panel"))
		end
	end
	
	function HUDAssaultCorner:stop_ecm()
		if managers.hud and managers.hud._jammers then
			self._hud_panel:child("icons_panel"):child("pagers_panel"):child("ecm_icon"):stop()
		end
	end
	
	function HUDAssaultCorner:_animate_jammer(ecm_icon, time, pagers_panel)
		local ecm_time = pagers_panel:child("ecm_time")
		local pagers_icon = pagers_panel:child("pagers_icon")
		local num_pagers = pagers_panel:child("num_pagers")
		local TOTAL_T = time
		local t = 0
		pagers_panel:set_visible(VoidUI.options.jammers or VoidUI.options.pagers)
		ecm_icon:set_visible(VoidUI.options.jammers > 1)
		ecm_time:set_visible(VoidUI.options.jammers > 1)
		pagers_icon:set_visible(VoidUI.options.jammers < 2)
		num_pagers:set_visible(VoidUI.options.jammers < 2)
		t = 0
		TOTAL_T = time
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			pagers_panel:set_visible(VoidUI.options.jammers > 1 or VoidUI.options.pagers) 
			if (time - t) > 10 then 
				ecm_time:set_text(string.format("%.0fs", time - t))
			else
				ecm_time:set_text(string.format("%.1fs", time - t))
			end
		end
		ecm_icon:set_visible(false)
		ecm_time:set_visible(false)
		pagers_icon:set_visible(true)
		num_pagers:set_visible(true)
		pagers_panel:set_visible(VoidUI.options.pagers)
		if managers.hud and managers.hud._jammers then
			local jammers = table.remove(managers.hud._jammers, VoidUI.options.jammers == 2 and 1 or #managers.hud._jammers)
			if jammers and #managers.hud._jammers > 0 then
				setup:add_end_frame_clbk(callback(self, self, "ecm_timer", managers.hud._jammers[VoidUI.options.jammers == 2 and 1 or #managers.hud._jammers]:base():battery_life()))
			end
		end
	end
	
	function HUDAssaultCorner:set_assault_phase()
		self._assault_phase = 1
	end
elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	
	local update = GroupAIStateBase.update
	function GroupAIStateBase:update(t, dt)
		update(self, t, dt)
		if not self._last_updated then self._last_updated = t end
		if self._last_updated and self._last_updated + 50 <= t then managers.groupai:state():sync_hostage_headcount() end
	end

elseif RequiredScript == "lib/managers/objectinteractionmanager" then
	local interact = ObjectInteractionManager.end_action_interact
	function ObjectInteractionManager:end_action_interact(player)
		if alive(self._active_unit) and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
			managers.hud:pager_used()
		end
		return interact(self, player)
	end

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then

	local set_active = ECMJammerBase.set_active
	function ECMJammerBase:set_active(active)
		active = active and true
		if self._jammer_active == active then
			return
		end
		set_active(self, active)
		if active then
			managers.hud:add_ecm_timer(self._unit)
		end
	end
end