_G.VoidUI = _G.VoidUI or {}
VoidUI.Warning = 0
VoidUI.loaded = false
VoidUI.mod_path = ModPath
VoidUI.options_path = SavePath .. "VoidUI.txt"
VoidUI.options = {} 
VoidUI.hook_files = {
	["lib/managers/hudmanager"] = {"hudmanager.lua"},
	["lib/managers/hud/hudteammate"] = {"hudteammate.lua"},
	["lib/managers/hud/hudtemp"] = {"hudtemp.lua"},
	["lib/managers/hud/hudblackscreen"] = {"hudblackscreen.lua"},
	["lib/managers/hud/hudsuspicion"] = {"hudsuspicion.lua"},
	["lib/states/ingamewaitingforplayers"] = {"hudblackscreen.lua"},
	["lib/managers/hudmanagerpd2"] = {"hudmanager.lua", "hudscoreboard.lua"},
	["lib/units/beings/player/huskplayermovement"] = {"hudplayerdowned.lua"},
	["lib/units/beings/player/states/playerbleedout"] = {"hudplayerdowned.lua"},
	["lib/network/handlers/unitnetworkhandler"] = {"hudplayerdowned.lua", "jokers.lua"},
	["lib/units/equipment/doctor_bag/doctorbagbase"] = {"hudplayerdowned.lua"},
	["lib/managers/hud/hudplayerdowned"] = {"hudplayerdowned.lua"},
	["lib/managers/hud/hudobjectives"] = {"hudobjectives.lua"},
	["lib/managers/hud/hudheisttimer"] = {"hudheisttimer.lua"},
	["lib/managers/customsafehousemanager"] = {"hudpresenter.lua"},
	["lib/managers/challengemanager"] = {"hudpresenter.lua"},
	["lib/managers/hud/hudpresenter"] = {"hudpresenter.lua"},
	["lib/managers/hud/hudhint"] = {"hudhint.lua"},
	["lib/managers/hintmanager"] = {"hudhint.lua"},
	["lib/managers/hud/hudinteraction"] = {"hudinteraction.lua"},
	["lib/managers/hud/hudchat"] = {"hudchat.lua"},
	["lib/managers/hud/hudassaultcorner"] = {"hudassaultcorner.lua"},
	["lib/managers/group_ai_states/groupaistatebase"] = {"hudassaultcorner.lua", "jokers.lua"},
	["lib/managers/objectinteractionmanager"] = {"hudassaultcorner.lua"},
	["lib/units/equipment/ecm_jammer/ecmjammerbase"] = {"hudassaultcorner.lua"},
	["lib/units/contourext"] = {"jokers.lua"},
	["lib/units/enemies/cop/huskcopbrain"] = {"jokers.lua"},
	["lib/units/enemies/cop/copdamage"] = {"jokers.lua", "hudscoreboard.lua"},
	["lib/units/player_team/teamaidamage"] = {"hudmanager.lua"},
	["lib/units/player_team/huskteamaidamage"] = {"hudmanager.lua"},
	["core/lib/managers/subtitle/coresubtitlepresenter"] = {"hudmanager.lua"},
	["lib/managers/hud/hudwaitinglegend"] = {"hudmanager.lua"},
	["lib/units/civilians/civiliandamage"] = {"hudscoreboard.lua"},
	["lib/managers/hud/hudstatsscreen"] = {"hudscoreboard.lua"}
}
VoidUI.disable_list = {
	["anim_badge"] = "show_badge",
	["health_jokers"] = "label_jokers",
	["label_minscale"] = "label_minmode",
	["label_minrank"] = "label_minmode",
	["label_minmode_dist"] = "label_minmode",
	["label_minmode_dot"] = "label_minmode",
	["scoreboard_character"] = "scoreboard",
	["scoreboard_skills"] = "scoreboard",
	["scoreboard_kills"] = "scoreboard",
	["scoreboard_specials"] = "scoreboard",
	["scoreboard_civs"] = "scoreboard",
	["scoreboard_downs"] = "scoreboard",
	["scoreboard_weapons"] = "scoreboard",
	["scoreboard_skins"] = "scoreboard",
	["scoreboard_armor"] = "scoreboard",
	["scoreboard_perk"] = "scoreboard",
	["scoreboard_playtime"] = "scoreboard",
	["scoreboard_ping"] = "scoreboard",
	["ping_frequency"] = "scoreboard"	
}

function VoidUI:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end
function VoidUI:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options_temp = json.decode( file:read("*all") )
		file:close()
		for k,v in pairs(self.options_temp) do 
			self.options[k] = v 
		end
		self.options_temp = nil
	else
		VoidUI:DefaultConfig()
		VoidUI:Save()
	end
