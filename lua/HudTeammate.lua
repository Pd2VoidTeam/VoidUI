CloneClass(HUDTeammate)
function HUDTeammate:init(i, teammates_panel, is_player, width) 
	self.orig.init(self, i, teammates_panel, is_player, width)
	local teammate_panel = self._panel
	self._teammates_panel = teammates_panel
	self._main_scale = HeistHUD.options.hud_main_scale
	self._mate_scale = HeistHUD.options.hud_mate_scale

	self._w = self._main_player and 145 * self._main_scale or 111 * self._mate_scale
	self._bg_h = self._main_player and 120 * self._main_scale or 92 * self._mate_scale
	self._border_h = self._main_player and 40 * self._main_scale or 0 * self._mate_scale
	self._health_w = self._main_player and 55 * self._main_scale or 41 * self._mate_scale
	self._armor_value = self._main_player and 48 * self._main_scale or 0 * self._mate_scale
	self._health_value = self._main_player and 45 * self._main_scale or 35 * self._mate_scale
	self._ammo_panel_h = self._main_player and 40 * self._main_scale or 31 * self._mate_scale
	self._equipment_panel_w = self._main_player and 47 * self._main_scale or 36 * self._mate_scale
	self._equipment_panel_h = self._main_player and 38 * self._main_scale or 30 * self._mate_scale
	self._downs_max = self._main_player and (tweak_data.player.damage.LIVES_INIT - 1 - (managers.job:current_difficulty_stars() == 6 and 2 or 0) + (self._main_player and managers.player:upgrade_value("player", "additional_lives", 0) or 0)) or 3
	self._downs = self._downs_max
	self._primary_max = 0
	self._secondary_max = 0
	self._max_cooldown = 0
		
	self._player_panel:child("radial_health_panel"):set_visible(false)
	self._player_panel:child("weapons_panel"):set_visible(false)
	self._player_panel:child("deployable_equipment_panel"):set_visible(false)
	self._player_panel:child("cable_ties_panel"):set_visible(false)
	self._player_panel:child("grenades_panel"):set_visible(false)

	
	teammate_panel:child("name"):set_visible(false)
	teammate_panel:child("name_bg"):set_visible(false)
	teammate_panel:child("callsign_bg"):set_visible(false)
	teammate_panel:child("callsign"):set_visible(false)
	
	if self._main_player then
		teammate_panel:set_w(220 * self._main_scale)
		teammate_panel:set_h(200 * self._main_scale)
	else
		teammate_panel:set_w(154 * self._mate_scale)
		teammate_panel:set_h(146 * self._mate_scale)
	end
	teammate_panel:set_bottom(teammates_panel:h())
		
	local custom_player_panel = teammate_panel:panel({
		name = "custom_player_panel",
		w = teammate_panel:w(),
		h = teammate_panel:h()
	})
	self._custom_player_panel = custom_player_panel
	
	local name = custom_player_panel:text({
		name = "name",
		text = " EASTER EGG",
		layer = 1,
		color = Color.white,
		vertical = "bottom",
		font_size = 19,
		font = "fonts/font_medium_mf",
		visible = false
	})
	local name_shadow = custom_player_panel:text({
		name = "name_shadow",
		text = " ANOTHER EASTER EGG",
		layer = 0,
		color = Color.black,
		vertical = "bottom",
		font_size = 19,
		font = "fonts/font_medium_mf",
		visible = false
	})
	local health_panel = custom_player_panel:panel({
		name = "health_panel",
		w = self._health_w,
		h = self._bg_h,
		layer = 2
	})
	health_panel:set_bottom(custom_player_panel:bottom())
	if self._main_player then health_panel:set_x(custom_player_panel:w() - health_panel:w()) end
	
	local health_background = health_panel:bitmap({
		name = "health_background",
		w = health_panel:w(),
		h = health_panel:h(),
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {525,0,202,472},
		layer = 1
	})
	
	local health_bar = health_panel:bitmap({
		name = "health_bar",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {727,0,202,472},
		layer = 2,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
	})
	
	local health_shade = health_panel:bitmap({
		name = "health_shade",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {929,0,201,472},
		layer = 3,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
		color = Color(0,0,0)
	})
	local custom_bar = health_panel:bitmap({
		name = "custom_bar",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {727,0,202,472},
		layer = 2,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
		color = Color(0.0, 0.4, 0.4),
	})	
	custom_bar:hide()
	

	local condition_icon = health_panel:bitmap({
		name = "condition_icon",
		layer = 6,
		w = health_panel:w() / 1.5,
		h = health_panel:w() / 1.5,
		alpha = 1,
	})	
	condition_icon:hide()
	condition_icon:set_bottom(health_background:bottom() - 5)
	condition_icon:set_center_x(health_background:center_x() - 3)
	
	local health_value = health_panel:text({
		name = "health_value",
		w = self._health_value,
		h = self._health_value,
		font_size = self._health_value / 1.4,
		text = "100",
		vertical = "bottom",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		layer = 5,
		color = Color.white
	})	
	health_value:set_bottom(health_background:bottom() - 3)
	
	local downs_value = health_panel:text({
		name = "downs_value",
		w = self._health_value,
		h = self._health_value,
		font_size = self._health_value / 1.5,
		text = "x".. tostring(self._downs),
		vertical = "top",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		layer = 5,
		color = Color.white,
	})	
	downs_value:set_top(health_background:top() + 3)
	downs_value:set_right(health_background:right() - (self._main_player and 3 or 1))
	
	local detect_value = health_panel:text({
		name = "detect_value",
		w = self._health_value,
		h = self._health_value,
		font_size = self._main_player and self._health_value / 1.5 or self._health_value / 1.7,
		text = "75%",
		vertical = "top",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		layer = 5,
		color = Color.white,
		visible = false
	})	
	detect_value:set_top(health_background:top() + 3)
	detect_value:set_right(health_background:right() - (self._main_player and 3 or 1))
	
	local armor_background = health_panel:bitmap({
		name = "armor_background",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {1130,0,208,479},
		layer = 3,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
		color = Color(0,0,0)
	})	
	local armor_bar = health_panel:bitmap({
		name = "armor_bar",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {1130,0,208,479},
		layer = 4,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
	})

	local armor_value = health_panel:text({
		name = "armor_value",
		w = self._armor_value,
		h = self._armor_value,
		font_size = self._armor_value / 2.5,
		text = "100",
		vertical = "bottom",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		layer = 5,
		color = Color.white
	})	
	armor_value:set_bottom(health_value:top() * 1.25)
	
	local condition_timer = custom_player_panel:text({
		name = "condition_timer",
		visible = false,
		w = self._health_value,
		h = health_panel:h(),
		font_size = self._health_value / 1.4,
		text = "15",
		vertical = "bottom",
		align = "center",
		font = "fonts/font_medium_shadow_mf",
		layer = 7,
		color = Color.white
	})
	condition_timer:set_bottom(custom_player_panel:bottom() - 5)
	
	local health_stored_bg = custom_player_panel:bitmap({
		name = "health_stored_bg",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {1408,0,69,473},
		layer = 3,
		w = 0,
		h = health_panel:h(),
		alpha = 1,
		visible = false
	})
	health_stored_bg:set_x(health_panel:x())
	health_stored_bg:set_bottom(custom_player_panel:h())
	local health_stored = custom_player_panel:bitmap({
		name = "health_stored",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {1339,0,69,473},
		layer = 4,
		w = self._health_w / 2.9,
		h = health_panel:h(),
		alpha = 1,
		visible = false
	})
	health_stored:set_right(health_panel:x() + (11 * self._main_scale))
	health_stored:set_bottom(custom_player_panel:h())
	local weapons_panel = custom_player_panel:panel({
		name = "weapons_panel",
		layer = 1,
		w = self._w,
		h = self._bg_h,
		visible = true
	})
	weapons_panel:set_bottom(custom_player_panel:bottom())
	weapons_panel:set_x(self._main_player and health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale) or health_panel:right() - (6 * self._mate_scale))
	
	local weapons_background = weapons_panel:bitmap({
		name = "weapons_background",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {0,0,525,471},
		layer = 1,
		w = weapons_panel:w(),
		h = weapons_panel:h(),
		alpha = 1,
	})	
	local primary_ammo_panel = weapons_panel:panel({
		name = "primary_ammo_panel",
		layer = 1,
		x = 5,
		w = self._w,
		h = self._ammo_panel_h,
	})
	
	local primary_ammo_amount = primary_ammo_panel:text({
		name = "primary_ammo_amount",
		w = self._w,
		h = self._ammo_panel_h,
		font_size = self._ammo_panel_h / 1.4,
		text = "000/000",
		vertical = "center",
		align = self._main_player and"left" or "right",
		font = "fonts/font_large_mf",
		layer = 3,
		alpha = 1,
	})
	primary_ammo_amount:set_left(primary_ammo_panel:left() + (self._main_player and 15 * self._main_scale or -15 * self._mate_scale))
	
	local primary_firemode = primary_ammo_panel:text({
		name = "primary_firemode",
		w = self._w,
		h = self._ammo_panel_h / 1.6,
		font_size = self._ammo_panel_h / 3,
		text = "Semi",
		vertical = "center",
		align = "left",
		font = "fonts/font_large_mf",
		layer = 3,
		visible = self._main_player and true or false
	})
	primary_firemode:set_left(primary_ammo_panel:left() + (87 * self._main_scale))
	
	local primary_pickup = primary_ammo_panel:text({
		name = "primary_pickup",
		visible = self._main_player and true or false,
		w = self._w,
		h = self._ammo_panel_h / 1.35,
		font_size = self._ammo_panel_h / 3.3,
		text = "+1",
		vertical = "bottom",
		align = "left",
		font = "fonts/font_large_mf",
		layer = 3,
		alpha = 0,
		color = Color(0.2, 0.5, 0.2)
	})
	primary_pickup:set_left(primary_ammo_panel:left() + (90 * self._main_scale))
	
	local primary_selected_image = primary_ammo_panel:bitmap({
		name = "primary_selected_image",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {0,479,525,161},
		layer = 1,
		w = self._w,
		h = self._ammo_panel_h,
		alpha = 0,
	})	
		
		
	local secondary_ammo_panel = weapons_panel:panel({
		name = "secondary_ammo_panel",
		layer = 1,
		w = self._w,
		h = self._ammo_panel_h,
	})
	secondary_ammo_panel:set_top(primary_ammo_panel:bottom() + 1 * self._main_scale)
	
	local secondary_ammo_amount = secondary_ammo_panel:text({
		name = "secondary_ammo_amount",
		w = self._w,
		h = self._ammo_panel_h,
		font_size = self._ammo_panel_h / 1.4,
		text = "000/000",
		vertical = "center",
		align = self._main_player and"left" or "right",
		font = "fonts/font_large_mf",
		layer = 3,
		alpha = 1,
	})
	secondary_ammo_amount:set_left(secondary_ammo_panel:left() + (self._main_player and 15 * self._main_scale or -15 * self._mate_scale))
	
	local secondary_firemode = secondary_ammo_panel:text({
		name = "secondary_firemode",
		w = self._w,
		h = self._ammo_panel_h / 1.6,
		font_size = self._ammo_panel_h / 3,
		text = "Semi",
		vertical = "center",
		align = "left",
		font = "fonts/font_large_mf",
		layer = 3,
		visible = self._main_player and true or false
	})
	secondary_firemode:set_left(secondary_ammo_panel:left() + (87 * self._main_scale))
	
	local secondary_pickup = secondary_ammo_panel:text({
		name = "secondary_pickup",
		visible = self._main_player and true or false,
		w = self._w,
		h = self._ammo_panel_h / 1.35,
		font_size = self._ammo_panel_h / 3.3,
		text = "+1",
		vertical = "bottom",
		align = "left",
		font = "fonts/font_large_mf",
		layer = 3,
		alpha = 0,
		color = Color(0.2, 0.5, 0.2)
	})
	secondary_pickup:set_left(secondary_ammo_panel:left() + (90 * self._main_scale))
	
	local secondary_selected_image = secondary_ammo_panel:bitmap({
		name = "secondary_selected_image",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {15,479,525,161},
		layer = 1,
		w = self._w,
		h = self._ammo_panel_h,
		alpha = 0,
	})

	local equipment_panel = weapons_panel:panel({
		name = "equipment_panel",
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
	})
	equipment_panel:set_bottom(weapons_background:bottom())
	
	local equipment_border = equipment_panel:bitmap({
		name = "equipment_border",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {746,479,170,150},
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		alpha = 1,
	})	
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data("equipment_doctor_bag")
	local equipment_image = equipment_panel:bitmap({
		name = "equipment_image",
		texture = icon,
		texture_rect = texture_rect,
		layer = 2,
		w = self._equipment_panel_w / 1.9,
		h = self._equipment_panel_h / 1.5,
		alpha = 0.6,
	})
	equipment_image:set_center(equipment_border:center())
	local equipment_count = equipment_panel:text({
		name = "equipment_count",
		w = self._equipment_panel_w / 1.2,
		h = self._equipment_panel_h,
		font_size = self._equipment_panel_h / 2,
		text = "x0",
		vertical = "bottom",
		align = "right",
		font = "fonts/font_medium_shadow_mf",
		layer = 3,
		alpha = 1,
	})
	
	
	local ties_panel = weapons_panel:panel({
		name = "ties_panel",
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
	})
	equipment_panel:set_bottom(weapons_background:bottom())
	ties_panel:set_left(equipment_panel:right() - (self._main_player and 2 * self._main_scale or 2 * self._mate_scale))
	
	local ties_border = ties_panel:bitmap({
		name = "ties_border",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {746,479,170,150},
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		alpha = 1,
	})
	ties_panel:set_bottom(weapons_background:bottom())
	
	local texture, rect = tweak_data.hud_icons:get_icon_data(tweak_data.equipments.specials.cable_tie.icon)
	
	local ties_image = ties_panel:bitmap({
		name = "ties_image",
		texture = texture,
		texture_rect = rect,
		layer = 2,
		w = self._equipment_panel_w / 1.5,
		h = self._equipment_panel_h / 1.5,
		alpha = 0.6,
	})
	ties_image:set_center(ties_border:center())
	local ties_count = ties_panel:text({
		name = "ties_count",
		w = self._equipment_panel_w / 1.2,
		h = self._equipment_panel_h,
		font_size = self._equipment_panel_h / 2,
		text = "x0",
		vertical = "bottom",
		align = "right",
		font = "fonts/font_medium_shadow_mf",
		layer = 3,
		alpha = 1,
	})
	
	
	local grenades_panel = weapons_panel:panel({
		name = "grenades_panel",
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
	})
	grenades_panel:set_bottom(weapons_background:bottom())
	grenades_panel:set_left(ties_panel:right() - (self._main_player and 2 * self._main_scale or 2 * self._mate_scale))
	
	local grenades_border = grenades_panel:bitmap({
		name = "grenades_border",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {746,479,170,150},
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		alpha = 1,
	})
	grenades_panel:set_bottom(weapons_background:bottom())
	
	local texture, rect = tweak_data.hud_icons:get_icon_data("frag_grenade")
	local grenades_image = grenades_panel:bitmap({
		name = "grenades_image",
		texture = texture,
		texture_rect = rect,
		layer = 2,
		w = self._equipment_panel_w / 1.7,
		h = self._equipment_panel_h / 1.5,
		alpha = 0.6,
	})
	grenades_image:set_center(grenades_border:center())
	local grenades_count = grenades_panel:text({
		name = "grenades_count",
		w = self._equipment_panel_w / 1.2,
		h = self._equipment_panel_h,
		font_size = self._equipment_panel_h / 2,
		text = "",
		vertical = "bottom",
		align = "right",
		font = "fonts/font_medium_shadow_mf",
		layer = 4,
		alpha = 1,
	})	
	local cooldown_panel = grenades_panel:panel({
		name = "cooldown_panel",
		layer = 1,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		visible = false
	})
	
	local cooldown_border = cooldown_panel:bitmap({
		name = "cooldown_border",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {746,479,170,150},
		layer = 2,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		alpha = 1,
		color = Color(1,0,0)
	})
	local cooldown_bg = cooldown_panel:bitmap({
		name = "cooldown_bg",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {553,479,169,149},
		layer = -10,
		w = self._equipment_panel_w,
		h = self._equipment_panel_h,
		alpha = 0.8,
		color = Color(0.5,0,0)
	})
	local cooldown_image = cooldown_panel:bitmap({
		name = "cooldown_image",
		texture = texture,
		texture_rect = rect,
		layer = 2,
		w = self._equipment_panel_w / 1.7,
		h = self._equipment_panel_h / 1.5,
		alpha = 1,
		color = Color(1,0,0)
	})
	cooldown_image:set_center(cooldown_border:center())
	local carry_panel = custom_player_panel:panel({
		name = "carry_panel",
		visible = false,
		layer = 1,
		w = 140 * self._mate_scale,
		h = 23 * self._mate_scale,
		x = 10 * self._mate_scale
	})
	carry_panel:set_bottom(health_panel:top() - 35 * self._mate_scale)
	carry_panel:bitmap({
		name = "bag",
		texture = "guis/textures/pd2/hud_tabs",
		w = 20 * self._mate_scale,
		h = 20 * self._mate_scale,
		texture_rect = {32, 33, 32, 31},
		visible = true,
		layer = 0,
		color = Color.white,
		x = 1,
		y = 1
	})
	carry_panel:text({
		name = "name",
		visible = true,
		text = "",
		layer = 0,
		color = Color.white,
		x = 22  * self._mate_scale,
		h = 23  * self._mate_scale,
		vertical = "center",
		font_size = 18 * self._mate_scale,
		font = "fonts/font_medium_shadow_mf"
	})
	
	local interact_panel = custom_player_panel:panel({
		name = "interact_panel",
		visible = false,
		layer = 1,
	})
	interact_panel:set_bottom(health_panel:bottom())
	local interact_text = interact_panel:text({
		name = "interact_text",
		text = string.upper(managers.localization:text("hud_action_generic")),
		layer = 3,
		color = Color.white,
		vertical = "bottom",
		align = "left",
		font_size = 19,
		font = "fonts/font_medium_shadow_mf"
	})
	interact_text:set_bottom(health_panel:top() - 1)
	interact_text:set_x(9 * self._mate_scale)
	local interact_bar = interact_panel:bitmap({
		name = "interact_bar",
		texture = "guis/textures/pd2/skilltree/bg_mastermind",
		texture_rect = {1130,0,208,479},
		layer = 4,
		w = health_panel:w(),
		h = health_panel:h(),
		alpha = 1,
	})
	local interact_time = interact_panel:text({
		name = "interact_time",
		w = self._health_value,
		h = self._health_value,
		font_size = self._health_value / 1.9,
		text = "3s",
		vertical = "bottom",
		align = "center",
		font = "fonts/font_medium_noshadow_mf",
		layer = 6,
		color = Color.white
	})	
	interact_time:set_bottom(self._custom_player_panel:bottom() - 3)
	self:set_info_visible()
