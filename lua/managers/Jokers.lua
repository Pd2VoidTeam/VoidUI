if RequiredScript == "lib/units/contourext" then
	table.insert(ContourExt._types, "joker")
	ContourExt._types["joker"] = {priority = 1, material_swap_required = true} 

elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	
	Hooks:PostHook(GroupAIStateBase,"convert_hostage_to_criminal","void_convert_hostage_to_criminal", function(self, unit, peer_unit)
		if alive(unit) then
			local player_unit = peer_unit or managers.player:player_unit()
			local unit_data = self._police[unit:key()]
			local color_id = managers.criminals:character_color_id_by_unit(player_unit)
			if VoidUI.options.outlines then
				unit:contour():add("joker", nil, 1)
				unit:contour():change_color("joker", tweak_data.peer_vector_colors[color_id])
			end
			
			if unit_data and VoidUI.options.enable_labels and VoidUI.options.label_jokers then
				local panel_id = managers.hud:_add_name_label({unit = unit, name = "Joker", owner_unit = player_unit})
				local label = managers.hud:_get_name_label(panel_id)
				if VoidUI.options.health_jokers and VoidUI.options.enable_labels and label.panel:child("minmode_panel") then
					label.interact:set_visible(true)
						label.interact_bg:set_visible(true)
						label.panel:child("minmode_panel"):child("min_interact"):set_visible(true)
						label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(true)
						label.interact:set_w(label.interact_bg:w())
				end
				unit:unit_data().label_id = panel_id
			end
			unit:base().owner_peer_id = player_unit:network():peer():id()
		end
	end)

	Hooks:PreHook(GroupAIStateBase,"remove_minion","void_remove_minion", function(self, minion_key, player_key)
		local minion_unit = self._converted_police[minion_key]
		if alive(minion_unit) then
			if minion_unit.unit_data and minion_unit:unit_data().label_id then
				managers.hud:_remove_name_label(minion_unit:unit_data().label_id)	
			end
			minion_unit:contour():remove("joker")
		end
	end)
	
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	Hooks:PostHook(UnitNetworkHandler,"mark_minion","void_mark_minion", function(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
		if alive(unit) and minion_owner_peer_id and managers.network and managers.network:session() then
			local get_owner = managers.network:session():peer(minion_owner_peer_id):unit()
			local color_id = minion_owner_peer_id and managers.criminals and managers.criminals:character_color_id_by_unit(get_owner) or 1
			if VoidUI.options.outlines then
				unit:contour():add("joker", nil, 1)
				unit:contour():change_color("joker", tweak_data.peer_vector_colors[color_id])
			end
			
			if VoidUI.options.enable_labels and VoidUI.options.label_jokers then
				local panel_id = managers.hud:_add_name_label({ unit = unit, name = "Joker", owner_unit = managers.network:session():peer(minion_owner_peer_id):unit()})
				local label = managers.hud:_get_name_label(panel_id)
				if VoidUI.options.health_jokers and VoidUI.options.enable_labels and label.panel:child("minmode_panel") then
					label.interact:set_visible(true)
					label.interact_bg:set_visible(true)
					label.panel:child("minmode_panel"):child("min_interact"):set_visible(true)
					label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(true)
					label.interact:set_w(label.interact_bg:w())
				end
				unit:unit_data().label_id = panel_id
			end
			unit:base().owner_peer_id = minion_owner_peer_id
		end
	end)
	
	Hooks:PreHook(UnitNetworkHandler,"hostage_trade","void_hostage_trade", function(self, unit, enable, trade_success, skip_hint)
		if alive(unit) then
			if unit.unit_data and unit:unit_data().label_id then
				managers.hud:_remove_name_label(unit:unit_data().label_id)	
				unit:unit_data().label_id = nil
			end
			unit:contour():remove("joker")
		end
	end)
elseif RequiredScript == "lib/units/enemies/cop/huskcopbrain" then
	
	Hooks:PreHook(HuskCopBrain,"clbk_death","void_cop_clbk_death", function(self, my_unit, damage_info)
		if alive(self._unit) then
			if self._unit:unit_data().label_id then
				managers.hud:_remove_name_label(self._unit:unit_data().label_id)	
				self._unit:unit_data().label_id = nil
			end
			self._unit:contour():remove("joker")
		end
	end)
	
elseif RequiredScript == "lib/units/enemies/cop/copdamage" and VoidUI.options.enable_labels then

	Hooks:PostHook(CopDamage,"_on_damage_received","void_cop_on_damage_received", function(self, damage_info)
		if alive(self._unit) and self._unit:unit_data().label_id then
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
	end)
	
end