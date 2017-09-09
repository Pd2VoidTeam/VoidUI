if RequiredScript == "lib/managers/hud/hudblackscreen" then
	function HUDBlackScreen:init(hud)
		self._hud_panel = hud.panel
		if self._hud_panel:child("blackscreen_panel") then
			self._hud_panel:remove(self._hud_panel:child("blackscreen_panel"))
		end
		self._blackscreen_panel = self._hud_panel:panel({
			visible = true,
			name = "blackscreen_panel",
			y = 0,
			valign = "grow",
			halign = "grow",
			layer = 10
		})
		local mid_text = self._blackscreen_panel:text({
			name = "mid_text",
			visible = true,
			text = "000",
			layer = 1,
			color = Color.white,
			y = 0,
			valign = {0.4, 0},
			align = "center",
			vertical = "center",
			font_size = tweak_data.hud.default_font_size * 2,
			font = tweak_data.hud.medium_font,
			w = self._blackscreen_panel:w()
		})
		local _, _, _, h = mid_text:text_rect()
		mid_text:set_h(h)
		mid_text:set_center_x(self._blackscreen_panel:center_x())
		mid_text:set_center_y(self._blackscreen_panel:h() / 2.5)
		local is_server = Network:is_server()
		local continue_button = managers.menu:is_pc_controller() and "ENTER" or nil
		local text = managers.localization:to_upper_text("hud_skip_blackscreen", {BTN_ACCEPT = continue_button})
		if continue_button == nil then continue_button = utf8.char(57344) end
		local start, _ = string.find(text, continue_button)
		if start then text = string.sub(text, start - 1) end
		local skip_text = self._blackscreen_panel:text({
			name = "skip_text",
			visible = is_server,
			text = text,
			layer = 1,
			color = Color.white,
			y = 0,
			align = "center",
			vertical = "bottom",
			font_size = nil,
			font = tweak_data.hud.medium_font_noshadow
		})
		local loading_text = managers.localization:text("menu_loading_progress", {prog = 0})
		local loading_text_object = self._blackscreen_panel:text({
			name = "loading_text",
			visible = false,
			text = loading_text,
			layer = 1,
			color = Color.white,
			y = 0,
			align = "center",
			vertical = "bottom",
			font_size = nil,
			font = tweak_data.hud.medium_font_noshadow
		})
		managers.hud:make_fine_text(skip_text)
		loading_text_object:set_h(select(4,loading_text_object:text_rect()))
	end

	function HUDBlackScreen:_set_job_data()
		if not managers.job:has_active_job() then
			return
		end
		local job_panel = self._blackscreen_panel:panel({
			visible = true,
			name = "custom_job_panel",
			y = 0,
			valign = "grow",
			halign = "grow",
			layer = 1
		})
		local skip_text = self._blackscreen_panel:child("skip_text")
		local loading_text = self._blackscreen_panel:child("loading_text")
		local risk_panel = job_panel:panel({name = "risk_panel"})
		local last_risk_level
		local blackscreen_risk_textures = tweak_data.gui.blackscreen_risk_textures
		local risk_text = risk_panel:text({
			name = "risk_text",
			text = managers.localization:to_upper_text(tweak_data.difficulty_name_id),
			font = tweak_data.menu.pd2_large_font,
			font_size = 35,
			align = "right",
			vertical = "center",
			color = tweak_data.screen_colors.risk,
			y = 2,
			h = 35
		})
		managers.hud:make_fine_text(risk_text)
		local current_dif = managers.job:current_difficulty_stars()
		for i = 1, #tweak_data.difficulties - 2 do
			local difficulty_name = tweak_data.difficulties[i + 2]
			local texture = blackscreen_risk_textures[difficulty_name] or "guis/textures/pd2/risklevel_blackscreen"
			last_risk_level = risk_panel:bitmap({
				name = "star_"..i,
				texture = texture,
				color = tweak_data.screen_colors.risk,
				w = 35,
				h = 35
			})
			last_risk_level:set_color(i <= current_dif and tweak_data.screen_colors.risk or tweak_data.screen_colors.text)
			last_risk_level:set_alpha(i <= current_dif and 1 or 0.20)
			last_risk_level:move(risk_text:w() + (i - 1) * last_risk_level:w(), 0)
		end
		if last_risk_level then
			risk_panel:set_size(last_risk_level:right(), last_risk_level:bottom())
			risk_panel:set_center(job_panel:w() / 2, job_panel:h() / 2)
			risk_panel:set_position(math.round(risk_panel:x()), math.round(risk_panel:y()))
		end
		skip_text:set_top(risk_panel:bottom() + skip_text:h())
		skip_text:set_center_x(job_panel:w() / 2)
		loading_text:set_top(risk_panel:bottom() + loading_text:h())
		loading_text:set_center_x(job_panel:w() / 2)
		
		local level_data = managers.job:current_level_data()
		if level_data then
			local level_text = job_panel:text({
				name = "level_text",
				text = managers.localization:to_upper_text(level_data.name_id),
				font = tweak_data.menu.pd2_large_font,
				font_size = 50,
				align = "center",
				vertical = "bottom",
				color = tweak_data.screen_colors.risk,
			})
			level_text:set_bottom(risk_panel:top())
			level_text:set_center_x(risk_panel:center_x())
		end
		job_panel:animate(callback(self, self, "_animate_grow"))
	end

	function HUDBlackScreen:_animate_grow(job_panel)
		local level_text = job_panel:child("level_text")
		--local risk_panel = job_panel:child("risk_panel")
		--local risk_text = risk_panel:child("risk_text")
		--local star = risk_panel:child("star_1")
		--local panel_w, panel_h = risk_panel:size()
		--local risk_w, risk_h = risk_text:size()	
		local t = 0
		local TOTAL_T = 120
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			level_text:set_font_size(math.lerp(50, 120, t / TOTAL_T))
			--[[
			risk_text:set_font_size(math.lerp(35, 18, t / TOTAL_T))
			risk_panel:set_size(math.lerp(panel_w, panel_w / 2, t / TOTAL_T), math.lerp(panel_h, panel_h / 2, t / TOTAL_T))
			risk_text:set_size(math.lerp(risk_w, risk_w / 2, t / TOTAL_T), math.lerp(risk_h, risk_h / 2, t / TOTAL_T))
			risk_panel:set_center(job_panel:w() / 2, job_panel:h() / 2)
			
			for i = 1, #tweak_data.difficulties - 2 do
				star = risk_panel:child("star_"..i)
				star:set_size(math.lerp(35, 18, t / TOTAL_T), math.lerp(35, 18, t / TOTAL_T))
				star:set_x(risk_text:w() + (i - 1) * star:w())
			end
			--]]
		end
	end

	function HUDBlackScreen:_set_job_data_crime_spree()
		local skip_text = self._blackscreen_panel:child("skip_text")
		local loading_text = self._blackscreen_panel:child("loading_text")
		local job_panel = self._blackscreen_panel:panel({
			visible = true,
			name = "custom_job_panel",
			y = 0,
			valign = "grow",
			halign = "grow",
			layer = 1
		})
		local risk_panel = job_panel:panel({name = "risk_panel"})
		local job_text = risk_panel:text({
			text = managers.localization:to_upper_text("cn_crime_spree"),
			font = tweak_data.menu.pd2_large_font,
			font_size = 35,
			align = "center",
			vertical = "bottom",
			color = tweak_data.screen_colors.crime_spree_risk
		})
		managers.hud:make_fine_text(job_text)
		local risk_text = risk_panel:text({
			text = managers.localization:to_upper_text("menu_cs_level", {
				level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
			}),
			font = tweak_data.menu.pd2_large_font,
			font_size = 35,
			align = "center",
			vertical = "top",
			color = tweak_data.screen_colors.crime_spree_risk
		})
		managers.hud:make_fine_text(risk_text)
		risk_text:set_left(job_text:right() + 10)
		risk_panel:set_size(risk_text:right(), risk_text:bottom())
		risk_panel:set_center(job_panel:w() / 2, job_panel:h() / 2)
		risk_panel:set_position(math.round(risk_panel:x()), math.round(risk_panel:y()))
		
		skip_text:set_top(risk_panel:bottom() + skip_text:h())
		skip_text:set_center_x(job_panel:w() / 2)
		loading_text:set_top(risk_panel:bottom() + loading_text:h())
		loading_text:set_center_x(job_panel:w() / 2)
		
		local level_data = managers.job:current_level_data()
		if level_data then
			local level_text = job_panel:text({
				name = "level_text",
				text = managers.localization:to_upper_text(level_data.name_id),
				font = tweak_data.menu.pd2_large_font,
				font_size = 50,
				align = "center",
				vertical = "bottom",
				color = tweak_data.screen_colors.crime_spree_risk,
			})
			level_text:set_bottom(risk_panel:top())
			level_text:set_center_x(risk_panel:center_x())
		end
		job_panel:animate(callback(self, self, "_animate_grow"))
	end

	local fade_out_mid_text = HUDBlackScreen.fade_out_mid_text
	function HUDBlackScreen:fade_out_mid_text()
		fade_out_mid_text(self)
		self._blackscreen_panel:child("skip_text"):set_visible(false)
	end

	animate_fade_out = HUDBlackScreen._animate_fade_out
	function HUDBlackScreen:_animate_fade_out(...)
		animate_fade_out(self, ...)
		self._blackscreen_panel:child("custom_job_panel"):stop()
	end

	function HUDBlackScreen:set_skip_circle(current, total)
	end

	function HUDBlackScreen:skip_circle_done()
		self._blackscreen_panel:child("skip_text"):set_visible(false)
	end
	
elseif RequiredScript == "lib/states/ingamewaitingforplayers" then
	local update = IngameWaitingForPlayersState.update
	function IngameWaitingForPlayersState:update(t, dt)
		if self._skip_data then self._skip_data.total = 0 end
		return update(self, t, dt)
	end
end