if VoidUI.options.enable_stats then
	if RequiredScript == "lib/managers/hud/newhudstatsscreen" then
		function HudTrackedAchievement:init(parent, id, i, h, scale)
			self._scale = scale
			self._panel = parent:panel({
				name = "achievement_panel",
				w = parent:w(),
				y = (35 * self._scale) * (i - 1) + (i - 1) * 5,
				h = h
			})
			self._panel:bitmap({
				name = "background",
				w = self._panel:w(),
				h = self._panel:h(),
				color = Color.black,
				alpha = 0.6,
				layer = 1
			})
			self._panel:bitmap({
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				w = self._panel:w(),
				h = self._panel:h(),
				layer = 2
			})
			self._info = managers.achievment:get_info(id)
			self._visual = tweak_data.achievement.visual[id]
			self._progress = self._visual and self._visual.progress
			local texture, texture_rect = tweak_data.hud_icons:get_icon_or(self._visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
			local bitmap = self._panel:bitmap({
				w = h,
				h = h,
				texture = texture,
				texture_rect = texture_rect,
				layer = 3
			})
			local awarded = self._info.awarded

			if not awarded then
				bitmap:set_color(Color.white:with_alpha(0.1))
				self._panel:bitmap({
					texture = "guis/dlcs/trk/textures/pd2/lock",
					w = bitmap:w(),
					h = bitmap:h(),
					x = bitmap:x(),
					y = bitmap:y(),
					layer = 4
				})
			end
			
			self._name = self._panel:text({
				text = managers.localization:text(self._visual.name_id),
				font = "fonts/font_medium_mf",
				font_size = 14 * self._scale,
				x = bitmap:right() + 5,
				w = self._panel:w() - bitmap:w() - 5,
				h = self._panel:h() / 2.3,
				layer = 3,
				vertical = "bottom"
			})
			local desc = self._panel:text({
				wrap = true,
				word_wrap = true,
				text = managers.localization:text(self._visual.desc_id),
				font = "fonts/font_medium_mf",
				font_size = 12 * self._scale,
				color = tweak_data.screen_colors.achievement_grey,
				y = self._name:bottom(),
				x = bitmap:right() + 5,
				w = self._panel:w() - bitmap:w() - 5,
				h = self._panel:h() / 1.7,
				layer = 3,
				vertical = "middle"
			})
			if self._progress then
				self._count = self._panel:text({
					text = self._progress:get().."/"..self._progress.max,
					name = "progress_count",
					font = "fonts/font_small_mf",
					font_size = 12 * self._scale,
					w = bitmap:w(),
					h = bitmap:h(),
					x = bitmap:x(),
					y = bitmap:y(),
					layer = 5,
					align = "right",
					vertical = "bottom"
				})
				
				self._bar = self._panel:bitmap({
				name = "progress_bg",
				w = self._panel:w() * (self._progress:get() / self._progress.max),
				h = self._panel:h(),
				alpha = 0.8,
			})
				
			end
		end

		function HudTrackedAchievement:update_progress()
			if self._bar then
				if self._info.awarded then
					self._bar:set_w(self._panel:w())
					self._count:set_text(self._progress.max.."/"..self._progress.max)
					self._name:set_color(Color.green)
				else
					self._bar:set_w(self._panel:w() * (self._progress:get() / self._progress.max))
					self._count:set_text(self._progress:get().."/"..self._progress.max)
				end
			end
		end
		
		local init = HUDStatsScreen.init
		function HUDStatsScreen:init()
			self._scoreboard_enabled = VoidUI.options.scoreboard
			self._scale = VoidUI.options.scoreboard_scale
			self._timer = VoidUI.options.enable_timer
			self._objective = VoidUI.options.enable_objectives
			self._mouse = managers.mouse_pointer:get_id()
			self._full_hud_panel = managers.hud:script(managers.hud.STATS_SCREEN_FULLSCREEN).panel
			self._visible_panel = self._scoreboard_enabled and "scoreboard_panel" or "achievements_panel"
			self._toggle_text = ""
			init(self)
			self._scroll = 0
			self._full_hud_panel:set_alpha(0)
			self:create_scoreboards()
			self._blur = self._full_hud_panel:bitmap({
				name = "blur_bg",
				texture = "guis/textures/test_blur_df",
				render_template = "VertexColorTexturedBlur3D",
				w = self._full_hud_panel:w(),
				h = self._full_hud_panel:h(),
				layer = -1,
			})
			self._full_hud_panel:bitmap({
				name = "bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				alpha = 0.5,
				w = self._full_hud_panel:w(),
				h = self._full_hud_panel:h(),
				layer = -3,
			})
			local mutators_panel = self._full_hud_panel:panel({
				name = "mutators_panel",
				valign = "scale",
				w = self._full_hud_panel:w() / 3
			})
			mutators_panel:set_right(self._full_hud_panel:w())
			local top_panel = self._full_hud_panel:panel({
				name = "top_panel",
				w = self._full_hud_panel:w(),
				h = self._full_hud_panel:h() / 3
			})
			local loot_stats = top_panel:text({
				name = "loot_stats",
				font_size = 18 * self._scale,
				font = tweak_data.menu.pd2_large_font,
				text = managers.localization:text("hud_body_bags")..": "..tostring(managers.player:get_body_bags_amount()),
				align = "center",
				layer = 1,
			})
			loot_stats:set_h(select(4,loot_stats:text_rect()))
			loot_stats:set_bottom(top_panel:h())
			local loot_stats_shadow = top_panel:text({
				name = "loot_stats_shadow",
				font_size = 18 * self._scale,
				font = tweak_data.menu.pd2_large_font,
				text = loot_stats:text(),
				x = 2 * self._scale,
				y = loot_stats:y() + 2 * self._scale,
				h = loot_stats:h(),
				align = "center",
				color = Color.black,
				layer = -2,
			})
			local risk_panel = top_panel:panel({name = "risk_panel"})
			local job_data = managers.job:current_job_data()
			if job_data then
				local difficulty_stars = managers.job:current_difficulty_stars()
				local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_id)
				local difficulty_color = tweak_data.screen_colors.text
				if managers.crime_spree:is_active() then
					difficulty_string = managers.localization:to_upper_text("cn_crime_spree")..": "..managers.localization:text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
					difficulty_color = tweak_data.screen_colors.crime_spree_risk
				elseif Global.game_settings.one_down then difficulty_color = tweak_data.screen_colors.one_down
				elseif difficulty_stars > 0 then difficulty_color = tweak_data.screen_colors.risk end
			
				local risk_text = risk_panel:text({
					name = "risk_text",
					font = tweak_data.menu.pd2_large_font,
					font_size = 25 * self._scale,
					y = 2,
					text = difficulty_string,
					color = difficulty_color
				})
				managers.hud:make_fine_text(risk_text)
				local risk_text_shadow = risk_panel:text({
					name = "risk_text_shadow",
					x = 2 * self._scale,
					y = 2 + (2 * self._scale),
					font = tweak_data.menu.pd2_large_font,
					font_size = 25 * self._scale,
					text = difficulty_string,
					color = Color.black,
					layer = -2,
					rotation = 360
				})
				managers.hud:make_fine_text(risk_text_shadow)
				if not managers.crime_spree:is_active() then
					local risk_star, risk_star_shadow
					local risk_textures = tweak_data.gui.blackscreen_risk_textures
					for i = 1, #tweak_data.difficulties - 2 do
						local difficulty_name = tweak_data.difficulties[i + 2]
						local texture = risk_textures[difficulty_name] or "guis/textures/pd2/risklevel_blackscreen"
						risk_star = risk_panel:bitmap({
							name = "risk_star"..i,
							texture = texture,
							color = tweak_data.screen_colors.text,
							w = 25 * self._scale,
							h = 25 * self._scale,
							color = Color(0.5,0.5,0.5)
						})
						risk_star:set_x(risk_text_shadow:right() + (i - 1) * risk_star:w())
						if i <= difficulty_stars then risk_star:set_color(difficulty_color) end
						risk_star_shadow = risk_panel:bitmap({
							name = "risk_star_shadow"..i,
							texture = texture,
							color = tweak_data.screen_colors.text,
							y = 2 * self._scale,
							w = 25 * self._scale,
							h = 25 * self._scale,
							layer = -2,
							rotation = 360,
							color = Color.black
						})
						risk_star_shadow:set_x(risk_star:x() + 2 * self._scale)
					end
					if _G.DW and risk_textures and difficulty_stars > 4 then
						local stars_image = difficulty_stars == 6 and risk_textures.sm_wish or risk_textures.overkill_290
						for i=1, difficulty_stars-1 do
							risk_panel:child("risk_star"..i):set_image(stars_image)
							risk_panel:child("risk_star_shadow"..i):set_image(stars_image)
						end
						risk_panel:child("risk_star"..difficulty_stars):set_image(risk_textures.deathwishplus)
						risk_panel:child("risk_star_shadow"..difficulty_stars):set_image(risk_textures.deathwishplus)
					end
					risk_panel:set_size(risk_star_shadow:right(), risk_star_shadow:bottom())
				else
					risk_panel:set_size(risk_text_shadow:right(), risk_text_shadow:bottom())			
				end
				risk_panel:set_center_x(top_panel:w() / 2)
				risk_panel:set_bottom(loot_stats:top())
			end
			
			local day_title = top_panel:text({
				name = "day_title",
				font_size = 35 * self._scale,
				h = 35 * self._scale,
				font = tweak_data.menu.pd2_large_font,
				text = "Jewlery Store",
				align = "center",
				vertical = "center",
			})
			day_title:set_bottom(risk_panel:top())
			local day_title_shadow = top_panel:text({
				name = "day_title_shadow",
				color = Color.black,
				font_size = 35 * self._scale,
				x = 2 * self._scale,
				h = 35 * self._scale,
				font = tweak_data.menu.pd2_large_font,
				text = "Jewlery Store",
				align = "center",
				vertical = "center",
				layer = -2
			})
			day_title_shadow:set_bottom(risk_panel:top() + 2 * self._scale)
			local days_title = top_panel:text({
				name = "days_title",
				font_size = 15 * self._scale,
				font = tweak_data.hud_stats.objectives_font,
				text = "Day 1 of 3",
				align = "center",
				vertical = "center",
				h = 15
			})
			managers.hud:make_fine_text(days_title)
			days_title:set_bottom(day_title:top())
			days_title:set_center_x(top_panel:w() / 2)
			local days_title_shadow = top_panel:text({
				name = "days_title_shadow",
				color = Color.black,
				font_size = 15 * self._scale,
				font = tweak_data.hud_stats.objectives_font,
				text = "Day 1 of 3",
				align = "center",
				vertical = "center",
				h = 15,
				layer = -2
			})
			managers.hud:make_fine_text(days_title_shadow)
			days_title_shadow:move(days_title:x() + 2 * self._scale, days_title:y() + 2 * self._scale)
			
			local is_level_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id())
			local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
			local ghost_icon = top_panel:bitmap({
				name = "ghost_icon",
				texture = "guis/textures/pd2/cn_minighost",
				w = 12 * self._scale,
				h = 12 * self._scale,
			})
			ghost_icon:set_left(days_title_shadow:right())
			ghost_icon:set_center_y(days_title:center_y())
			ghost_icon:set_visible(is_level_ghostable)
			ghost_icon:set_color(is_whisper_mode and Color.white or tweak_data.screen_colors.important_1)
			local ghost_icon_shadow = top_panel:bitmap({
				name = "ghost_icon_shadow",
				texture = "guis/textures/pd2/cn_minighost",
				x = ghost_icon:x() + 2 * self._scale,
				y = ghost_icon:y() + 2 * self._scale,
				w = 12 * self._scale,
				h = 12 * self._scale,
				color = Color.black,
				layer = -2,
				visible = ghost_icon:visible()
			})
			local extras_panel = self._full_hud_panel:panel({
				name = "extras_panel",
				w = self._scoreboard_panels and self._scoreboard_panels[#self._scoreboard_panels]._panel:w() or (managers.gui_data:full_16_9_size().w / 1.55) * self._scale,
				h = self._full_hud_panel:h() / 3
			})
		end
		
		function HUDStatsScreen:_create_stats_screen_profile(extras_panel)
			extras_panel:stop()
			extras_panel:clear()
			if HUDManager.PLAYER_PANEL > 7 and self._scoreboard_enabled then
				local scroll_text = extras_panel:text({
					name = "scroll_text",
					x = -self._scoreboard_panels[1]._h,
					w = self._scoreboard_panels[1]._h,
					h = -self._full_hud_panel:child("scoreboard_panel"):h(),
					font = tweak_data.menu.pd2_large_font,
					font_size = 15 * self._scale,
					align = "center",
					vertical = "center",
					rotation = 270,
					text = "< MOUSE WHEEL >"
				})
				local scroll_text_shadow = extras_panel:text({
					name = "scroll_textt_shadow",
					font = tweak_data.menu.pd2_large_font,
					x = -self._scoreboard_panels[1]._h + 2,
					y = 2,
					w = self._scoreboard_panels[1]._h,
					h = -self._full_hud_panel:child("scoreboard_panel"):h(),
					font_size = 15 * self._scale,
					align = "center",
					vertical = "center",
					rotation = 270,
					text = "< MOUSE WHEEL >",
					layer = -2,
					color = Color.black
				})
			end
			
			local next_level_data = managers.experience:next_level_data() or {}
			local gain_xp = managers.experience:get_xp_dissected(true, 0, true)
			local at_max_level = managers.experience:current_level() == managers.experience:level_cap()
			local current_level = managers.experience:current_level()
			local can_lvl_up = not at_max_level and gain_xp >= next_level_data.points - next_level_data.current_points
			local progress = (next_level_data.current_points or 1) / (next_level_data.points or 1)
			local gain_progress = math.min(1, (gain_xp or 1) / (next_level_data.points or 1))
			
			local show_level = true
			if at_max_level == true then
				show_level = VoidUI.options.scoreboard_maxlevel
			end
			local experience_bg = extras_panel:bitmap({
				name = "experience_bg",
				h = show_level and 15 * self._scale or 0,
				color = Color.black,
				alpha = 0.6
			})
			local experience_bar = extras_panel:bitmap({
				name = "experience_bg",
				x = 4 * self._scale,
				y = 4 * self._scale,
				w = ((next_level_data.current_points or 1) / (next_level_data.points or 1)) * (extras_panel:w() - 8 * self._scale),
				h = show_level and 7 * self._scale or 0,
				alpha = 0.6
			})
			local exp_gain_bar = extras_panel:bitmap({
				name = "exp_gain_bar",
				y = 4 * self._scale,
				x = progress * (extras_panel:w() - 8 * self._scale) + 4 * self._scale,
				w = gain_progress * (extras_panel:w() - experience_bar:w() - 8 * self._scale),
				h = show_level and 7 * self._scale or 0,
				color = tweak_data.hud_stats.potential_xp_color,
				alpha = 0.6
			})
			local current_level_text = extras_panel:text({
				name = "current_level_text",
				font = tweak_data.menu.pd2_large_font,
				x = 2,
				y = experience_bg:bottom(),
				font_size = show_level and tweak_data.hud_stats.day_description_size * self._scale or 0,
				text = at_max_level and tostring(current_level - 1) or tostring(current_level)
			})
			local current_level_text_shadow = extras_panel:text({
				name = "current_level_text_shadow",
				font = tweak_data.menu.pd2_large_font,
				x = 2 + 2 * self._scale,
				y = experience_bg:bottom() + 2 * self._scale,
				font_size = show_level and tweak_data.hud_stats.day_description_size * self._scale or 0,
				text = at_max_level and tostring(current_level - 1) or tostring(current_level),
				layer = -2,
				color = Color.black
			})
			local next_level_text = extras_panel:text({
				name = "next_level_text",
				font = tweak_data.menu.pd2_large_font,
				x = -2,
				y = experience_bg:bottom(),
				font_size = show_level and tweak_data.hud_stats.day_description_size * self._scale or 0,
				text = at_max_level and tostring(current_level) or tostring(current_level + 1),
				align = "right"
			})
			local next_level_text_shadow = extras_panel:text({
				name = "next_level_text_shadow",
				font = tweak_data.menu.pd2_large_font,
				y = experience_bg:bottom() + 2,
				font_size = show_level and tweak_data.hud_stats.day_description_size * self._scale or 0,
				text = at_max_level and tostring(current_level) or tostring(current_level + 1),
				layer = -2,
				color = Color.black,
				align = "right"
			})

			if at_max_level then
				local text = show_level and managers.localization:text("hud_at_max_level") or ""
				next_level_text:set_text(text.." "..next_level_text:text())
				next_level_text_shadow:set_text(next_level_text:text())
				next_level_text:set_range_color(0, utf8.len(text), tweak_data.hud_stats.potential_xp_color)
			else
				local current_text = current_level_text:text()
				local points = next_level_data.points - next_level_data.current_points
				local text = managers.localization:text("hud_potential_xp", {
					XP = managers.money:add_decimal_marks_to_string(tostring(gain_xp))
				})
				current_level_text:set_text(current_level_text:text().." "..text)
				current_level_text:set_range_color(utf8.len(current_text), utf8.len(current_level_text:text()), tweak_data.hud_stats.potential_xp_color)
				current_level_text_shadow:set_text(current_level_text:text())
				
				local text = managers.localization:text("menu_es_next_level") .. " " .. managers.money:add_decimal_marks_to_string(tostring(points))
				local next_level_in = extras_panel:text({
					name = "next_level_in",
					font = tweak_data.menu.pd2_large_font,
					y = experience_bg:bottom(),
					font_size = tweak_data.hud_stats.day_description_size * self._scale,
					text = text,
					align = "center"
				})
				local next_level_in_shadow = extras_panel:text({
					name = "next_level_in_shadow",
					font = tweak_data.menu.pd2_large_font,
					x = 2 * self._scale,
					y = experience_bg:bottom() + 2 * self._scale,
					font_size = tweak_data.hud_stats.day_description_size * self._scale,
					text = text,
					layer = -2,
					color = Color.black,
					align = "center"
				})
				if can_lvl_up  then
					local text = managers.localization:text("hud_potential_level_up")
					next_level_text:set_text(text:gsub("!",":").." "..next_level_text:text())
					next_level_text_shadow:set_text(next_level_text:text())
					next_level_text:set_color(tweak_data.hud_stats.potential_xp_color)
					next_level_text:animate(callback(self, self, "_animate_text_pulse"), next_level_text_shadow)			
				end
				
			end
		end

		
		function HUDStatsScreen:_animate_text_pulse(text, shadow)
			local t = 0
			local length = utf8.len(text:text())
			while true do
				local dt = coroutine.yield()
				t = t + dt
				local fast = math.abs((math.sin(t * 90 * 1)))
				local slow = math.abs((math.sin(t * 45 * 1)))
				text:set_font_size(math.lerp(tweak_data.hud_stats.day_description_size * self._scale, tweak_data.hud_stats.day_description_size * self._scale + 3 * self._scale, fast * fast))
				shadow:set_font_size(text:font_size())
				shadow:set_x(math.lerp(-4,0, slow * slow))
			end
		end
		
		function HUDStatsScreen:_update_stats_screen_loot(extras_panel, top_panel)
			local payout = managers.money:get_potential_payout_from_current_stage()		
			local payday = extras_panel:text({
					name = "payday",
					font = tweak_data.menu.pd2_large_font,
					font_size = 30 * self._scale,
					text = managers.localization:text("hud_day_payout", {MONEY = managers.experience:cash_string(payout)}),
					h = extras_panel:h() / (3 / self._scale),
					align = "center",
					vertical = "bottom"
			})
			local payday_shadow = extras_panel:text({
					name = "payday_shadow",
					x = 2 * self._scale,
					y = 2 * self._scale,
					font = tweak_data.menu.pd2_large_font,
					font_size = 30 * self._scale,
					text = managers.localization:text("hud_day_payout", {MONEY = managers.experience:cash_string(payout)}),
					h = extras_panel:h() / (3 / self._scale),
					color = Color.black,
					layer = -2,
					align = "center",
					vertical = "bottom"
			})
			local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
			local secured_amount = managers.loot:get_secured_mandatory_bags_amount()
			local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
			local mission_amount = managers.loot:get_secured_mandatory_bags_amount()
			local mission_vis = mission_amount > 0 or secured_amount > 0
			local mandatory_cash = managers.money:get_secured_mandatory_bags_money()
			local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
			local mandatory_amount = mandatory_bags_data and mandatory_bags_data.amount
			local small_loot = managers.loot:get_real_total_small_loot_value()
			local hit_accuracy = managers.statistics:session_hit_accuracy()
			local player_unit = managers.player:player_unit()
			local trade_delay = alive(player_unit) and not tweak_data.player.damage.automatic_respawn_time and managers.groupai:state():all_criminals()[managers.player:player_unit():key()] and managers.groupai:state():all_criminals()[managers.player:player_unit():key()].respawn_penalty

			local body_bag = managers.localization:text("hud_body_bags")..": "..tostring(managers.player:get_body_bags_amount())
			local bags = ""
			if mandatory_amount and mandatory_amount > 0 then
				bags = " Ї "..utf8.to_lower(managers.localization:text("hud_stats_bags_secured")):gsub("^%l", string.upper)..": ".. (bonus_amount > 0 and string.format("%d/%d +%d", secured_amount, mandatory_amount, bonus_amount) or string.format("%d/%d", secured_amount, mandatory_amount))
			else
				bags = " Ї "..utf8.to_lower(managers.localization:text("hud_stats_bags_secured")):gsub("^%l", string.upper)..": "..tostring(bonus_amount)
			end
			local instant_cash = small_loot > 0 and " Ї "..managers.localization:text("hud_instant_cash")..": "..managers.experience:cash_string(small_loot) or ""
			local accuracy = VoidUI.options.scoreboard_accuracy and hit_accuracy and " Ї "..utf8.to_lower(managers.localization:text("menu_stats_hit_accuracy")):gsub("^%l", string.upper).." ".. hit_accuracy.."%" or ""
			local delay = VoidUI.options.scoreboard_delay and trade_delay and " Ї "..managers.localization:text("hud_trade_delay", {TIME = tostring(self:_get_time_text(trade_delay))}) or ""

			top_panel:child("loot_stats"):set_text(body_bag..accuracy..delay..bags..instant_cash)
			top_panel:child("loot_stats_shadow"):set_text(body_bag..accuracy..delay..bags..instant_cash)
			local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
			music = managers.localization:text("VoidUI_nosong")
			if (level_data and level_data.music == "no_music") or Global.music_manager.current_track then
				music = managers.music:current_track_string()
			end
			local track_text = extras_panel:text({
				name = "track_text",
				font_size = 20 * self._scale,
				font = "fonts/font_medium_mf",
				text = managers.localization:to_upper_text("menu_es_playing_track") .. " " .. music,
				align = "center",
				layer = 1,
			})
			managers.hud:make_fine_text(track_text)
			track_text:set_center_x(extras_panel:w() / 2)
			track_text:set_top(extras_panel:h() / (3 / self._scale))
			local track_text_shadow = extras_panel:text({
				name = "track_text_shadow",
				font_size = 20 * self._scale,
				font = "fonts/font_medium_mf",
				text = track_text:text(),
				align = "center",
				color = Color.black,
				layer = -2,
				rotation = 360,
			})
			managers.hud:make_fine_text(track_text_shadow)
			track_text_shadow:set_center_x(extras_panel:w() / 2 + 2 * self._scale)
			track_text_shadow:set_top(extras_panel:h() / (3 / self._scale) + 2 * self._scale)
			if self._scoreboard_panels and #self._scoreboard_panels > 0 and managers.achievment and #managers.achievment:get_tracked_fill() then
				local toggle_text = extras_panel:text({
					name = "track_text",
					font_size = 15 * self._scale,
					font = "fonts/font_medium_mf",
					text = (VoidUI.options.scoreboard_toggle < 3 and self._toggle_text ~= "" and (utf8.to_upper(managers.localization:btn_macro(VoidUI.options.scoreboard_toggle == 1 and "jump" or "duck")) .." ") or "")..self._toggle_text,
					vertical = "top",
					align = "center",
					layer = 1,
				})
				toggle_text:set_top(track_text_shadow:bottom())
				managers.hud:make_fine_text(toggle_text)
				local toggle_image = extras_panel:bitmap({
					name = "toggle_image",
					texture = "guis/textures/pd2/mouse_buttons",
					texture_rect = {19,2,15,21},
					w = VoidUI.options.scoreboard_toggle == 3 and toggle_text:h() / 1.5 or 0,
					h = toggle_text:h(),
					layer = 2
				})
				toggle_text:set_center_x(extras_panel:w() / 2 + toggle_image:w() * 1.2)
				local toggle_text_shadow = extras_panel:text({
					name = "toggle_text_shadow",
					font_size = 15 * self._scale,
					font = "fonts/font_medium_mf",
					text = toggle_text:text(),
					vertical = "top",
					align = "center",
					color = Color.black,
					layer = -2
				})
				toggle_text_shadow:set_top(toggle_text:top() + 2 * self._scale)
				managers.hud:make_fine_text(toggle_text_shadow)
				toggle_text_shadow:set_x(toggle_text:x() + 2 * self._scale)
				toggle_image:set_right(toggle_text:left() - toggle_text:h() / 2)
				toggle_image:set_top(toggle_text:top())
			end
		end
		function HUDStatsScreen:_get_time_text(time)
			time = math.max(math.floor(time), 0)
			local minutes = math.floor(time / 60)
			time = time - minutes * 60
			local seconds = math.round(time)
			local text = ""
	
			return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
		end	
		function HUDStatsScreen:_create_mutators_list(mutators_panel)
			mutators_panel:clear()
			if not managers.mutators:are_mutators_active() then
				return
			end
			local title = mutators_panel:text({
				name = "title",
				text = managers.localization:text("menu_mutators"),
				font_size = tweak_data.hud_stats.loot_title_size * self._scale,
				font = tweak_data.menu.pd2_large_font,
				align = "right",
				vertical = "center",
				w = mutators_panel:w(),
				h = tweak_data.hud_stats.loot_title_size
			})
			managers.hud:make_fine_text(title)
			title:set_right(mutators_panel:w() - 2 * self._scale)
			local title_shadow = mutators_panel:text({
				name = "title_shadow",
				text = managers.localization:text("menu_mutators"),
				font_size = tweak_data.hud_stats.loot_title_size * self._scale,
				font = tweak_data.menu.pd2_large_font,
				color = Color.black,
				align = "right",
				vertical = "center",
				layer = -2,
				w = mutators_panel:w(),
				h = tweak_data.hud_stats.loot_title_size,
				y = 2 * self._scale
			})
			managers.hud:make_fine_text(title_shadow)
			title_shadow:set_right(mutators_panel:w())
			local mutator_text
			for i, active_mutator in ipairs(managers.mutators:active_mutators()) do
				mutator_text = mutators_panel:text({
					name = "mutator_" .. tostring(i),
					font_size = tweak_data.hud_stats.day_description_size * self._scale,
					font = tweak_data.hud_stats.objectives_font,
					text = active_mutator.mutator:name(),
					align = "right",
					w = mutators_panel:w(),
					h = tweak_data.hud_stats.day_description_size * self._scale,
					x = -2 * self._scale,
					y = 15 + (tweak_data.hud_stats.day_description_size * self._scale) * i
				})
				local mutator_text_shadow = mutators_panel:text({
					name = "mutator_shadow_" .. tostring(i),
					color = Color.black,
					font_size = tweak_data.hud_stats.day_description_size * self._scale,
					font = tweak_data.hud_stats.objectives_font,
					text = mutator_text:text(),
					align = "right",
					w = mutator_text:w(),
					h = mutator_text:h(),
					y = mutator_text:y() + 2 * self._scale,
					layer = -2
				})
			end
			mutators_panel:set_h(mutator_text and mutator_text:bottom() + 2 or 0)
			mutators_panel:set_center_y(self._full_hud_panel:h() / 2)
		end
		function HUDStatsScreen:loot_value_updated()
			local extras_panel = self._full_hud_panel:child("extras_panel")
			local top_panel = self._full_hud_panel:child("top_panel")
			self:_create_stats_screen_profile(extras_panel)
			self:_update_stats_screen_loot(extras_panel, top_panel)
		end
		
		function HUDStatsScreen:on_ext_inventory_changed()
			local extras_panel = self._full_hud_panel:child("extras_panel")
			local top_panel = self._full_hud_panel:child("top_panel")
			if not alive(extras_panel) then
				return
			end
			self:_create_stats_screen_profile(extras_panel)
			self:_update_stats_screen_loot(extras_panel, top_panel)
		end
		
		function HUDStatsScreen:mouse_pressed(o, k)
			if HUDManager.PLAYER_PANEL > 7 then
				if k == Idstring("mouse wheel up") then
					self._scroll = math.max(self._scroll-1,0)
					self:align_scoreboard_panels()
				elseif k == Idstring("mouse wheel down") then
					self._scroll = math.min(self._scroll+1, HUDManager.PLAYER_PANEL - 7)
					self:align_scoreboard_panels()
				end
			end
			if k == Idstring("1") and VoidUI.options.scoreboard_toggle == 3 then
				self:toggle_panels()
			end
		end

		function HUDStatsScreen:show()
			local safe = managers.hud.STATS_SCREEN_SAFERECT
			local full = managers.hud.STATS_SCREEN_FULLSCREEN
			managers.hud:show(full)
			managers.mouse_pointer:use_mouse{
				id = self._mouse,
				mouse_press = callback(self, self, 'mouse_pressed')
			}
			if not self._input_keyboard then
				self._input_keyboard = Input:keyboard()
			end
			local type = managers.controller:get_default_wrapper_type()
			self._key = managers.controller:get_settings(type):get_connection(VoidUI.options.scoreboard_toggle == 1 and "jump" or "duck"):get_input_name_list()[1]
			managers.mouse_pointer._mouse:child("pointer"):set_visible(false)
			local left_panel = self._left
			local top_panel = self._full_hud_panel:child("top_panel")
			local extras_panel = self._full_hud_panel:child("extras_panel")
			local scoreboard_panel = self._full_hud_panel:child("scoreboard_panel")
			local mutators_panel = self._full_hud_panel:child("mutators_panel")
			self:recreate_right()
			self:_create_stats_screen_profile(extras_panel)
			self:_update_stats_screen_loot(extras_panel, top_panel)
			self:_update_stats_screen_day(top_panel)
			self:_create_mutators_list(mutators_panel)
			left_panel:set_alpha(0)
			self._blur:set_visible(VoidUI.options.scoreboard_blur)
			left_panel:stop()
			left_panel:animate(callback(self, self, "_animate_show_stats_left_panel"), self._full_hud_panel, top_panel, scoreboard_panel, extras_panel, mutators_panel)
			self:align_scoreboard_panels()
			self._showing_stats_screen = true
			if managers.groupai:state() and not self._whisper_listener then
				self._whisper_listener = "HUDStatsScreen_whisper_mode"
				managers.groupai:state():add_listener(self._whisper_listener, {
					"whisper_mode"
				}, callback(self, self, "on_whisper_mode_changed"))
			end
		end
		
		function HUDStatsScreen:hide()
			if self._showing_stats_screen == false then return end
			self._showing_stats_screen = false
			local safe = managers.hud.STATS_SCREEN_SAFERECT
			local full = managers.hud.STATS_SCREEN_FULLSCREEN
			if not managers.hud:exists(safe) then
				return
			end
			managers.hud:hide(safe)
			if self._mouse then 
				managers.mouse_pointer:set_pointer_image("arrow")
				managers.mouse_pointer:remove_mouse(self._mouse) 
				managers.mouse_pointer._mouse:child("pointer"):set_visible(true)
			end
			local left_panel = self._left
			local top_panel = self._full_hud_panel:child("top_panel")
			local extras_panel = self._full_hud_panel:child("extras_panel")
			local scoreboard_panel = self._full_hud_panel:child("scoreboard_panel")
			local mutators_panel = self._full_hud_panel:child("mutators_panel")
			left_panel:set_alpha(0)
			left_panel:stop()
			left_panel:animate(callback(self, self, "_animate_hide_stats_left_panel"), self._full_hud_panel, top_panel, scoreboard_panel, extras_panel, mutators_panel)
			if managers.groupai:state() and self._whisper_listener then
				managers.groupai:state():remove_listener(self._whisper_listener)
				self._whisper_listener = nil
			end
		end
		
		function HUDStatsScreen:_animate_show_stats_left_panel(left_panel, full_hud_panel, top_panel, scoreboard_panel, extras_panel, mutators_panel)
			local start_x = left_panel:x()
			local start_a = 1 - start_x / -left_panel:w()
			local TOTAL_T = 0.2 * (start_x / -left_panel:w())
			scoreboard_panel:set_top(self._full_hud_panel:h() / 2.5)
			local timer_panel
			local obj_panel
			local timer_a
			local obj_a
			if self._timer and managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._enabled then 
				timer_panel = managers.hud._hud_heist_timer._heist_timer_panel
				timer_a = timer_panel:alpha()
				timer_panel:set_layer(VoidUI.options.show_timer == 2 and self._full_hud_panel:layer() + 1 or 0)
				timer_panel:set_visible(VoidUI.options.show_timer > 1)
			end
			if managers.hud._hud_objectives then
				obj_panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
				obj_a = obj_panel:alpha()
				obj_panel:set_layer(self._objective and (VoidUI.options.show_objectives == 2 and self._full_hud_panel:layer() + 1 or 0) or 0)
				obj_panel:set_visible(self._objective and VoidUI.options.show_objectives > 1 or true)
				if self._timer and VoidUI.options.show_timer > 1 then
					obj_panel:set_y(self._objective and 0 or 40 * managers.hud._hud_heist_timer._scale)
				elseif (self._timer and not VoidUI.options.show_timer > 1) or not self._timer then
					obj_panel:set_y(self._objective and -(32 * managers.hud._hud_objectives._scale) or 0)
				end	
			end
			
			local t = 0
			while TOTAL_T > t do
				local dt = coroutine.yield() * (1 / TimerManager:game():multiplier())
				t = t + dt
				left_panel:set_x(math.lerp(start_x, 0, t / TOTAL_T))
				local a = math.clamp(math.lerp(start_a, 1, t / TOTAL_T), 0, 1)
				full_hud_panel:set_alpha(a)
				top_panel:set_top(math.lerp(-(top_panel:h() / 2), 0, t / TOTAL_T))
				scoreboard_panel:set_top(math.lerp(self._full_hud_panel:h() / 2, self._full_hud_panel:h() / 2.5, t / TOTAL_T))
				mutators_panel:set_right(math.lerp(full_hud_panel:w() + mutators_panel:w(), full_hud_panel:w(), t / TOTAL_T))
				self:align_scoreboard_panels()
				if self._timer and managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._enabled then 
					timer_panel:set_alpha(math.lerp(timer_a, VoidUI.options.show_timer > 1 and 1 or 0, t / TOTAL_T))
				end
				if self._objective and managers.hud._hud_objectives then 
					obj_panel:set_alpha(math.lerp(obj_a, VoidUI.options.show_objectives > 1 and 1 or 0, t / TOTAL_T))
				end
			end
			full_hud_panel:set_alpha(1)
			top_panel:set_top(0)
			scoreboard_panel:set_top(self._full_hud_panel:h() / 2.5)
			mutators_panel:set_right(full_hud_panel:w())
			self:align_scoreboard_panels()
		end
		
		function HUDStatsScreen:_animate_hide_stats_left_panel(left_panel, full_hud_panel, top_panel, scoreboard_panel, extras_panel, mutators_panel)
			local start_x = left_panel:x()
			local start_a = 1 - start_x / -left_panel:w()
			local TOTAL_T = 0.2 * (1 - start_x / -left_panel:w())
			scoreboard_panel:set_top(self._full_hud_panel:h() / 2.5)
			local timer_panel
			local obj_panel
			local timer_a
			local obj_a
			if self._timer and managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._enabled then 
					timer_panel = managers.hud._hud_heist_timer._heist_timer_panel
					timer_a = timer_panel:alpha()
			end
			if managers.hud._hud_objectives then
				obj_panel = managers.hud._hud_objectives._hud_panel:child("objectives_panel")
				obj_a = obj_panel:alpha()
				if (self._timer and VoidUI.options.show_timer == 2 and VoidUI.options.show_objectives == 3) or not self._timer then
					obj_panel:set_y(self._objective and -(32 * managers.hud._hud_objectives._scale) or 0)
				elseif self._timer and not VoidUI.options.show_timer == 2 and not VoidUI.options.show_objectives == 3 then
					obj_panel:set_y(self._objective and 0 or 40 * managers.hud._hud_heist_timer._scale)
				end
			end
			local t = 0
			while TOTAL_T > t do
				local dt = coroutine.yield() * (1 / TimerManager:game():multiplier())
				t = t + dt
				left_panel:set_x(math.lerp(start_x, -left_panel:w(), t / TOTAL_T))
				local a = math.clamp(math.lerp(start_a, 0, t / TOTAL_T), 0, 1)
				full_hud_panel:set_alpha(a)
				top_panel:set_top(math.lerp(0, -(top_panel:h() / 2), t / TOTAL_T))
				scoreboard_panel:set_top(math.lerp(self._full_hud_panel:h() / 2.5, self._full_hud_panel:h() / 2, t / TOTAL_T))
				mutators_panel:set_right(math.lerp(full_hud_panel:w(), full_hud_panel:w() + mutators_panel:w(), t / TOTAL_T))
				self:align_scoreboard_panels()
				if self._timer and managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._enabled then 
					timer_panel:set_alpha(math.lerp(timer_a, VoidUI.options.show_timer == 3 and 1 or 0, t / TOTAL_T))
				end
				if self._objective and managers.hud._hud_objectives then 
					obj_panel:set_alpha(math.lerp(obj_a, VoidUI.options.show_objectives == 3 and 1 or 0, t / TOTAL_T))
				end
			end
			if self._timer and managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._enabled then 
				timer_panel:set_layer(0)
				timer_panel:set_visible(VoidUI.options.show_timer == 3)
			end
			if self._objective and managers.hud._hud_objectives then 
				obj_panel:set_layer(0)
				obj_panel:set_visible(VoidUI.options.show_objectives == 3)
			end
			full_hud_panel:set_alpha(0)
			top_panel:set_top(-top_panel:h())
			scoreboard_panel:set_top(self._full_hud_panel:h() / 1.5)
			mutators_panel:set_right(full_hud_panel:w() + mutators_panel:w())
			self:align_scoreboard_panels()
		end
		function HUDStatsScreen:on_whisper_mode_changed()
			local is_level_ghostable = managers.job:is_level_ghostable(managers.job:current_level_id()) and managers.groupai and managers.groupai:state():whisper_mode()
			local top_panel = self._full_hud_panel:child("top_panel")
			local ghost_icon = top_panel:child("ghost_icon")
			if alive(ghost_icon) then
				ghost_icon:set_color(tweak_data.screen_colors.important_1)
			end
		end
		
		function HUDStatsScreen:toggle_panels()
			if managers.achievment and #managers.achievment:get_tracked_fill() > 0 and self._scoreboard_panels and #self._scoreboard_panels > 0 then
				self._visible_panel = self._visible_panel == "scoreboard_panel" and "achievements_panel" or "scoreboard_panel"
				self._toggle_text = (self._visible_panel == "scoreboard_panel" and managers.localization:text("hud_stats_tracked") or managers.localization:to_upper_text("VoidUI_scoreboard"))
				self._full_hud_panel:child("achievements_panel"):set_visible(not self._full_hud_panel:child("achievements_panel"):visible())
				self._full_hud_panel:child("scoreboard_panel"):set_visible(not self._full_hud_panel:child("scoreboard_panel"):visible())
				local extras_panel = self._full_hud_panel:child("extras_panel")
				local top_panel = self._full_hud_panel:child("top_panel")
				self:_create_stats_screen_profile(extras_panel)
				self:_update_stats_screen_loot(extras_panel, top_panel)
				self:align_scoreboard_panels()
			end
		end
		local update = HUDStatsScreen.update
		function HUDStatsScreen:update(t, dt)
			update(self, t, dt)

			if self._showing_stats_screen == true and VoidUI.options.scoreboard_toggle < 3 and self._input_keyboard:pressed(Idstring(self._key)) then
				self:toggle_panels()
			end
		end
		function HUDStatsScreen:recreate_right()
			if self._full_hud_panel:child("achievements_panel") then
				self._full_hud_panel:remove(self._full_hud_panel:child("achievements_panel"))
			end
			local achievements_panel = self._full_hud_panel:panel({
				name = "achievements_panel",
				w = (managers.gui_data:full_16_9_size().w / 1.55) * self._scale,
				y = (self._full_hud_panel:h() / 2.5) * self._scale,
				h = (35 * self._scale) * 4,
				visible = self._visible_panel == "achievements_panel" and true or false
			})
			achievements_panel:set_center_x(self._full_hud_panel:w() / 2)
			local tracked = managers.achievment:get_tracked_fill()
			if #tracked == 0 then
				self._visible_panel = "scoreboard_panel"
			else
				self._tracked_items = {}
				self._toggle_text = managers.localization:text("hud_stats_tracked")
				local t
				for i, id in pairs(tracked) do 
					if 	i <= AchievmentManager.MAX_TRACKED then
						t = HudTrackedAchievement:new(achievements_panel, id, i, 35 * self._scale, self._scale)
						if t._progress and t._progress.update and table.contains({
							"realtime",
							"second"
						}, t._progress.update) then
							table.insert(self._tracked_items, t)
						end
					end
				end
				achievements_panel:set_h(t._panel:bottom() + 5)
				local labels = {
					{parent = "background", name = "name", text = utf8.to_lower(managers.localization:text("hud_stats_tracked")):gsub("^%l", string.upper)}
				}
				self:create_scoreboard_labels(achievements_panel, t._panel, labels, self._scale)
			end
		end
		
		function HUDStatsScreen:create_scoreboards()
			if self._full_hud_panel:child("scoreboard_panel") then
				return
			end
			local scale = self._scale
			local scoreboard_panel = self._full_hud_panel:panel({
				name = "scoreboard_panel",
				w = (managers.gui_data:full_16_9_size().w / 1.55) * scale,
				y = (self._full_hud_panel:h() / 2.5) * scale,
				h = 0
			})
			scoreboard_panel:set_center_x(self._full_hud_panel:w() / 2)
			if self._scoreboard_enabled then
				self._scoreboard_panels = {}
				local h = 35 * scale
				local score
				for i = 1, HUDManager.PLAYER_PANEL do
					local is_player = i == HUDManager.PLAYER_PANEL
					score = HUDScoreboard:new(i, scoreboard_panel, is_player, h, scale)
					table.insert(self._scoreboard_panels, score)
				end
				local labels = {
					{parent = "name_bg", name = "name", text = (VoidUI.options.scoreboard_character and (managers.localization:text("menu_preferred_character").. " / ") or "" ) ..managers.localization:text("VoidUI_player").. " / " .. (VoidUI.options.scoreboard_skills and managers.localization:text("menu_st_skilltree") or ""), align = "left"},
					{parent = "kills_bg", name = "kills", text = managers.localization:text("VoidUI_kills")},
					{parent = "specials_bg", name = "specials", text = managers.localization:text("VoidUI_specials")},
					{parent = "civs_bg", name = "civs", text = managers.localization:text("VoidUI_civs")},
					{parent = "downs_bg", name = "downs", text = managers.localization:text("VoidUI_downs")},
					{parent = "primary_bg", name = "primary", text = managers.localization:text("bm_menu_primaries")},
					{parent = "secondary_bg", name = "secondary", text = managers.localization:text("bm_menu_secondaries")},
					{parent = "melee_bg", name = "melee", text = managers.localization:text("bm_menu_melee_weapons")},
					{parent = "armor_bg", name = "armor", text = managers.localization:text("bm_menu_armors")},
					{parent = "perk_bg", name = "perk", text = managers.localization:text("VoidUI_perk")},
					{parent = "hours_bg", name = "hours", text = managers.localization:text("VoidUI_playtime")},
					{parent = "ping_bg", name = "ping", text = managers.localization:text("VoidUI_ping")}
				}
				self:create_scoreboard_labels(scoreboard_panel, score._panel, labels, scale)
				scoreboard_panel:set_w(score._panel:child("ping_bg"):right())
				scoreboard_panel:set_center_x(self._full_hud_panel:w() / 2)
			end
		end
		
		function HUDStatsScreen:create_scoreboard_labels(scoreboard_panel, score_panel, labels, scale)
			if not score_panel then
				return
			end
			for index, data in ipairs(labels) do
				local parent = score_panel:child(labels[index]["parent"])
				local name = labels[index]["name"]
				local text = labels[index]["text"]
				local align = labels[index]["align"]
				scoreboard_panel:text({
					name = name.."_text",
					x = parent:x(),
					y = -parent:h(),
					w = parent:w(),
					h = parent:h(),
					visible = parent:w() > 0,
					font = tweak_data.menu.pd2_large_font,
					font_size = 15 * scale,
					text = text,
					vertical = "bottom",
					align = align and align or "center",
					rotation = 360
				})
				
				scoreboard_panel:text({
					name = name.."_text_shadow",
					x = parent:x() + 2 * self._scale,
					y = -parent:h() + 2 * self._scale,
					w = parent:w(),
					h = parent:h(),
					visible = parent:w() > 0,
					font = tweak_data.menu.pd2_large_font,
					color = Color.black,
					layer = -2,
					font_size = 15 * scale,
					text = text,
					vertical = "bottom",
					align = align and align or "center",
					rotation = 360
				})
			end
		end
		function HUDStatsScreen:add_scoreboard_panel(character_name, player_name, ai, peer_id)
			for i, panel in ipairs(self._scoreboard_panels) do
				if self._scoreboard_enabled and panel._taken == false then
					self._scoreboard_panels[i]:set_player(character_name, player_name, ai, peer_id)
					break
				end
			end
			self:align_scoreboard_panels()
		end

		function HUDStatsScreen:get_scoreboard_panel_by_peer_id(peer_id)
			if self._scoreboard_enabled and self._scoreboard_panels then 
				for i, panel in ipairs(self._scoreboard_panels) do
					if panel._peer_id == peer_id then
						return panel
					end
				end
			else
				return nil
			end
		end
		
		function HUDStatsScreen:get_scoreboard_panel_by_character(character_name)
			if self._scoreboard_enabled and self._scoreboard_panels then 
				for i, panel in ipairs(self._scoreboard_panels) do
					if panel._character == character_name then
						return panel
					end
				end
			else
				return nil
			end
		end
		function HUDStatsScreen:remove_scoreboard_panel(id)
			if self._scoreboard_panels[id] then
				self._scoreboard_panels[id]:remove_panel()
				self:align_scoreboard_panels()
			end
		end
		function HUDStatsScreen:free_scoreboard_panel(id)
			if self._scoreboard_panels[id] then
				self._scoreboard_panels[id]._taken = false
				self:align_scoreboard_panels()
			end
		end
		function HUDStatsScreen:align_scoreboard_panels()
			local extras_panel = self._full_hud_panel:child("extras_panel")
			if self._scoreboard_panels then
				local taken_panels = 0
				for i, panel in ipairs(self._scoreboard_panels) do
					panel._panel:set_h(panel._taken and panel._h or 0)
					panel._panel:set_visible(panel._taken)
					panel._panel:set_y(i == 1 and -(self._scroll * (panel._panel:h() + 5)) or (panel._taken and self._scoreboard_panels[i - 1]._panel:bottom() + 5 or self._scoreboard_panels[i - 1]._panel:bottom()))
					taken_panels = taken_panels + (panel._taken and 1 or 0)
				end
				self._full_hud_panel:child("scoreboard_panel"):set_h(self._scoreboard_panels[1]._h * math.min(taken_panels,7) + math.min(taken_panels,7) * 5)
			end
			if managers.achievment and #managers.achievment:get_tracked_fill() > 0 then self._full_hud_panel:child("achievements_panel"):set_y(self._full_hud_panel:child("scoreboard_panel"):y()) end
			extras_panel:set_center_x(self._full_hud_panel:child("scoreboard_panel"):center_x())
			extras_panel:set_y(self._full_hud_panel:child(self._visible_panel):bottom())
		end
		
		function HUDStatsScreen:_update_stats_screen_day(top_panel)
			local job_data = managers.job:current_job_data()
			local stage_data = managers.job:current_stage_data()
			local has_stage_data = stage_data and true or false
			local days_title = top_panel:child("days_title")
			local days_title_shadow = top_panel:child("days_title_shadow")
			local ghost_icon = top_panel:child("ghost_icon")
			local ghost_icon_shadow = top_panel:child("ghost_icon_shadow")
			top_panel:set_visible(has_stage_data)
			if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
				top_panel:set_visible(false)
				return
			end
			if has_stage_data then
				local job_chain = managers.job:current_job_chain_data()
				local day = managers.job:current_stage()
				if day and managers.job:current_job_data().name_id == "heist_rvd" then
					day = 3 - day
				end
				local days = job_chain and #job_chain or 0
				local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
				days_title:set_text(utf8.to_upper(managers.localization:text("hud_days_title", {DAY = day, DAYS = days})))
				managers.hud:make_fine_text(days_title)
				days_title_shadow:set_text(utf8.to_upper(managers.localization:text("hud_days_title", {DAY = day, DAYS = days})))
				managers.hud:make_fine_text(days_title_shadow)
				ghost_icon:set_x(days_title_shadow:right())
				ghost_icon_shadow:set_x(ghost_icon:x() + 2 * self._scale)
				ghost_icon:set_color(is_whisper_mode and Color.white or tweak_data.screen_colors.important_1)
				local level_data = managers.job:current_level_data()
				if level_data then
					local day_title = top_panel:child("day_title")
					local day_title_shadow = top_panel:child("day_title_shadow")
					day_title:set_text(managers.localization:text(managers.crime_spree:is_active() and level_data.name_id or (level_data.name_id == "heist_branchbank_hl" and job_data.name_id or level_data.name_id)))
					day_title_shadow:set_text(day_title:text())
				end
			end
			if managers.crime_spree:is_active() then
				days_title:set_visible(false)
				days_title_shadow:set_visible(false)
				ghost_icon:set_visible(false)
				ghost_icon_shadow:set_visible(false)
			end
		end

	elseif RequiredScript == "lib/managers/hudmanagerpd2" then
		HUDScoreboard = HUDScoreboard or class()
		function HUDScoreboard:init(i, scoreboard_panel, is_player, h, scale)
			self._scale = scale
			self._i = i
			self._main_player = i == HUDManager.PLAYER_PANEL
			self._taken = false
			self._peer_id = nil
			self._ai = nil
			self._character = nil
			self._name = nil
			self._h = h
			
			self._panel = scoreboard_panel:panel({
				name = "scoreboard_panel_" .. i,
				h = h
			})
			
			local background = self._panel:bitmap({
				name = "background",
				w = self._panel:w(),
				h = self._panel:h(),
				color = Color.black,
				alpha = 0.6
			})
			
			local character_icon = self._panel:bitmap({
				name = "character_icon",
				texture = tweak_data.blackmarket:get_character_icon("dallas"),
				w = VoidUI.options.scoreboard_character and h or 0,
				h = h,
				layer = 2
			})
			local name = self._panel:text({
				name = "name",
				text = "XXVЇ100 Almir",
				layer = 2,
				color = Color.white,
				vertical = "center",
				font_size = 20 * self._scale,
				x = VoidUI.options.scoreboard_character and character_icon:right() or 5 * self._scale,
				y = 2,
				w = 230 * self._scale,
				h = self._h / 2,
				font = "fonts/font_medium_mf",
			})
			self._panel:text({
				name = "skills",
				text = "M:00 00 00  E:00 00 00  T:00 00 00  G:00 00 00  F:00 00 00",
				layer = 2,
				color = Color.white,
				vertical = "bottom",
				font_size = 13 * self._scale,
				x = VoidUI.options.scoreboard_character and character_icon:right() or 5 * self._scale,
				w = name:w(),
				h = h - 2,
				font = "fonts/font_medium_mf",
			})
			local name_bg = self._panel:bitmap({
				name = "name_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				w = name:right(),
				h = h,
				layer = 1
			})
			local kills_bg = self._panel:bitmap({
				name = "kills_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_kills > 1 and name_bg:right() + 5 * self._scale or name_bg:right(),
				w = VoidUI.options.scoreboard_kills > 1 and h or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "kills",
				text = "0",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = kills_bg:x(),
				w = VoidUI.options.scoreboard_kills > 1 and h or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
			local specials_bg = self._panel:bitmap({
				name = "specials_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_specials and kills_bg:right() + 5 * self._scale or kills_bg:right(),
				w = VoidUI.options.scoreboard_specials and h or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "specials",
				text = "0",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = specials_bg:x(),
				w = VoidUI.options.scoreboard_specials and h or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
			local civs_bg = self._panel:bitmap({
				name = "civs_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_civs and specials_bg:right() + 5 * self._scale or specials_bg:right(),
				w = VoidUI.options.scoreboard_civs and h or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "civs",
				text = "0",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = civs_bg:x(),
				w = VoidUI.options.scoreboard_civs and h or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
			local downs_bg = self._panel:bitmap({
				name = "downs_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_downs and civs_bg:right() + 5 * self._scale or civs_bg:right(),
				w = VoidUI.options.scoreboard_downs and h or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "downs",
				text = "0",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = downs_bg:x(),
				w = VoidUI.options.scoreboard_downs and h or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
			local primary_bg = self._panel:bitmap({
				name = "primary_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_weapons and downs_bg:right() + 5 * self._scale or downs_bg:right(),
				w = VoidUI.options.scoreboard_weapons and h * 2 or 0,
				h = h,
				layer = 1
			})
			local primary_icon = self._panel:bitmap({
				name = "primary_icon",
				texture = managers.blackmarket:get_weapon_icon_path("new_m4"),
				w = h * 1.8,
				h = VoidUI.options.scoreboard_weapons and h * 0.8 or 0,
				layer = 3
			})
			primary_icon:set_center(primary_bg:center())
			local primary_rarity = self._panel:bitmap({
				name = "primary_rarity",
				texture = managers.blackmarket:get_cosmetic_rarity_bg("common"),
				visible = false,
				w = VoidUI.options.scoreboard_weapons and h * 2 or 0,
				h = h * 0.8,
				blend_mode = "add",
				layer = 2
			})
			primary_rarity:set_center(primary_bg:center())
			local primary_silencer = self._panel:bitmap({
				name = "primary_silencer",
				texture = "guis/textures/pd2/blackmarket/inv_mod_silencer",
				visible = false,
				w = VoidUI.options.scoreboard_weapons and h * 0.3 or 0,
				h = h * 0.3,
				layer = 4
			})
			primary_silencer:set_rightbottom(primary_bg:right() - 2, primary_bg:bottom() - 2)
			local secondary_bg = self._panel:bitmap({
				name = "secondary_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_weapons and primary_bg:right() + 5 * self._scale or primary_bg:x(),
				w = VoidUI.options.scoreboard_weapons and h * 2 or 0,
				h = h,
				layer = 1
			})
			local secondary_icon = self._panel:bitmap({
				name = "secondary_icon",
				texture = managers.blackmarket:get_weapon_icon_path("glock_17"),
				w = VoidUI.options.scoreboard_weapons and h * 1.8 or 0,
				h = h * 0.8,
				layer = 3
			})
			secondary_icon:set_center(secondary_bg:center())
			local secondary_rarity = self._panel:bitmap({
				name = "secondary_rarity",
				texture = managers.blackmarket:get_cosmetic_rarity_bg("common"),
				visible = false,
				w = VoidUI.options.scoreboard_weapons and h * 2 or 0,
				h = h * 0.8,
				blend_mode = "add",
				layer = 2
			})
			secondary_rarity:set_center(secondary_bg:center())
			local secondary_silencer = self._panel:bitmap({
				name = "secondary_silencer",
				texture = "guis/textures/pd2/blackmarket/inv_mod_silencer",
				visible = false,
				w = VoidUI.options.scoreboard_weapons and h * 0.3 or 0,
				h = h * 0.3,
				layer = 4
			})
			secondary_silencer:set_rightbottom(secondary_bg:right() - 2, secondary_bg:bottom() - 2)
			local melee_bg = self._panel:bitmap({
				name = "melee_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_weapons and secondary_bg:right() + 5 * self._scale or secondary_bg:x(),
				w = VoidUI.options.scoreboard_weapons and h * 2 or 0,
				h = h,
				layer = 1
			})
			local melee_icon = self._panel:bitmap({
				name = "melee_icon",
				texture = "guis/textures/pd2/blackmarket/icons/melee_weapons/brass_knuckles",
				w = VoidUI.options.scoreboard_weapons and h * 1.8 or 0,
				h = h * 0.8,
				layer = 2
			})
			melee_icon:set_center(melee_bg:center())
			local armor_bg = self._panel:bitmap({
				name = "armor_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_armor and melee_bg:right() + 5 * self._scale or melee_bg:right(),
				w = VoidUI.options.scoreboard_armor and h or 0,
				h = h,
				layer = 1
			})
			local armor_icon = self._panel:bitmap({
				name = "armor_icon",
				texture = "guis/textures/pd2/blackmarket/icons/armors/level_1",
				w = VoidUI.options.scoreboard_armor and h or 0,
				h = h,
				layer = 2
			})
			armor_icon:set_center(armor_bg:center())
			local perk_bg = self._panel:bitmap({
				name = "perk_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_perk and armor_bg:right() + 5 * self._scale or armor_bg:right(),
				w = VoidUI.options.scoreboard_perk and h or 0,
				h = h,
				layer = 1
			})
			local perk_icon = self._panel:bitmap({
				name = "perk_icon",
				texture = tweak_data.skilltree:get_specialization_icon_data(1),
				texture_rect = select(2, tweak_data.skilltree:get_specialization_icon_data(1)),
				w = VoidUI.options.scoreboard_perk and h * 0.8 or 0,
				h = h * 0.8,
				layer = 2,
				alpha = 0.6
			})
			perk_icon:set_center(perk_bg:center())
			
			self._panel:text({
				name = "perk_count",
				text = "9/9",
				layer = 3,
				vertical = "bottom",
				align = "right",
				font_size = 15 * self._scale,
				x = perk_bg:x(),
				w = VoidUI.options.scoreboard_perk and h / 1.1 or 0,
				h = h / 1.1,
				font = "fonts/font_medium_noshadow_mf",
			})
			local hours_bg = self._panel:bitmap({
				name = "hours_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_playtime and perk_bg:right() + 5 * self._scale or perk_bg:right(),
				w = VoidUI.options.scoreboard_playtime and h * 1.5 or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "hours",
				text = "0hrs",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = hours_bg:x(),
				w = VoidUI.options.scoreboard_playtime and h * 1.5 or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
			local skill_icon = self._panel:bitmap({
				name = "skill_icon",
				texture = "guis/textures/pd2/add_icon",
				w = VoidUI.options.scoreboard_playtime and h * 0.8 or 0,
				h = h * 0.8,
				layer = 2,
				alpha = 0.6,
				visible = false
			})
			skill_icon:set_center(hours_bg:center())
			local ping_bg = self._panel:bitmap({
				name = "ping_bg",
				texture = "guis/textures/VoidUI/hud_weapons",
				texture_rect = {69,0,416,150},
				x = VoidUI.options.scoreboard_ping and hours_bg:right() + 5 * self._scale or hours_bg:right(),
				w = VoidUI.options.scoreboard_ping and h or 0,
				h = h,
				layer = 1
			})
			self._panel:text({
				name = "ping",
				text = "0",
				layer = 2,
				vertical = "center",
				align = "center",
				font_size = 15 * self._scale,
				x = ping_bg:x(),
				color = Color.green,
				w = VoidUI.options.scoreboard_ping and h or 0,
				h = h,
				font = "fonts/font_medium_mf",
			})
		end
		
		function HUDScoreboard:set_player(character_name, player_name, ai, peer_id)
			if self._name ~= player_name then
				self:remove_panel()
				self._taken = true
				self._peer_id = peer_id
				self._ai = ai
				self._name = player_name
				self._character = character_name
				self._color_id = ai and tweak_data.max_players + 1 or peer_id
				if bkin_bl__menu and self._ai then self._color_id = 6 end

				local name = self._panel:child("name")
				local skills_text = self._panel:child("skills")
				local character_icon = self._panel:child("character_icon")
				local primary_icon = self._panel:child("primary_icon")
				local secondary_bg = self._panel:child("secondary_bg")
				local primary_rarity = self._panel:child("primary_rarity")
				local primary_silencer = self._panel:child("primary_silencer")
				local secondary_icon = self._panel:child("secondary_icon")
				local secondary_rarity = self._panel:child("secondary_rarity")
				local secondary_silencer = self._panel:child("secondary_silencer")
				local melee_icon = self._panel:child("melee_icon")
				local armor_icon = self._panel:child("armor_icon")
				local perk_icon = self._panel:child("perk_icon")
				local skill_icon = self._panel:child("skill_icon")
				local perk_count = self._panel:child("perk_count")
				local hours = self._panel:child("hours")
				local ping = self._panel:child("ping")
				local peer = managers.network:session():peer(peer_id)
				local color = tweak_data.chat_colors[self._color_id] or Color.white
				local outfit = peer and peer:blackmarket_outfit()
				local level = "" 
				if peer then 
					if peer:user_id() then
						dohttpreq("http://steamcommunity.com/profiles/" .. peer:user_id() .. "/games/?tab=recent", callback(self, self, 'get_hours'))
					end
					local rank = self._main_player and managers.experience:current_rank() or peer:rank()
					rank = rank and rank > 0 and managers.experience:rank_string(rank).."Ї" or ""
					local lvl = self._main_player and managers.experience:current_level() or peer:level()
					level = rank or ""..lvl or"".." "
				end
				name:set_text(level .. player_name)
				if ai or not VoidUI.options.scoreboard_skills then name:set_h(self._h) name:set_y(0) else name:set_h(self._h / 2) name:set_y(2) end
				name:set_color(color)
				name:set_range_color(0, math.max(0, utf8.len(level)), Color.white:with_alpha(1))
				local size = (20 * self._scale)
				name:set_font_size(size)
				local name_w = select(3, name:text_rect())
				if name_w > name:w() then 
					name:set_font_size(size * (name:w()/name_w))
				end
				character_icon:set_image(tweak_data.blackmarket:get_character_icon(character_name or "dallas"))
				skills_text:set_visible(VoidUI.options.scoreboard_skills and not ai or false)
				perk_count:set_visible(not ai)
				hours:set_visible(not ai)
				skill_icon:set_visible(ai)
				secondary_icon:set_w(VoidUI.options.scoreboard_weapons and (ai and self._h * 0.8 or self._h * 1.8) or 0)
				secondary_icon:set_center_x(secondary_bg:center_x())
				ping:set_color(ai and Color.white or Color.green)
				if ai then 
					ping:set_text("AI") 
					self:sync_bot_loadout(character_name)
				elseif outfit then
					local texture, rarity = managers.blackmarket:get_weapon_icon_path(outfit.primary and outfit.primary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id) or "new_m4", VoidUI.options.scoreboard_skins > 1 and outfit.primary and outfit.primary.cosmetics)
					primary_icon:set_image(texture)
					primary_rarity:set_visible(VoidUI.options.scoreboard_skins == 2 and rarity and true or false)
					primary_rarity:set_image(rarity and rarity)
					primary_silencer:set_visible(managers.blackmarket:get_perks_from_weapon_blueprint(outfit.primary and outfit.primary.factory_id, outfit.primary and outfit.primary.blueprint)["silencer"] and true or false)
					texture, rarity = managers.blackmarket:get_weapon_icon_path(outfit.secondary and outfit.secondary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id) or "glock_17", VoidUI.options.scoreboard_skins > 1 and outfit.secondary and outfit.secondary.cosmetics)
					secondary_icon:set_image(texture)
					secondary_rarity:set_visible(VoidUI.options.scoreboard_skins == 2 and rarity and true or false)
					secondary_rarity:set_image(rarity and rarity)
					secondary_silencer:set_visible(managers.blackmarket:get_perks_from_weapon_blueprint(outfit.secondary and outfit.secondary.factory_id, outfit.secondary and outfit.secondary.blueprint)["silencer"] and true or false)
					melee_icon:set_image(self:get_melee_weapon(outfit.melee_weapon and outfit.melee_weapon or "weapon"))
					armor_icon:set_image("guis/textures/pd2/blackmarket/icons/armors/".. outfit.armor or "level_1")
					local skills = outfit and outfit.skills.skills
					if skills then
						skills_text:set_text(string.format("M:%02u %02u %02u  E:%02u %02u %02u  T:%02u %02u %02u  G:%02u %02u %02u  F:%02u %02u %02u", 
						skills[1] or "0", skills[2] or "0", skills[3] or "0",
						skills[4] or "0", skills[5] or "0", skills[6] or "0",
						skills[7] or "0", skills[8] or "0", skills[9] or "0",
						skills[10] or "0", skills[11] or "0", skills[12] or "0", 
						skills[13] or "0",skills[14] or "0", skills[15] or "0"))
						local skillpoints = 0
						for i = 1, #skills do
							skillpoints = skillpoints + skills[i]
						end
						skills_text:set_color(skillpoints > 120 and Color.red or Color.white)
						perk_count:set_text((outfit.skills.specializations[2] or "0") .. "/9")
						local icon, rect = tweak_data.hud_icons:get_texture("pd2_question")
						if tweak_data.skilltree.specializations[tonumber(outfit.skills.specializations[1])] then
							icon, rect = tweak_data.skilltree:get_specialization_icon_data(tonumber(outfit.skills.specializations[1]))							
						end
						perk_icon:set_image(icon, unpack(rect))	
					end
				end
			else
				self._taken = true
			end
		end
		
		function HUDScoreboard:sync_bot_loadout(character_name)
			local primary_icon = self._panel:child("primary_icon")
			local secondary_bg = self._panel:child("secondary_bg")
			local primary_rarity = self._panel:child("primary_rarity")
			local primary_silencer = self._panel:child("primary_silencer")
			local secondary_icon = self._panel:child("secondary_icon")
			local secondary_rarity = self._panel:child("secondary_rarity")
			local secondary_silencer = self._panel:child("secondary_silencer")
			local melee_icon = self._panel:child("melee_icon")
			local armor_icon = self._panel:child("armor_icon")
			local perk_icon = self._panel:child("perk_icon")
			local skill_icon = self._panel:child("skill_icon")
			local perk_count = self._panel:child("perk_count")
			
			local unit = managers.criminals:character_unit_by_name(character_name)
			if unit then
				local loadout = unit and unit:base() and unit:base()._loadout
				melee_icon:set_image(self:get_melee_weapon("weapon"))
				if loadout then
					local primary =	loadout.primary and managers.weapon_factory:get_weapon_id_by_factory_id(loadout.primary:gsub("_npc", "")) or (unit:inventory() and unit:inventory():equipped_unit() and unit:inventory():equipped_unit():base() and unit:inventory():equipped_unit():base()._factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(unit:inventory():equipped_unit():base()._factory_id:gsub("_npc","")))
					local texture, rarity = managers.blackmarket:get_weapon_icon_path(primary or "new_m4", VoidUI.options.scoreboard_skins > 1 and unit:inventory() and unit:inventory():equipped_unit():base() and {id = unit:inventory():equipped_unit():base()._cosmetics_id} or nil)
					primary_icon:set_image(texture)
					primary_rarity:set_visible(VoidUI.options.scoreboard_skins == 2 and rarity and true or false)
					primary_rarity:set_image(rarity and rarity)
					secondary_icon:set_image(managers.blackmarket:get_mask_icon(loadout.mask))
					armor_icon:set_image("guis/textures/pd2/blackmarket/icons/armors/".. (loadout.armor and loadout.armor or "level_1"))
					local ability = tweak_data.upgrades.crew_ability_definitions[loadout.ability]
					if ability then 
						local icon, rect = tweak_data.hud_icons:get_icon_data(ability.icon)
						perk_icon:set_image(icon, unpack(rect))	
					else
						perk_icon:set_image("guis/textures/pd2/add_icon")
					end

					local skill = tweak_data.upgrades.crew_skill_definitions[loadout.skill]
					if skill then 
						local icon, rect = tweak_data.hud_icons:get_icon_data(skill.icon)
						skill_icon:set_image(icon, unpack(rect))	
					else
						skill_icon:set_image("guis/textures/pd2/add_icon")
					end
				end
			end
		end
		
		function HUDScoreboard:get_hours(webpage)
			if not self._panel or not self._panel:child("hours") then
				return
			end
			
			local hours = self._panel:child("hours")
			local hours_played = managers.localization:text("VoidUI_error")
			hours:set_wrap(true)
			local start_pos = select(2, webpage:find("var rgGames =."))
			if start_pos then
				local tables = json.decode(webpage:sub(start_pos, webpage:find(".var rgChangingGames", start_pos)))
				if tables and #tables == 0 then
					hours_played = managers.localization:text("VoidUI_hidden")
				elseif tables and #tables > 0 then
					for i = 1, #tables do
						if tables[i].appid == 218620 then
							hours_played = tables[i].hours_forever:gsub(",", "") .. "h"
							hours:set_wrap(false)
						end
					end
				end
			elseif webpage:find("profile_private_info") then
				hours_played = managers.localization:text("VoidUI_private")
				hours:set_wrap(true)
			end
			hours:set_text(hours_played)
			local size = 15 * self._scale
			hours:set_font_size(size)
			local hours_w = select(3, hours:text_rect())
			if hours_w > hours:w() then
				hours:set_font_size(size * (hours:w()/ hours_w))
			end
		end
		function HUDScoreboard:set_ping(ping)
			local ping_text = self._panel:child("ping")
			local color = Color.green
			if ping > 200 then
				color = Color.red
			elseif ping > 100 then
				color = Color.yellow
			end
			ping_text:set_text(ping)
			ping_text:set_color(color)
		end
		
		function HUDScoreboard:add_stat(stat)
			local stat_count = self._panel:child(stat)
			if stat_count then
				stat_count:set_text(tonumber(stat_count:text()) + 1)	
			end
		end
		
		function HUDScoreboard:remove_panel()
			self._taken = false
			self._peer_id = nil
			self._ai = nil
			self._color_id = nil
			self._character = nil
			self._name = nil
			self._panel:child("name"):set_text("")
			self._panel:child("kills"):set_text("0")
			self._panel:child("specials"):set_text("0")
			self._panel:child("civs"):set_text("0")
			self._panel:child("downs"):set_text("0")
			self._panel:child("ping"):set_text("0")
			self._panel:child("primary_silencer"):set_visible(false)
			self._panel:child("secondary_silencer"):set_visible(false)
			self._panel:child("primary_rarity"):set_visible(false)
			self._panel:child("secondary_rarity"):set_visible(false)
		end
		
		function HUDScoreboard:get_melee_weapon(melee_weapon)
			local guis_catalog = "guis/"
			local bundle_folder = tweak_data.blackmarket.melee_weapons[melee_weapon] and tweak_data.blackmarket.melee_weapons[melee_weapon].texture_bundle_folder
			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end
			local melee_weapon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. tostring(melee_weapon)
			local melee_weapon_string = managers.localization:text(tweak_data.blackmarket.melee_weapons[melee_weapon].name_id)
			return melee_weapon_texture
		end
		
	elseif RequiredScript == "lib/units/enemies/cop/copdamage" and VoidUI.options.scoreboard then
		local on_damage_received = CopDamage._on_damage_received
		function CopDamage:_on_damage_received(damage_info)
			if self._dead then
				local special = managers.groupai:state():is_enemy_special(self._unit)
				managers.hud:scoreboard_unit_killed(damage_info.attacker_unit, special and "specials" or "kills")
			end
			on_damage_received(self, damage_info)
		end
		
	elseif RequiredScript == "lib/units/civilians/civiliandamage" and VoidUI.options.scoreboard then
		local on_damage_received = CivilianDamage._on_damage_received
		function CivilianDamage:_on_damage_received(damage_info)
			if self._dead then
				managers.hud:scoreboard_unit_killed(damage_info.attacker_unit, "civs")
			end
			on_damage_received(self, damage_info)
		end
	end
end