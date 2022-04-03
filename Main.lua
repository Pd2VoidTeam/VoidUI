_G.VoidUI = _G.VoidUI or {}
VoidUI.Warning = 0
VoidUI.loaded = false
VoidUI.mod_path = ModPath
VoidUI.options_path = SavePath .. "VoidUI.txt"
VoidUI.options = {} 
VoidUI.menus = {}
VoidUI.hook_files = {
	["lib/managers/hudmanager"] = {"managers/HudManager.lua"},
	["lib/units/enemies/cop/copdamage"] = {"managers/Jokers.lua", "hud/HudScoreboard.lua"},
	["lib/units/player_team/teamaidamage"] = {"managers/HudManager.lua"},
	["lib/units/player_team/huskteamaidamage"] = {"managers/HudManager.lua"},
	["core/lib/managers/subtitle/coresubtitlepresenter"] = {"managers/HudManager.lua"},
	["lib/managers/hud/hudwaitinglegend"] = {"managers/HudManager.lua"},
	["lib/units/player_team/teamaiinventory"] = {"managers/HudManager.lua"},
	["lib/managers/achievmentmanager"] = {"managers/HudManager.lua"},
	["lib/managers/playermanager"] = {"managers/HudManager.lua"},
	["lib/managers/menumanagerdialogs"] = {"managers/HudManager.lua"},
	["lib/network/base/basenetworksession"] = {"managers/HudManager.lua"},
	["lib/states/ingamemaskoff"] = {"managers/HudManager.lua"},
	["lib/units/contourext"] = {"managers/Jokers.lua"},
	["lib/managers/hud/hudteammate"] = {"hud/HudTeammate.lua"},
	["lib/managers/hud/hudtemp"] = {"hud/HudTemp.lua"},
	["lib/managers/hud/hudblackscreen"] = {"hud/HudBlackscreen.lua"},
	["lib/managers/hud/hudsuspicion"] = {"hud/HudSuspicion.lua"},
	["lib/states/ingamewaitingforplayers"] = {"hud/HudBlackscreen.lua"},
	["lib/managers/menu/fadeoutguiobject"] = {"hud/HudBlackscreen.lua"},
	["lib/managers/hudmanagerpd2"] = {"managers/HudManager.lua", "hud/HudScoreboard.lua", "hud/HudVoice.lua"},
	["lib/units/beings/player/huskplayermovement"] = {"hud/HudPlayerDowned.lua"},
	["lib/units/beings/player/states/playerbleedout"] = {"hud/HudPlayerDowned.lua"},
	["lib/network/handlers/unitnetworkhandler"] = {"hud/HudPlayerDowned.lua", "managers/Jokers.lua"},
	["lib/units/equipment/doctor_bag/doctorbagbase"] = {"hud/HudPlayerDowned.lua"},
	["lib/managers/hud/hudplayerdowned"] = {"hud/HudPlayerDowned.lua"},
	["lib/managers/hud/hudobjectives"] = {"hud/HudObjectives.lua"},
	["lib/managers/hud/hudheisttimer"] = {"hud/HudHeistTimer.lua"},
	["lib/managers/hud/hudchallengenotification"] = {"hud/HudPresenter.lua"},
	["lib/managers/hud/hudpresenter"] = {"hud/HudPresenter.lua"},
	["lib/managers/hud/hudhint"] = {"hud/HudHint.lua"},
	["lib/managers/hintmanager"] = {"hud/HudHint.lua"},
	["lib/managers/hud/hudinteraction"] = {"hud/HudInteraction.lua"},
	["lib/managers/hud/hudchat"] = {"hud/HudChat.lua"},
	["lib/managers/hud/hudassaultcorner"] = {"hud/HudAssaultCorner.lua"},
	["lib/managers/group_ai_states/groupaistatebase"] = {"hud/HudAssaultCorner.lua", "managers/Jokers.lua"},
	["lib/managers/objectinteractionmanager"] = {"hud/HudAssaultCorner.lua"},
	["lib/units/equipment/ecm_jammer/ecmjammerbase"] = {"hud/HudAssaultCorner.lua"},
	["lib/units/enemies/cop/huskcopbrain"] = {"managers/Jokers.lua"},
	["lib/units/civilians/civiliandamage"] = {"hud/HudScoreboard.lua"},
	["lib/managers/hud/newhudstatsscreen"] = {"hud/HudScoreboard.lua"},
	["lib/managers/hud/hudstatsscreenskirmish"] = {"hud/HudScoreboard.lua"},
	["lib/setups/setup"] = {"Setup.lua"},
	["lib/managers/menumanager"] = {"menu/CustomMenu.lua"},
	["lib/network/matchmaking/networkvoicechatsteam"] = {"hud/HudVoice.lua"}	
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
	for _, file in pairs(file.GetFiles(VoidUI.mod_path.. "guis/textures/VoidUI")) do
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/VoidUI/".. file:gsub(".texture", "")), VoidUI.mod_path.. "guis/textures/VoidUI/".. file)
	end
end
Hooks:Add("LocalizationManagerPostInit", "VoidUI_Localization", function(loc)
	local loc_path = VoidUI.mod_path .. "loc/"

	if file.DirectoryExists(loc_path) then
		if BLT.Localization._current == 'cht' or BLT.Localization._current == 'zh-cn' then
			loc:load_localization_file(loc_path .. "chinese.json")
		else
			for _, filename in pairs(file.GetFiles(loc_path)) do
				local str = filename:match('^(.*).json$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					loc:load_localization_file(loc_path .. filename)
					break
				end
			end
		end
		loc:load_localization_file(loc_path .. "english.json", false)
	else
		log("Localization folder seems to be missing!")
	end
end)

function VoidUI:DefaultConfig()
	VoidUI.options = {
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
		challanges_scale = 1,
		hint_scale = 1,
		label_scale = 1,
		waypoint_scale = 0.8,
		subtitle_scale = 0.9,
		joining_mods_scale = 1,
		voice_scale = 1,
		teammate_panels = true,
		enable_interact = true,
		enable_suspicion = true,
		enable_assault = true,
		enable_chat = true,
		enable_labels = true,
		enable_timer = true,
		enable_objectives = true,
		enable_presenter = true,
		enable_hint = true,
		enable_blackscreen = true,
		enable_stats = true,
		enable_subtitles = true,
		enable_challanges = true,
		enable_loadingscreen = true,
		enable_joining = true,
		enable_waypoints = true,
		enable_voice = true,
		loading_heistinfo = true,
		loading_players = true,
		loading_briefing = false,
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
		label_upper = false,
		mate_upper = false,
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
		scoreboard_accuracy = true,
		scoreboard_delay = false,
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
		scoreboard_toggle = 1,
		save_warning = false,
		presenter_sound = false,
		hint_color = true,
		hint_anim = true,
		vape_hints = true,
		blackscreen_map = true,
		blackscreen_risk = true,
		blackscreen_skull = true,
		blackscreen_linger = true,
		scoreboard_maxlevel = true,
		joining_rank = true,
		joining_time = true,
		joining_border = true,
		joining_mods = false,
		joining_drawing = true,
		voice_name = true,
		joining_anim = 4,
		blackscreen_time = 0,
		scoreboard_skins = 2,
		scoreboard_kills = 3,
		show_objectives = 3,
		subtitles_bg = 2,
		show_timer = 3,
		ping_frequency = 2,
		jammers = 2,
		label_minscale = 1,
		hud_objective_history = 3,
		presenter_buffer = 5,
		label_minmode_dist = 7,
		label_minmode_dot = 1,
		chat_copy = 5,
		main_health = 2,
		mate_health = 2,
		mate_show = 3,
		chattime = 1,
		main_armor = 2,
		mate_armor = 1,
		assault_lines = 3,
		waypoint_radius = 200,
		suspicion_y = 160,
		interact_y = 40,
		main_anim_time = 0.2,
		mate_anim_time = 0.2
		--c_main_fg = {1,1,1}
	}
end

if not VoidUI.loaded then
	VoidUI.loaded = true
	VoidUI:DefaultConfig()
	VoidUI:Load()
	VoidUI:LoadTextures()
end

function VoidUI:GetColor(name)
	if VoidUI.options[name] then
		local color = VoidUI.options[name]
		return Color(unpack(color))
	else
		return Color.white
	end
end
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_VoidUI", function(menu_manager, nodes)	
	MenuCallbackHandler.OpenVoidOptions = function(self, item)
		VoidUI.Menu = VoidUI.Menu or VoidUIMenu:new()
		VoidUI.Menu:Open()
	end
	
	local node = nodes["blt_options"]

	local item_params = {
		name = "VoidUI_OpenMenu",
		text_id = "VoidUI_options_title",
		help_id = "VoidUI_options_desc",
		callback = "OpenVoidOptions",
		localize = true,
	}
	local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
    node:add_item(item)
	
	local menus = file.GetFiles(VoidUI.mod_path.. "menu/")
	for i= 1, #menus do
		table.insert(VoidUI.menus, VoidUI.mod_path .. "menu/"..menus[i])
	end
end)

Hooks:PostHook(MenuManager, "update", "update_menu", function(self, t, dt)
	if VoidUI.Menu and VoidUI.Menu.update and VoidUI.Menu._enabled then
		VoidUI.Menu:update(t, dt)
	end
end)

if RequiredScript then
	local requiredScript = RequiredScript:lower()
		if VoidUI.hook_files[requiredScript] then
			for _, file in ipairs(VoidUI.hook_files[requiredScript]) do
			dofile( VoidUI.mod_path .. "lua/" .. file )
		end
	end
end

if MenuManager then
	function MenuManager:toggle_chatinput()
		if Application:editor() then
			return
		end
		if game_state_machine and game_state_machine:current_state_name() == "editor" then
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
end
