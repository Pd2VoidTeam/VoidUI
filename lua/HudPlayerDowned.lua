if RequiredScript == "lib/managers/hud/hudplayerdowned" and VoidUI.options.teammate_panels then
	
	function HUDPlayerDowned:init(hud)
		self._hud = hud
		self._hud_panel = hud.panel
		self._hud_panel:set_layer(0)
		if self._hud_panel:child("downed_panel") then
			self._hud_panel:remove(self._hud_panel:child("downed_panel"))
		end
		local player = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]
		local player_panel = player._custom_player_panel
		local downed_panel = self._hud_panel:panel({
			name = "downed_panel",
			w = player._health_w,
			h = player._bg_h,
			x = player_panel:child("health_panel"):world_x(),
			y = player_panel:child("health_panel"):world_y(),
		})
		
		local downed_bar = downed_panel:bitmap({
			name = "downed_bar",
			texture = "guis/textures/VoidUI/hud_health",
			texture_rect = {203,0,202,472},
			layer = 4,
			w = player._health_w,
			h = player._bg_h,
			alpha = 1,
		})
		local downed_icon = downed_panel:bitmap({
			name = "downed_icon",
			layer = 8,
			w = downed_panel:w() / 1.5,
			h = downed_panel:w() / 1.5,
			alpha = 0.5,
		})
		downed_icon:set_bottom(downed_bar:h() - 2)
		downed_icon:set_center_x(downed_bar:center_x() - 5)
		self._hud.timer:set_size(player._health_value, player._health_value)
		self._hud.timer:set_font(Idstring(tweak_data.hud.medium_font_noshadow))
		self._hud.timer:set_font_size(player._health_value / 1.4)
		self._hud.timer:set_x(downed_panel:x())
		self._hud.timer:set_bottom(downed_panel:bottom())
		self._hud.timer:set_align("center")
		self._hud.timer:set_vertical("bottom")
		self._hud.timer:set_layer(10)
		self._hud.arrest_finished_text:set_font(Idstring(tweak_data.hud.medium_font_noshadow))
		self._hud.arrest_finished_text:set_font_size(tweak_data.hud_mask_off.text_size)
		self:set_arrest_finished_text()
		local _, _, w, h = self._hud.arrest_finished_text:text_rect()
		self._hud.arrest_finished_text:set_h(h)
		self._hud.arrest_finished_text:set_y(28)
		self._hud.arrest_finished_text:set_center_x(self._hud_panel:center_x())
	end
	
	function HUDPlayerDowned:start_timer(time)
		self._hud_panel:child("downed_panel"):stop()
		self._hud_panel:child("downed_panel"):animate(callback(self, self, "_aimate_timer"), time)
	end
	function HUDPlayerDowned:_aimate_timer(downed_panel, time)
		local player_panel = managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]._custom_player_panel
		downed_panel:set_position(player_panel:child("health_panel"):world_x(), player_panel:child("health_panel"):world_y())
		self._hud.timer:set_x(downed_panel:x())
		self._hud.timer:set_bottom(downed_panel:bottom())
		local downed_bar = downed_panel:child("downed_bar")
		local total_time = time
		local amount = time / total_time
		downed_bar:set_h(downed_panel:h())
		downed_bar:set_texture_rect(203, 0, 202, 472)
		downed_bar:set_bottom(downed_panel:h())
		self._hud.timer:set_text(time)
		while time >= 0 do
		local dt = coroutine.yield()
			if self._hud.paused == false then
				time = time - dt
				amount = time / total_time
				self._hud.timer:set_text(math.round(time))
				downed_bar:set_h(amount * downed_panel:h())
				downed_bar:set_texture_rect(203, (1- amount) * 472, 202, 472 * amount)
				downed_bar:set_bottom(downed_panel:h())
			end
		end
	end
	function HUDPlayerDowned:on_downed()
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_downed")
		local downed_panel = self._hud_panel:child("downed_panel")
		local downed_bar = downed_panel:child("downed_bar")
		local downed_icon = downed_panel:child("downed_icon")
		downed_bar:set_color(tweak_data.screen_colors.pro_color * 0.7 + Color.black * 0.9)
		self._hud.timer:set_color(tweak_data.screen_colors.pro_color * 0.4 + Color.black * 0.9)
		downed_icon:set_color(tweak_data.screen_colors.pro_color)
		downed_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end
	function HUDPlayerDowned:on_arrested()
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_cuffed")
		local downed_panel = self._hud_panel:child("downed_panel")
		local downed_bar = downed_panel:child("downed_bar")
		local downed_icon = downed_panel:child("downed_icon")
		downed_bar:set_color(tweak_data.chat_colors[5] * 0.7 + Color.black * 0.9)
		self._hud.timer:set_color(tweak_data.chat_colors[5] * 0.4 + Color.black * 0.9)
		downed_icon:set_color(tweak_data.chat_colors[5])
		downed_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end
	function HUDPlayerDowned:show_timer()
		local downed_panel = self._hud_panel:child("downed_panel")
		local downed_bar = downed_panel:child("downed_bar")
		self._hud.timer:set_visible(true)
		downed_bar:set_alpha(1)
		self._hud.timer:set_alpha(1)
	end
	function HUDPlayerDowned:hide_timer()
		local downed_panel = self._hud_panel:child("downed_panel")
		local downed_bar = downed_panel:child("downed_bar")
		downed_bar:set_alpha(0.8)
		self._hud.timer:set_alpha(0.9)
	end
	function HUDPlayerDowned:show_arrest_finished()
		self._hud.arrest_finished_text:set_visible(true)
		local downed_panel = self._hud_panel:child("downed_panel")
		self._hud.timer:set_visible(false)
	end
	