end

function HUDTeammate:whisper_mode_changed()
	self:set_info_visible()
end
	
function HUDTeammate:set_bodybags()
	local health_panel = self._custom_player_panel:child("health_panel")
	local detect_value = health_panel:child("detect_value")
	detect_value:set_text("x"..tostring(managers.player:get_body_bags_amount()))
end

function HUDTeammate:set_info_visible()
	local health_panel = self._custom_player_panel:child("health_panel")
	local detect_value = health_panel:child("detect_value")
	local downs_value = health_panel:child("downs_value")
	local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
	local visible = true
	if self._ai then
		detect_value:set_visible(false)
		downs_value:set_visible(false)
	else
		if is_whisper_mode == true then
			if self._main_player then visible = HeistHUD.options.main_stealth 
			else visible = HeistHUD.options.mate_stealth end
			detect_value:set_visible(visible)
			downs_value:set_visible(false)
		elseif is_whisper_mode == false then
			if self._main_player then visible = HeistHUD.options.main_loud
			else visible = HeistHUD.options.mate_loud end
			detect_value:set_visible(false)
			downs_value:set_visible(visible)
		end
	end
end
function HUDTeammate:set_detection()
	local health_panel = self._custom_player_panel:child("health_panel")
	local detect_value = health_panel:child("detect_value")
	local downs_value = health_panel:child("downs_value")
	local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
	
	if self:peer_id() then
		detect_value:set_text(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_peer(managers.network:session():peer(self:peer_id()), tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100).."%")
	end
