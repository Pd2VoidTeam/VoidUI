if RequiredScript == "lib/managers/hudmanager" then
	-- Assault Corner
	if VoidUI.options.enable_assault then		
		local sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
		function HUDManager:sync_start_anticipation_music()
			sync_start_anticipation_music(self)
			managers.hud:assault_anticipation()
		end
		
		show_endscreen_hud = HUDManager.show_endscreen_hud
		function HUDManager:show_endscreen_hud()
			show_endscreen_hud(self)
			self._hud_assault_corner:stop_ecm()
		end
	end
	
	function HUDManager:setup_anticipation(total_t)
		local exists = self._anticipation_dialogs and true or false
		self._anticipation_dialogs = {}
		
		if not VoidUI.options.assault_lines == 1 then
			return
		end
		if not exists and total_t == 30 then
			if VoidUI.options.assault_lines == 3 then
				table.insert(self._anticipation_dialogs, {time = 30, dialog = 2})
				table.insert(self._anticipation_dialogs, {time = 20, dialog = 3})
				table.insert(self._anticipation_dialogs, {time = 10, dialog = 4})
			elseif VoidUI.options.assault_lines == 2 then
				table.insert(self._anticipation_dialogs, {time = 30, dialog = 2})
			end
		elseif exists and total_t == 30 then
			if VoidUI.options.assault_lines == 3 then
				table.insert(self._anticipation_dialogs, {time = 30, dialog = 6})
				table.insert(self._anticipation_dialogs, {time = 20, dialog = 7})
				table.insert(self._anticipation_dialogs, {time = 10, dialog = 8})
			elseif VoidUI.options.assault_lines == 2 then
				table.insert(self._anticipation_dialogs, {time = 30, dialog = 6})
			end
		end
	end
	
	local add_waypoint = HUDManager.add_waypoint
	function HUDManager:add_waypoint(id, data)
		add_waypoint(self, id, data)
		
		if self._hud.waypoints[id] then
			local scale = VoidUI.options.waypoint_scale
			local bitmap = self._hud.waypoints[id].bitmap
			local arrow = self._hud.waypoints[id].arrow
			local distance = self._hud.waypoints[id].distance
			local text = self._hud.waypoints[id].text
			local timer = self._hud.waypoints[id].timer_gui
			
			bitmap:set_size(bitmap:w() * scale, bitmap:h() * scale)
			arrow:set_size(arrow:w() * scale, arrow:h() * scale)
			text:set_font_size(text:font_size() * scale)
			text:set_size(text:w() * scale, text:h() * scale)
			self._hud.waypoints[id].size = Vector3(bitmap:w(), bitmap:h(), 0)
			self._hud.waypoints[id].radius = VoidUI.options.waypoint_radius
			
			if data.distance then
				distance:set_font_size(distance:font_size() * scale)
				distance:set_size(distance:w() * scale, distance:h() * scale)
			end
			if data.timer then
				timer:set_size(timer:w() * scale, timer:h() * scale)
				timer:set_font_size(timer:font_size() * scale)
			end
		end
	end
	
	local change_waypoint_icon = HUDManager.change_waypoint_icon
	function HUDManager:change_waypoint_icon(id, icon)
		change_waypoint_icon(self, id, icon)
		
		if self._hud.waypoints[id] then
			local scale = VoidUI.options.waypoint_scale
			local bitmap = self._hud.waypoints[id].bitmap
			bitmap:set_size(bitmap:w() * scale, bitmap:h() * scale)
			self._hud.waypoints[id].size = Vector3(bitmap:w(), bitmap:h(), 0)
		end
	end
	
	local update_waypoints = HUDManager._update_waypoints
	function HUDManager:_update_waypoints(t, dt)
		update_waypoints(self, t, dt)
		local cam = managers.viewport:get_current_camera()
		if not cam then
			return
		end
		
		local wp_pos = Vector3()
		local wp_onscreen_direction = Vector3()
		
		for id, data in pairs(self._hud.waypoints) do
			if data.state == "offscreen" then
					local panel = data.bitmap:parent()
					mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
					local show = VoidUI.options.label_waypoint_offscreen
					data.bitmap:set_visible(show)
					data.arrow:set_visible(show)
					data.text:set_visible(show)
					
					local direction = wp_onscreen_direction
					local panel_center_x, panel_center_y = panel:center()
					local scale = VoidUI.options.waypoint_scale
					mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
					mvector3.normalize(direction)
					data.arrow:set_center(mvector3.x(data.current_position) + direction.x * (24 * scale), mvector3.y(data.current_position) + direction.y * (24 * scale))
			elseif data.state == "onscreen" and not VoidUI.options.label_waypoint_offscreen then
				data.bitmap:set_visible(true)
				data.text:set_visible(true)
			end
		end
	end
	
	-- Name Labels
	if VoidUI.options.enable_labels then
		function HUDManager:update_name_label_by_peer(peer)
			for _, data in pairs(self._hud.name_labels) do
				if data.peer_id == peer:id() then
					local name = data.character_name
					local experience = ""
					if peer:level() then
						experience = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "Ї" or "") .. peer:level() .. " "
						name =  experience .. (VoidUI.options.label_upper and utf8.to_upper(name) or name)
					end
					data.text:set_text(name)
					data.text:set_range_color(0, utf8.len(experience), Color.white) 
					self:align_teammate_name_label(data.panel, data.interact)
				else
				end
			end
		end

		function HUDManager:update_vehicle_label_by_id(label_id, num_players)
			for _, data in pairs(self._hud.name_labels) do
				if data.id == label_id then
					local name = VoidUI.options.label_upper and utf8.to_upper(data.character_name) or data.character_name
					if num_players > 0 then
						name = name.." (" .. num_players .. ")"
					end
					data.text:set_text(name)
					data.panel:child("extended_panel"):child("text_shadow"):set_text(name)
					data.minmode_panel:child("text"):set_text(name)
					data.minmode_panel:child("text_shadow"):set_text(name)
					self:align_teammate_name_label(data.panel, data.interact)
				else
				end
			end
		end
	
		local update_name_labels = HUDManager._update_name_labels
		function HUDManager:_update_name_labels(t, dt)	
			local cam = managers.viewport:get_current_camera()
			if not cam then
				return
			end
			update_name_labels(self, t, dt)
			
			local nl_w_pos = Vector3()
			local nl_dir = Vector3()
			local nl_dir_normalized = Vector3()
			local nl_cam_forward = Vector3()
			local cam_pos = managers.viewport:get_current_camera_position()
			local cam_rot = managers.viewport:get_current_camera_rotation()
			mrotation.y(cam_rot, nl_cam_forward)
			
			for _, data in ipairs(self._hud.name_labels) do
				local pos
				if data.movement then
					if alive(data.movement._unit) then
						pos = data.movement:m_pos()
						mvector3.set(nl_w_pos, pos)
						mvector3.set_z(nl_w_pos, mvector3.z(data.movement:m_head_pos()) + 30)
					end
				elseif data.vehicle then
					if not alive(data.vehicle) then
						return
					end
					pos = data.vehicle:position()
					mvector3.set(nl_w_pos, pos)
					mvector3.set_z(nl_w_pos, pos.z + data.vehicle:vehicle_driving().hud_label_offset)
				end
				if VoidUI.options.label_minmode and pos then
					mvector3.set(nl_dir, nl_w_pos)
					mvector3.subtract(nl_dir, cam_pos)
					mvector3.set(nl_dir_normalized, nl_dir)
					mvector3.normalize(nl_dir_normalized)
					
					local dot = mvector3.dot(nl_cam_forward, nl_dir_normalized)
					local unit = data.vehicle and data.vehicle or data.movement._unit and data.movement._unit
					local dis = alive(unit) and mvector3.distance(unit:position(), cam_pos) or 0
					local label_panel = data.panel
					if math.ceil(dis / 100) > VoidUI.options.label_minmode_dist and math.clamp((1 - dot) * 100, 0, VoidUI.options.label_minmode_dot) == VoidUI.options.label_minmode_dot then
						label_panel:child("minmode_panel"):set_visible(true)
						label_panel:child("extended_panel"):set_visible(false)
					else
						label_panel:child("minmode_panel"):set_visible(false)
						label_panel:child("extended_panel"):set_visible(true)
					end
				else
					data.panel:child("minmode_panel"):set_visible(false)
					data.panel:child("extended_panel"):set_visible(true)
				end
			end
		end
	end
	
	--Stat Panel
	if VoidUI.options.scoreboard and VoidUI.options.enable_stats then
		local reset_player_hpbar = HUDManager.reset_player_hpbar
		function HUDManager:reset_player_hpbar()
			reset_player_hpbar(self)
			local character_name = managers.criminals:local_character_name()
			local crim_entry = managers.criminals:character_static_data_by_name(character_name)
			if self._hud_statsscreen and self._hud_statsscreen._scoreboard_panels[HUDManager.PLAYER_PANEL] then
				self._hud_statsscreen._scoreboard_panels[HUDManager.PLAYER_PANEL]:set_player(character_name, managers.network:session():local_peer():name(), false, managers.network:session():local_peer():id())
			end
		end
		local setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2
		function HUDManager:_setup_player_info_hud_pd2()
			setup_player_info_hud_pd2(self)
			if not self._hud_statsscreen then
				self:_setup_stats_screen()
				self:show_stats_screen()
				self:hide_stats_screen()
			end
		end
		
		local update = HUDManager.update
		function HUDManager:update(t, dt)
			update(self, t, dt)
			self._last_sc_update = self._last_sc_update or t
			local peers = managers.network:session() and managers.network:session():peers()
			if self._hud_statsscreen and peers and self._last_sc_update + VoidUI.options.ping_frequency < t then
				self._last_sc_update = t
				for _, peer in pairs(peers) do
					if peer and peer:id() and peer:rpc() then
						local panel = self._hud_statsscreen:get_scoreboard_panel_by_peer_id(peer:id())
						if panel then panel:set_ping(math.floor(Network:qos(peer:rpc()).ping)) end
					end
				end
			end
		end
	end
	
	-- Player and Teammate Panels
	if VoidUI.options.teammate_panels then
		local show = HUDManager.show
		function HUDManager:show(name)
			show(self, name)
			if name == PlayerBase.PLAYER_DOWNED_HUD and self._teammate_panels[HUDManager.PLAYER_PANEL] then
				local health_panel = self._teammate_panels[HUDManager.PLAYER_PANEL]._custom_player_panel:child("health_panel")
				health_panel:child("armor_value"):hide()
				health_panel:child("health_value"):hide()
				health_panel:child("health_bar"):hide()
			end
		end
		
		local hide = HUDManager.hide
		function HUDManager:hide(name)
			hide(self, name)
			if name == PlayerBase.PLAYER_DOWNED_HUD and self._teammate_panels[HUDManager.PLAYER_PANEL] then
				local health_panel = self._teammate_panels[HUDManager.PLAYER_PANEL]._custom_player_panel:child("health_panel")
				health_panel:child("armor_value"):show()
				health_panel:child("health_value"):show()
				health_panel:child("health_bar"):show()
			end
		end
		
		function HUDManager:pd_start_timer(data)
			local hud = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD)
			hud.unpause_timer()
			if self._hud_player_downed then
				self._hud_player_downed:start_timer(data.time or 10)
			end
		end
	end
	
	--Interaction Panel
	if VoidUI.options.enable_interact then
		function HUDManager:pd_start_progress(current, total, msg, icon_id)
			if not self._hud_interaction then
				return
			end
			self._hud_interaction:show_interaction_bar(current, total)
			self._hud_player_downed:hide_timer()
			local function feed_circle(o, total)
				local t = 0
				while total > t do
					t = t + coroutine.yield()
					self._hud_interaction:set_interaction_bar_width(t, total)
					self._hud_interaction:show_interact({text = utf8.to_upper(managers.localization:text(msg))})
				end
				self._hud_interaction:remove_interact()
				self._hud_interaction:hide_interaction_bar(true)
			end
			self._hud_interaction._interact_bar:stop()
			self._hud_interaction._interact_bar:animate(feed_circle, total)
		end
		
		function HUDManager:pd_stop_progress()
			if not self._hud_interaction then
				return
			end
			self._hud_interaction:remove_interact()
			self._hud_interaction:hide_interaction_bar(false)
			self._hud_player_downed:show_timer()
		end
	end

	