elseif RequiredScript == "lib/units/beings/player/huskplayermovement" and VoidUI.options.teammate_panels then
	
	local start_bleedout = HuskPlayerMovement._perform_movement_action_enter_bleedout
	
	function HuskPlayerMovement:_perform_movement_action_enter_bleedout(...)
		local data = managers.criminals:character_data_by_unit(self._unit)
		if data and data.panel_id then
			managers.hud:player_downed(data.panel_id)
		end
	
		return start_bleedout(self, ...)
	end
	
elseif RequiredScript == "lib/units/beings/player/states/playerbleedout" and VoidUI.options.teammate_panels then
	local start_bleedout = PlayerBleedOut._enter
	
	function PlayerBleedOut:_enter(...)
		managers.hud:player_downed(HUDManager.PLAYER_PANEL)
		return start_bleedout(self, ...)
	end
	
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	
	local doctor_bag_taken = UnitNetworkHandler.sync_doctor_bag_taken

	function UnitNetworkHandler:sync_doctor_bag_taken(unit, amount, sender, ...)
		local peer = self._verify_sender(sender)
		if peer then
			local data = managers.criminals:character_data_by_peer_id(peer:id())
			if data and data.panel_id then
				managers.hud:player_reset_downs(data.panel_id)
			end
		end
		
		return doctor_bag_taken(self, unit, amount, sender, ...)
	end
	
	local teammate_interact = UnitNetworkHandler.sync_teammate_progress
	function UnitNetworkHandler:sync_teammate_progress(type_index, enabled, tweak_data_id, timer, success, sender)
		if tweak_data_id == "corpse_alarm_pager" and success == true then managers.hud:pager_used() end
		return teammate_interact(self, type_index, enabled, tweak_data_id, timer, success, sender)
	end

elseif RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" and VoidUI.options.teammate_panels then
	
	local doctor_bag_taken = DoctorBagBase.take

	function DoctorBagBase:take(...)
		managers.hud:player_reset_downs(HUDManager.PLAYER_PANEL)
		
		return doctor_bag_taken(self, ...)
	end

end