end
function HUDTeammate:set_state(state)
	local is_player = state == "player"
	local health_panel = self._custom_player_panel:child("health_panel")
	local name = self._custom_player_panel:child("name")
	local name_shadow = self._custom_player_panel:child("name_shadow")
	local downs_value = health_panel:child("downs_value")
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
	local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
	if not self._main_player then
		if is_player then
			name:set_bottom(health_panel:top() - 1)
			name:set_x(9 * self._mate_scale)
			name_shadow:set_position(name:x() + 1, name:y() + 1)
			name:show()
			name_shadow:show()
			weapons_panel:show()
			local peer = managers.network:session():peer(self:peer_id())
			local outfit = peer and peer:blackmarket_outfit()
			local skills = outfit and outfit.skills
			skills = skills and skills.skills
			self._downs_max = tweak_data.player.damage.LIVES_INIT - 1 - (managers.job:current_difficulty_stars() == 6 and 2 or 0) + (tonumber(skills[14]) >= 3 and 1 or 0)
			self:reset_downs()
		else
			name:set_bottom(health_panel:top() - 1)
			name:set_x(9 * self._mate_scale)
			name_shadow:set_position(name:x() + 1, name:y() + 1)
			name:show()
			name_shadow:show()
			weapons_panel:hide()
		end
	else
		weapons_panel:show()
	end
	managers.hud:align_teammate_panels()
end
function HUDTeammate:color_id()
	return self._color_id
end

function HUDTeammate:set_callsign(id)
	self._color_id = id
	
	local name = self._custom_player_panel:child("name")
	local health_panel = self._custom_player_panel:child("health_panel")
	local health_background = health_panel:child("health_background")
	local health_stored_bg =  self._custom_player_panel:child("health_stored_bg")
	local health_bar = health_panel:child("health_bar")
	local health_value = health_panel:child("health_value")
	local downs_value = health_panel:child("downs_value")
	local detect_value = health_panel:child("detect_value")
	local armor_value = health_panel:child("armor_value")
	local color = tweak_data.chat_colors[id] or Color.white
	
	name:set_color(color)
	health_background:set_color(color * 0.2 + Color.black)
	health_stored_bg:set_color(color * 0.4 + Color.black)
	health_bar:set_color(color * 0.7 + Color.black * 0.9)
	armor_value:set_color(color * 0.4 + Color.black * 0.5)
	health_value:set_color(color * 0.4 + Color.black * 0.5)
	downs_value:set_color(color * 0.8 + Color.black * 0.5)
	detect_value:set_color(color * 0.8 + Color.black * 0.5)
	
	if not self._whisper_listener then
		self._whisper_listener = "HUDTeammate_whisper_mode_"..self._id
		managers.groupai:state():add_listener(self._whisper_listener, {
			"whisper_mode"
		}, callback(self, self, "whisper_mode_changed"))
	end
	self:set_detection()
end

