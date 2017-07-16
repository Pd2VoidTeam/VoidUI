function HUDManager:_create_teammates_panel(hud)
	hud = hud or managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self._hud.teammate_panels_data = self._hud.teammate_panels_data or {}
	self._teammate_panels = {}
	if hud.panel:child("teammates_panel") then
		hud.panel:remove(hud.panel:child("teammates_panel"))
	end
	local h = self:teampanels_height() * 2
	self._main_scale = HeistHUD.options.hud_main_scale and HeistHUD.options.hud_main_scale or 1
	self._mate_scale = HeistHUD.options.hud_mate_scale and HeistHUD.options.hud_mate_scale or 1
	local teammates_panel = hud.panel:panel({
		name = "teammates_panel",
		h = h,
		y = hud.panel:h() - h,
		halign = "grow",
		valign = "bottom"
	})
	for i = 1, 4 do
		local is_player = i == HUDManager.PLAYER_PANEL
		self._hud.teammate_panels_data[i] = {
			taken = false,
			special_equipments = {}
		}

		local teammate = HUDTeammate:new(i, teammates_panel, is_player, teammates_panel:w())
		if is_player then
			teammate._panel:set_w(220 * self._main_scale)
			teammate._panel:set_right(teammates_panel:right())
		else
			teammate._panel:set_w(154 * self._mate_scale)
			teammate._panel:set_left(teammates_panel:left() + ((i - 1) * teammate._panel:w()) + (2 * (i - 1))* self._mate_scale)
		end
		table.insert(self._teammate_panels, teammate)
		if is_player then
			teammate:add_panel()
		end
	end
end

HUDManager.align_teammate_panels = HUDManager.align_teammate_panels or function(self)
	for i, data in ipairs(self._hud.teammate_panels_data) do
		if i ~= HUDManager.PLAYER_PANEL then
			local panel = self._teammate_panels[i]
			if panel:ai() or panel:peer_id() then panel._panel:set_w((panel:ai() and 51 or 154) * self._mate_scale)
			else panel._panel:set_w(0) end
			if i ~= 1 then
				panel._panel:set_x(self._teammate_panels[i - 1]._panel:right() + 2 * self._mate_scale)
			end
		end
	end
end

function HUDManager:teammate_progress(peer_id, type_index, enabled, tweak_data_id, timer, success)
	local name_label = self:_name_label_by_peer_id(peer_id)
	if name_label then
		name_label.interact:set_visible(enabled)
		name_label.panel:child("action"):set_visible(enabled)
		name_label.panel:child("interact_bg"):set_visible(enabled)
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
		name_label.panel:child("action"):set_text(action_text .. string.format(" (%.1fs)", timer))
		name_label.panel:child("interact_bg"):set_w(select(3, name_label.panel:child("action"):text_rect()))
		name_label.panel:child("interact_bg"):set_center_x(name_label.panel:child("action"):center_x())
		name_label.panel:stop()
		if enabled then
			name_label.panel:animate(callback(self, self, "_animate_label_interact"), name_label.interact, name_label.panel:child("interact_bg"), name_label.panel:child("action"), action_text, timer)
		end
	end
	local character_data = managers.criminals:character_data_by_peer_id(peer_id)
	if character_data then
		self._teammate_panels[character_data.panel_id]:teammate_progress(enabled, type_index, tweak_data_id, timer, success)
	end
end

function HUDManager:_animate_label_interact(panel, interact, interact_bg, action, action_text, timer)
	local t = 0
	interact:set_x(interact_bg:x())
	while timer >= t do
		local dt = coroutine.yield()
		t = t + dt
		interact:set_w(math.lerp(0, interact_bg:w(), t / timer))
		action:set_text(action_text .. string.format(" (%.1fs)", math.clamp(timer - t, 0, timer)))
	end
	interact:set_w(interact_bg:w())
end

function HUDManager:_animate_label_color(text, len)
	wait(2)
	text:set_range_color(0, len, Color.white) 
