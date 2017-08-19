if RequiredScript == "lib/units/contourext" then
	table.insert(ContourExt._types, "joker")
	ContourExt._types["joker"] = {priority = 1, material_swap_required = true} 

elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	
	local convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal
	function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)
		convert_hostage_to_criminal(self, unit, peer_unit)
		
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		local player_unit = peer_unit or managers.player:player_unit()
		local unit_data = self._police[unit:key()]
		local color_id = managers.criminals:character_color_id_by_unit(player_unit)
		if VoidUI.options.outlines then
			unit:contour():add("joker", nil, 1)
			unit:contour():change_color("joker", tweak_data.peer_vector_colors[color_id])
		end
		
		if unit_data and VoidUI.options.label_jokers then
			local panel_id = managers.hud:_add_name_label({ unit = unit, name = "Joker", owner_unit = player_unit})
			
			if VoidUI.options.health_jokers then
				local label = managers.hud:_get_name_label(panel_id)
				label.interact:set_visible(true)
				label.interact_bg:set_visible(true)
				label.panel:child("minmode_panel"):child("min_interact"):set_visible(true)
				label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(true)
				label.interact:set_w(label.interact_bg:w())
			end
			
			unit:base().owner_peer_id = player_unit:network():peer():id()
			unit:unit_data().label_id = panel_id
		end
	end

	local remove_minion = GroupAIStateBase.remove_minion
	function GroupAIStateBase:remove_minion(minion_key, player_key)
		local minion_unit = self._converted_police[minion_key]
		if minion_unit:unit_data().label_id then
			managers.hud:_remove_name_label(minion_unit:unit_data().label_id)	
		end
		minion_unit:contour():remove("joker")

		remove_minion(self, minion_key, player_key)
	end
	
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	local mark_minion = UnitNetworkHandler.mark_minion
	function UnitNetworkHandler:mark_minion(unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
		mark_minion(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
		
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		local color_id = managers.criminals:character_color_id_by_unit(managers.network:session():peer(minion_owner_peer_id):unit())
		if VoidUI.options.outlines then
			unit:contour():add("joker", nil, 1)
			unit:contour():change_color("joker", tweak_data.peer_vector_colors[color_id])
		end
		
		if VoidUI.options.label_jokers then
			local panel_id = managers.hud:_add_name_label({ unit = unit, name = "Joker", owner_unit = managers.network:session():peer(minion_owner_peer_id):unit()})
			if VoidUI.options.health_jokers then
				local label = managers.hud:_get_name_label(panel_id)
				label.interact:set_visible(true)
				label.interact_bg:set_visible(true)
				label.panel:child("minmode_panel"):child("min_interact"):set_visible(true)
				label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(true)
				label.interact:set_w(label.interact_bg:w())
			end
			unit:base().owner_peer_id = minion_owner_peer_id
			unit:unit_data().label_id = panel_id
		end
	end
	
	local hostage_trade = UnitNetworkHandler.hostage_trade
	function UnitNetworkHandler:hostage_trade(unit, enable, trade_success, skip_hint)
		if unit:unit_data().label_id then
				managers.hud:_remove_name_label(unit:unit_data().label_id)	
				unit:unit_data().label_id = nil
			end
			unit:contour():remove("joker")

		hostage_trade(self, unit, enable, trade_success, skip_hint)
	end
elseif RequiredScript == "lib/units/enemies/cop/huskcopbrain" then
	
	local clbk_death = HuskCopBrain.clbk_death
	function HuskCopBrain:clbk_death(my_unit, damage_info)
		if self._unit:unit_data().label_id then
			managers.hud:_remove_name_label(self._unit:unit_data().label_id)	
			self._unit:unit_data().label_id = nil
		end
		self._unit:contour():remove("joker")

		clbk_death(self, my_unit, damage_info)
	end
	
elseif RequiredScript == "lib/units/enemies/cop/copdamage" then

	local on_damage_received = CopDamage._on_damage_received
	function CopDamage:_on_damage_received(damage_info)
		on_damage_received(self, damage_info)
		if self._unit:unit_data().label_id then
			local label = managers.hud:_get_name_label(self._unit:unit_data().label_id)
			if label then
				label.interact:set_visible(VoidUI.options.health_jokers)
				label.interact_bg:set_visible(VoidUI.options.health_jokers)
				label.panel:child("minmode_panel"):child("min_interact"):set_visible(VoidUI.options.health_jokers)
				label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(VoidUI.options.health_jokers)
				label.interact:set_w(label.interact_bg:w() * self._health_ratio)
				label.panel:child("minmode_panel"):child("min_interact"):set_w(label.panel:child("minmode_panel"):child("min_interact_bg"):w() * self._health_ratio)
			end
		end
	end
	
end