function HUDTeammate:set_name(teammate_name)
	local name = self._custom_player_panel:child("name")
	local name_shadow = self._custom_player_panel:child("name_shadow")
	local peer = managers.network:session():peer(self:peer_id())
	local level = "" 
	if HeistHUD.options.mate_name and peer then 
		level = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "Ї" or "" ) .. (peer:level() and peer:level().. " " or (self:ai() and "" or " "))
	end
	name:set_font_size(19 * (self._mate_scale < 1 and self._mate_scale or 1))
	name_shadow:set_font_size(19 * (self._mate_scale < 1 and self._mate_scale or 1))
	name:set_text(level .. teammate_name)
	name_shadow:set_text(level .. teammate_name)
	local _, _, name_w,name_h = name:text_rect()
	if not self:ai() and name_w > (self._mate_scale < 1 and 140 * self._mate_scale or 140) then 
		name:set_font_size(name:font_size() * ((self._mate_scale < 1 and 140 * self._mate_scale or 140)/name_w)) 	
	elseif self:ai() and name_w > 40 then name:set_font_size(name:font_size() * (40/name_w)) name:set_x(0) name_shadow:set_x(1) end
	if not self:ai() then name:set_range_color(0, utf8.len(level), Color.white:with_alpha(1)) end
	name_shadow:set_font_size(name:font_size())
	name:set_h(name_h)
	name_shadow:set_h(name_h)
	local h = name:h()
	managers.hud:make_fine_text(name)
	managers.hud:make_fine_text(name_shadow)
	name:set_h(name_h)
	name_shadow:set_h(name_h)
end

function HUDTeammate:set_ai(ai)
	self._ai = ai
	self:set_info_visible(true)
end

function HUDTeammate:ai()
	return self._ai
end
function HUDTeammate:set_cheater(state)
	self._custom_player_panel:child("name"):set_color(state and tweak_data.screen_colors.pro_color or Color.white)
end

function HUDTeammate:set_condition(icon_data, text)
	local health_panel = self._custom_player_panel:child("health_panel")
	local condition_icon = health_panel:child("condition_icon")
	local health_value = health_panel:child("health_value")
	local downs_value = health_panel:child("downs_value")
	if icon_data == "mugshot_normal" then
		condition_icon:set_visible(false)
		health_value:set_visible(true)
		self:set_info_visible(self._ai == false and false or true)
	else
		if icon_data == "mugshot_in_custody" then
			downs_value:set_visible(false)
			self:reset_downs()
		end
		condition_icon:set_visible(true)
		health_value:set_visible(false)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon_data)
		condition_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end
end

function HUDTeammate:round(number)
	local dec = number - math.floor(number)
	if dec >= 0.5 then
		return math.ceil(number)
	else
		return math.floor(number)
	end
end
function HUDTeammate:set_health(data)
	local health_stored = self._custom_player_panel:child("health_stored")
	local health_stored_bg = self._custom_player_panel:child("health_stored_bg")
	local health_panel = self._custom_player_panel:child("health_panel")
	local health_background = health_panel:child("health_background")
	local health_bar = health_panel:child("health_bar")
	local health_value = health_panel:child("health_value")
	local percentage = math.floor((data.current / data.total) * 100)
	if percentage > 100 then percentage = 100 end
	local show_health = self._main_player and HeistHUD.options.main_health or HeistHUD.options.mate_health
	health_value:stop()
	health_value:animate(function(o)
		local current_percentage = (health_bar:h() / self._bg_h) * 100
		local hp_value = ""
		over(0.2, function(p)
			if alive(health_bar) then
				value = math.floor(math.lerp(current_percentage, percentage, p))
				if show_health == 2 then hp_value = math.floor(value)
				elseif show_health == 3 then hp_value = self:round((data.total * 10) * (value / 100)) end
				value = value / 100
				health_bar:set_h(self._bg_h * value)
				health_bar:set_texture_rect(727, 0 + ((1- value) * 472),202,472 * value)
				health_bar:set_bottom(health_background:bottom())
				health_value:set_text(hp_value)
				
				health_stored_bg:set_bottom(math.clamp(health_panel:y() + health_bar:top(), health_panel:top() + health_stored_bg:h(), health_panel:bottom()))
				health_stored:set_bottom(health_stored_bg:bottom())
				health_stored_bg:set_texture_rect(1408,(((health_stored_bg:y() - health_panel:y()) / self._bg_h) * 473),69,473 * (health_stored_bg:h() / self._bg_h))
				health_stored:set_texture_rect(1408,(((health_stored:y() - health_panel:y()) / self._bg_h) * 473),69,473 * (health_stored:h() / self._bg_h))
			end
		end)
	end)
end

function HUDTeammate:_damage_taken()
	local health_panel = self._custom_player_panel:child("health_panel")
	local health_shade = health_panel:child("health_shade")
	health_shade:stop()
	health_shade:animate(callback(self, self, "_animate_damage_taken"))
end
function HUDTeammate:_animate_damage_taken(health_shade)
	health_shade:set_color(Color(1,0,0))
	local st = 3
	local t = st
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		health_shade:set_color(Color(t / st, 0, 0))
	end
	health_shade:set_color(Color(0,0,0))
end

function HUDTeammate:set_custom_radial(data)
	local health_panel = self._custom_player_panel:child("health_panel")
	local health_background = health_panel:child("health_background")
	local custom_bar = health_panel:child("custom_bar")
	local condition_icon = health_panel:child("condition_icon")
	
	local value = data.current / data.total
	
	if (data.current / data.total) * 100 > 1 then
		custom_bar:show()
		custom_bar:set_h(self._bg_h * value)
		custom_bar:set_texture_rect(726, 0 + ((1- value) * 472),202,472 * value)
		custom_bar:set_bottom(health_background:bottom())
		custom_bar:set_color(Color(0.0, 0.4, 0.4))
		custom_bar:set_alpha(1)
		condition_icon:set_color(Color(0.0, 0.7, 0.7))
	else
		custom_bar:hide()
		condition_icon:set_color(Color(1, 1, 1))
	end
end
function HUDTeammate:set_armor(data)
	local health_panel = self._custom_player_panel:child("health_panel")
	local armor_background = health_panel:child("armor_background")
	local armor_bar = health_panel:child("armor_bar")
	local armor_value = health_panel:child("armor_value")
	local percentage = math.ceil((data.current / data.total) * 100)
	if percentage > 100 then percentage = 100 end
	local value = percentage / 100
	
	armor_bar:set_h(self._bg_h * value)
	armor_bar:set_texture_rect(1130,0 + ((1- value) * 479),208,479 * value)
	armor_bar:set_bottom(armor_background:bottom())
	
	local arm_value = ""
	if HeistHUD.options.armor == 2 then arm_value = self:round(value * 100)
	elseif HeistHUD.options.armor == 3 then arm_value = self:round((data.total * 10) * value) end
	armor_value:set_text(arm_value)
	
	if (data.current / data.total) * 100 < 1 then
		armor_bar:set_h(0)
		armor_value:set_text("")
	end
	
	if self._main_player and HeistHUD.options.main_health == 1 or HeistHUD.options.mate_health == 1 then
		armor_value:set_w(self._health_value)
		armor_value:set_font_size(self._armor_value / 2)
		armor_value:set_bottom(health_panel:h() - 5)
	else
		armor_value:set_w(self._armor_value)
		armor_value:set_font_size(self._armor_value / 2.5)
		armor_value:set_bottom(health_panel:child("health_value"):top() * 1.25)
	end
end

