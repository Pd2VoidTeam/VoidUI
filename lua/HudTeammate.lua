if VoidUI.options.teammate_panels then 
	local init = HUDTeammate.init
	function HUDTeammate:init(i, teammates_panel, is_player, width) 
		init(self, i, teammates_panel, is_player, width)
		local teammate_panel = self._panel
		self._teammates_panel = teammates_panel
		self._main_scale = VoidUI.options.hud_main_scale
		self._mate_scale = VoidUI.options.hud_mate_scale

		self._w = self._main_player and 145 * self._main_scale or 111 * self._mate_scale
		self._bg_h = self._main_player and 120 * self._main_scale or 92 * self._mate_scale
		self._border_h = self._main_player and 40 * self._main_scale or 0 * self._mate_scale
		self._health_w = self._main_player and 55 * self._main_scale or 41 * self._mate_scale
		self._armor_value = self._main_player and 48 * self._main_scale or 36 * self._mate_scale
		self._health_value = self._main_player and 45 * self._main_scale or 35 * self._mate_scale
		self._ammo_1_w = self._main_player and 138 * self._main_scale or 105 * self._mate_scale
		self._ammo_2_w = self._main_player and 142 * self._main_scale or 108 * self._mate_scale
		self._ammo_panel_h = self._main_player and 39 * self._main_scale or 30 * self._mate_scale
		self._equipment_panel_w = self._main_player and 47 * self._main_scale or 36 * self._mate_scale
		self._equipment_panel_h = self._main_player and 40 * self._main_scale or 30 * self._mate_scale
		self._downs_max = tweak_data.player.damage.LIVES_INIT -(Global.game_settings.difficulty == "sm_wish" and - 2 or 0)
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
		
		local health_texture = "guis/textures/VoidUI/hud_health"
		local health_background = health_panel:bitmap({
			name = "health_background",
			w = health_panel:w(),
			h = health_panel:h(),
			texture = health_texture,
			texture_rect = {0,0,202,472},
			layer = 1
		})
		
		local health_bar = health_panel:bitmap({
			name = "health_bar",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			layer = 2,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
		})
		
		local health_shade = health_panel:bitmap({
			name = "health_shade",
			texture = health_texture,
			texture_rect = {406,0,202,472},
			layer = 4,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
			color = Color.black
		})
		local custom_bar = health_panel:bitmap({
			name = "custom_bar",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			layer = 3,
			w = health_panel:w(),
			h = health_panel:h(),
			visible = false,
			alpha = 1,
			color = Color(0.0, 0.4, 0.4)
		})	
		custom_bar:hide()
		
		local ability_bar = health_panel:bitmap({
			name = "ability_bar",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			layer = 3,
			w = health_panel:w(),
			h = health_panel:h(),
			visible = false,
			alpha = 0.6,
			color = Color(1, 0.6, 0)
		})	
		local delayed_damage_health_bar = health_panel:bitmap({
			name = "delayed_damage_health_bar",
			texture = health_texture,
			texture_rect = {881,0,202,472},
			layer = 3,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
			visible = false,
		})	
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
			texture = health_texture,
			texture_rect = {609,0,201,472},
			layer = 4,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
			color = Color.black,
		})	
		local armor_bar = health_panel:bitmap({
			name = "armor_bar",
			texture = health_texture,
			texture_rect = {609,0,201,472},
			layer = 5,
			w = health_panel:w(),
			h = 0,
			alpha = 1,
		})
		local delayed_damage_armor_bar = health_panel:bitmap({
			name = "delayed_damage_armor_bar",
			texture = health_texture,
			texture_rect = {1084,0,201,472},
			layer = 6,
			w = health_panel:w(),
			h = health_panel:h(),
			color = Color(0.2,0.2,0.2),
			visible = false,
		})
		local armor_value = health_panel:text({
			name = "armor_value",
			w = self._armor_value,
			h = self._armor_value,
			font_size = self._armor_value / 2.5,
			text = "",
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
			font_size = self._health_value / 1.4 * self._mate_scale,
			x = health_panel:x(),
			text = "15",
			vertical = "bottom",
			align = "center",
			font = "fonts/font_medium_noshadow_mf",
			layer = 9,
			color = Color.white
		})
		condition_timer:set_bottom(custom_player_panel:bottom() - 5)
		
		local health_stored_bg = custom_player_panel:bitmap({
			name = "health_stored_bg",
			texture = health_texture,
			texture_rect = {811,0,70,472},
			layer = 3,
			w = 0,
			h = health_panel:h(),
			alpha = 1,
			color = Color(0.6,0.6,0.6),
			visible = false
		})
		health_stored_bg:set_x(health_panel:x())
		health_stored_bg:set_bottom(custom_player_panel:h())
		local health_stored = custom_player_panel:bitmap({
			name = "health_stored",
			texture = health_texture,
			texture_rect = {811,0,70,472},
			layer = 4,
			w = self._health_w / 2.9,
			h = health_panel:h(),
			alpha = 1,
			visible = false
		})
		health_stored:set_right(health_panel:x() + (11 * self._main_scale))
		health_stored:set_bottom(custom_player_panel:h())
		local absorb_color = tweak_data.chat_colors[5]
		local absorb_shield_bar = health_panel:bitmap({
			name = "absorb_shield_bar",
			texture = health_texture,
			texture_rect = {609,0,201,472},
			color = absorb_color,
			layer = 5,
			w = health_panel:w(),
			h = 0,
			alpha = 1,
		})
		local absorb_health_bar = health_panel:bitmap({
			name = "absorb_health_bar",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			color = absorb_color,
			layer = 2,
			w = health_panel:w(),
			h = 0,
			alpha = 1,
		})
		local weapons_panel = custom_player_panel:panel({
			name = "weapons_panel",
			layer = 1,
			w = self._w,
			h = self._bg_h,
			visible = true
		})
		weapons_panel:set_bottom(custom_player_panel:bottom())
		weapons_panel:set_x(self._main_player and health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale) or health_panel:right() - (6 * self._mate_scale))
		self._fore_color = self._main_player and VoidUI:GetColor("c_main_fg") or VoidUI:GetColor("c_mate_fg") 
		local weapons_background = weapons_panel:bitmap({
			name = "weapons_background",
			texture = "guis/textures/VoidUI/hud_weapons",
			layer = 1,
			w = weapons_panel:w(),
			h = weapons_panel:h(),
			alpha = 1,
		})	
		local primary_ammo_panel = weapons_panel:panel({
			name = "primary_ammo_panel",
			layer = 1,
			x = 5,
			w = self._ammo_1_w,
			h = self._ammo_panel_h,
		})
		primary_ammo_panel:set_right(weapons_panel:w())
		local primary_ammo_amount = primary_ammo_panel:text({
			name = "primary_ammo_amount",
			w = self._ammo_1_w,
			h = self._ammo_panel_h,
			font_size = self._ammo_panel_h / 1.4,
			text = "000/000",
			vertical = "center",
			align = self._main_player and"left" or "right",
			font = "fonts/font_large_mf",
			color = self._fore_color,
			layer = 3,
			alpha = 1,
		})
		primary_ammo_amount:set_left(primary_ammo_panel:left() + (self._main_player and 5 * self._main_scale or -15 * self._mate_scale))
		
		local primary_firemode = primary_ammo_panel:text({
			name = "primary_firemode",
			w = self._ammo_1_w,
			h = self._ammo_panel_h / 1.6,
			font_size = self._ammo_panel_h / 3,
			text = "Semi",
			vertical = "center",
			align = "left",
			font = "fonts/font_large_mf",
			color = self._fore_color,
			layer = 3,
			visible = self._main_player and true or false
		})
		primary_firemode:set_left(primary_ammo_panel:left() + (77 * self._main_scale))
		
		local primary_pickup = primary_ammo_panel:text({
			name = "primary_pickup",
			visible = self._main_player and true or false,
			w = self._ammo_1_w,
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
		primary_pickup:set_left(primary_ammo_panel:left() + (80 * self._main_scale))
		local highlight_texture = "guis/textures/VoidUI/hud_highlights"
		local selected_rect = self._main_player and {0,0,503,157} or {0,158,503,157}
		local primary_selected_image = primary_ammo_panel:bitmap({
			name = "primary_selected_image",
			texture = highlight_texture,
			texture_rect = selected_rect,
			layer = 1,
			color = self._fore_color,
			w = self._ammo_1_w,
			h = self._ammo_panel_h,
			alpha = 1,
		})	
			
		local secondary_ammo_panel = weapons_panel:panel({
			name = "secondary_ammo_panel",
			layer = 1,
			w = self._ammo_2_w,
			h = self._ammo_panel_h,
		})
		secondary_ammo_panel:set_top(primary_ammo_panel:bottom() + 1 * self._main_scale)
		secondary_ammo_panel:set_right(weapons_panel:w())
		local secondary_ammo_amount = secondary_ammo_panel:text({
			name = "secondary_ammo_amount",
			w = self._ammo_1_w,
			h = self._ammo_panel_h,
			font_size = self._ammo_panel_h / 1.4,
			text = "000/000",
			vertical = "center",
			align = self._main_player and"left" or "right",
			font = "fonts/font_large_mf",
			color = self._fore_color,
			layer = 3,
			alpha = 1,
		})
		secondary_ammo_amount:set_left(secondary_ammo_panel:left() + (self._main_player and 10 * self._main_scale or -10 * self._mate_scale))
		
		local secondary_firemode = secondary_ammo_panel:text({
			name = "secondary_firemode",
			w = self._ammo_1_w,
			h = self._ammo_panel_h / 1.6,
			font_size = self._ammo_panel_h / 3,
			text = "Semi",
			vertical = "center",
			align = "left",
			font = "fonts/font_large_mf",
			color = self._fore_color,
			layer = 3,
			visible = self._main_player and true or false
		})
		secondary_firemode:set_left(secondary_ammo_panel:left() + (82 * self._main_scale))
		
		local secondary_pickup = secondary_ammo_panel:text({
			name = "secondary_pickup",
			visible = self._main_player and true or false,
			w = self._ammo_1_w,
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
		secondary_pickup:set_left(secondary_ammo_panel:left() + (85 * self._main_scale))
		
		local secondary_selected_image = secondary_ammo_panel:bitmap({
			name = "secondary_selected_image",
			texture = highlight_texture,
			texture_rect = selected_rect,
			layer = 1,
			w = self._ammo_1_w,
			h = self._ammo_panel_h,
			color = self._fore_color,
			alpha = 1,
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
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
			layer = 1,
			w = self._equipment_panel_w,
			h = self._equipment_panel_h,
			color = self._fore_color,
			alpha = 1,
		})	
		local equipment_image = equipment_panel:bitmap({
			name = "equipment_image",
			texture = "guis/textures/pd2/add_icon",
			layer = 2,
			w = self._equipment_panel_w / 1.9,
			h = self._equipment_panel_h / 1.6,
			color = self._fore_color,
			alpha = 0.6,
		})
		equipment_image:set_center(equipment_border:center())
		local equipment_count = equipment_panel:text({
			name = "equipment_count",
			w = self._equipment_panel_w / 1.2,
			h = self._equipment_panel_h,
			font_size = self._equipment_panel_h / 2,
			color = self._fore_color,
			text = "",
			vertical = "bottom",
			align = "right",
			font = "fonts/font_medium_noshadow_mf",
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
		ties_panel:set_left(equipment_panel:right() - (self._main_player and 2 * self._main_scale or 1 * self._mate_scale))
		
		local ties_border = ties_panel:bitmap({
			name = "ties_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
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
			h = self._equipment_panel_h / 1.6,
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
			font = "fonts/font_medium_noshadow_mf",
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
		grenades_panel:set_left(ties_panel:right() - (self._main_player and 1 * self._main_scale or 1 * self._mate_scale))
		
		local grenades_border = grenades_panel:bitmap({
			name = "grenades_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
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
			h = self._equipment_panel_h / 1.6,
			alpha = 0.6,
		})
		grenades_image:set_center(grenades_border:center())
		local grenades_icon_ghost = grenades_panel:bitmap({
			name = "grenades_icon_ghost",
			rotation = 360,
			texture = texture,
			texture_rect = rect,
			visible = false,
			layer = 3,
			x = grenades_image:x(),
			y = grenades_image:y(),
			w = grenades_image:w(),
			h = grenades_image:h(),
		})
		local grenades_count = grenades_panel:text({
			name = "grenades_count",
			w = self._equipment_panel_w / 1.2,
			h = self._equipment_panel_h,
			font_size = self._equipment_panel_h / 2,
			text = "",
			vertical = "bottom",
			align = "right",
			font = "fonts/font_medium_noshadow_mf",
			layer = 4,
			alpha = 1,
		})	
		local cooldown_panel = grenades_panel:panel({
			name = "cooldown_panel",
			layer = 1,
			w = self._equipment_panel_w,
			h = self._equipment_panel_h,
			alpha = 0,
			visible = false
		})
		
		local cooldown_border = cooldown_panel:bitmap({
			name = "cooldown_border",
			texture = highlight_texture,
			texture_rect = {172,316,171,150},
			layer = 2,
			w = self._equipment_panel_w,
			h = self._equipment_panel_h,
			alpha = 1,
			color = Color.red
		})
		local cooldown_bg = cooldown_panel:bitmap({
			name = "cooldown_bg",
			texture = highlight_texture,
			texture_rect = {0,316,171,150},
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
			color = Color.red
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
			font = "fonts/font_medium_mf"
		})
		carry_panel:text({
			name = "name_shadow",
			visible = true,
			text = "",
			layer = -1,
			color = Color.black,
			x = 23  * self._mate_scale,
			h = 24  * self._mate_scale,
			vertical = "center",
			font_size = 18 * self._mate_scale,
			font = "fonts/font_medium_mf"
		})
		local interact_panel = custom_player_panel:panel({
			name = "interact_panel",
			visible = false,
			layer = 3,
		})
		interact_panel:set_bottom(health_panel:bottom())
		local interact_text = interact_panel:text({
			name = "interact_text",
			text = string.upper(managers.localization:text("hud_action_generic")),
			layer = 3,
			color = Color.white,
			vertical = "bottom",
			align = self._main_player and "right" or "left",
			font_size = 19 * self._mate_scale,
			font = "fonts/font_medium_noshadow_mf"
		})
		interact_text:set_bottom(self._main_player and health_panel:top() - self._equipment_panel_h or health_panel:top() - 1)
		interact_text:set_x(self._main_player and 0 or 9 * self._mate_scale)
		local interact_text_shadow = interact_panel:text({
			name = "interact_text_shadow",
			text = string.upper(managers.localization:text("hud_action_generic")),
			layer = 2,
			color = Color.black,
			vertical = "bottom",
			align = self._main_player and "right" or "left",
			font_size = 19 * self._mate_scale,
			font = "fonts/font_medium_noshadow_mf"
		})
		interact_text_shadow:set_position(interact_text:x() + 1, interact_text:y() + 1)
		local interact_bar = interact_panel:bitmap({
			name = "interact_bar",
			texture = health_texture,
			texture_rect = {609,0,201,472},
			layer = 4,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
		})
		interact_bar:set_x(self._main_player and interact_panel:w() - interact_bar:w() or 0)
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
		interact_time:set_x(self._main_player and interact_panel:w() - health_panel:w() or 0)
		interact_time:set_bottom(self._custom_player_panel:bottom() - 3)
		self:create_custom_waiting_panel(teammates_panel)
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
				if self._main_player then visible = VoidUI.options.main_stealth 
				else visible = VoidUI.options.mate_stealth end
				detect_value:set_visible(visible)
				downs_value:set_visible(false)
			elseif is_whisper_mode == false then
				if self._main_player then visible = VoidUI.options.main_loud
				else visible = VoidUI.options.mate_loud end
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
		local armor_value = health_panel:child("armor_value")
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
				armor_value:show()
			else
				name:set_bottom(health_panel:top() - 1)
				name:set_x(9 * self._mate_scale)
				name_shadow:set_position(name:x() + 1, name:y() + 1)
				self:set_health({current = 100, total = 100})
				self:set_armor({current = 100, total = 100})
				name:show()
				name_shadow:show()
				weapons_panel:hide()
				armor_value:hide()
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
		if bkin_bl__menu and self._ai then id = 6 end
		self._color_id = id
		local name = self._custom_player_panel:child("name")
		local health_panel = self._custom_player_panel:child("health_panel")
		local health_background = health_panel:child("health_background")
		local health_stored_bg =  self._custom_player_panel:child("health_stored_bg")
		local delayed_damage_health_bar = health_panel:child("delayed_damage_health_bar")
		local health_bar = health_panel:child("health_bar")
		local health_value = health_panel:child("health_value")
		local downs_value = health_panel:child("downs_value")
		local detect_value = health_panel:child("detect_value")
		local armor_value = health_panel:child("armor_value")
		local color = tweak_data.chat_colors[id] or Color.white
		
		name:set_color(color)
		health_background:set_color(color * 0.2 + Color.black)
		health_bar:set_color(color * 0.7 + Color.black * 0.9)
		armor_value:set_color(color * 0.4 + Color.black * 0.5)
		health_value:set_color(color * 0.4 + Color.black * 0.5)
		downs_value:set_color(color * 0.8 + Color.black * 0.5)
		detect_value:set_color(color * 0.8 + Color.black * 0.5)
		delayed_damage_health_bar:set_color(color * 0.48 + Color.black)
		
		if not self._whisper_listener then
			self._whisper_listener = "HUDTeammate_whisper_mode_"..self._id
			managers.groupai:state():add_listener(self._whisper_listener, {
				"whisper_mode"
			}, callback(self, self, "whisper_mode_changed"))
		end
		self:set_detection()
		self:set_max_downs()
	end
	local set_name = HUDTeammate.set_name
	function HUDTeammate:set_name(teammate_name)
		set_name(self, teammate_name)
		if teammate_name == managers.localization:text("menu_jowi") then teammate_name = managers.localization:text("VoidUI_jowi") 
		elseif teammate_name == managers.localization:text("menu_chico") then teammate_name = managers.localization:text("VoidUI_chico") end
		teammate_name = VoidUI.options.mate_upper and utf8.to_upper(teammate_name) or teammate_name
		local name = self._custom_player_panel:child("name")
		local name_shadow = self._custom_player_panel:child("name_shadow")
		local peer = managers.network:session():peer(self:peer_id())
		local level = "" 
		if VoidUI.options.mate_name and peer then 
			level = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "Ї" or "" ) .. (peer:level() and peer:level().. " " or (self:ai() and "" or " "))
		end
		name:set_font_size(19 * (self._mate_scale < 1 and self._mate_scale or 1))
		name_shadow:set_font_size(19 * (self._mate_scale < 1 and self._mate_scale or 1))
		name:set_text(level .. teammate_name)
		name_shadow:set_text(level .. teammate_name)
		local _, _, name_w,name_h = name:text_rect()
		if not self:ai() and name_w > (140 * self._mate_scale) then 
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
		if self:ai() then 
			data.current = (data.current / data.total) * 10
			data.total = 10
		end
		
		self._health_data = data
		local anim_time = self._main_player and VoidUI.options.main_anim_time or VoidUI.options.mate_anim_time
		local health_stored = self._custom_player_panel:child("health_stored")
		local health_stored_bg = self._custom_player_panel:child("health_stored_bg")
		local health_panel = self._custom_player_panel:child("health_panel")
		local health_background = health_panel:child("health_background")
		local health_bar = health_panel:child("health_bar")
		local health_value = health_panel:child("health_value")
		local show_health_value = self._main_player and VoidUI.options.main_health or VoidUI.options.mate_health
		local amount = math.clamp(data.current / data.total, 0, 1)
		if amount < math.clamp(health_bar:h() / self._bg_h, 0, 1) then self:_damage_taken() end
		health_bar:stop()
		health_bar:animate(function(o)
			local s = math.clamp(health_bar:h() / self._bg_h, 0, 1)
			local c = s
			over(anim_time, function(p)
				if alive(health_bar) then
					c =	math.lerp(s, amount, p)
					health_bar:set_h(self._bg_h * c)
					health_bar:set_texture_rect(203, 0 + ((1- c) * 472),202,472 * c)
					health_bar:set_bottom(health_background:bottom())
					
					if show_health_value == 1 then health_value:set_text("")
					elseif show_health_value == 2 then health_value:set_text(math.clamp(self:round(c * 100), 0, 100))
					elseif show_health_value == 3 then health_value:set_text(self:round((data.total * 10) * c)) end
					
					health_stored_bg:set_bottom(math.clamp(health_panel:y() + health_bar:top(), health_panel:top() + health_stored_bg:h(), health_panel:bottom()))
					health_stored:set_bottom(health_stored_bg:bottom())
					health_stored_bg:set_texture_rect(811,(((health_stored_bg:y() - health_panel:y()) / self._bg_h) * 472),70,472 * (health_stored_bg:h() / self._bg_h))
					health_stored:set_texture_rect(811,(((health_stored:y() - health_panel:y()) / self._bg_h) * 472),70,472 * (health_stored:h() / self._bg_h))
					self:update_delayed_damage()
				end
			end)
		end)
	end
	
	function HUDTeammate:update_delayed_damage()
		local damage = self._delayed_damage or 0
		local health_panel = self._custom_player_panel:child("health_panel")
		local health_bar = health_panel:child("health_bar")
		local armor_bar = health_panel:child("armor_bar")
		local delayed_damage_armor = health_panel:child("delayed_damage_armor_bar")
		local delayed_damage_health = health_panel:child("delayed_damage_health_bar")
		local armor_max = self._armor_data.total
		local armor_current = self._armor_data.current
		local armor_ratio = armor_bar:h() / self._bg_h
		local health_max = self._health_data.total
		local health_current = self._health_data.current
		local health_ratio = health_bar:h() / self._bg_h
		local armor_damage = damage < armor_current and damage or armor_current
		damage = damage - armor_damage
		local health_damage = damage < health_current and damage or health_current
		local armor_damage_ratio = armor_damage > 0 and armor_damage / armor_max or 0
		local health_damage_ratio = health_damage / health_max

		delayed_damage_armor:set_visible(armor_damage_ratio > 0)
		delayed_damage_health:set_visible(health_damage_ratio > 0)
		delayed_damage_armor:set_h(self._bg_h * armor_damage_ratio)
		delayed_damage_armor:set_top(armor_bar:top())
		delayed_damage_armor:set_texture_rect(1084,((1- armor_ratio) * 472),201,472 * armor_damage_ratio)
		delayed_damage_health:set_h(self._bg_h * health_damage_ratio)
		delayed_damage_health:set_top(health_bar:top())
		delayed_damage_health:set_texture_rect(881,((1- health_ratio) * 472),202,472 * health_damage_ratio)
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
			custom_bar:set_texture_rect(203, 0 + ((1- value) * 472),202,472 * value)
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
		self._armor_data = data
		local health_panel = self._custom_player_panel:child("health_panel")
		local armor_background = health_panel:child("armor_background")
		local armor_bar = health_panel:child("armor_bar")
		local armor_value = health_panel:child("armor_value")
		local amount = data.total ~= 0 and math.ceil((data.current / data.total) * 100) / 100 or 0
		
		armor_bar:set_h(self._bg_h * amount)
		armor_bar:set_texture_rect(609,0 + ((1- amount) * 472),201,472 * amount)
		armor_bar:set_bottom(armor_background:bottom())
		
		local show_armor_value = self._main_player and VoidUI.options.main_armor or VoidUI.options.mate_armor
		if show_armor_value == 2 then armor_value:set_text(self:round(amount * 100))
		elseif show_armor_value == 3 then armor_value:set_text(self:round((data.total * 10) * amount))
		else armor_value:set_text("") end
		self:update_delayed_damage()
		if data.total == 0 or (data.current / data.total) < 0.01 then
			armor_bar:set_h(0)
			armor_value:set_text("")
		end
		
		if self._main_player and VoidUI.options.main_health == 1 or VoidUI.options.mate_health == 1 then
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

		primary_ammo_panel:animate(function(o)
			local x = primary_ammo_panel:x()
			local x2 = is_secondary and (self._main_player and 20 * self._main_scale or -20 * self._mate_scale) or 0
			local a = primary_selected_image:alpha()
			local a2 = is_secondary and 0 or 1
			over(0.2, function(p)
				if alive(primary_ammo_panel) then
					primary_ammo_panel:set_x(math.lerp(x, weapons_panel:w() - primary_ammo_panel:w() + x2, p))
					primary_selected_image:set_alpha(math.lerp(a, a2, p))
				end
			end)
		end)
		secondary_ammo_panel:animate(function(o)
			local x = secondary_ammo_panel:x()
			local x2 = is_secondary and 0 or (self._main_player and 15 * self._main_scale or -15 * self._mate_scale)
			local a = secondary_selected_image:alpha()
			local a2 = is_secondary and 1 or 0
			over(0.2, function(p)
				if alive(secondary_ammo_panel) then
					secondary_ammo_panel:set_x(math.lerp(x, weapons_panel:w() - secondary_ammo_panel:w() + x2, p))
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
		local color = self._fore_color
		
		local current_left_total = current_left
		local max_total = max
		local peer = managers.network:session():peer(self:peer_id())
		local outfit = peer and peer:blackmarket_outfit()
		if (self._main_player and ((type == "primary" and managers.blackmarket:equipped_primary().weapon_id ~= "saw") or (type == "secondary" and managers.blackmarket:equipped_secondary().weapon_id ~= "saw_secondary")) or ((type == "primary" and outfit and outfit.primary and outfit.primary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id) ~= "saw") or (type == "secondary" and outfit and outfit.secondary and outfit.secondary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id) ~= "saw_secondary"))) then
			if VoidUI.options.totalammo == true then
				current_left = current_left - current_clip
				max = max - max_clip
			end
		else
			max_total = 2
		end

		ammo_amount:set_text(string.gsub("000", "0", "", string.len(tostring(current_clip))).. tostring(current_clip).."/"..string.gsub("000", "0", "", string.len(tostring(current_left)))..tostring(current_left)) 
		ammo_amount:set_color(math.lerp(Color.red, self._fore_color, math.min(1, (current_left_total/max_total) / 0.4)))
		ammo_image:set_color(ammo_amount:color()) 
		
		if VoidUI.options.ammo_pickup and type == "primary" and self._primary_max < current_left and current_left - self._primary_max ~= 0 then
			pickup:stop()
			pickup:animate(callback(self, self, "_animate_pickup"))
			pickup:set_text("+".. string.sub(pickup:text(), 2) + current_left - self._primary_max) 
		elseif VoidUI.options.ammo_pickup and type == "secondary" and self._secondary_max < current_left and current_left - self._secondary_max ~= 0 then
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
		primary_firemode:set_text(managers.localization:text(is_primary_auto and "VoidUI_fire_auto" or "VoidUI_fire_semi"))
		secondary_firemode:set_text(managers.localization:text(is_sec_auto and "VoidUI_fire_auto" or "VoidUI_fire_semi"))
		
	end

	function HUDTeammate:set_weapon_firemode(id, firemode)
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
		local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
		local primary_firemode = primary_ammo_panel:child("primary_firemode")
		local secondary_firemode = secondary_ammo_panel:child("secondary_firemode")
		if id == 2 then
			if firemode == "single" then
				primary_firemode:set_text(managers.localization:text("VoidUI_fire_semi"))
			else
				primary_firemode:set_text(managers.localization:text("VoidUI_fire_auto"))
			end
		else
			if firemode == "single" then
				secondary_firemode:set_text(managers.localization:text("VoidUI_fire_semi"))
			else
				secondary_firemode:set_text(managers.localization:text("VoidUI_fire_auto"))
			end
		end
	end
	
	function HUDTeammate:set_weapon_firemode_burst(id)
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local primary_ammo_panel = weapons_panel:child("primary_ammo_panel")
		local secondary_ammo_panel = weapons_panel:child("secondary_ammo_panel")
		local primary_firemode = primary_ammo_panel:child("primary_firemode")
		local secondary_firemode = secondary_ammo_panel:child("secondary_firemode")
		if id == 2 then
			primary_firemode:set_text(managers.localization:text("VoidUI_fire_burst"))
		else
			secondary_firemode:set_text(managers.localization:text("VoidUI_fire_burst"))
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
			ties_amount:set_color(self._fore_color)
			ties_border:set_color(self._fore_color)
			ties_image:set_color(self._fore_color)
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
			equipment_count:set_color(self._fore_color)
			equipment_border:set_color(self._fore_color)
			equipment_image:set_color(self._fore_color)
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
			equipment_count:set_color(self._fore_color)
			equipment_border:set_color(self._fore_color)
			equipment_image:set_color(self._fore_color)
		else
			equipment_count:set_color(Color(1,0,0))
			equipment_border:set_color(Color(1,0,0))
			equipment_image:set_color(Color(1,0,0))
		end
		
		equipment_count:set_visible(visible)
		equipment_count:set_text(data.amount_str)
	end

	function HUDTeammate:set_grenades(data)
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon, {0, 0, 32, 32})
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local grenades_image = grenades_panel:child("grenades_image")
		local cooldown_image = grenades_panel:child("cooldown_panel"):child("cooldown_image")
		local grenades_count = grenades_panel:child("grenades_count")
		local grenades_border = grenades_panel:child("grenades_border")
		local grenades_icon_ghost = grenades_panel:child("grenades_icon_ghost")
		if not PlayerBase.USE_GRENADES then
			grenades_count:set_text("")
			grenades_border:set_color(Color(1,0,0))
			grenades_image:set_color(Color(1,0,0))
		end
		grenades_image:set_image(icon, unpack(texture_rect))
		cooldown_image:set_image(icon, unpack(texture_rect))
		grenades_icon_ghost:set_image(icon, unpack(texture_rect))
		self:set_grenades_amount(data)
	end
	
	function HUDTeammate:set_ability_icon(icon)
		log("Icon: "..tostring(icon))
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local grenades_image = grenades_panel:child("grenades_image")
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {0, 0, 32, 32})
		grenades_image:set_image(texture, unpack(texture_rect))
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
		else
			grenades_count:set_text(tweak_data and tweak_data.blackmarket and tweak_data.blackmarket.projectiles and tweak_data.blackmarket.projectiles[data.icon] and tweak_data.blackmarket.projectiles[data.icon].base_cooldown and "" or "x"..data.amount)
			grenades_count:set_color(self._fore_color)
			if self._ability_color then 
				grenades_border:set_color(self._ability_color + Color.white * 0.05)
				grenades_image:set_color(grenades_border:color())
			else
				grenades_border:set_color(self._fore_color)
				grenades_image:set_color(self._fore_color)
			end
		end
	end

	function HUDTeammate:set_grenade_cooldown(data)
		if not PlayerBase.USE_GRENADES then
			return
		end
		local end_time = data and data.end_time
		local duration = data and data.duration
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local cooldown_panel = grenades_panel:child("cooldown_panel")
		local grenades_image = grenades_panel:child("grenades_image")
		local grenades_count = grenades_panel:child("grenades_count")
		local grenades_border = grenades_panel:child("grenades_border")
		
		if not end_time or not duration then
			grenades_count:set_visible(false)
			cooldown_panel:set_visible(false)
			cooldown_panel:stop()
			cooldown_panel:set_h(self._equipment_panel_h)
		else
			grenades_count:set_visible(true)
			cooldown_panel:set_visible(true)
			cooldown_panel:stop()
			self:animate_grenade_charge()
			cooldown_panel:animate(function(o)
					local time_left = end_time - managers.game_play_central:get_heist_timer()
					local left_ratio = time_left/duration
					local h = self._equipment_panel_h * left_ratio
					local start_time = duration * left_ratio
					over(time_left, function(p)
						if alive(cooldown_panel) then
							cooldown_panel:set_h(math.lerp(h, 0, p))
							grenades_count:set_text(1 + math.floor(start_time * (1-p)))
						end
					end)
					cooldown_panel:set_h(0)
					cooldown_panel:set_visible(false)
					cooldown_panel:set_h(self._equipment_panel_h)
				end)
		
			if self._main_player and managers.network and managers.network:session() then
				managers.network:session():send_to_peers("sync_grenades_cooldown", end_time, duration)
			end
		end
	end
	function HUDTeammate:set_ability_color(color)
		self._ability_color = color
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local cooldown_panel = grenades_panel:child("cooldown_panel")
		local cooldown_border = cooldown_panel:child("cooldown_border")
		local cooldown_image = cooldown_panel:child("cooldown_image")
		local cooldown_bg = cooldown_panel:child("cooldown_bg")
		local border = grenades_panel:child("grenades_border")
		local image = grenades_panel:child("grenades_image")
		if color then
			cooldown_image:set_color(color * 0.5 + Color.black)
			cooldown_border:set_color(color * 0.4 + Color.black * 0.9)
			cooldown_bg:set_color(color * 0.5 + Color.black)
			border:set_color(color + Color.white * 0.15)
			image:set_color(border:color())
		else
			cooldown_image:set_color(Color.red)
			cooldown_border:set_color(Color.red)
			cooldown_bg:set_color(Color.red:with_alpha(0.8))
			if cooldown_panel:visible() then
				border:set_color(Color(1,0.8,0.8))
				image:set_color(border:color())
			else
				border:set_color(self._fore_color)
				image:set_color(self._fore_color)
			end
		end
	end
	
	function HUDTeammate:animate_grenade_charge()
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local cooldown_panel = grenades_panel:child("cooldown_panel")
		local count = grenades_panel:child("grenades_count")
		local icon_ghost = grenades_panel:child("grenades_icon_ghost")
		local border = grenades_panel:child("grenades_border")
		local image = grenades_panel:child("grenades_image")
		local ability_color = self._ability_color and self._ability_color + Color.white * 0.15 or Color(1,0.8,0.8)
		local function animate_fade()			
			local a = cooldown_panel:alpha()
			over(0.2 , function (p)
				cooldown_panel:set_alpha(math.lerp(a,1,p))
				count:set_alpha(cooldown_panel:alpha())
				border:set_color(ability_color)
				count:set_color(self._fore_color)
				image:set_color(ability_color)
			end)
			cooldown_panel:set_alpha(1)
			count:set_alpha(1)
		end
		icon_ghost:set_visible(false)
		grenades_panel:stop()
		grenades_panel:animate(animate_fade)
	end
	
	function HUDTeammate:animate_grenade_flash()
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local grenades_panel = weapons_panel:child("grenades_panel")
		local icon = grenades_panel:child("grenades_image")
		local icon_ghost = grenades_panel:child("grenades_icon_ghost")
		local cooldown_panel = grenades_panel:child("cooldown_panel")
		local count = grenades_panel:child("grenades_count")

		local function animate_flash()
			local icon_w, icon_h = icon:size()
			local icon_x, icon_y = icon:center()
			
			cooldown_panel:set_alpha(0)
			icon_ghost:set_visible(true)
			count:set_visible(true)
			over(0.6, function (p)
				local color = math.lerp(Color(1,1,0.8,0.8), Color(0,1,1,1), p)
				local scale = 1 + p
				icon_ghost:set_color(color)
				icon_ghost:set_size(icon_w * scale, icon_h * scale)
				icon_ghost:set_center(icon_x, icon_y)
				count:set_alpha(1 - p)
				count:set_text("0")
			end)
			count:set_visible(false)
			count:set_text("")
			icon_ghost:set_visible(false)
			icon_ghost:set_size(icon_w, icon_h)
			icon_ghost:set_center(icon_x, icon_y)
		end

		grenades_panel:stop()
		grenades_panel:animate(animate_flash)
	end
	
	function HUDTeammate:set_ability_radial(data)
		local health_panel = self._custom_player_panel:child("health_panel")
		local ability_bar = health_panel:child("ability_bar")
		local percentage = data.current / data.total
		ability_bar:set_visible(percentage > 0)
		ability_bar:set_h(self._bg_h * percentage)
		ability_bar:set_texture_rect(203, 0 + ((1 - percentage) * 472),202,472 * percentage)
		ability_bar:set_bottom(health_panel:child("health_background"):bottom())
	end

	function HUDTeammate:activate_ability_radial(time_left, time_total)
		local health_panel = self._custom_player_panel:child("health_panel")
		local ability_bar = health_panel:child("ability_bar")
		time_total = time_total or time_left
		local progress_start = time_left / time_total
		ability_bar:stop()
		ability_bar:animate(function(o)
			ability_bar:set_visible(true)
			ability_bar:set_color(Color(1, 0.6, 0))
			ability_bar:set_alpha(0.5)
			over(time_left, function(p)
				local progress = 1 - progress_start * math.lerp(1, 0, p)
				ability_bar:set_h(math.lerp(self._bg_h, 0, progress))
				ability_bar:set_texture_rect(203, math.lerp(0, 472, progress),202,math.lerp(472, 0, progress))
				ability_bar:set_bottom(health_panel:child("health_background"):bottom())
			end)
			ability_bar:set_visible(false)
			self:set_ability_color(nil)
		end)
		
		if self._main_player and managers.network and managers.network:session() then
			local current_time = managers.game_play_central:get_heist_timer()
			local end_time = current_time + time_left

			managers.network:session():send_to_peers("sync_ability_hud", end_time, time_total)
		end
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
				panel:set_bottom(self._custom_player_panel:child("health_panel"):top() - (self._mate_scale < 1 and 19 * self._mate_scale or 19))
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

	end

	function HUDTeammate:create_custom_waiting_panel(parent_panel)
		local panel = parent_panel:panel()
		panel:set_visible(false)
		panel:set_lefttop(self._panel:lefttop())
		local name = panel:text({
			name = "name",
			font_size = 19,
			vertical = "bottom",
			layer = 1,
			font = "fonts/font_medium_mf",
			text = "Name"
		})
		local name_shadow = panel:text({
			name = "name_shadow",
			font_size = 19,
			vertical = "bottom",
			color = Color.black,
			font = "fonts/font_medium_mf",
			text = "Name"
		})
		local player_panel = self._custom_player_panel
		local health_panel = player_panel:child("health_panel")
		local detection = panel:panel({
			name = "detection",
			w = health_panel:w(),
			h = health_panel:h()
		})
		local health_texture = "guis/textures/VoidUI/hud_health"
		detection:set_lefttop(health_panel:lefttop())
		local armor_bar_bg = detection:bitmap({
			name = "detection_bar_bg",
			texture = health_texture,
			texture_rect = {609,0,201,472},
			layer = 2,
			color = Color.white,
			w = detection:w(),
			h = detection:h()
		})
		local detection_bar_bg = detection:bitmap({
			name = "detection_bar_bg",
			texture = health_texture,
			texture_rect = {0,0,202,472},
			color = Color.black,
			w = detection:w(),
			h = detection:h()
		})
		local detection_bar = detection:bitmap({
			name = "detection_bar",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			layer = 1,
			w = detection:w(),
			h = detection:h()
		})
		local detection_shade = detection:bitmap({
			name = "detection_shade",
			texture = health_texture,
			texture_rect = {406,0,202,472},
			layer = 2,
			w = detection:w(),
			h = detection:h(),
			color = Color.black
		})
		local detection_value = panel:text({
			name = "detection_value",
			w = self._health_value,
			h = self._health_value,
			font_size = self._health_value / 1.7,
			font = "fonts/font_medium_noshadow_mf",
			layer = 3,
			text = "75%",
			vertical = "bottom",
			align = "center",
		})
		detection_value:set_left(health_panel:left())
		detection_value:set_bottom(health_panel:bottom() - 3)
		name:set_leftbottom(detection:left() + 9 * self._mate_scale, detection:top())
		name_shadow:set_leftbottom(name:x() + 1, detection:top() + 1)
		local weapons_panel = player_panel:child("weapons_panel")
		local background = panel:bitmap({
			name = "background",
			texture = "guis/textures/VoidUI/hud_weapons",
			w = weapons_panel:w(),
			h = weapons_panel:h(),
			visible = true,
			layer = -1
		})
		background:set_lefttop(detection:right() - (6 * self._mate_scale), detection:top())
		local highlight_texture = "guis/textures/VoidUI/hud_highlights"
		local primary_border = panel:bitmap({
			name = "primary_border",
			texture = highlight_texture,
			texture_rect = {0,158,503,157},
			layer = 1,
			y = background:top(),
			w = self._w,
			h = self._ammo_panel_h,
			alpha = 1
		})
		primary_border:set_right(weapons_panel:right())
		local primary_weapon = panel:bitmap({
			name = "primary_weapon",
			w = weapons_panel:w() / 2 * self._mate_scale,
			h = self._ammo_panel_h / 1.2,
			texture = managers.blackmarket:get_weapon_icon_path("new_m4"),
			layer = 2
		})
		primary_weapon:set_center(primary_border:center())
		local secondary_border = panel:bitmap({
			name = "secondary_border",
			texture = highlight_texture,
			texture_rect = {0,158,503,157},
			layer = 1,
			y = primary_border:bottom() + 1 * self._mate_scale,
			w = self._w,
			h = self._ammo_panel_h,
			alpha = 1
		})
		secondary_border:set_right(weapons_panel:right() - 3 * self._mate_scale)
		local secondary_weapon = panel:bitmap({
			name = "secondary_weapon",
			w = weapons_panel:w() /2 * self._mate_scale,
			h = self._ammo_panel_h / 1.2,
			texture = managers.blackmarket:get_weapon_icon_path("glock_17"),
			layer = 2
		})
		secondary_weapon:set_center(secondary_border:center())
		local deploy_panel = panel:panel({name = "deploy"})
		local throw_panel = panel:panel({name = "throw"})
		local perk_panel = panel:panel({name = "perk"})
		self:_create_equipment(deploy_panel, "frag_grenade", self._mate_scale)
		self:_create_equipment(throw_panel, "frag_grenade", self._mate_scale)
		self:_create_equipment(perk_panel, "frag_grenade", self._mate_scale)
		deploy_panel:set_leftbottom(background:left(), background:bottom())
		throw_panel:set_leftbottom(deploy_panel:right() - 1 * self._mate_scale, background:bottom())
		perk_panel:set_leftbottom(throw_panel:right() - 2 * self._mate_scale, background:bottom())
		self._wait_panel = panel
	end

	function HUDTeammate:_create_equipment(panel, icon_name, scale)
		scale = scale or 1
		local icon, rect
		if icon_name then
			icon, rect = tweak_data.hud_icons:get_icon_data(icon_name)
		end
		panel:set_w(self._equipment_panel_w)
		panel:set_h(self._equipment_panel_h)
		local vis_at_start = true
		local bg = panel:bitmap({
			name = "bg",
			texture = "guis/textures/VoidUI/hud_highlights",
			texture_rect = {172,316,171,150},
			visible = true,
			layer = 0,
			color = bg_color,
			w = panel:w(),
			h = panel:h(),
			x = 0
		})
		local icon = panel:bitmap({
			name = "icon",
			texture = icon,
			texture_rect = rect,
			visible = vis_at_start,
			layer = 1,
			alpha = 0.6,
			color = Color.white,
			w = self._equipment_panel_w / 1.6,
			h = self._equipment_panel_h / 1.5,
			x = 2
		})
		icon:set_center(bg:center())
		local amount = panel:text({
			name = "amount",
			visible = vis_at_start,
			text = "x0",
			font = "fonts/font_medium_noshadow_mf",
			vertical = "bottom",
			align = "right",
			layer = 2,
			w = self._equipment_panel_w / 1.2,
			h = self._equipment_panel_h,
			font_size = self._equipment_panel_h / 2
		})
	end
	local set_icon_data = function(image, icon, rect)
		if rect then
			image:set_image(icon, unpack(rect))
			return
		end
		local text, rect = tweak_data.hud_icons:get_icon_data(icon or "fallback")
		image:set_image(text, unpack(rect))
	end
	function HUDTeammate:set_waiting(waiting, peer)
		local my_peer = managers.network:session():peer(self._peer_id)
		peer = peer or my_peer
		if self._wait_panel then
			if waiting then
				local color = tweak_data.chat_colors[peer:id()] or Color.white
				self._panel:set_visible(false)
				self._wait_panel:set_lefttop(self._panel:lefttop())
				local name = self._wait_panel:child("name")
				local name_shadow = self._wait_panel:child("name_shadow")
				local detection = self._wait_panel:child("detection")
				local detection_value = self._wait_panel:child("detection_value")
				local current, reached = managers.blackmarket:get_suspicion_offset_of_peer(peer, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
				detection:child("detection_bar"):set_h(detection:h() * current)
				detection:child("detection_bar"):set_texture_rect(203, 0 + ((1- current) * 472),202,472 * current)
				detection:child("detection_bar"):set_bottom(detection:child("detection_bar_bg"):bottom())
				detection:child("detection_bar"):set_color(math.round(current * 100) > 50 and tweak_data.screen_colors.pro_color or tweak_data.chat_colors[5])
				detection_value:set_color(math.round(current * 100) > 50 and tweak_data.screen_colors.pro_color + Color.black * 0.5 or tweak_data.chat_colors[5] + Color.black * 0.5)
				detection_value:set_text(math.round(current * 100) .. "%")
				if reached then
					detection_value:set_color(Color(255, 255, 42, 0) / 255)
				else
					detection_value:set_color(tweak_data.screen_colors.text)
				end
				local outfit = peer:profile().outfit
				outfit = outfit or managers.blackmarket:unpack_outfit_from_string(peer:profile().outfit_string) or {}
				local _, _, name_w, _ = name:text_rect()
				local level = (0 < peer:rank() and managers.experience:rank_string(peer:rank()) .. "Ї" or "") .. (peer:level() .. " " or "") .. ""
				name:set_text(level .. peer:name())
				name_shadow:set_text(name:text())
				if name_w > (140 * self._mate_scale) then name:set_font_size(name:font_size() * ((self._mate_scale < 1 and 140 * self._mate_scale or 140)/name_w)) end
				name_shadow:set_font_size(name:font_size())
				name:set_color(color)
				name:set_range_color(0, utf8.len(level), Color.white:with_alpha(1))
				if outfit.primary and outfit.primary.factory_id then 
					local texture = managers.blackmarket:get_weapon_icon_path(outfit.primary and outfit.primary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id) or "new_m4", VoidUI.options.scoreboard_skins > 1 and outfit.primary and outfit.primary.cosmetics)
					self._wait_panel:child("primary_weapon"):set_image(texture) 	
				end
				if outfit.secondary and outfit.secondary.factory_id then 
					local texture = managers.blackmarket:get_weapon_icon_path(outfit.secondary and outfit.secondary.factory_id and managers.weapon_factory:get_weapon_id_by_factory_id(outfit.secondary.factory_id) or "glock_17", VoidUI.options.scoreboard_skins > 1 and outfit.secondary and outfit.secondary.cosmetics)
					self._wait_panel:child("secondary_weapon"):set_image(texture) 
				end
				local has_deployable = outfit.deployable and outfit.deployable ~= "nil"
				self._wait_panel:child("deploy"):child("amount"):set_text(has_deployable and "x" .. outfit.deployable_amount or "")
				self._wait_panel:child("throw"):child("amount"):set_text("x" .. managers.player:get_max_grenades(peer:grenade_id()))
				self._wait_panel:child("perk"):child("amount"):set_text(outfit.skills.specializations[2] or "" .. "/9")
				local deploy_image = self._wait_panel:child("deploy"):child("icon")
				if has_deployable then
					set_icon_data(deploy_image, tweak_data.equipments[outfit.deployable].icon)
				else
					set_icon_data(deploy_image, "none_icon")
				end
				set_icon_data(self._wait_panel:child("throw"):child("icon"), outfit.grenade and tweak_data.blackmarket.projectiles[outfit.grenade].icon)
				set_icon_data(self._wait_panel:child("perk"):child("icon"), tweak_data.skilltree:get_specialization_icon_data(tonumber(outfit.skills.specializations[1])))
			elseif self._ai or my_peer and my_peer:unit() then
				self._panel:set_visible(true)
			end
			self._wait_panel:set_visible(waiting)
		end
		managers.hud:align_teammate_panels()
	end

	function HUDTeammate:teammate_progress(enabled, type_index, tweak_data_id, timer, success)
		self._custom_player_panel:child("interact_panel"):stop()
		self._custom_player_panel:child("interact_panel"):set_visible(enabled)
		local interact_text = self._custom_player_panel:child("interact_panel"):child("interact_text")
		local interact_text_shadow = self._custom_player_panel:child("interact_panel"):child("interact_text_shadow")
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
		interact_text:set_font_size(19 * self._mate_scale)
		interact_text_shadow:set_text(" ".. action_text)
		interact_text_shadow:set_font_size(19 * self._mate_scale)
		local _,_,text_w,_ = interact_text:text_rect()
		if text_w > 140 * self._mate_scale then interact_text:set_font_size(interact_text:font_size() * (140 * self._mate_scale/text_w)) interact_text_shadow:set_font_size(interact_text:font_size()) end
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
					interact_text_shadow:set_alpha(interact_text:alpha())
				end
			end)
		end)
		if enabled then
			self._custom_player_panel:child("interact_panel"):animate(callback(self, self, "_animate_interact"), self._custom_player_panel:child("interact_panel"):child("interact_bar"), timer)
		elseif success then
			local panel = self._custom_player_panel
			local health_panel = panel:child("health_panel")
			
			local bar = self._custom_player_panel:bitmap({
				texture = "guis/textures/VoidUI/hud_health",
				texture_rect = {609,0,201,472},
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
				font = "fonts/font_medium_noshadow_mf"
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
						interact_text_shadow:set_alpha(interact_text:alpha())
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
			interact:set_texture_rect(609,0 + ((1- value) * 472),201,472 * value)
			interact:set_bottom(self._custom_player_panel:bottom())
			if VoidUI.options.mate_interact and left > 0 then panel:child("interact_time"):set_text(string.format("%.1fs", left))
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
		local value_text_shadow = carry_panel:child("name_shadow")
		value_text:set_text(tweak_data.carry[carry_id].name_id and managers.localization:text(tweak_data.carry[carry_id].name_id or ""))
		value_text_shadow:set_text(value_text:text())
		
	end
	function HUDTeammate:remove_carry_info()
		local carry_panel = self._custom_player_panel:child("carry_panel")
		carry_panel:set_visible(false)
	end

	function HUDTeammate:start_timer(time)
		self._timer_paused = 0
		self._timer = time
		self._timer_total = time
		self._custom_player_panel:child("condition_timer"):set_color(Color(1, 0.7, 0.7))
		self._custom_player_panel:child("condition_timer"):set_font_size(30 * self._mate_scale)
		self._custom_player_panel:child("condition_timer"):stop()
		self._custom_player_panel:child("condition_timer"):set_visible(true)
		self._custom_player_panel:child("health_panel"):child("custom_bar"):set_visible(true)
		self._custom_player_panel:child("health_panel"):child("health_bar"):set_visible(false)
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
		if not alive(self._custom_player_panel) then
			return
		end
		self._custom_player_panel:child("condition_timer"):stop()
		self._custom_player_panel:child("condition_timer"):set_visible(false)
		self._custom_player_panel:child("health_panel"):child("custom_bar"):set_visible(false)
		self._custom_player_panel:child("health_panel"):child("health_bar"):set_visible(true)
		self._custom_player_panel:child("health_panel"):child("condition_icon"):set_alpha(1)
		
	end
	function HUDTeammate:is_timer_running()
		return self._custom_player_panel:child("condition_timer"):visible()
	end

	function HUDTeammate:_animate_timer()
		local rounded_timer = math.round(self._timer)
		local custom_bar = self._custom_player_panel:child("health_panel"):child("custom_bar")
		local amount = (self._timer / self._timer_total)
		while self._timer >= 0 do
			local dt = coroutine.yield()
			custom_bar:set_visible(true)
			custom_bar:set_color(tweak_data.screen_colors.pro_color * 0.7 + Color.black * 0.9)
			if self._timer_paused == 0 then
				self._timer = self._timer - dt
				local text = self._timer < 0 and "00" or (math.round(self._timer) < 10 and "0" or "") .. math.round(self._timer)
				self._custom_player_panel:child("condition_timer"):set_text(text)
				amount = self._timer / self._timer_total
				custom_bar:set_h(self._bg_h * amount)
				custom_bar:set_texture_rect(203, 0 + ((1- amount) * 472),202,472 * amount)
				custom_bar:set_bottom(self._custom_player_panel:child("health_panel"):h())
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
			local g = math.lerp(0.7 or self._point_of_no_return_color.g, 0.1, n)
			local b = math.lerp(0.7 or self._point_of_no_return_color.b, 0.1, n)
			condition_timer:set_color(Color(r, g, b))
			condition_timer:set_alpha(1)
			condition_timer:set_font_size(math.lerp(30 * self._mate_scale, 45 * self._mate_scale, n))
		end
		condition_timer:set_font_size(30 * self._mate_scale)
	end


	function HUDTeammate:remove_panel()
		local teammate_panel = self._panel
		teammate_panel:set_visible(false)
		local special_equipment = self._special_equipment
		while special_equipment[1] do
			self._custom_player_panel:remove(table.remove(special_equipment))
		end
		self:set_condition("mugshot_normal")
		self._custom_player_panel:child("health_panel"):child("custom_bar"):set_h(0)
		self._custom_player_panel:child("weapons_panel"):set_visible(false)
		if not self._main_player then self._custom_player_panel:child("weapons_panel"):set_x(self._custom_player_panel:child("health_panel"):right() - (6 * self._mate_scale)) end
		self._custom_player_panel:child("carry_panel"):set_visible(false)
		self._custom_player_panel:child("carry_panel"):child("name"):set_text("")
		self._custom_player_panel:child("carry_panel"):child("name_shadow"):set_text("")
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
		local color = tweak_data.chat_colors[self._color_id] or Color.white
		if alive(health_stored_bg) and value > 0 then	
			health_stored:set_visible(true)
			health_stored:set_w(self._health_w / 2.9)
			health_stored_bg:set_visible(true)
			health_stored_bg:set_w(self._health_w / 2.9)
			health_stored_bg:set_h(self._bg_h * value)
			health_stored_bg:set_right(health_panel:x() + (11 * self._main_scale))
			health_stored_bg:set_texture_rect(811,((1- value) * 472),70,472 * value)
			health_stored_bg:set_bottom(self._custom_player_panel:h())
			health_stored_bg:set_color(color * 0.4 + Color.black)
			health_stored:set_color(color * 0.7 + Color.black * 0.9)
			weapons_panel:set_x(health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale))
			if not health_stored_max then 	
				local health_stored_max = self._custom_player_panel:bitmap({
					name = "health_stored_max",
					texture = "guis/textures/VoidUI/hud_health",
					texture_rect = {811,0,70,472},
					layer = 1,
					w = self._health_w / 2.9,
					h = self._bg_h,
					alpha = 1,
				})
				health_stored_max:set_color(color * (Color.white * 0.5))
				health_stored_max:set_right(health_panel:x() + (11 * self._main_scale))
				health_stored_max:set_bottom(self._custom_player_panel:h())
			else
				health_stored_max:set_color(color * (Color.white * 0.5))
				health_stored_max:set_right(health_panel:x() + (11 * self._main_scale))
				health_stored_max:set_bottom(self._custom_player_panel:h())
			end
		end
	end

	function HUDTeammate:set_stored_health(stored_health_ratio)
		local health_panel = self._custom_player_panel:child("health_panel")
		local health_stored = self._custom_player_panel:child("health_stored")
		local health_stored_bg = self._custom_player_panel:child("health_stored_bg")
		if alive(health_stored) then
			local value = math.min(stored_health_ratio, 1)
			health_stored:animate(function(o)
				local current_value = health_stored:h() / health_panel:h()
				local h = health_stored:h()
				over(0.2, function(p)
					health_stored:set_h(math.lerp(h, health_panel:h() * value, p))
					health_stored:set_bottom(health_stored_bg:bottom())
					health_stored:set_texture_rect(811,((health_stored:y() - health_panel:y()) / self._bg_h) * 472, 70, 472 * (health_stored:h() / self._bg_h))
				end)
			end)
		end
	end

	function HUDTeammate:_animate_update_absorb(o, radial_absorb_shield_name, radial_absorb_health_name, var_name, blink)
		repeat
			coroutine.yield()
		until alive(self._panel) and self[var_name] and self._armor_data and self._health_data
		local teammate_panel = self._panel:child("player")
		local health_panel = self._custom_player_panel:child("health_panel")
		local armor_bar = health_panel:child("armor_bar")
		local health_bar = health_panel:child("health_bar")
		local absorb_shield_bar = health_panel:child("absorb_shield_bar")
		local absorb_health_bar = health_panel:child("absorb_health_bar")
		local current_absorb = 0
		local current_shield, current_health, armor_value, health_value
		local step_speed = 1
		local lerp_speed = 1
		local dt, update_absorb
		local t = 0
		while alive(teammate_panel) do
			dt = coroutine.yield()
			if self[var_name] and self._armor_data and self._health_data then
				update_absorb = false
				
				current_shield = self._armor_data.current
				current_health = self._health_data.current
				
				armor_value = self._armor_data.current / self._armor_data.total
				health_value = health_bar:h() / self._bg_h
				
				if absorb_shield_bar:y() ~= armor_bar:y() or absorb_health_bar ~= health_bar:y() then
					absorb_shield_bar:set_top(armor_bar:y())
					absorb_health_bar:set_top(health_bar:y())
					update_absorb = true
				end
				if current_absorb ~= self[var_name] then
					current_absorb = math.lerp(current_absorb, self[var_name], lerp_speed * dt)
					current_absorb = math.step(current_absorb, self[var_name], step_speed * dt)
					update_absorb = true
				end
				if blink then
					t = (t + dt * 0.5) % 1
					armor_bar:set_alpha(math.abs(math.sin(t * 180)) * 0.25 + 0.75)
					health_bar:set_alpha(math.abs(math.sin(t * 180)) * 0.25 + 0.75)
				end
				if update_absorb and current_absorb > 0 then
					local shield_ratio = current_shield == 0 and 0 or math.min(current_absorb / current_shield, 1)
					local health_ratio = current_health == 0 and 0 or math.min((current_absorb - shield_ratio * current_shield) / current_health, 1)
					local shield = math.clamp(shield_ratio, 0, 1)
					local health = math.clamp(health_ratio, 0, 1)
					
					absorb_shield_bar:set_h(self._bg_h * shield)
					absorb_shield_bar:set_texture_rect(609, ((1- armor_value) * 472), 201,472 * shield)
					
					absorb_health_bar:set_h(self._bg_h * health)
					absorb_health_bar:set_texture_rect(203, ((1- health_value) * 472), 202,472 * health)
					
					absorb_shield_bar:set_visible(armor_value * 100 > 1)
					absorb_health_bar:set_visible(health_value * 100 > 1)
				else
					absorb_shield_bar:set_visible(false)
					absorb_health_bar:set_visible(false)
				end
			end
		end
	end
	function HUDTeammate:set_absorb_active(absorb_amount)
		self._absorb_active_amount = absorb_amount

		if self._main_player and managers.network and managers.network:session() then
			managers.network:session():send_to_peers("sync_damage_absorption_hud", self._absorb_active_amount)
		end
	end
	function HUDTeammate:set_info_meter(data)
		local health_panel = self._custom_player_panel:child("health_panel")
		local weapons_panel = self._custom_player_panel:child("weapons_panel")
		local health_stored = self._custom_player_panel:child("health_stored")
		local health_stored_bg = self._custom_player_panel:child("health_stored_bg")

		local percentage = math.clamp(data.current / data.max, 0, 1)
		if data.total > 0 then
			if self._main_player then
				health_stored_bg:set_visible(true)
				health_stored:set_visible(true)
				health_stored_bg:set_w(self._health_w / 2.9)
				health_stored:set_w(self._health_w / 2.9)
				health_stored_bg:set_right(health_panel:x() + (11 * self._main_scale))
				weapons_panel:set_x(health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale))
			else
				health_stored_bg:set_visible(true)
				health_stored:set_visible(true)
				health_stored_bg:set_w(self._health_w / 2.9)
				health_stored:set_w(self._health_w / 2.9)
				health_stored_bg:set_left(health_panel:right() - (5 * self._mate_scale))
				health_stored:set_left(health_panel:right() - (5 * self._mate_scale))
				weapons_panel:set_x(health_stored_bg:x() + (8 * self._mate_scale))
			
			end
		else
			if self._main_player then
				health_stored_bg:set_visible(false)
				health_stored:set_visible(false)
				health_stored_bg:set_y(health_panel:x())
				weapons_panel:set_x(health_stored_bg:x() - weapons_panel:w() + (8 * self._main_scale))
			else
				health_stored_bg:set_visible(false)
				health_stored:set_visible(false)
				health_stored_bg:set_left(health_panel:right() - (5 * self._mate_scale))
				health_stored:set_left(health_panel:right() - (5 * self._mate_scale))
				weapons_panel:set_x(health_panel:right() - (6 * self._mate_scale))
			
			end
		end
		health_stored:stop()
		health_stored:animate(function(o)
			local current_percentage = health_stored:h() / self._bg_h
			over(0.2, function(p)
				local value = math.lerp(current_percentage, percentage, p) 
				health_stored:set_h(self._bg_h * value)
				health_stored:set_texture_rect(811,(1 - value) * 472, 70, 472 * value)
				health_stored:set_bottom(self._custom_player_panel:h())
				health_stored:set_visible(value > 0)
			end)
		end)
	end

	function HUDTeammate:downed()
		local health_panel = self._custom_player_panel:child("health_panel")
		local downs_value = health_panel:child("downs_value")
		self._downs = math.clamp(self._downs - 1, 0, self._downs_max)
		downs_value:set_text("x".. tostring(self._downs))
	end

	function HUDTeammate:reset_downs()
		local health_panel = self._custom_player_panel:child("health_panel")
		local downs_value = health_panel:child("downs_value")
		self._downs = self._downs_max
		downs_value:set_text("x".. tostring(self._downs))
	end
	
	function HUDTeammate:set_max_downs()
		local health_panel = self._custom_player_panel:child("health_panel")
		local downs_value = health_panel:child("downs_value")
		self._downs_max = Global.game_settings.one_down and 2 or tweak_data.player.damage.LIVES_INIT
		if self._main_player then
			self._downs_max = self._downs_max - (managers.player:upgrade_value("player", "additional_lives", 0) == 1 and 0 or 1)
		elseif self._peer_id then
			local peer = managers.network:session():peer(self._peer_id)
			local outfit = peer and peer:blackmarket_outfit()
			local skills = outfit and outfit.skills
			skills = skills and skills.skills
			self._downs_max = self._downs_max - (tonumber(skills[14] or 0) >= 3 and 0 or 1)
		end
		self._downs_max = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._downs_max)
		self._downs = self._downs_max
		downs_value:set_text("x".. tostring(self._downs))
	end
end