elseif RequiredScript == "lib/managers/hudmanagerpd2" then
	
	if VoidUI.options.teammate_panels or VoidUI.options.enable_labels then 
		local set_ai_stopped = HUDManager.set_ai_stopped
		function HUDManager:set_ai_stopped(ai_id, stopped)
			set_ai_stopped(self, ai_id, stopped)
			local teammate_panel = self._teammate_panels[ai_id]
			if not teammate_panel or stopped and not teammate_panel._ai then
				return
			end
			local panel = teammate_panel._panel:child("custom_player_panel") and teammate_panel._panel:child("custom_player_panel"):child("health_panel")
			local name = panel and teammate_panel._panel:child("custom_player_panel"):child("name") and string.gsub(teammate_panel._panel:child("custom_player_panel"):child("name"):text(), "%W", "") or (teammate_panel._panel:child("name") and string.gsub(teammate_panel._panel:child("name"):text(), "%W", ""))
			local label
			for _, lbl in ipairs(self._hud.name_labels) do
				if string.gsub(lbl.character_name, "%W", "") == name then
					label = lbl
					break
				end
			end
			if stopped then
				if panel then
					local downs_value = panel:child("downs_value")
					local stop_icon = panel:bitmap({
						name = "stopped",
						texture = tweak_data.hud_icons.ai_stopped.texture,
						texture_rect = tweak_data.hud_icons.ai_stopped.texture_rect,
						layer = 6
					})
					stop_icon:set_w(downs_value:w() / 2.2)
					stop_icon:set_h(downs_value:h() / 1.3)
					stop_icon:set_center_x(downs_value:center_x())
					stop_icon:set_top(downs_value:top())
				end
				if label and label.panel:child("extended_panel") then
					local label_stop_icon = label.panel:child("extended_panel"):bitmap({
						name = "stopped",
						texture = tweak_data.hud_icons.ai_stopped.texture,
						texture_rect = tweak_data.hud_icons.ai_stopped.texture_rect,
						rotation = 360
					})
					label_stop_icon:set_right(label.text:left())
					label_stop_icon:set_center_y(label.text:center_y())
				end
			else
				if panel and panel:child("stopped") then
					panel:remove(panel:child("stopped"))
				end
				if label and label.panel:child("extended_panel") and label.panel:child("extended_panel"):child("stopped") then
					label.panel:child("extended_panel"):remove(label.panel:child("extended_panel"):child("stopped"))
				end
			end
		end
		
		function HUDManager:teammate_progress(peer_id, type_index, enabled, tweak_data_id, timer, success)
			local name_label = self:_name_label_by_peer_id(peer_id)
			if name_label then
				name_label.interact:set_visible(enabled)
				if name_label.panel:child("extended_panel") then
					name_label.panel:child("extended_panel"):child("action"):set_visible(enabled)
					name_label.panel:child("extended_panel"):child("interact_bg"):set_visible(enabled)
					name_label.panel:child("minmode_panel"):child("min_interact"):set_visible(enabled)
					name_label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(enabled)
				else
					name_label.panel:child("action"):set_visible(enabled)
				end
				local action_text = ""
				if type_index == 1 then
					action_text = managers.localization:text(tweak_data.interaction[tweak_data_id].action_text_id or "hud_action_generic")
				elseif type_index == 2 then
					if enabled then
						local equipment_name = managers.localization:text(tweak_data.equipments[tweak_data_id].text_id)
						local deploying_text = tweak_data.equipments[tweak_data_id].deploying_text_id and managers.localization:text(tweak_data.equipments[tweak_data_id].deploying_text_id) or false
						action_text = deploying_text or managers.localization:text("hud_deploying_equipment", {EQUIPMENT = equipment_name})
					end
				elseif type_index == 3 then
					action_text = managers.localization:text("hud_starting_heist")
				end
				if name_label.panel:child("extended_panel") then
					name_label.panel:child("extended_panel"):child("action"):set_text(action_text .. string.format(" (%.1fs)", timer))
					name_label.panel:child("extended_panel"):stop()
				else
					name_label.panel:child("action"):set_text(utf8.to_upper(action_text))
					name_label.panel:stop()
				end
				if enabled and name_label.panel:child("extended_panel") then
					name_label.panel:animate(callback(self, self, "_animate_label_interact_custom"), name_label.interact, name_label.panel:child("minmode_panel"):child("min_interact"), name_label.panel:child("extended_panel"):child("interact_bg"), name_label.panel:child("minmode_panel"):child("min_interact_bg"), name_label.panel:child("extended_panel"):child("action"), action_text, timer)
				elseif enabled and not name_label.panel:child("extended_panel") then
					name_label.panel:animate(callback(self, self, "_animate_label_interact"), name_label.interact, timer)
				elseif success and name_label.panel:child("extended_panel") then
					local panel = name_label.panel
					local bar = panel:bitmap({
						layer = 0,
					})
					bar:set_size(name_label.interact:size())
					bar:set_position(name_label.interact:position())
					bar:set_color(name_label.interact:color())
					bar:animate(callback(self, self, "_animate_interaction_complete"), panel)
				elseif success and not name_label.panel:child("extended_panel") then
					local panel = name_label.panel
					local bitmap = panel:bitmap({
						blend_mode = "add",
						texture = "guis/textures/pd2/hud_progress_active",
						layer = 2,
						align = "center",
						rotation = 360,
						valign = "center"
					})

					bitmap:set_size(name_label.interact:size())
					bitmap:set_position(name_label.interact:position())

					local radius = name_label.interact:radius()
					local circle = CircleBitmapGuiObject:new(panel, {
						blend_mode = "normal",
						rotation = 360,
						layer = 3,
						radius = radius,
						color = Color.white:with_alpha(1)
					})

					circle:set_position(name_label.interact:position())
					bitmap:animate(callback(HUDInteraction, HUDInteraction, "_animate_interaction_complete"), circle)
				end
			end
			
			local character_data = managers.criminals:character_data_by_peer_id(peer_id)
			if character_data and self._teammate_panels[character_data.panel_id]._custom_player_panel then
				self._teammate_panels[character_data.panel_id]:teammate_progress(enabled, type_index, tweak_data_id, timer, success)
			elseif character_data and not self._teammate_panels[character_data.panel_id]._custom_player_panel then 
				self._teammate_panels[character_data.panel_id]:teammate_progress(enabled, tweak_data_id, timer, success)
			end
		end
		function HUDManager:_animate_interaction_complete(bar, panel)
			local center_x = bar:center_x()
			local w = bar:w()
			local t = 0
			local TOTAL_T = 0.2
			while t < TOTAL_T do
				local dt = coroutine.yield()
				t = t + dt
				bar:set_w(math.lerp(w, 0, t / TOTAL_T))
				bar:set_center_x(center_x)
			end
			bar:set_w(0)
			panel:remove(bar)
		end
	end
	
	--Player and Teammate Panels
	if VoidUI.options.teammate_panels then 
		function HUDManager:teampanels_height()
			return 300
		end
		
		local create_teammates_panel = HUDManager._create_teammates_panel
		function HUDManager:_create_teammates_panel(...)
			self._main_scale = VoidUI.options.hud_main_scale
			self._mate_scale = VoidUI.options.hud_mate_scale
			create_teammates_panel(self, ...)
			self:align_teammate_panels()
		end
		
		function HUDManager:align_teammate_panels()
			for i, data in ipairs(self._hud.teammate_panels_data) do
				local panel = self._teammate_panels[i]
				if i == HUDManager.PLAYER_PANEL then
					panel._panel:set_w(220 * self._main_scale)
					panel._panel:set_right(panel._panel:parent():right())
				else
					if panel:is_waiting() then panel._panel:set_w(165 * self._mate_scale)
					elseif panel:ai() or panel:panel():child("custom_player_panel"):child("weapons_panel"):visible() == false then panel._panel:set_w(62 * self._mate_scale)
					elseif panel:peer_id() then panel._panel:set_w(165 * self._mate_scale)
					else panel._panel:set_w(0) end
					panel._panel:set_x(i == 1 and 0 or self._teammate_panels[i - 1]._panel:right() -  9 * self._mate_scale)
				end
			end
		end	

		local ext_inventory_changed = HUDManager.on_ext_inventory_changed
		function HUDManager:on_ext_inventory_changed()
			if self._teammate_panels[HUDManager.PLAYER_PANEL] then
				self._teammate_panels[HUDManager.PLAYER_PANEL]:set_bodybags()
				self._teammate_panels[HUDManager.PLAYER_PANEL]:set_info_visible()
			end
			ext_inventory_changed(self)
		end

		function HUDManager:hide_player_gear(panel_id)
			if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
				local player_panel = self._teammate_panels[panel_id]:panel():child("custom_player_panel")
				player_panel:child("weapons_panel"):set_visible(false)
				self:align_teammate_panels()

			end
		end
		function HUDManager:show_player_gear(panel_id)
			if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
				local player_panel = self._teammate_panels[panel_id]:panel():child("custom_player_panel")
				player_panel:child("weapons_panel"):set_visible(true)
				self:align_teammate_panels()
			end
		end	
		
		HUDManager.set_teammate_ability_color = HUDManager.set_teammate_ability_color or function(self, i, color)
			self._teammate_panels[i]:set_ability_color(color)
		end		
	end		
	
	if VoidUI.options.teammate_panels or (VoidUI.options.scoreboard and VoidUI.options.enable_stats) then	
		HUDManager.player_downed = HUDManager.player_downed or function(self, i)
			if self._teammate_panels and self._teammate_panels[i].downed then
				self._teammate_panels[i]:downed()
			end
			if self._hud_statsscreen and self._hud_statsscreen._scoreboard_panels then
				self._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
			end
		end

		HUDManager.player_reset_downs = HUDManager.player_reset_downs or function(self, i)
			if self._teammate_panels and self._teammate_panels[i].reset_downs then
				self._teammate_panels[i]:reset_downs()
			end
		end
	end
	
	--Stat Screen and Scoreboard
	if VoidUI.options.scoreboard and VoidUI.options.enable_stats then
		local add_teammate_panel = HUDManager.add_teammate_panel
		function HUDManager:add_teammate_panel(character_name, player_name, ai, peer_id)
			local add_panel = add_teammate_panel(self, character_name, player_name, ai, peer_id)
			self._hud_statsscreen:add_scoreboard_panel(character_name, player_name, ai, peer_id)
			return add_panel
		end
		
		function HUDManager:scoreboard_unit_killed(killer_unit, stat)
			
			if alive(killer_unit) and killer_unit:base() and self._hud_statsscreen  then
				if killer_unit:base().thrower_unit then
					killer_unit = killer_unit:base():thrower_unit()
				elseif killer_unit:base().sentry_gun then
					killer_unit = killer_unit:base():get_owner()
				end
				if killer_unit == nil then return end
				
				local character_data = managers.criminals:character_data_by_unit(killer_unit)
				if character_data then
					local panel_id = (managers.criminals:character_peer_id_by_unit(killer_unit) == managers.network:session():local_peer():id() and HUDManager.PLAYER_PANEL) or (character_data and character_data.panel_id and character_data.panel_id)
					self._hud_statsscreen._scoreboard_panels[panel_id]:add_stat(stat)
					if stat == "civs" or (stat == "specials" and VoidUI.options.scoreboard_kills == 3) then self._hud_statsscreen._scoreboard_panels[panel_id]:add_stat("kills") end
				end
			end
		end
		
		function HUDManager:remove_teammate_scoreboard_panel(id)
			if self._hud_statsscreen then
				self._hud_statsscreen:remove_scoreboard_panel(id)
			end
		end
		
		local remove_teammate_panel = HUDManager.remove_teammate_panel
		function HUDManager:remove_teammate_panel(id)
			self._hud_statsscreen:free_scoreboard_panel(id)
			remove_teammate_panel(self, id)
		end
	end	

	--Assault Corner
	if VoidUI.options.enable_assault then
		HUDManager.assault_anticipation = HUDManager.assault_anticipation or function(self)
			if self._hud_assault_corner then
				self._hud_assault_corner:set_assault_phase()
			end
		end
		
		HUDManager.add_ecm_timer = HUDManager.add_ecm_timer or function(self, unit)
			if unit and unit:base():battery_life() then
				self._jammers = self._jammers or {}
				table.insert(self._jammers, unit)
				self:start_ecm_timer()
			end
		end
		
		HUDManager.start_ecm_timer = HUDManager.start_ecm_timer or function(self)		
			if self._hud_assault_corner and self._jammers and #self._jammers > 0 then
				self._hud_assault_corner:ecm_timer(self._jammers[VoidUI.options.jammers == 2 and 1 or #managers.hud._jammers]:base():battery_life())
			end
		end

		HUDManager.pager_used = HUDManager.pager_used or function(self)
			if self._hud_assault_corner then
				self._hud_assault_corner:pager_used()
			end
		end
	end
	
	--Name Labels
	if VoidUI.options.enable_labels then
		function HUDManager:_animate_label_interact_custom(panel, interact, minmode_interact, interact_bg, minmode_bg, action, action_text, timer)
			local t = 0
			interact:set_x(interact_bg:x())
			while timer >= t do
				local dt = coroutine.yield()
				t = t + dt
				interact:set_w(math.lerp(0, interact_bg:w(), t / timer))
				minmode_interact:set_w(math.lerp(0, minmode_bg:w(), t / timer))
				action:set_text(action_text .. string.format(" (%.1fs)", math.clamp(timer - t, 0, timer)))
			end
			interact:set_w(interact_bg:w())
		end

		function HUDManager:_add_name_label(data)
			data.name = VoidUI.options.label_upper and utf8.to_upper(data.name) or data.name
			local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)		
			local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
			local id = last_id + 1
			local large_scale = VoidUI.options.label_scale
			local min_scale = VoidUI.options.label_minscale
			local character_name = data.name
			local rank = 0
			local peer_id
			local is_husk_player = data.unit:base().is_husk_player
			local experience = ""
			local color_id = managers.criminals:character_color_id_by_unit(data.owner_unit and data.owner_unit or data.unit)
			local crim_color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
			if is_husk_player then
				peer_id = data.unit:network():peer():id()
				local level = data.unit:network():peer():level()
				rank = data.unit:network():peer():rank()
				if level then
					experience = (rank > 0 and managers.experience:rank_string(rank) .. "Ї" or "") .. level .. " "
					data.name = experience .. data.name
				end
			end
			local panel = hud.panel:panel({
				name = "name_label" .. id
			})
			panel:text({
				name = "cheater",
				text = managers.localization:text("menu_hud_cheater"),
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 1.3,
				color = tweak_data.screen_colors.pro_color,
				align = "center",
				layer = -1,
				visible = false,
				w = 256,
				h = 18
			})
			local text = panel:text({
				name = "text",
				text = "",
				font = tweak_data.hud.medium_font,
				font_size = 0,
				w = 32,
				h = 0
			})
			local extended_panel = panel:panel({
				name = "extended_panel"
			})
			local interact = extended_panel:bitmap({
				h = 2 * large_scale,
				layer = 0,
				visible = false,
				color = crim_color
			})
			local interact_bg = extended_panel:bitmap({
				name = "interact_bg",
				h = 2 * large_scale,
				color = Color.black,
				visible = false,
				layer = -1
			})
			local text = extended_panel:text({
				name = "text",
				text = data.name,
				font = tweak_data.hud.medium_font,
				font_size = (tweak_data.hud.name_label_font_size / 1.2) * large_scale,
				color = crim_color,
				align = "center",
				vertical = "top",
				layer = -1,
				w = 256 * large_scale,
				h = 18 * large_scale
			})
			text:set_range_color(0, utf8.len(experience), Color.white) 
			local text_shadow = extended_panel:text({
				name = "text_shadow",
				text = data.name,
				font = tweak_data.hud.medium_font,
				font_size = (tweak_data.hud.name_label_font_size / 1.2) * large_scale,
				color = Color.black,
				align = "center",
				vertical = "top",
				layer = -2,
				w = 256,
				h = 18,
				x = 1,
				y = 1,
			})
			
			local bag = extended_panel:bitmap({
				name = "bag",
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {2, 34, 20, 17},
				layer = 0,
				color = crim_color,
				visible = false,
				x = 1,
				y = 1,
				rotation = 360
			})
			extended_panel:text({
				name = "action",
				rotation = 360,
				text = "Fixing",
				font = "fonts/font_medium_shadow_mf",
				font_size = (tweak_data.hud.name_label_font_size / 1.3) * large_scale,
				color = crim_color,
				align = "center",
				vertical = "bottom",
				layer = -1,
				visible = false,
				w = 256,
				h = 18
			})
			local minmode_panel = panel:panel({
				name = "minmode_panel"
			})
			local min_text = minmode_panel:text({
				name = "text",
				text = VoidUI.options.label_minrank and data.name or character_name,
				font = tweak_data.hud.medium_font,
				font_size = (tweak_data.hud.name_label_font_size / 2) * min_scale,
				color = crim_color,
				align = "center",
				vertical = "top",
				layer = -1,
				w = 100,
				h = 18
			})
			min_text:set_range_color(0, VoidUI.options.label_minrank and utf8.len(experience) or 0, Color.white) 
			local min_text_shadow = minmode_panel:text({
				name = "text_shadow",
				text = VoidUI.options.label_minrank and data.name or character_name,
				font = tweak_data.hud.medium_font,
				font_size = (tweak_data.hud.name_label_font_size / 2) * min_scale,
				color = Color.black,
				align = "center",
				vertical = "top",
				layer = -2,
				w = 100,
				h = 18,
				x = 1,
				y = 1,
			})
			local min_interact = minmode_panel:bitmap({
				name = "min_interact",
				h = 2 * min_scale,
				layer = 0,
				visible = false,
				color = crim_color
			})
			local min_interact_bg = minmode_panel:bitmap({
				name = "min_interact_bg",
				h = 2 * min_scale,
				color = Color.black,
				visible = false,
				layer = -1,
				rotation = 360
			})
			local min_bag = minmode_panel:bitmap({
				name = "min_bag",
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {2, 34, 20, 17},
				layer = 0,
				color = crim_color,
				visible = false,
				x = 1,
				y = 1,
				rotation = 360
			})
			
			self:align_teammate_name_label(panel, interact)
			table.insert(self._hud.name_labels, {
				movement = data.unit:movement(),
				panel = panel,
				minmode_panel = minmode_panel,
				text = text,
				id = id,
				peer_id = peer_id,
				character_name = character_name,
				experience = experience,
				interact = interact,
				interact_bg = interact_bg,
				bag = bag
			})
			return id
		end

		function HUDManager:align_teammate_name_label(panel, interact, experience)
			local minmode_panel = panel:child("minmode_panel")
			local extended_panel = panel:child("extended_panel")
			local min_text = minmode_panel:child("text")
			local min_text_shadow = minmode_panel:child("text_shadow")
			local text = extended_panel:child("text")
			local text_shadow = extended_panel:child("text_shadow")
			local action = extended_panel:child("action")
			local bag = extended_panel:child("bag")
			local min_bag = minmode_panel:child("min_bag")
			local bag_number = extended_panel:child("bag_number")
			local min_bag_number = minmode_panel:child("min_bag_number")
			local cheater = panel:child("cheater")
			local interact_bg = extended_panel:child("interact_bg")
			local min_interact = minmode_panel:child("min_interact")
			local min_interact_bg = minmode_panel:child("min_interact_bg")
			local _, _, tw, th = text:text_rect()
			local _, _, aw, ah = action:text_rect()
			local _, _, cw, ch = cheater:text_rect()
			local _, _, mtw, mth = min_text:text_rect()
			
			panel:set_size(math.max(tw, cw, aw, mtw) + 4, th + ah + ch)
			cheater:set_size(panel:w(), ch)
			cheater:set_position(0, 0)
			
			extended_panel:set_size(panel:w(), panel:h())
			text:set_size(panel:w(), th)
			text_shadow:set_size(panel:w(), th)
			text_shadow:set_x(1)
			text:set_top(cheater:bottom())
			text_shadow:set_y(text:y() + 1)
			interact:set_w(tw)
			interact_bg:set_w(interact:w())
			interact:set_center_x(text:center_x())
			interact_bg:set_center_x(interact:center_x())
			interact:set_bottom(text_shadow:bottom())
			interact_bg:set_y(interact:y())
			action:set_size(panel:w(), ah)
			action:set_y(interact:bottom())
			bag:set_size(th, th * 0.8)
			bag:set_right(0)
			bag:set_center_y(text:center_y())
			panel:child("text"):set_x(panel:x())
			panel:child("text"):set_center_y(text:center_y())
			if bag_number then
				bag_number:set_size(bag:w(), bag:h())
				bag_number:set_center(bag:center())
			end
			
			minmode_panel:set_size(panel:w(), mth + 1)
			minmode_panel:set_bottom(text:bottom())
			min_text:set_size(mtw, mth)
			min_text_shadow:set_size(mtw, mth)
			min_text:set_center_x(minmode_panel:center_x())
			min_text_shadow:set_x(min_text:x() + 1)
			min_text:set_y(0)
			min_text_shadow:set_y(1)
			min_interact:set_w(mtw)
			min_interact_bg:set_w(min_interact:w())
			min_interact:set_center_x(min_text:center_x())
			min_interact_bg:set_center_x(interact:center_x())
			min_interact:set_bottom(min_text:bottom() + 1)
			min_interact_bg:set_y(min_interact:y())
			min_bag:set_size(mth, mth * 0.8)
			min_bag:set_right(min_text:left() - 2)
			min_bag:set_center_y(min_text:center_y())
			if min_bag_number then
				min_bag_number:set_size(min_bag:w(), min_bag:h())
				min_bag_number:set_center(min_bag:center())
			end
		end

		function HUDManager:add_vehicle_name_label(data)
			data.name = VoidUI.options.label_upper and utf8.to_upper(data.name) or data.name
			local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
			local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
			local id = last_id + 1
			local vehicle_name = data.name
			local crim_color = tweak_data.chat_colors[#tweak_data.chat_colors]
			local panel = hud.panel:panel({
				name = "name_label" .. id
			})
			panel:text({
				name = "cheater",
				text = managers.localization:text("menu_hud_cheater"),
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 1.3,
				color = tweak_data.screen_colors.pro_color,
				align = "center",
				layer = -1,
				visible = false,
				w = 256,
				h = 18
			})
			panel:text({
				name = "text",
				text = "",
				font = tweak_data.hud.medium_font,
				font_size = 0,
				w = 32,
				h = 0
			})
			local extended_panel = panel:panel({
				name = "extended_panel"
			})
			local interact = extended_panel:bitmap({
				h = 2,
				layer = 0,
				visible = false,
				color = crim_color
			})
			local interact_bg = extended_panel:bitmap({
				name = "interact_bg",
				h = 2,
				color = Color.black,
				visible = false,
				layer = -1
			})
			local text = extended_panel:text({
				name = "text",
				text = vehicle_name,
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 1.2,
				color = crim_color,
				align = "center",
				vertical = "top",
				layer = -1,
				w = 256,
				h = 18
			})
			text:set_range_color(0, utf8.len(experience), Color.white) 
			local text_shadow = extended_panel:text({
				name = "text_shadow",
				text = vehicle_name,
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 1.2,
				color = Color.black,
				align = "center",
				vertical = "top",
				layer = -2,
				w = 256,
				h = 18,
				x = 1,
				y = 1,
			})
			
			local bag = extended_panel:bitmap({
				name = "bag",
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {2, 34, 20, 17},
				layer = 0,
				color = crim_color,
				visible = false,
				x = 1,
				y = 1,
				alpha = 0.5,
				rotation = 360
			})
			local bag_number = extended_panel:text({
				name = "bag_number",
				visible = false,
				text = utf8.to_upper(""),
				font = "fonts/font_medium_shadow_mf",
				font_size = tweak_data.hud.small_name_label_font_size,
				color = Color.white,
				align = "center",
				vertical = "center",
				layer = 1,
				w = bag:w(),
				h = bag:h(),
				rotation = 360
			})
			extended_panel:text({
				name = "action",
				rotation = 360,
				text = "Fixing",
				font = "fonts/font_medium_shadow_mf",
				font_size = tweak_data.hud.name_label_font_size / 1.3,
				color = crim_color,
				align = "center",
				vertical = "bottom",
				layer = -1,
				visible = false,
				w = 256,
				h = 18
			})
			local minmode_panel = panel:panel({
				name = "minmode_panel"
			})
			local min_text = minmode_panel:text({
				name = "text",
				text = vehicle_name,
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 2,
				color = crim_color,
				align = "center",
				vertical = "top",
				layer = -1,
				w = 100,
				h = 18
			})
			local min_text_shadow = minmode_panel:text({
				name = "text_shadow",
				text = vehicle_name,
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.name_label_font_size / 2,
				color = Color.black,
				align = "center",
				vertical = "top",
				layer = -2,
				w = 100,
				h = 18,
				x = 1,
				y = 1,
			})
			local min_interact = minmode_panel:bitmap({
				name = "min_interact",
				h = 1,
				layer = 0,
				visible = false,
				color = crim_color
			})
			local min_interact_bg = minmode_panel:bitmap({
				name = "min_interact_bg",
				h = 1,
				color = Color.black,
				visible = false,
				layer = -1
			})
			local min_bag = minmode_panel:bitmap({
				name = "min_bag",
				texture = "guis/textures/pd2/hud_tabs",
				texture_rect = {2, 34, 20, 17},
				layer = 0,
				color = crim_color,
				visible = false,
				x = 1,
				y = 1,
				alpha = 0.5,
				rotation = 360
			})
			local min_bag_number = minmode_panel:text({
				name = "min_bag_number",
				visible = false,
				text = utf8.to_upper(""),
				font = "fonts/font_medium_shadow_mf",
				font_size = tweak_data.hud.small_name_label_font_size / 1.5,
				color = Color.white,
				align = "center",
				vertical = "center",
				layer = 1,
				w = min_bag:w(),
				h = min_bag:h(),
				rotation = 360
			})
			self:align_teammate_name_label(panel, interact)
			table.insert(self._hud.name_labels, {
				vehicle = data.unit,
				panel = panel,
				minmode_panel = minmode_panel,
				text = text,
				id = id,
				character_name = vehicle_name,
				interact = interact,
				bag = bag,
				bag_number = bag_number
			})
			return id
		end

		
		function HUDManager:set_name_label_carry_info(peer_id, carry_id, value)
			local name_label = self:_name_label_by_peer_id(peer_id)
			if name_label then
				name_label.panel:child("extended_panel"):child("bag"):set_visible(true)
				name_label.panel:child("minmode_panel"):child("min_bag"):set_visible(true)
			end
		end
		function HUDManager:set_vehicle_label_carry_info(label_id, value, number)
			local name_label = self:_get_name_label(label_id)
			if name_label then
				name_label.panel:child("extended_panel"):child("bag"):set_visible(value)
				name_label.panel:child("minmode_panel"):child("min_bag"):set_visible(value)
				name_label.panel:child("extended_panel"):child("bag_number"):set_visible(value)
				name_label.panel:child("minmode_panel"):child("min_bag_number"):set_visible(value)
				name_label.panel:child("extended_panel"):child("bag_number"):set_text(number)
				name_label.panel:child("minmode_panel"):child("min_bag_number"):set_text(number)
			end
		end
		function HUDManager:remove_name_label_carry_info(peer_id)
			local name_label = self:_name_label_by_peer_id(peer_id)
			if name_label then
				name_label.panel:child("extended_panel"):child("bag"):set_visible(false)
				name_label.panel:child("minmode_panel"):child("min_bag"):set_visible(false)
			end
		end
	end

	--Timer panel
	if VoidUI.options.enable_timer then
		local loot_value = HUDManager.loot_value_updated
		function HUDManager:loot_value_updated(...)
			if self._hud_heist_timer then
				self._hud_heist_timer:loot_value_changed()
			end
			return loot_value(self, ...)
		end	
	end
	
elseif RequiredScript == "lib/units/player_team/teamaidamage" then
	
	if VoidUI.options.teammate_panels then
		local apply_damage_orig = TeamAIDamage._apply_damage
		function TeamAIDamage:_apply_damage(attack_data, result)
			local damage_percent, health_subtracted = apply_damage_orig(self, attack_data, result)
			local i = managers.criminals:character_data_by_unit(self._unit).panel_id
			managers.hud:set_teammate_health(i, {current = self._health, total = self._HEALTH_INIT})
			return damage_percent, health_subtracted
		end	
		
		local regenerated = TeamAIDamage._regenerated
		function TeamAIDamage:_regenerated()
			regenerated(self)
			local i = managers.criminals:character_data_by_unit(self._unit).panel_id
			managers.hud:set_teammate_health(i, {current = self._health, total = self._HEALTH_INIT})
		end
	end
	
	if VoidUI.options.enable_stats and VoidUI.options.scoreboard then
		local check_bleed_out = TeamAIDamage._check_bleed_out
		function TeamAIDamage:_check_bleed_out()
			if self._health <= 0 then
				local i = managers.criminals:character_data_by_unit(self._unit).panel_id
				if managers.hud._hud_statsscreen then
					managers.hud._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
				end
			end
			check_bleed_out(self)
		end
	end
	
elseif RequiredScript == "lib/units/player_team/huskteamaidamage" and VoidUI.options.enable_stats and VoidUI.options.scoreboard then
	local on_bleedout = HuskTeamAIDamage._on_bleedout
	function HuskTeamAIDamage:_on_bleedout()
		on_bleedout(self)
		local i = managers.criminals:character_data_by_unit(self._unit).panel_id
		if managers.hud._hud_statsscreen then
			managers.hud._hud_statsscreen._scoreboard_panels[i]:add_stat("downs")
		end
	end
	
elseif RequiredScript == "core/lib/managers/subtitle/coresubtitlepresenter" and VoidUI.options.enable_subtitles then
	
	core:module("CoreSubtitlePresenter")
	function OverlayPresenter:show_text(text, duration)
		self._bg_mode = _G.VoidUI.options.subtitles_bg
		self.__font_name = "fonts/font_medium_mf"
		self._text_scale = _G.VoidUI.options.subtitle_scale
		local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
			name = "label",
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			color = Color.white,
			align = "center",
			vertical = "bottom",
			layer = 1,
			wrap = true,
			word_wrap = true
		})
		local shadow = self.__subtitle_panel:child("shadow") or self.__subtitle_panel:text({
			name = "shadow",
			x = 1,
			y = 1,
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			color = Color.black:with_alpha(1),
			align = "center",
			vertical = "bottom",
			layer = 0,
			wrap = true,
			word_wrap = true
		})
		label:set_text(text)
		shadow:set_text(text)	
		label:set_font_size(self.__font_size * self._text_scale)
		shadow:set_font_size(self.__font_size * self._text_scale)
		shadow:set_visible(self._bg_mode == 2)
		local background = self.__subtitle_panel:child("background") or self.__subtitle_panel:bitmap({
			name = "background",
			color = Color.black,
			alpha = 0.5,
			w = 0,
			h = 0,
			layer = -1
		})
		background:set_visible(self._bg_mode == 3)
			local blur = self.__subtitle_panel:child("blur") or self.__subtitle_panel:bitmap({
			name = "blur",
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			w = 0,
			h = 0,
			layer = -2
		})
		blur:set_visible(self._bg_mode == 3)
		local x, y, w, h = label:text_rect()
		background:set_shape(x-4, y-4, w+8, h+8)
		blur:set_shape(x-4, y-4, w+8, h+8)
	end

