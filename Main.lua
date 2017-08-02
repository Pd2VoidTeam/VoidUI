_G.HeistHUD = _G.HeistHUD or {}
HeistHUD.mod_path = ModPath
HeistHUD.options_path = SavePath .. "HeistHUD.txt"
HeistHUD.options = {} 
HeistHUD.hook_files = {
	["lib/managers/hudmanager"] = {"HudManager.lua"},
	["lib/managers/hud/hudteammate"] = {"HudTeammate.lua"},
	["lib/managers/hud/hudtemp"] = {"HudTemp.lua"},
	["lib/managers/hud/hudblackscreen"] = {"HudBlackscreen.lua"},
	["lib/states/ingamewaitingforplayers"] = {"HudBlackscreen.lua"},
	["lib/managers/hudmanagerpd2"] = {"HudManager.lua"},
	["lib/units/beings/player/huskplayermovement"] = {"HudDowns.lua"},
	["lib/units/beings/player/states/playerbleedout"] = {"HudDowns.lua"},
	["lib/network/handlers/unitnetworkhandler"] = {"HudDowns.lua", "Jokers.lua"},
	["lib/units/equipment/doctor_bag/doctorbagbase"] = {"HudDowns.lua"},
	["lib/managers/hud/hudobjectives"] = {"HudObjectives.lua"},
	["lib/managers/hud/hudheisttimer"] = {"HudHeistTimer.lua"},
	["lib/managers/customsafehousemanager"] = {"HudPresenter.lua"},
	["lib/managers/hud/hudpresenter"] = {"HudPresenter.lua"},
	["lib/managers/hud/hudhint"] = {"HudHint.lua"},
	["lib/managers/hintmanager"] = {"HudHint.lua"},
	["lib/managers/hud/hudinteraction"] = {"HudInteraction.lua"},
	["lib/managers/hud/hudchat"] = {"HudChat.lua"},
	["lib/managers/hud/hudassaultcorner"] = {"HudAssaultCorner.lua"},
	["lib/managers/group_ai_states/groupaistatebase"] = {"HudAssaultCorner.lua", "Jokers.lua"},
	["lib/managers/objectinteractionmanager"] = {"HudAssaultCorner.lua"},
	["lib/units/equipment/ecm_jammer/ecmjammerbase"] = {"HudAssaultCorner.lua"},
	["lib/units/contourext"] = {"Jokers.lua"},
	["lib/units/enemies/cop/huskcopbrain"] = {"Jokers.lua"},
	["lib/units/enemies/cop/copdamage"] = {"Jokers.lua"},
	["lib/units/player_team/teamaidamage"] = {"HudManager.lua"},
	["lib/units/player_team/huskteamaidamage"] = {"HudManager.lua"},
	["core/lib/managers/subtitle/coresubtitlepresenter"] = {"HudManager.lua"}
}
function HeistHUD:Save()
	local file = io.open( self.options_path, "w+" )
	if file then
		file:write( json.encode( self.options ) )
		file:close()
	end
end
function HeistHUD:Load()
	local file = io.open( self.options_path, "r" )
	if file then
		self.options = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "HeistHUD_Localization", function(loc)
	local loc_path = HeistHUD.mod_path .. "loc/"

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