function HUDTeammate:_set_weapon_selected(id, hud_icon)
	local is_secondary = id == 1
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
	local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
	local primary_selected_image = primary_ammo_panel:child("primary_selected_image")
	local secondary_selected_image = secondary_ammo_panel:child("secondary_selected_image")
	
	if not self._main_player then
		primary_ammo_panel:child("primary_selected_image"):set_rotation(180)
		primary_ammo_panel:child("primary_selected_image"):set_texture_rect(26,479,525,161)
		secondary_ammo_panel:child("secondary_selected_image"):set_rotation(180)
		secondary_ammo_panel:child("secondary_selected_image"):set_texture_rect(25,479,525,161)
	end

	primary_ammo_panel:animate(function(o)
		local x = primary_ammo_panel:x()
		local x2 = is_secondary and (self._main_player and 20 * self._main_scale or -20 * self._mate_scale) or 0
		over(0.2, function(p)
			if alive(primary_ammo_panel) then
				primary_ammo_panel:set_x(math.lerp(x, x2, p))
			end
		end)
	end)
	secondary_ammo_panel:animate(function(o)
		local x = secondary_ammo_panel:x()
		local x2 = is_secondary and (self._main_player and 0 or -2 * self._mate_scale) or (self._main_player and 25 * self._main_scale or -20 * self._mate_scale)
		over(0.2, function(p)
			if alive(secondary_ammo_panel) then
				secondary_ammo_panel:set_x(math.lerp(x, x2, p))
			end
		end)
	end)
	
	primary_selected_image:animate(function(o)
		local a = primary_selected_image:alpha()
		local a2 = is_secondary and 0 or 1
		over(0.2, function(p)
			if alive(primary_selected_image) then
				primary_selected_image:set_alpha(math.lerp(a, a2, p))
			end
		end)
	end)
	secondary_selected_image:animate(function(o)
		local a = secondary_selected_image:alpha()
		local a2 = is_secondary and 1 or 0
		over(0.2, function(p)
			if alive(secondary_selected_image) then
				secondary_selected_image:set_alpha(math.lerp(a, a2, p))
			end
		end)
	end)
end

function HUDTeammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max)
	local selected_ammo_panel = self._custom_player_panel:child("weapons_panel"):child(type.."_ammo_panel")
	local ammo_amount = selected_ammo_panel:child(type.."_ammo_amount")
	local ammo_image = selected_ammo_panel:child(type.."_selected_image")
	local pickup = selected_ammo_panel:child(type.."_pickup")
	local color = Color.white
	
	local current_left_total = current_left
	local max_total = max
	if (HeistHUD.options.totalammo or false) == true and self._main_player and ((type == "primary" and managers.blackmarket:equipped_primary().weapon_id ~= "saw") or (type == "secondary" and managers.blackmarket:equipped_secondary().weapon_id ~= "saw_secondary")) then
		current_left = current_left - current_clip
		max = max - max_clip
	end

	ammo_amount:set_text(string.gsub("000", "0", "", string.len(tostring(current_clip))).. tostring(current_clip).."/"..string.gsub("000", "0", "", string.len(tostring(current_left)))..tostring(current_left)) 
	ammo_amount:set_color(Color(1, (current_left_total/max_total) / 0.4,(current_left_total/max_total) / 0.4)) 
	ammo_image:set_color(Color(1, (current_left_total/max_total) / 0.4,(current_left_total/max_total) / 0.4)) 
	
	if HeistHUD.options.ammo_pickup and type == "primary" and self._primary_max < current_left and current_left - self._primary_max ~= 0 then
		pickup:stop()
		pickup:animate(callback(self, self, "_animate_pickup"))
		pickup:set_text("+".. string.sub(pickup:text(), 2) + current_left - self._primary_max) 
	elseif HeistHUD.options.ammo_pickup and type == "secondary" and self._secondary_max < current_left and current_left - self._secondary_max ~= 0 then
		pickup:stop()
		pickup:animate(callback(self, self, "_animate_pickup"))
		pickup:set_text("+".. string.sub(pickup:text(), 2) + current_left - self._secondary_max) 
	end
	if type == "primary" then self._primary_max = current_left else self._secondary_max = current_left end
end

function HUDTeammate:_animate_pickup(pickup)
	local TOTAL_T = 0.3
	local t = 0
	local a = pickup:alpha()
	if pickup:alpha() < 1 then 
		while TOTAL_T >= t do
			local dt = coroutine.yield()
			t = t + dt
			pickup:set_alpha(math.lerp(a, 1, t / TOTAL_T))
		end
	end
	wait(1.5)
	pickup:set_text("+0")
	pickup:set_alpha(0)
end
function HUDTeammate:get_firemode()
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
	local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
	local primary_firemode = primary_ammo_panel:child("primary_firemode")
	local secondary_firemode = secondary_ammo_panel:child("secondary_firemode")
	local is_primary_auto = tweak_data.weapon[managers.blackmarket:equipped_primary().weapon_id].FIRE_MODE == "auto"
	local is_sec_auto = tweak_data.weapon[managers.blackmarket:equipped_secondary().weapon_id].FIRE_MODE == "auto"
	primary_firemode:set_text(is_primary_auto and "Auto" or "Semi")
	secondary_firemode:set_text(is_sec_auto and "Auto" or "Semi")
	
end

function HUDTeammate:set_weapon_firemode(id, firemode)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
	local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
	local primary_firemode = primary_ammo_panel:child("primary_firemode")
	local secondary_firemode = secondary_ammo_panel:child("secondary_firemode")
	if id == 2 then
		if firemode == "single" then
			primary_firemode:set_text("Semi")
		else
			primary_firemode:set_text("Auto")
		end
	else
		if firemode == "single" then
			secondary_firemode:set_text("Semi")
		else
			secondary_firemode:set_text("Auto")
		end
	end
end

function HUDTeammate:set_cable_ties_amount(amount)
	local visible = amount ~= 0
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local ties_panel = weapons_panel:child("ties_panel")
	local ties_border = ties_panel:child("ties_border")
	local ties_image = ties_panel:child("ties_image")
	local ties_amount = ties_panel:child("ties_count")
	if amount == -1 then
		ties_amount:set_text("x0")
	elseif amount == 0 then
		ties_amount:set_text("")
		ties_amount:set_color(Color(1,0,0))
		ties_border:set_color(Color(1,0,0))
		ties_image:set_color(Color(1,0,0))
	else
		ties_amount:set_text("x"..amount)
		ties_amount:set_color(Color.white)
		ties_border:set_color(Color.white)
		ties_image:set_color(Color.white)
	end
end

function HUDTeammate:set_deployable_equipment(data)
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local equipment_panel = weapons_panel:child("equipment_panel")
	local equipment_image = equipment_panel:child("equipment_image")
	equipment_image:set_image(icon, unpack(texture_rect))
	self:set_deployable_equipment_amount(1, data)
end

function HUDTeammate:set_deployable_equipment_from_string(data)
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local equipment_panel = weapons_panel:child("equipment_panel")
	local equipment_image = equipment_panel:child("equipment_image")
	equipment_image:set_image(icon, unpack(texture_rect))
	self:set_deployable_equipment_amount_from_string(1, data)
end

function HUDTeammate:set_deployable_equipment_amount(index, data)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local equipment_panel = weapons_panel:child("equipment_panel")
	local equipment_image = equipment_panel:child("equipment_image")
	local equipment_count = equipment_panel:child("equipment_count")
	local equipment_border = equipment_panel:child("equipment_border")

	if data.amount == 0 then
		equipment_count:set_text("")
		equipment_count:set_color(Color(1,0,0))
		equipment_border:set_color(Color(1,0,0))
		equipment_image:set_color(Color(1,0,0))
	else
		equipment_count:set_text("x"..data.amount)
		equipment_count:set_color(Color.white)
		equipment_border:set_color(Color.white)
		equipment_image:set_color(Color.white)
	end
end	

function HUDTeammate:set_deployable_equipment_amount_from_string(index, data)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local equipment_panel = weapons_panel:child("equipment_panel")
	local equipment_image = equipment_panel:child("equipment_image")
	local equipment_count = equipment_panel:child("equipment_count")
	local equipment_border = equipment_panel:child("equipment_border")
	local visible = false
	for i = 1, #data.amount do
		if data.amount[i] > 0 then
			visible = true
		end
	end
	if visible then
		equipment_count:set_color(Color.white)
		equipment_border:set_color(Color.white)
		equipment_image:set_color(Color.white)
	else
		equipment_count:set_color(Color(1,0,0))
		equipment_border:set_color(Color(1,0,0))
		equipment_image:set_color(Color(1,0,0))
	end
	
	equipment_count:set_visible(visible)
	equipment_count:set_text(data.amount_str)
