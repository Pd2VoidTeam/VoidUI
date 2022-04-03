local function make_fine_text(text_obj)
	local x, y, w, h = text_obj:text_rect()

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))
end	

local init = Hooks:GetFunction(LevelLoadingScreenGuiScript, "init")
Hooks:OverrideFunction(LevelLoadingScreenGuiScript, "init", function(self, scene_gui, res, progress, base_layer)
	if arg.void then
		self._void = true
		local void_data = arg.void
		self._scene_gui = scene_gui
		self._res = res
		self._base_layer = base_layer
		self._level_tweak_data = arg.load_level_data.level_tweak_data
		self._gui_tweak_data = arg.load_level_data.gui_tweak_data
		self._menu_tweak_data = arg.load_level_data.menu_tweak_data
		self._scale_tweak_data = arg.load_level_data.scale_tweak_data
		self._gui_data = arg.load_level_data.gui_data
		self._workspace_size = self._gui_data.workspace_size
		self._saferect_size = self._gui_data.saferect_size
		local challenges = arg.load_level_data.challenges
		local safe_rect_pixels = self._gui_data.safe_rect_pixels
		local safe_rect = self._gui_data.safe_rect
		local aspect_ratio = self._gui_data.aspect_ratio
		self._safe_rect_pixels = safe_rect_pixels
		self._safe_rect = safe_rect
		self._gui_data_manager = GuiDataManager:new(self._scene_gui, res, safe_rect_pixels, safe_rect, aspect_ratio)
		self._back_drop_gui = MenuBackdropGUI:new(nil, self._gui_data_manager, true)
		local base_panel = self._back_drop_gui:get_new_base_layer()
		self._base = base_panel
		self._back_drop_gui:enable_light(false)
		local level_image = base_panel:bitmap({
			texture = self._gui_data.bg_texture,
			color = Color(0.5,0.5,0.5)
		})
		level_image:set_size(level_image:parent():h() * level_image:texture_width() / level_image:texture_height(), level_image:parent():h())
		level_image:set_position(0, -20)

		local background_fullpanel = self._back_drop_gui:get_new_background_layer()
		local background_safepanel = self._back_drop_gui:get_new_background_layer()
		
		self._back_drop_gui:set_panel_to_saferect(background_safepanel)

		if arg.load_level_data.tip then
			self._loading_hint = self:_make_loading_hint(background_safepanel, arg.load_level_data.tip)
		end
		
		background_fullpanel:gradient({
			layer = 0,
			orientation = "vertical",
			gradient_points = {
				0,
				Color.black:with_alpha(1),
				0.05,
				Color.black:with_alpha(1),
				0.25,
				Color.black:with_alpha(0),
				0.75,
				Color.black:with_alpha(0),
				0.95,
				Color.black:with_alpha(1),
				1,
				Color.black:with_alpha(1)
			},
		})

		self._fader = background_fullpanel:bitmap({
			name = "fader",
			layer = 19,
			color = Color.black
		})
		self._fade_t = 0
		self._fade_max = 0.8

		local extras = "guis/textures/VoidUI/hud_extras"
		self._indicator = background_safepanel:bitmap({
			name = "indicator",
			texture = extras,
			texture_rect = {
				875,
				0,
				55,
				54
			},
			layer = 20
		})
		self._indicator:set_rightbottom(background_safepanel:w(), background_safepanel:h())
		local logo = background_safepanel:bitmap({
			name = "logo",
			texture = extras,
			texture_rect = {
				933,
				4,
				37,
				37
			},
			layer = 21
		})
		logo:set_center(self._indicator:center())
		local loading_text = background_safepanel:text({
			vertical = "center",
			y = 0,
			h = 35,
			text_id = "debug_loading_level",
			font_size = 30,
			align = "left",
			font = "fonts/font_large_mf",
			layer = 20,
			color = Color.white
		})

		loading_text:set_text(utf8.to_upper(loading_text:text()))
		make_fine_text(loading_text)
		loading_text:set_right(self._indicator:left())
		loading_text:set_center_y(self._indicator:center_y() + 2)
		
		local level_text = background_safepanel:text({
			h = 45,
			text = "",
			font_size = 35,
			font = "fonts/font_large_mf",
			layer = 5,
			color = Color.white
		})
		if void_data.contractor and (void_data.level or void_data.job) then
			local level_name = string.format("%1s: %2s", void_data.contractor, void_data.days and void_data.level or void_data.job)
			level_text:set_text(level_name)
		end
		make_fine_text(level_text)
		level_text:set_center_x(level_text:parent():w() / 2)

		if void_data.risk then
			local risk_color = void_data.risk.color or Color.white

			local risk_panel = background_safepanel:panel()
			local risk_text = risk_panel:text({
				text = void_data.risk.name,
				font_size = 25,
				y = 2,
				font = "fonts/font_large_mf",
				layer = 5,
				color = risk_color
			})
			make_fine_text(risk_text)

			if void_data.risk.difficulties then
				local last_risk_level
				local x = risk_text:right()
				local w = 25
				for i = 1, #void_data.risk.difficulties - 2 do
					local difficulty_name = void_data.risk.difficulties[i + 2]
					local texture = void_data.risk.risk_textures[difficulty_name] or "guis/textures/pd2/risklevel_blackscreen"
					local current = i <= void_data.risk.current
					last_risk_level = risk_panel:bitmap({
						texture = texture,
						color = risk_color,
						x = x,
						w = w,
						h = w
					})
					last_risk_level:set_color(current and risk_color or Color.white)
					last_risk_level:set_alpha(current and 1 or 0.20)
					risk_panel:set_size(last_risk_level:right(), last_risk_level:bottom())
					x = x + w
				end
			else
				risk_panel:set_size(risk_text:right(), risk_text:bottom())
			end
			risk_panel:set_center_x(level_text:center_x())
			risk_panel:set_top(level_text:bottom())
		end

		if void_data.briefing then
			local level_briefing = background_safepanel:text({
				text = void_data.briefing,
				font_size = 15,
				width = 300,
				align = "right",
				wrap = true,
				font = "fonts/font_small_mf",
				layer = 5,
			})
			level_briefing:set_right(level_briefing:parent():w())
		end

		if void_data.days then
			local text = string.format("%1s %2s", void_data.job, void_data.days)
			background_safepanel:text({
				text = text,
				font_size = 20,
				font = "fonts/font_medium_mf",
				layer = 5,
			})
		end
		--local peer_names = self._void_data.peers
		--if peer_names then
		--	local peer_names_count = #peer_names
		--	local additional_players = self._void_data.additional_players
		--	local player_count = self._void_data.player_count
		--	for id, peer in pairs(peer_names) do
		--		background_safepanel:text({
		--			text = peer.name or "",
		--			font_size = 18,
		--			y = (id - (days ~= "" and 0 or 1)) * 16 + 2,
		--			font = "fonts/font_medium_mf",
		--			layer = 5,
		--			color = self._void_data.chat_colors[peer.id]
		--		})
		--	end
		--	if player_count ~= peer_names_count then
		--		background_safepanel:text({
		--			text = additional_players,
		--			font_size = 15,
		--			y = (peer_names_count + (days ~= "" and 1 or 0)) * 16 + 2,
		--			font = "fonts/font_medium_mf",
		--			layer = 5,
		--			color = self._void_data.chat_colors[#self._void_data.chat_colors or 5]
		--		})
		--	end
		--end
		--black_shader:animate(callback(self, self, "_animate_fade"))
	else
		init(self, scene_gui, res, progress, base_layer) 
	end
end)

local hint_orig = Hooks:GetFunction(LevelLoadingScreenGuiScript, "_make_loading_hint")
Hooks:OverrideFunction(LevelLoadingScreenGuiScript, "_make_loading_hint", function(self, parent, tip)
	if self._void then
		local hint_text_width = 450
		local font = "fonts/font_medium_mf"
		local font_size = 20
		
		local container = parent:panel({
			h = 145
		})
		container:set_bottom(parent:height())
		local hint_image = container:bitmap({
			height = 128,
			width = 128,
			texture = "guis/textures/loading/hints/" .. tip.image
		})
		hint_image:set_bottom(container:h())

		local text = string.format("%1s #%d / %d\n%2s", tip.title, tip.index, tip.total, tip.text)
		local hint_text = container:text({
			wrap = true,
			word_wrap = true,
			x = 128,
			y = 10,
			w = hint_text_width,
			h = 128,
			vertical = "center",
			text = text,
			font = font,
			font_size = font_size,
			color = Color.white
		})

		return container
	else
		return hint_orig(self, parent, tip)
	end
end)

local update_orig = Hooks:GetFunction(LevelLoadingScreenGuiScript, "update")
Hooks:OverrideFunction(LevelLoadingScreenGuiScript, "update", function(self, progress, t, dt)
	if self._void then
		self._indicator:set_alpha(math.abs(math.sin(60 * t)))

		if self._fade_t < self._fade_max then
			self._fade_t = self._fade_t + dt
			self._fader:set_alpha(math.lerp(2, 0, self._fade_t / self._fade_max))
		end
	else 
		update_orig(self, progress, t, dt)
	end
end)
	--local _start_loading_screen = Setup._start_loading_screen
	--function Setup:_start_loading_screen(...)
	--	if Global.load_level then
	--		local level_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	--		if level_tweak_data then			
	--			if VoidUI and VoidUI.options.enable_loadingscreen then
	--				if level_tweak_data.risk == nil then level_tweak_data.risk = {} end
	--				if VoidUI.options.loading_heistinfo then
	--					if managers.crime_spree:is_active() then
	--						local mission = managers.crime_spree and managers.crime_spree:get_mission()
	--						local level_data = managers.job and managers.job:current_level_data()
	--						level_tweak_data.risk.color = tweak_data.screen_colors.crime_spree_risk
	--						level_tweak_data.risk.name = managers.crime_spree and managers.localization:to_upper_text("cn_crime_spree").." "..managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")}) or ""
	--						level_tweak_data.contractor	= managers.localization:text(level_data.name_id)
	--						level_tweak_data.level = "+" .. managers.localization:text("menu_cs_level", {level = mission and mission.add or 0})
	--					else
	--						local contract_data = managers.job and managers.job:current_contact_data()
	--						local job_data = managers.job and managers.job:current_job_data()
	--						local job_chain = managers.job and managers.job:current_job_chain_data()
	--						local level_data = managers.job and managers.job:current_level_data()
	--						local day = managers.job and managers.job:current_stage() or 0
	--						if day and job_data and job_data.name_id == "heist_rvd" then
	--							day = 3 - day
	--						end
	--						local days = job_chain and #job_chain or 0
							
	--						level_tweak_data.name_id = level_data and managers.localization:to_upper_text(level_data.name_id == "heist_branchbank_hl" and job_data.name_id or level_data.name_id) or ""
	--						level_tweak_data.risk.name = Global.game_settings and managers.localization:text(tweak_data.difficulty_name_ids[Global.game_settings.difficulty]) or "normal"
	--						level_tweak_data.risk.color = Global.game_settings.one_down and tweak_data.screen_colors.one_down or tweak_data.screen_colors.risk
	--						level_tweak_data.risk.current = managers.job and managers.job:current_difficulty_stars()
	--						level_tweak_data.risk.difficulties = tweak_data.difficulties
	--						level_tweak_data.risk.risk_textures = tweak_data.gui.blackscreen_risk_textures
	--						level_tweak_data.contractor = contract_data and managers.localization:text(contract_data.name_id) or ""
	--						level_tweak_data.days = days > 1 and managers.localization:text(job_data.name_id).." "..managers.localization:text("hud_days_title", {DAY = day, DAYS = days}) or ""
	--					end
	--				end
	--				level_tweak_data.briefing = "" --VoidUI.options.loading_briefing and managers.localization:text(level_tweak_data.briefing_id) or ""
	--				--[[ if VoidUI.LoadingScreenInfo and VoidUI.options.loading_players then
	--					level_tweak_data.peers = VoidUI.LoadingScreenInfo.peers
	--					level_tweak_data.additional_players = VoidUI.LoadingScreenInfo.additional_players
	--					level_tweak_data.player_count = VoidUI.LoadingScreenInfo.player_count
	--					level_tweak_data.chat_colors = tweak_data.chat_colors
	--					VoidUI.LoadingScreenInfo = nil
	--				end ]]
	--			end
	--		end
	--	end
	--	return _start_loading_screen(self, ...)
	--end
	
--[[ elseif RequiredScript == "lib/network/base/clientnetworksession" then
	local ok_to_load_level = ClientNetworkSession.ok_to_load_level
	function ClientNetworkSession:ok_to_load_level(load_counter, ...)
		if not VoidUI.options.loading_players and self._closing or self._received_ok_to_load_level or self._load_counter == load_counter then
			return ok_to_load_level(self, load_counter, ...)
		end
		ok_to_load_level(self, load_counter, ...)
		if managers.network and managers.network.matchmake and managers.network:session() then
			local lobby_handler = managers.network.matchmake.lobby_handler
			if not alive(lobby_handler) or lobby_handler.get_lobby_data == nil then
				return
			end
			
			local peers = {}
			local peer_count = 0
			for i, peer in pairs(managers.network:session():all_peers()) do
				if peer then
					table.insert(peers, {id = peer:id() or 0, name = peer:name() or ""})
					if peer ~= managers.network:session():local_peer() then
						peer_count = peer_count + 1
					end
				end
			end
			local player_count = 0
			lobby_handler = lobby_handler:get_lobby_data()
			player_count = lobby_handler.num_players
			VoidUI.LoadingScreenInfo = {
				peers = peers,
				additional_players = player_count-peer_count > 0 and managers.localization:text("VoidUI_loading_others", {PLAYERS = player_count-peer_count}) or "",
				player_count = tonumber(player_count)
			}
		end
	end
elseif RequiredScript == "lib/network/base/hostnetworksession" then
	local load_level = HostNetworkSession.load_level
	function HostNetworkSession:load_level(...)
		if managers.network and managers.network.matchmake and managers.network:session() and VoidUI.options.loading_players then
			local lobby_handler = managers.network.matchmake.lobby_handler
			if not alive(lobby_handler) or lobby_handler.get_lobby_data == nil or lobby_handler:get_lobby_data() == nil then
				return load_level(self, ...)
			end
			local peers = {}
			local peer_count = 0
			for i, peer in pairs(managers.network:session():all_peers()) do
				if peer then
					table.insert(peers, {id = peer:id() or 0, name = peer:name() or ""})
					if peer ~= managers.network:session():local_peer() then
						peer_count = peer_count + 1
					end
				end
			end
			local player_count = 0
			lobby_handler = lobby_handler:get_lobby_data()
			player_count = lobby_handler.num_players
			VoidUI.LoadingScreenInfo = {
				peers = peers,
				additional_players = player_count-peer_count > 0 and managers.localization:text("VoidUI_loading_others", {PLAYERS = player_count-peer_count}) or "",
				player_count = tonumber(player_count)
			}
		end
		return load_level(self, ...)
	end ]]