function HeistHUD:reset_options()
	HeistHUD.options.totalammo = true
	HeistHUD.options.main_loud = true
	HeistHUD.options.main_stealth = true
	HeistHUD.options.mate_loud = true
	HeistHUD.options.mate_stealth = true
	HeistHUD.options.mate_name = true
	HeistHUD.options.show_levelname = true
	HeistHUD.options.show_ghost_icon = true
	HeistHUD.options.show_badge = true
	HeistHUD.options.anim_badge = true
	HeistHUD.options.show_charactername = true
	HeistHUD.options.label_jokers = true
	HeistHUD.options.label_minmode = true
	HeistHUD.options.label_minrank = true
	HeistHUD.options.label_waypoint_offscreen = true
	HeistHUD.options.chat_mouse = true
	HeistHUD.options.mate_interact = true
	HeistHUD.options.ammo_pickup = true
	HeistHUD.options.hud_scale = 1
	HeistHUD.options.hud_main_scale = 1
	HeistHUD.options.hud_mate_scale = 1
	HeistHUD.options.hud_chat_scale = 1
	HeistHUD.options.hud_assault_scale = 1
	HeistHUD.options.hud_objectives_scale = 1
	HeistHUD.options.waypoint_scale = 0.8
	HeistHUD.options.label_minscale = 1
	HeistHUD.options.label_scale = 1
	HeistHUD.options.hud_objective_history = 3
	HeistHUD.options.label_minmode_dist = 7
	HeistHUD.options.label_minmode_dot = 1
	HeistHUD.options.chat_copy = 4
	HeistHUD.options.main_health = 2
	HeistHUD.options.mate_health = 2
	HeistHUD.options.chattime = 1
	HeistHUD.options.armor = 2
	HeistHUD.options.waypoint_radius = 200
	HeistHUD:Save()
end
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_HeistHUD", function(menu_manager)
	MenuCallbackHandler.callback_heisthud_hudscale = function(self, item)
		HeistHUD.options.hud_scale = item:value()
		HeistHUD.options.hud_main_scale = item:value()
		HeistHUD.options.hud_mate_scale = item:value()
		HeistHUD.options.hud_objectives_scale = item:value()
		HeistHUD.options.hud_assault_scale = item:value()
		HeistHUD.options.hud_chat_scale = item:value()
		local hudteammate = MenuHelper:GetMenu("HeistHUD_options_hudteammate")
		if hudteammate then 
			hudteammate._items_list[2]:set_value(item:value())
			hudteammate._items_list[11]:set_value(item:value())
		end
		local objectives = MenuHelper:GetMenu("HeistHUD_options_objectives")
		if objectives then
			objectives._items_list[1]:set_value(item:value())
		end
		local assault = MenuHelper:GetMenu("HeistHUD_options_assault")
		if assault then
			assault._items_list[1]:set_value(item:value())
		end
		local chat = MenuHelper:GetMenu("HeistHUD_options_chat")
		if assault then
			chat._items_list[1]:set_value(item:value())
		end
	end
	MenuCallbackHandler.basic_option_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = item:value()
	end
	MenuCallbackHandler.toggle_option_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = (item:value() == "on" and true or false)
	end
	MenuCallbackHandler.toggle_badge_clbk = function(self, item)
		HeistHUD.options[item:parameters().name] = (item:value() == "on" and true or false)
		
		local assault = MenuHelper:GetMenu("HeistHUD_options_assault")
		if assault then
			assault._items_list[3]:set_enabled(item:value() == "on" and true or false)
		end
	end
	
	MenuCallbackHandler.callback_heisthud_reset = function(self, item)
		local buttons = {
			[1] = { 
				text = managers.localization:text("dialog_yes"), 
				callback = function(self, item)
					HeistHUD:reset_options()
				end,
				},
			[2] = { text = managers.localization:text("dialog_no"), is_cancel_button = true, }
		}
		QuickMenu:new( managers.localization:text("HeistHUD_reset_title"), managers.localization:text("HeistHUD_reset_confirm"), buttons, true )
	end
	
	MenuCallbackHandler.heisthud_save = function(self, item)
		HeistHUD:Save()
	end	
	
	HeistHUD:Load()
	if HeistHUD.options.chat_mouse == nil then HeistHUD:reset_options() end
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/options.json", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/chat.json", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/assaultcorner.json", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/labels.json", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/objectives.json", HeistHUD, HeistHUD.options)
	MenuHelper:LoadFromJsonFile(HeistHUD.mod_path .. "menu/hudteammate.json", HeistHUD, HeistHUD.options)
end )

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
		if HeistHUD.hook_files[requiredScript] then
			for _, file in ipairs(HeistHUD.hook_files[requiredScript]) do
			dofile( HeistHUD.mod_path .. "lua/" .. file )
		end
	end
end