end

function HUDTeammate:set_grenades(data)
	if not PlayerBase.USE_GRENADES then
		grenades_count:set_text("")
		grenades_border:set_color(Color(1,0,0))
		grenades_image:set_color(Color(1,0,0))
	end
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local grenades_panel = weapons_panel:child("grenades_panel")
	local grenades_image = grenades_panel:child("grenades_image")
	local cooldown_image = grenades_panel:child("cooldown_panel"):child("cooldown_image")
	local grenades_count = grenades_panel:child("grenades_count")
	local grenades_border = grenades_panel:child("grenades_border")
	grenades_image:set_image(icon, unpack(texture_rect))
	cooldown_image:set_image(icon, unpack(texture_rect))
	self:set_grenades_amount(data)
end

function HUDTeammate:set_grenades_amount(data)
	if not PlayerBase.USE_GRENADES then
		return
	end
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local grenades_panel = weapons_panel:child("grenades_panel")
	local grenades_image = grenades_panel:child("grenades_image")
	local grenades_count = grenades_panel:child("grenades_count")
	local grenades_border = grenades_panel:child("grenades_border")
	
	if data.amount == 0 then
		grenades_count:set_text("")
		grenades_count:set_color(Color(1,0,0))
		grenades_border:set_color(Color(1,0,0))
		grenades_image:set_color(Color(1,0,0))
	elseif data.icon ~= "smoke_screen_grenade" and data.icon ~= "chico_injector" then
		grenades_count:set_text("x"..data.amount)
		grenades_count:set_color(Color.white)
		grenades_border:set_color(Color.white)
		grenades_image:set_color(Color.white)
	end
end

function HUDTeammate:set_ability_cooldown(data)
	if not PlayerBase.USE_GRENADES then
		return
	end
	data.cooldown = data.cooldown and math.ceil(data.cooldown) or 0
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local grenades_panel = weapons_panel:child("grenades_panel")
	local cooldown_panel = grenades_panel:child("cooldown_panel")
	local grenades_image = grenades_panel:child("grenades_image")
	local grenades_count = grenades_panel:child("grenades_count")
	local grenades_border = grenades_panel:child("grenades_border")
	if data.cooldown > 0 then
		if self._max_cooldown == 0 then self._max_cooldown = data.cooldown end
		grenades_count:set_visible(true)
		cooldown_panel:set_visible(true)
		cooldown_panel:stop()
		cooldown_panel:animate(function(o)
			local h = cooldown_panel:h()
			local h2 = self._equipment_panel_h * (data.cooldown / self._max_cooldown)
			over(1, function(p)
				if alive(cooldown_panel) then
					cooldown_panel:set_h(math.lerp(h, h2, p))
				end
			end)
		end)
		grenades_border:set_color(Color(1,0.8,0.8))
		grenades_image:set_color(Color(1,0.8,0.8))
	else
		grenades_count:set_visible(false)
		cooldown_panel:set_visible(false)
		cooldown_panel:stop()
		cooldown_panel:set_h(self._equipment_panel_h)
		grenades_border:set_color(Color.white)
		grenades_image:set_color(Color.white)
	end
	grenades_count:set_text(data.cooldown)
end

function HUDTeammate:set_ability_radial(data)
	local health_panel = self._custom_player_panel:child("health_panel")
	local custom_bar = health_panel:child("custom_bar")
	local percentage = data.current / data.total
	custom_bar:set_color(Color(1, 0.6, 0))
	custom_bar:set_alpha(0.5)
	custom_bar:set_visible(percentage > 0)
	custom_bar:set_h(self._bg_h * percentage)
	custom_bar:set_texture_rect(726, 0 + ((1 - percentage) * 472),202,472 * percentage)
	custom_bar:set_bottom(health_panel:child("health_background"):bottom())
end

function HUDTeammate:activate_ability_radial(time)
	local health_panel = self._custom_player_panel:child("health_panel")
	local custom_bar = health_panel:child("custom_bar")
	local function anim(o)
		custom_bar:set_visible(true)
		custom_bar:set_color(Color(1, 0.6, 0))
		custom_bar:set_alpha(0.5)
		over(time, function(p)
			custom_bar:set_h(math.lerp(self._bg_h, 0, p))
			custom_bar:set_texture_rect(726, math.lerp(0, 472, p),202,math.lerp(472, 0, p))
			custom_bar:set_bottom(health_panel:child("health_background"):bottom())
		end)
		custom_bar:set_visible(false)
	end
	custom_bar:animate(anim)
end

function HUDTeammate:add_special_equipment(data)
	local special_equipment = self._special_equipment
	local id = data.id
	local equipment_panel = self._custom_player_panel:panel({
		name = id,
		layer = 0,
		y = 0
	})
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	if self._main_player then equipment_panel:set_size(25 * math.clamp(self._main_scale, 0.65 , 1), 25 * math.clamp(self._main_scale, 0.65 , 1)) else equipment_panel:set_size(18 * math.clamp(self._mate_scale, 0.65 , 1), 18 * math.clamp(self._mate_scale, 0.65 , 1)) end
	local bitmap = equipment_panel:bitmap({
		name = "bitmap",
		texture = icon,
		color = Color.white,
		layer = 1,
		texture_rect = texture_rect,
		w = 0,
		h = 0,
		rotation = 360
	})
	
	bitmap:animate(function(o)
		local w = 0
		local w2 = equipment_panel:w()
		over(0.3, function(p)
			if alive(bitmap) then
				bitmap:set_size(math.lerp(w, w2, p), math.lerp(w, w2, p))
				bitmap:set_x(equipment_panel:w() / 2 - bitmap:w() / 2)
				bitmap:set_y(equipment_panel:w() / 2 - bitmap:h() / 2)
			end
		end)
	end)
	local amount, amount_bg
	if data.amount then
		amount = equipment_panel:child("amount") or equipment_panel:text({
			name = "amount",
			text = "x"..tostring(data.amount),
			font = "fonts/font_small_shadow_mf",
			font_size = self._main_player and 12 or 10,
			align = "right",
			vertical = "bottom",
			layer = 4,
			w = equipment_panel:w(),
			h = equipment_panel:h() + 3
		})
		amount:set_visible(1 < data.amount)
		
		amount_bg = equipment_panel:child("amount_bg") or equipment_panel:bitmap({
			name = "amount_bg",
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			valign = "scale",
			layer = 3
		})
		amount_bg:set_visible(1 < data.amount)
	end
	table.insert(special_equipment, equipment_panel)
	local w = self._custom_player_panel:w()
	if self._main_player then equipment_panel:set_x(w - (equipment_panel:w() + 0) * 1) else equipment_panel:set_x(0) end
	if amount then
		local _, _, amount_w, _ = amount:text_rect()
		amount_bg:set_w(amount_w)
		amount_bg:set_h(self._main_player and 13 or 8)
		amount_bg:set_right(self._main_player and 20 or 18)
		amount_bg:set_bottom(self._main_player and 20 or 18)
	end
	self:layout_special_equipments()
end

function HUDTeammate:set_special_equipment_amount(equipment_id, amount)
	local special_equipment = self._special_equipment
	for i, panel in ipairs(special_equipment) do
		if panel:name() == equipment_id then
			panel:child("amount"):set_text("x"..tostring(amount))
			panel:child("amount"):set_visible(amount > 1)
			panel:child("amount_bg"):set_visible(amount > 1)
			return
		end
	end
end