elseif RequiredScript == "lib/managers/hud/hudwaitinglegend" and VoidUI.options.teammate_panels then
	local PADDING = 8
	function HUDWaitingLegend:init(hud)
		self._hud_panel = hud.panel
		self._panel = self._hud_panel:panel({
			h = tweak_data.hud_players.name_size + 16,
			halign = "grow",
			valign = "bottom"
		})
		self._all_buttons = {
			self:create_button("hud_waiting_accept", "drop_in_accept", "spawn"),
			self:create_button("hud_waiting_return", "drop_in_return", "return_back"),
			self:create_button("hud_waiting_kick", "drop_in_kick", "kick")
		}
		self._btn_panel = self._panel:panel()
		self._btn_text = self._btn_panel:text({
			text = "",
			x = 14,
			layer = 1,
			font_size = tweak_data.hud_players.name_size,
			font = tweak_data.hud_players.name_font,

			y = PADDING
		})
		managers.hud:make_fine_text(self._btn_text)
		self._background = self._btn_panel:bitmap({
			texture = "guis/textures/VoidUI/hud_weapons",
			texture_rect = {0,0,528,150},
			w = self._btn_panel:w(),
			h = self._btn_panel:h() - PADDING
		})
		self._background:set_center_y(self._btn_panel:center_y())
		self._foreground = self._btn_panel:bitmap({
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {0,158,503,157},
			layer = 1,
			x = 1,
			y = self._background:y(),
			w = self._btn_panel:w(),
			h = self._btn_panel:h() - PADDING
		})
		self._panel:set_visible(false)
	end
	
	function HUDWaitingLegend:update_buttons()
		local str = ""
		for k, btn in pairs(self._all_buttons) do
			local button_text = managers.localization:btn_macro(btn.binding, true, true)
			if button_text then
				str = str .. (str == "" and "" or "  ") .. managers.localization:text(btn.text, {MY_BTN = button_text})
			end
		end
		if str == "" then
			str = managers.localization:text("hud_waiting_no_binding_text")
		end
		self._btn_text:set_text("  " .. str .. "  ")
		managers.hud:make_fine_text(self._btn_text)
		self._btn_panel:set_w(self._btn_text:w() + 20)
		self._btn_panel:set_h(self._btn_text:bottom() + PADDING)
		self._background:set_w(self._btn_panel:w())
		self._foreground:set_w(self._btn_panel:w())
		if not self._panel:visible() then
			self:animate_open()
		end
		self._panel:set_visible(true)
	end
	
	function HUDWaitingLegend:animate_open()
		self._btn_panel:stop()
		self._btn_panel:animate(function()
			local TOTAL_T = 0.4
			local t = 0
			while TOTAL_T > t do
				local dt = coroutine.yield()
				t = t + dt
				self._btn_panel:set_w(math.lerp(0, self._background:w(), t / TOTAL_T))
				self._btn_text:set_w(math.lerp(0, self._background:w(), t / TOTAL_T))
			end
		end)
		self._btn_panel:set_w(self._background:w())
		managers.hud:make_fine_text(self._btn_text)
	end