end
function HUDManager:set_ai_stopped(ai_id, stopped)
	local teammate_panel = self._teammate_panels[ai_id]
	if not teammate_panel or stopped and not teammate_panel._ai then
		return
	end
	local panel = teammate_panel._custom_player_panel
	local name = panel:child("name") and string.gsub(panel:child("name"):text(), "%W", "")
	local label
	for _, lbl in ipairs(self._hud.name_labels) do
		if string.gsub(lbl.character_name, "%W", "") == name then
			label = lbl
		else
		end
	end
	if stopped then
		local name_text = panel:child("name")
		local stop_icon = panel:bitmap({
			name = "stopped",
			texture = tweak_data.hud_icons.ai_stopped.texture,
			texture_rect = tweak_data.hud_icons.ai_stopped.texture_rect
		})
		stop_icon:set_w(name_text:h() / 2)
		stop_icon:set_h(name_text:h())
		stop_icon:set_left(name_text:right() + 5)
		stop_icon:set_y(name_text:y())
		if label then
			local label_stop_icon = label.panel:bitmap({
				name = "stopped",
				texture = tweak_data.hud_icons.ai_stopped.texture,
				texture_rect = tweak_data.hud_icons.ai_stopped.texture_rect
			})
			label_stop_icon:set_right(label.text:left())
			label_stop_icon:set_center_y(label.text:center_y())
		end
	else
		if panel:child("stopped") then
			panel:remove(panel:child("stopped"))
		end
		if label and label.panel:child("stopped") then
			label.panel:remove(label.panel:child("stopped"))
		end
	end
end