end
function VoidUI:LoadTextures()
	for _, file in pairs(SystemFS:list(VoidUI.mod_path.. "guis/textures/VoidUI")) do
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/VoidUI/".. file:gsub(".texture", "")), VoidUI.mod_path.. "guis/textures/VoidUI/".. file)
	end
end
Hooks:Add("LocalizationManagerPostInit", "VoidUI_Localization", function(loc)
	local loc_path = VoidUI.mod_path .. "loc/"

	if file.DirectoryExists( loc_path ) then
		for _, filename in pairs(file.GetFiles(loc_path)) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(loc_path .. filename)
				break
			end
		end
		loc:load_localization_file(loc_path .. "english.json", false)
	else
		log("Localization folder seems to be missing!")
	end
end)
function VoidUI:DefaultConfig()
	VoidUI.options = {
		totalammo = true,
		main_loud = true,
		main_stealth = true,
		mate_loud = true,
		mate_stealth = true,
		mate_name = true,
		show_levelname = true,
		show_ghost_icon = true,
		show_badge = true,
		anim_badge = true,
		show_charactername = true,
		label_jokers = true,
		label_minmode = true,
		label_minrank = true,
		label_waypoint_offscreen = true,
		chat_mouse = true,
		mate_interact = true,
		ammo_pickup = true,
		show_loot = true,
		hostages = true,
		pagers = true,
		outlines = true,
		health_jokers = true,
		show_interact = true,
		scoreboard_blur = true,
		scoreboard = true,
		scoreboard_character = true,
		scoreboard_skills = true,
		scoreboard_specials = true,
		scoreboard_civs = true,
		scoreboard_downs = true,
		scoreboard_weapons = true,
		scoreboard_armor = true,
		scoreboard_perk = true,
		scoreboard_playtime = true,
		scoreboard_ping = true,
		trophies = true,
		save_warning = false,
		enable_interact = true,
		enable_suspicion = true,
		presenter_sound = true,
		hint_color = true,
		hint_anim = true,
		scoreboard_skins = 2,
		scoreboard_kills = 3,
		show_objectives = 3,
		show_timer = 3,
		ping_frequency = 2,
		jammers = 2,
		hud_scale = 1,
		hud_main_scale = 1,
		hud_mate_scale = 1,
		hud_chat_scale = 1,
		scoreboard_scale = 1,
		hud_assault_scale = 1,
		hud_objectives_scale = 1,
		presenter_scale = 1,
		suspicion_scale = 1,
		interact_scale = 1,
		waypoint_scale = 0.8,
		label_minscale = 1,
		label_scale = 1,
		hud_objective_history = 3,
		presenter_buffer = 5,
		hint_scale = 1,
		label_minmode_dist = 7,
		label_minmode_dot = 1,
		chat_copy = 5,
		main_health = 2,
		mate_health = 2,
		chattime = 1,
		main_armor = 2,
		mate_armor = 1,
		assault_lines = 3,
		waypoint_radius = 200,
		suspicion_y = 160,
		interact_y = 40,
		main_anim_time = 0.2,
		mate_anim_time = 0.2
	}

end

if not VoidUI.loaded then
	VoidUI.loaded = true
	VoidUI:DefaultConfig()
	VoidUI:Load()
	VoidUI:LoadTextures()
end