elseif RequiredScript == "lib/units/player_team/teamaiinventory" and VoidUI.options.scoreboard and VoidUI.options.enable_stats then
	local _ensure_weapon_visibility = TeamAIInventory._ensure_weapon_visibility
	function TeamAIInventory:_ensure_weapon_visibility(override_weapon, override)
		_ensure_weapon_visibility(self, override_weapon, override)
		local panel = managers.hud and managers.hud._hud_statsscreen:get_scoreboard_panel_by_character(managers.criminals:character_name_by_unit(self._unit))
		if panel then panel:sync_bot_loadout(panel._character) end
	end
elseif RequiredScript == "lib/states/ingamemaskoff" and VoidUI.options.enable_assault then
	local at_enter = IngameMaskOffState.at_enter
	function IngameMaskOffState:at_enter()
		at_enter(self)
		managers.hud:hide(self._MASK_OFF_HUD)
	end
elseif RequiredScript == "lib/managers/achievmentmanager" and VoidUI.options.enable_stats and VoidUI.options.scoreboard then
	AchievmentManager.MAX_TRACKED = 7
elseif RequiredScript == "lib/managers/playermanager" and (VoidUI.options.teammate_panels or VoidUI.options.vape_hints) then
	add_coroutine = PlayerManager.add_coroutine
	function PlayerManager:add_coroutine(name, func, ...)
		local arg = {...}
		local tagged = arg[1]
		if name == "tag_team" and tagged then
			if VoidUI.options.vape_hints then
				if tagged.base and tagged:base().nick_name then
					managers.hud:show_hint({text=managers.localization:text("VoidUI_tag_team_owner", {NAME=tagged:base():nick_name()}), time=5})
				elseif tagged.base and tagged:base().owner_peer_id then
					managers.hud:show_hint({text=managers.localization:text("VoidUI_tag_team_owner_joker", {NAME=managers.criminals:character_unit_by_peer_id(tagged:base().owner_peer_id):base():nick_name()}), time=5})
				end
				tagged:contour():add("mark_unit")
			end
			if VoidUI.options.teammate_panels then
				managers.hud:set_teammate_ability_color(HUDManager.PLAYER_PANEL, tweak_data.chat_colors[managers.criminals:character_peer_id_by_unit(tagged)] or tweak_data.chat_colors[#tweak_data.chat_colors])
			end
		end
		add_coroutine(self, name, func, ...)
	end
	
	local sync_tag_team = PlayerManager.sync_tag_team
	function PlayerManager:sync_tag_team(tagged, owner, end_time)
		sync_tag_team(self, tagged, owner, end_time)
		local owner_name = owner:base():nick_name()
		local tagged_id = managers.criminals:character_peer_id_by_unit(tagged)
		local owner_data = managers.criminals:character_data_by_unit(owner)
		local owner_panel = (owner_data and owner_data.panel_id and owner_data.panel_id)
		if owner_panel and VoidUI.options.teammate_panels then
			managers.hud:set_teammate_ability_color(owner_panel, tweak_data.chat_colors[tagged_id] or tweak_data.chat_colors[#tweak_data.chat_colors])
		end
		if tagged == self:local_player() and VoidUI.options.vape_hints then
			owner:contour():add("mark_unit")
			self:player_unit():sound():play("perkdeck_activate")
			managers.hud:show_hint({text=managers.localization:text("VoidUI_tag_team_tagged", {NAME=owner_name}), time=5})
		end
	end
elseif RequiredScript == "lib/network/base/basenetworksession" and VoidUI.options.scoreboard and VoidUI.options.enable_stats then
	local remove_peer = BaseNetworkSession.remove_peer
	function BaseNetworkSession:remove_peer(peer, peer_id, reason)
		if managers.criminals and peer_id then
			local character_data = managers.criminals:character_data_by_peer_id(peer_id)

			if character_data and character_data.panel_id then
				managers.hud:remove_teammate_scoreboard_panel(character_data.panel_id)
			end
		end
		return remove_peer(self, peer, peer_id, reason)
	end
elseif RequiredScript == "lib/managers/menumanagerdialogs" then
	function MenuManager:show_person_joining(id, nick, progress_percentage, join_start)
		if not managers.hud and not managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:child("user_dropin" .. id) then
			return
		end
		if not self._person_joining then
			self._person_joining = join_start or os.clock()
			local color = tweak_data.chat_colors[id] or Color.white
			local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
			local panel = hud.panel:panel({name = "user_dropin" .. id, layer = 10000 + id})
			local bg_blur = panel:bitmap({
				name = "bg_blur",
				texture = "guis/textures/test_blur_df",
				render_template = "VertexColorTexturedBlur3D",
				w = panel:w(),
				h = panel:h(),
				layer = 0,
			})
			local bg_shade = panel:bitmap({
				name = "bg_shade",
				color = Color.black,
				alpha = 0.5,
				layer = 0,
			})
			local weapons_texture = "guis/textures/VoidUI/hud_weapons"
			local highlight_texture = "guis/textures/VoidUI/hud_highlights"
			local panel_bg = panel:bitmap({
				name = "panel_bg",
				texture = highlight_texture,
				texture_rect = {0,467,503,160},
				layer = 1,
				w = 480,
				h = 180,
				alpha = 1,
				color = color
			})
			panel_bg:set_center(bg_blur:center())
			local progressbar_bg = panel:bitmap({
				name = "progressbar_bg",
				w = 350,
				h = 10,
				color = color * 0.2 + Color.black,
				layer = 2,
			})
			progressbar_bg:set_center(panel:w() / 2, panel:h() / 2)
			local progressbar = panel:bitmap({
				name = "progressbar",
				w = (progress_percentage or 0) / 100 * 350,
				h = 10,
				layer = 3,
				color = color
			})
			progressbar:set_x(progressbar_bg:x())
			progressbar:set_center_y(progressbar_bg:center_y())
			local level = "" 
			local peer = managers.network:session():peer(id)
			if peer then 
				level = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "Ї" or "") .. (peer:level() and peer:level().. " " or "")
			end
			local title_text = panel:text({
				name = "title_text",
				font_size = 25,
				font = tweak_data.menu.pd2_large_font,
				text = level..managers.localization:text("dialog_dropin_title", {USER = nick}),
				layer = 2,
			})
			managers.hud:make_fine_text(title_text)
			title_text:set_range_color(utf8.len(level), utf8.len(level) + utf8.len(nick) , color)
			title_text:set_center_x(panel:w() / 2)
			title_text:set_bottom(progressbar_bg:top() - 5)
			local title_text_shadow = panel:text({
				name = "title_text_shadow",
				font_size = 25,
				font = tweak_data.menu.pd2_large_font,
				text = title_text:text(),
				layer = -2,
				color = Color.black
			})
			managers.hud:make_fine_text(title_text_shadow)
			title_text_shadow:set_position(title_text:x() + 2, title_text:y() + 2)
			
			local progress_text = panel:text({
				name = "progress_text",
				font_size = 25,
				font = tweak_data.menu.pd2_large_font,
				text = tonumber(progress_percentage or 0).."%",
				align = "center",
				layer = 2,
				color = color
			})
			managers.hud:make_fine_text(progress_text)
			progress_text:set_w(panel:w())
			progress_text:set_top(progressbar_bg:bottom() + 5)
			local progress_text_shadow = panel:text({
				name = "progress_text_shadow",
				font_size = 25,
				font = tweak_data.menu.pd2_large_font,
				text = progress_text:text(),
				align = "center",
				layer = -2,
				color = Color.black
			})
			managers.hud:make_fine_text(progress_text_shadow)
			progress_text_shadow:set_w(panel:w())
			progress_text_shadow:set_position(2, progress_text:y() + 2)			
			local function animation(o)
				local center_x, center_y = panel_bg:center()
				local w, h = panel_bg:size()
				local TOTAL_T = 0.25
				local t = 0
				while TOTAL_T >= t do
					coroutine.yield()
					t = t + 0.016
					o:set_alpha(math.lerp(0, 1, t / TOTAL_T))
					panel_bg:set_size(math.lerp(w * 2, w, t / TOTAL_T), math.lerp(h * 2, h, t / TOTAL_T))
					panel_bg:set_center(center_x, center_y)
				end
				t = 0
				local sin
				local speed = managers.groupai and managers.groupai:state():whisper_mode() and 40 or 100
				while true do
					coroutine.yield()
					t = t + 0.016
					sin = math.sin((speed + 75) * t) * 25
					panel_bg:set_rotation(math.sin(speed * t) * 3)
					panel_bg:set_size(w - sin, h - sin)
					panel_bg:set_center(center_x, center_y)
				end
			end
			panel:animate(animation)
		else
			self._joining_queue = self._joining_queue or {}
			table.insert(self._joining_queue, {id = id, nick = nick, join_start = managers.game_play_central:get_heist_timer()})
		end
	end
	function MenuManager:update_person_joining(id, progress_percentage)
		if not managers.hud and not managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) then
			return
		end
		local panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:child("user_dropin" .. id)
		if panel then
			local progress_text = panel:child("progress_text")
			local progress_text_shadow = panel:child("progress_text_shadow")
			local progressbar = panel:child("progressbar")
			local Time = os.clock()-self._person_joining
			local remaining = (Time/progress_percentage*100)-Time
			progressbar:stop()
			local function set_progress(o)
				local w = o:w()
				local max_w = panel:child("progressbar_bg"):w()
				local TOTAL_T = 0.15
				local t = 0
				while TOTAL_T >= t do
					coroutine.yield()
					t = t + 0.016
					o:set_w(math.lerp(w, tonumber(progress_percentage) / 100 * max_w, t / TOTAL_T))
					progress_text:set_text(string.format("%1s%% (%.1fs)", math.floor(o:w() / max_w * 100), remaining))
					progress_text_shadow:set_text(progress_text:text())
				end
				o:set_w(tonumber(progress_percentage) / 100 * max_w)
				progress_text:set_text(string.format("%1s%% (%.1fs)", progress_percentage, remaining))
				progress_text_shadow:set_text(progress_text:text())
			end
			progressbar:animate(set_progress)
		elseif self._joining_queue then
			for i, data in pairs(self._joining_queue) do
				if data.id == id then
					data.progress_percentage = progress_percentage
				end
			end			
		end
	end
	
	function MenuManager:close_person_joining(id)
		if not managers.hud and not managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) then
			return
		end
		
		local panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:child("user_dropin" .. id)
		if panel then
			local function animation(o)
				local panel_bg = panel:child("panel_bg")
				local center_x, center_y = panel_bg:center()
				local w, h = panel_bg:size()
				local TOTAL_T = 0.25
				local t = 0
				while TOTAL_T >= t do
					coroutine.yield()
					t = t + 0.016
					panel:set_alpha(math.lerp(1, 0, t / TOTAL_T))
					panel_bg:set_size(math.lerp(w, w * 1.5, t / TOTAL_T), math.lerp(h, h * 1.5, t / TOTAL_T))
					panel_bg:set_center(center_x, center_y)
				end
				managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:remove(panel)
				self._person_joining = nil
				if self._joining_queue and self._joining_queue[1] then
					local joining = self._joining_queue[1]
					self:show_person_joining(joining.id, joining.nick, joining.progress_percentage, joining.join_start)
					table.remove(self._joining_queue, 1)
				end
			end
			panel:stop()
			panel:animate(animation)
		elseif self._joining_queue then
			for i, data in pairs(self._joining_queue) do
				if data.id == id then
					table.remove(self._joining_queue, i)
				end
			end			
		end
	end
end