function HUDManager:_add_name_label(data)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
	local id = last_id + 1
	local character_name = data.name
	local rank = 0
	local peer_id
	local is_husk_player = data.unit:base().is_husk_player
	local experience = ""
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
	local interact = panel:bitmap({
		h = 2,
		layer = 0,
		visible = false,
	})
	local interact_bg = panel:bitmap({
		name = "interact_bg",
		h = 2,
		color = Color.black,
		visible = false,
		layer = -1
	})
	local color_id = managers.criminals:character_color_id_by_unit(data.unit)
	local crim_color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	local text = panel:text({
		name = "text",
		text = data.name,
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size / 1.2,
		color = crim_color,
		align = "center",
		vertical = "top",
		layer = -1,
		w = 256,
		h = 18
	})
	text:animate(callback(self, self, "_animate_label_color"), utf8.len(experience))
	local text_shadow = panel:text({
		name = "text_shadow",
		text = data.name,
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
	local bag = panel:bitmap({
		name = "bag",
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {2, 34, 20, 17},
		layer = 0,
		color = crim_color,
		visible = false,
		x = 1,
		y = 1
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
		name = "action",
		rotation = 360,
		text = "Fixing",
		font = "fonts/font_medium_shadow_mf",
		font_size = tweak_data.hud.name_label_font_size / 1.2,
		color = crim_color,
		align = "center",
		vertical = "bottom",
		layer = -1,
		visible = false,
		w = 256,
		h = 18
	})
	self:align_teammate_name_label(panel, interact)
	table.insert(self._hud.name_labels, {
		movement = data.unit:movement(),
		panel = panel,
		text = text,
		id = id,
		peer_id = peer_id,
		character_name = character_name,
		experience = experience,
		interact = interact,
		bag = bag
	})
	return id
end

function HUDManager:align_teammate_name_label(panel, interact, experience)
	local double_radius = 0
	local text = panel:child("text")
	local text_shadow = panel:child("text_shadow")
	local action = panel:child("action")
	local bag = panel:child("bag")
	local bag_number = panel:child("bag_number")
	local cheater = panel:child("cheater")
	local interact_bg = panel:child("interact_bg")
	local _, _, tw, th = text:text_rect()
	local _, _, aw, ah = action:text_rect()
	local _, _, cw, ch = cheater:text_rect()
	panel:set_size(math.max(tw, cw, aw) + 1, th + ah + ch + 5)
	bag:set_left(0)
	text:set_size(panel:w(), th)
	action:set_size(panel:w(), ah)
	cheater:set_size(panel:w(), ch)
	text:set_x(bag:right() + 4)
	text:set_text(text_shadow:text())
	action:set_x(bag:right() + 4)
	cheater:set_x(bag:right() + 4)
	text:set_top(cheater:bottom())
	bag:set_center_y(text:center_y())
	if bag_number then bag_number:set_center_y(bag:center_y())end
	action:set_top(text:bottom())
	text_shadow:set_size(panel:w(), th)
	panel:set_w(panel:w() + (bag:w() * 2) + 5)
	text_shadow:set_x(bag:right() + 5)
	text_shadow:set_top(text:top() + 1)
	interact:set_position(bag:right() + 4, action:top())
	interact_bg:set_position(bag:right() + 4, action:top())
	interact_bg:set_w(tw)
end

function HUDManager:add_vehicle_name_label(data)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	local last_id = self._hud.name_labels[#self._hud.name_labels] and self._hud.name_labels[#self._hud.name_labels].id or 0
	local id = last_id + 1
	local vehicle_name = data.name
	local panel = hud.panel:panel({
		name = "name_label" .. id
	})
	local radius = 24
	local interact = panel:bitmap({
		h = 2,
		layer = 0,
		visible = false,
	})
	local interact_bg = panel:bitmap({
		name = "interact_bg",
		h = 2,
		color = Color.black,
		visible = false,
		layer = -1
	})
	local crim_color = tweak_data.chat_colors[5]
	local text = panel:text({
		name = "text",
		text = utf8.to_upper(data.name),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = crim_color,
		align = "center",
		vertical = "top",
		layer = -1,
		w = 256,
		h = 18
	})
	local text_shadow = panel:text({
		name = "text_shadow",
		text = data.name,
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size,
		color = Color.black,
		align = "center",
		vertical = "top",
		layer = -2,
		w = 256,
		h = 18,
		x = 1,
		y = 1,
	})
	local bag = panel:bitmap({
		name = "bag",
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = {2, 34, 20, 17 },
		visible = false,
		layer = 0,
		color = crim_color:with_alpha(0.8),
		x = 1,
		y = 1
	})
	local bag_number = panel:text({
		name = "bag_number",
		visible = false,
		text = utf8.to_upper(""),
		font = "fonts/font_medium_shadow_mf",
		font_size = tweak_data.hud.small_name_label_font_size,
		color = crim_color,
		align = "right",
		vertical = "bottom",
		layer = 1,
		w = bag:w() * 1.2,
		h = bag:h() * 1.5
	})
	panel:text({
		name = "cheater",
		text = managers.localization:text("menu_hud_cheater"),
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size / 2,
		color = tweak_data.screen_colors.pro_color,
		align = "center",
		visible = false,
		layer = -1,
		w = 256,
		h = 18
	})
	panel:text({
		name = "action",
		rotation = 360,
		visible = false,
		text = "Fixing",
		font = tweak_data.hud.medium_font,
		font_size = tweak_data.hud.name_label_font_size / 2,
		color = crim_color:with_alpha(1),
		align = "left",
		vertical = "bottom",
		layer = -1,
		w = 256,
		h = 18
	})
	self:align_teammate_name_label(panel, interact)
	table.insert(self._hud.name_labels, {
		vehicle = data.unit,
		panel = panel,
		text = text,
		id = id,
		character_name = vehicle_name,
		interact = interact,
		bag = bag,
		bag_number = bag_number
	})
	return id
end

local loot_value = HUDManager.loot_value_updated
function HUDManager:loot_value_updated(...)
	if self._hud_heist_timer then
		self._hud_heist_timer:loot_value_changed()
	end
	return loot_value(self, ...)
end

local ext_inventory_changed = HUDManager.on_ext_inventory_changed
function HUDManager:on_ext_inventory_changed()
	if self._teammate_panels[HUDManager.PLAYER_PANEL] then
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_bodybags()
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_info_visible()
	end
	return ext_inventory_changed(self)
end

function HUDManager:show_local_player_gear()
	self:show_player_gear(HUDManager.PLAYER_PANEL)
end

function HUDManager:hide_player_gear(panel_id)
	if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
		local player_panel = self._teammate_panels[panel_id]:panel():child("custom_player_panel")
		player_panel:child("weapons_panel"):set_visible(false)
	end
end
function HUDManager:show_player_gear(panel_id)
	if self._teammate_panels[panel_id] and self._teammate_panels[panel_id]:panel() and self._teammate_panels[panel_id]:panel():child("player") then
		local player_panel = self._teammate_panels[panel_id]:panel():child("custom_player_panel")
		player_panel:child("weapons_panel"):set_visible(true)
	end
end

function HUDManager:sync_start_anticipation_music()
	managers.music:post_event(tweak_data.levels:get_music_event("anticipation"))
	managers.hud:assault_anticipation()
end

HUDManager.assault_anticipation = HUDManager.assault_anticipation or function(self)
	if self._hud_assault_corner then
		self._hud_assault_corner:set_assault_phase()
	end
end

HUDManager.player_downed = HUDManager.player_downed or function(self, i)
	self._teammate_panels[i]:downed()
end

HUDManager.player_reset_downs = HUDManager.player_reset_downs or function(self, i)
	self._teammate_panels[i]:reset_downs()
end

HUDManager.pager_used = HUDManager.pager_used or function(self)
	if self._hud_assault_corner then
		self._hud_assault_corner:pager_used()
	end
end