function HUDTeammate:layout_special_equipments()
	local special_equipment = self._special_equipment
	local name = self._custom_player_panel:child("name")
	local w = self._custom_player_panel:w()
	for i, panel in ipairs(special_equipment) do
		if self._main_player then
			panel:stop()
			panel:animate(function(o)
				local x = panel:x()
				local x2 = (w - (panel:w() + 0) * (#special_equipment - (i - 1)))
				over(0.2, function(p)
					if alive(panel) then
						panel:set_x(math.lerp(x, x2, p))
					end
				end)
			end)
			panel:set_bottom(self._custom_player_panel:child("health_panel"):top() - 2)
		else
			panel:stop()
			panel:animate(function(o)
				local x = panel:x()
				local x2 = (-8 + panel:w() * (#special_equipment - (i - 1)))
				over(0.2, function(p)
					if alive(panel) then
						panel:set_x(math.lerp(x, x2, p))
					end
				end)
			end)
			panel:set_bottom(self._custom_player_panel:child("health_panel"):top() - 19)
		end
	end
end

function HUDTeammate:remove_special_equipment(equipment)
	local special_equipment = self._special_equipment
	for i, panel in ipairs(special_equipment) do
		if panel:name() == equipment then
			local data = table.remove(special_equipment, i)
			self._custom_player_panel:remove(panel)
			self:layout_special_equipments()
			return
		end
	end
end

function HUDTeammate:create_waiting_panel(parent_panel)
	local PADD = 2
	local panel = parent_panel:panel()
	print(self._panel:lefttop())
	print(panel:lefttop())
	print(self._panel:world_x(), self._panel:world_y())
	print(panel:world_x(), panel:world_y())
	panel:set_visible(flase)
	panel:set_lefttop(self._panel:lefttop())
	local name = panel:text({
		name = "name",
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.hud_players.name_font
	})
	local player_panel = self._panel:child("player")
	local health_panel = player_panel:child("radial_health_panel")
	local detection = panel:panel({
		name = "detection",
		w = health_panel:w(),
		h = health_panel:h()
	})
	detection:set_lefttop(health_panel:lefttop())
	local detection_ring_left_bg = detection:bitmap({
		name = "detection_left_bg",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		alpha = 0.2,
		blend_mode = "add",
		w = detection:w(),
		h = detection:h()
	})
	local detection_ring_right_bg = detection:bitmap({
		name = "detection_right_bg",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		alpha = 0.2,
		blend_mode = "add",
		w = detection:w(),
		h = detection:h()
	})
	detection_ring_right_bg:set_texture_rect(detection_ring_right_bg:texture_width(), 0, -detection_ring_right_bg:texture_width(), detection_ring_right_bg:texture_height())
	local detection_ring_left = detection:bitmap({
		name = "detection_left",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		layer = 1,
		w = detection:w(),
		h = detection:h()
	})
	local detection_ring_right = detection:bitmap({
		name = "detection_right",
		texture = "guis/textures/pd2/mission_briefing/inv_detection_meter",
		render_template = "VertexColorTexturedRadial",
		blend_mode = "add",
		layer = 1,
		w = detection:w(),
		h = detection:h()
	})
	detection_ring_right:set_texture_rect(detection_ring_right:texture_width(), 0, -detection_ring_right:texture_width(), detection_ring_right:texture_height())
	local detection_value = panel:text({
		name = "detection_value",
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		align = "center",
		vertical = "center"
	})
	detection_value:set_center_x(detection:left() + detection:w() / 2)
	detection_value:set_center_y(detection:top() + detection:h() / 2 + 2)
	local bg_rect = {
		84,
		0,
		44,
		32
	}
	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local bg_color = Color.white / 3
	name:set_lefttop(detection:right() + PADD, detection:top())
	local bg = panel:bitmap({
		name = "name_bg",
		texture = tabs_texture,
		texture_rect = bg_rect,
		visible = true,
		layer = -1,
		color = bg_color,
		y = name:y() - PADD
	})
	bg:set_lefttop(detection:right() + PADD, detection:top())
	local deploy_panel = panel:panel({name = "deploy"})
	local throw_panel = panel:panel({name = "throw"})
	local perk_panel = panel:panel({name = "perk"})
	self:_create_equipment(deploy_panel, "frag_grenade")
	self:_create_equipment(throw_panel, "frag_grenade")
	self:_create_equipment(perk_panel, "frag_grenade")
	deploy_panel:set_lefttop(detection:right() + PADD, detection:center_y())
	throw_panel:set_lefttop(deploy_panel:right() + PADD, deploy_panel:top())
	perk_panel:set_lefttop(throw_panel:right() + PADD, deploy_panel:top())
	self._wait_panel = panel
end

function HUDTeammate:teammate_progress(enabled, type_index, tweak_data_id, timer, success)
	self._custom_player_panel:child("interact_panel"):stop()
	self._custom_player_panel:child("interact_panel"):set_visible(enabled)
	local interact_text = self._custom_player_panel:child("interact_panel"):child("interact_text")
	local name = self._custom_player_panel:child("name")
	local name_shadow = self._custom_player_panel:child("name_shadow")
	local prev_text = interact_text:text()
	local prev_size = interact_text:font_size()
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
	interact_text:set_text(" ".. action_text)
	interact_text:set_font_size(19)
	local _,_,text_w,_ = interact_text:text_rect()
	if text_w > 140 then interact_text:set_font_size(interact_text:font_size() * (140/text_w)) end
	self._custom_player_panel:child("health_panel"):child("health_bar"):set_alpha(enabled and 0.3 or 1)
	self._custom_player_panel:child("health_panel"):child("armor_bar"):set_visible(not enabled)
	self._custom_player_panel:child("health_panel"):child("armor_value"):set_visible(not enabled)
	self._custom_player_panel:child("health_panel"):child("health_value"):set_visible(not enabled)
	
	name:stop()
	interact_text:stop()
	name:animate(function(o)
		over(2, function(p)
			if alive(name) then
				name:set_alpha(math.lerp(name:alpha(), enabled == true and 0 or 1, p))
				name_shadow:set_alpha(math.lerp(name:alpha(), enabled == true and 0 or 1, p))
				interact_text:set_alpha(math.lerp(interact_text:alpha(),enabled == true and 1 or 0,p))
			end
		end)
	end)
	if enabled then
		self._custom_player_panel:child("interact_panel"):animate(callback(self, self, "_animate_interact"), self._custom_player_panel:child("interact_panel"):child("interact_bar"), timer)
	elseif success then
		local panel = self._custom_player_panel
		local health_panel = panel:child("health_panel")
		
		local bar = self._custom_player_panel:bitmap({
			texture = "guis/textures/pd2/skilltree/bg_mastermind",
			texture_rect = {1130,0,208,479},
			layer = 4,
			x = health_panel:x(),
			y = health_panel:y(),
			w = health_panel:w(),
			h = health_panel:h(),
			rotation = 360,
			alpha = 1,
		})
		
		local text = self._custom_player_panel:text({
			text = prev_text,
			layer = 3,
			color = Color.white,
			vertical = "bottom",
			align = "left",
			font_size = prev_size,
			rotation = 360,
			font = "fonts/font_medium_shadow_mf"
		})
		text:set_bottom(self._custom_player_panel:child("health_panel"):top() - 1)
		text:set_x(9 * self._mate_scale)
		
		
		name:stop()
		interact_text:stop()
		name:animate(function(o)
			over(2, function(p)
				if alive(name) then
					name:set_alpha(math.lerp(name:alpha(), 1, p))
					name_shadow:set_alpha(math.lerp(name:alpha(), 1, p))
					interact_text:set_alpha(math.lerp(interact_text:alpha(), 0, p))
				end
			end)
		end)
		bar:animate(callback(self, self, "_animate_interact_complete"), text)
	end
end

function HUDTeammate:_animate_interact(panel, interact, timer)
	local t = 0
	local value = t / timer
	local left = timer - t
	while timer >= t do
		local dt = coroutine.yield()
		t = t + dt
		value = t / timer
		left = timer - t
		interact:set_h(self._bg_h * value)
		interact:set_texture_rect(1130,0 + ((1- value) * 479),208,479 * value)
		interact:set_bottom(self._custom_player_panel:bottom())
		if HeistHUD.options.mate_interact and left > 0 then panel:child("interact_time"):set_text(string.format("%.1fs", left))
		else panel:child("interact_time"):set_text("") end
	end
end

function HUDTeammate:_animate_interact_complete(bar, text)
	local TOTAL_T = 1
	local t = 0
	local w = bar:w()
	local h = bar:h()
	local text_s = text:font_size()
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		bar:set_size(math.lerp(w, w * 1.4, t / TOTAL_T), math.lerp(h, h * 1.4, t / TOTAL_T))
		text:set_font_size(math.lerp(text_s, text_s * 1.2, t / TOTAL_T))
		bar:set_center(self._custom_player_panel:child("health_panel"):center())
		bar:set_alpha(math.lerp(1,0, t/ TOTAL_T))
		text:set_alpha(math.lerp(1,0, t/ TOTAL_T))
	end
	self._custom_player_panel:remove(bar)
	self._custom_player_panel:remove(text)
end
function HUDTeammate:set_carry_info(carry_id, value)
	local carry_panel = self._custom_player_panel:child("carry_panel")
	carry_panel:set_visible(true)
	local value_text = carry_panel:child("name")
	value_text:set_text(tweak_data.carry[carry_id].name_id and managers.localization:text(tweak_data.carry[carry_id].name_id or ""))
	
end
function HUDTeammate:remove_carry_info()
	local carry_panel = self._custom_player_panel:child("carry_panel")
	carry_panel:set_visible(false)
end

function HUDTeammate:start_timer(time)
	self._timer_paused = 0
	self._timer = time
	self._custom_player_panel:child("condition_timer"):set_font_size(tweak_data.hud_players.timer_size)
	self._custom_player_panel:child("condition_timer"):set_color(Color.white)
	self._custom_player_panel:child("condition_timer"):stop()
	self._custom_player_panel:child("condition_timer"):set_visible(true)
	self._custom_player_panel:child("health_panel"):child("condition_icon"):set_alpha(0.4)
	self._custom_player_panel:child("condition_timer"):animate(callback(self, self, "_animate_timer"))
end

function HUDTeammate:set_pause_timer(pause)
	if not self._timer_paused then
		return
	end
	self._timer_paused = self._timer_paused + (pause and 1 or -1)
end
function HUDTeammate:stop_timer()
	if not alive(self._panel) then
		return
	end
	self._custom_player_panel:child("condition_timer"):set_visible(false)
	self._custom_player_panel:child("health_panel"):child("condition_icon"):set_alpha(1)
	self._custom_player_panel:child("condition_timer"):stop()
end
function HUDTeammate:is_timer_running()
	return self._custom_player_panel:child("condition_timer"):visible()
end
function HUDTeammate:_animate_timer()
	local rounded_timer = math.round(self._timer)
	while self._timer >= 0 do
		local dt = coroutine.yield()
		if self._timer_paused == 0 then
			self._timer = self._timer - dt
			local text = self._timer < 0 and "00" or (math.round(self._timer) < 10 and "0" or "") .. math.round(self._timer)
			self._custom_player_panel:child("condition_timer"):set_text(text)
			if rounded_timer > math.round(self._timer) then
				rounded_timer = math.round(self._timer)
				if rounded_timer < 11 then
					self._custom_player_panel:child("condition_timer"):animate(callback(self, self, "_animate_timer_flash"))
				end
			end
		end
	end
end

function HUDTeammate:_animate_timer_flash()
	local t = 0
	local condition_timer = self._custom_player_panel:child("condition_timer")
	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		local r = math.lerp(1 or self._point_of_no_return_color.r, 1, n)
		local g = math.lerp(0 or self._point_of_no_return_color.g, 0.8, n)
		local b = math.lerp(0 or self._point_of_no_return_color.b, 0.2, n)
		condition_timer:set_color(Color(r, g, b))
		condition_timer:set_alpha(1)
		condition_timer:set_font_size(math.lerp(tweak_data.hud_players.timer_size, tweak_data.hud_players.timer_flash_size, n))
	end
	condition_timer:set_font_size(30)
end


function HUDTeammate:remove_panel()
	local teammate_panel = self._panel
	teammate_panel:set_visible(false)
	local special_equipment = self._special_equipment
	while special_equipment[1] do
		self._custom_player_panel:remove(table.remove(special_equipment))
	end
	self:set_condition("mugshot_normal")
	self._custom_player_panel:child("weapons_panel"):set_visible(false)
	self._custom_player_panel:child("carry_panel"):set_visible(false)
	self._custom_player_panel:child("carry_panel"):child("name"):set_text("")
	self:set_cheater(false)
	self:set_info_meter({
		current = 0,
		total = 0,
		max = 1
	})
	self:stop_timer()
	self:teammate_progress(false, false, false, false)
	self._peer_id = nil
	self._ai = nil
	self:reset_downs()
end

function HUDTeammate:set_stored_health_max(stored_health_ratio)
	local health_panel = self._custom_player_panel:child("health_panel")
	local weapons_panel = self._custom_player_panel:child("weapons_panel")
	local health_stored = self._custom_player_panel:child("health_stored")
	local health_stored_bg = self._custom_player_panel:child("health_stored_bg")
	local health_stored_max = self._custom_player_panel:child("health_stored_max")
	local value = math.min(stored_health_ratio, 1)
	if alive(health_stored_bg) and value > 0 then	
		health_stored:set_visible(true)
		health_stored:set_w(self._health_w / 2.9)
		
		health_stored_bg:set_visible(true)
		health_stored_bg:set_w(self._health_w / 2.9)
		health_stored_bg:set_h(self._bg_h * value)
		health_stored_bg:set_right(health_panel:x() + (11 * self._main_scale))
		health_stored_bg:set_texture_rect(1408,((1- value) * 473),69,473 * value)
		health_stored_bg:set_bottom(self._custom_player_panel:h())
		
		weapons_panel:set_x(health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale))
		if not health_stored_max then 	
			local health_stored_max = self._custom_player_panel:bitmap({
				name = "health_stored_max",
				texture = "guis/textures/pd2/skilltree/bg_mastermind",
				texture_rect = {1408,0,69,473},
				layer = 1,
				w = self._health_w / 2.9,
				h = self._bg_h,
				alpha = 1,
			})
		else
			health_stored_max:set_color(health_stored_bg:color() * (Color.white * 0.5))
			health_stored_max:set_right(health_panel:x() + (11 * self._main_scale))
			health_stored_max:set_bottom(self._custom_player_panel:h())
		end
	end
end

function HUDTeammate:set_stored_health(stored_health_ratio)
	local health_panel = self._custom_player_panel:child("health_panel")
	local health_stored = self._custom_player_panel:child("health_stored")
	local health_stored_bg = self._custom_player_panel:child("health_stored_bg")
	health_stored:set_color(health_panel:child("health_bar"):color())
	if alive(health_stored) then
		local value = math.min(stored_health_ratio, 1)
		health_stored:animate(function(o)
			local current_value = health_stored:h() / health_panel:h()
			local h = health_stored:h()
			over(0.2, function(p)
				health_stored:set_h(math.lerp(h, health_panel:h() * value, p))
				health_stored:set_bottom(health_stored_bg:bottom())
				health_stored:set_texture_rect(1408,((health_stored:y() - health_panel:y()) / self._bg_h) * 473, 69, 473 * (health_stored:h() / self._bg_h))
			end)
		end)
	end
end

function HUDTeammate:downed()
	local health_panel = self._custom_player_panel:child("health_panel")
	local downs_value = health_panel:child("downs_value")
	if (self._downs > -1) then self._downs = self._downs - 1 end
	downs_value:set_text("x".. tostring(self._downs))
end

function HUDTeammate:reset_downs()
	local health_panel = self._custom_player_panel:child("health_panel")
	local downs_value = health_panel:child("downs_value")
	self._downs = self._downs_max
	downs_value:set_text("x".. tostring(self._downs))
end