function VoidUI:UpdateMenu()
	for _, file in pairs(SystemFS:list(VoidUI.mod_path.. "menu/")) do
		local menu_name = "VoidUI_".. file:gsub(".json", "")
		for _, item in pairs(MenuHelper:GetMenu(menu_name)._items_list) do
			if VoidUI.disable_list[item:parameters().name] then
				local disable_list_entry = VoidUI.disable_list[item:parameters().name]
				item:set_enabled(VoidUI.options[disable_list_entry])
			end
			if item._type == "slider" then
				local value = VoidUI.options[item:parameters().name]
				local step = item:parameters().step
				if step >= 1 and value ~= nil and step ~= nil then
					if value % step ~= 0 then
						item:set_value(value + (value % step >= 0.5 and 1 - value % step or -(value % step)))
					end
				end
			end
		end
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_VoidUI", function(menu_manager)
	MenuCallbackHandler.callback_VoidUI_hudscale = function(self, item)
		VoidUI.options.hud_scale = item:value()
		VoidUI.options.hud_main_scale = item:value()
		VoidUI.options.hud_mate_scale = item:value()
		VoidUI.options.hud_objectives_scale = item:value()
		VoidUI.options.hud_assault_scale = item:value()
		VoidUI.options.hud_chat_scale = item:value()
		local hudteammate = MenuHelper:GetMenu("VoidUI_hudteammate")
		if hudteammate then 
			hudteammate._items_list[2]:set_value(item:value())
			hudteammate._items_list[13]:set_value(item:value())
		end
		local objectives = MenuHelper:GetMenu("VoidUI_objectives")
		if objectives then
			objectives._items_list[1]:set_value(item:value())
		end
		local assault = MenuHelper:GetMenu("VoidUI_assault")
		if assault then
			assault._items_list[1]:set_value(item:value())
		end
		local chat = MenuHelper:GetMenu("VoidUI_chat")
		if assault then
			chat._items_list[1]:set_value(item:value())
		end
		local interact = MenuHelper:GetMenu("VoidUI_interact")
		if interact then 
			interact._items_list[2]:set_value(item:value())
			interact._items_list[7]:set_value(item:value())
		end
		local scoreboard = MenuHelper:GetMenu("VoidUI_scoreboard")
		if scoreboard then 
			scoreboard._items_list[1]:set_value(item:value())
		end
		if VoidUI.Warning == 0 then VoidUI.Warning = 1 end
	end
	MenuCallbackHandler.basic_option_clbk = function(self, item)
		VoidUI.options[item:parameters().name] = item:value()
		if VoidUI.Warning == 0 then VoidUI.Warning = 1 end
		VoidUI:UpdateMenu()
	end
	MenuCallbackHandler.toggle_option_clbk = function(self, item)
		VoidUI.options[item:parameters().name] = (item:value() == "on" and true or false)
		if VoidUI.Warning == 0 then VoidUI.Warning = 1 end
		VoidUI:UpdateMenu()
	end
	
	MenuCallbackHandler.callback_VoidUI_reset = function(self, item)
		VoidUI.Warning = 0
		local buttons = {
			[1] = { 
				text = managers.localization:text("dialog_yes"), 
				callback = function(self, item)
					VoidUI:DefaultConfig()
					for _, file in pairs(SystemFS:list(VoidUI.mod_path.. "menu/")) do
						local menu_name = "VoidUI_".. file:gsub(".json", "")
						for _, item in pairs(MenuHelper:GetMenu(menu_name)._items_list) do
							local value = VoidUI.options[item:parameters().name]
							if value then 
								if item._type == "toggle" then
									item:set_value(value and "on" or "off")
								elseif item._type ~= "divider" then
									item:set_value(value)
								end
							end
						end
					end
					managers.viewport:resolution_changed()
				end,
				},
			[2] = { text = managers.localization:text("dialog_no"), is_cancel_button = true, }
		}
		QuickMenu:new( managers.localization:text("VoidUI_reset_title"), managers.localization:text("VoidUI_reset_confirm"), buttons, true )
	end
	MenuCallbackHandler.VoidUI_save = function(self, item)
		VoidUI:Save()
	end
	
	MenuCallbackHandler.VoidUI_warning_save = function(self, item)
		VoidUI:Save()
		if managers.hud and not VoidUI.options.save_warning and VoidUI.Warning == 1 then
			local buttons = {
				[1] = { 
					text = managers.localization:text("dialog_ok"), 
					callback = function(self, item)
						VoidUI.Warning = 2	
					end
					},
				[2] = { 
					text = managers.localization:text("VoidUI_warning_confirm"), 
					callback = function(self, item)
						VoidUI.options.save_warning = true	
						VoidUI:Save()
					end
				 }
			}
			QuickMenu:new(managers.localization:text("VoidUI_warning_title"), managers.localization:text("VoidUI_warning_desc"), buttons, true )
		end
	end	
	MenuHelper:LoadFromJsonFile(VoidUI.mod_path .. "menu/options.json", VoidUI, VoidUI.options)
	for _, file in pairs(SystemFS:list(VoidUI.mod_path.. "menu/")) do
		MenuHelper:LoadFromJsonFile(VoidUI.mod_path .. "menu/"..file, VoidUI, VoidUI.options)
	end
end )

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_VoidUI", function(menu_manager, nodes)
	VoidUI:UpdateMenu()
end)
	
function MenuManager:toggle_chatinput()
	if Application:editor() then
		return
	end
	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end
	if self:active_menu() then
		return
	end
	if not managers.network:session() then
		return
	end
	if managers.hud then
		managers.hud:toggle_chatinput()
		return true
	end
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
		if VoidUI.hook_files[requiredScript] then
			for _, file in ipairs(VoidUI.hook_files[requiredScript]) do
			dofile( VoidUI.mod_path .. "lua/" .. file )
		end
	end
end