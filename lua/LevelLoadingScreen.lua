local function make_fine_text(text_obj)
	local x, y, w, h = text_obj:text_rect()

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))
end	
if RequiredScript == "lib/utils/levelloadingscreenguiscript" then

	local init = LevelLoadingScreenGuiScript.init
	function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
		if arg.load_level_data.level_tweak_data.loading_enabled == false then
			return init(self, scene_gui, res, progress, base_layer) 
		end
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
		
		self._fade = background_fullpanel:gradient({
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
		local extras = "guis/textures/VoidUI/hud_extras"
		self._indicator = background_safepanel:bitmap({
			texture = extras,
			name = "indicator",
			texture_rect = {
				1085,
				174,
				55,
				54
			},
			layer = 1
		})
		self._logo = background_safepanel:bitmap({
			texture = extras,
			name = "logo",
			texture_rect = {
				1149,
				201,
				37,
				37
			},
			layer = 2
		})
		self._level_title_text = background_safepanel:text({
			y = 0,
			vertical = "center",
			h = 35,
			text_id = "debug_loading_level",
			font_size = 30,
			align = "left",
			font = "fonts/font_large_mf",
			layer = 1,
			color = Color.white
		})

		self._level_title_text:set_text(utf8.to_upper(self._level_title_text:text()))
		make_fine_text(self._level_title_text)
		self._indicator:set_rightbottom(self._indicator:parent():w(), self._indicator:parent():h())
		self._logo:set_center(self._indicator:center())
		self._level_title_text:set_right(self._indicator:left())
		self._level_title_text:set_center_y(self._indicator:center_y() + 2)
		
		local level_name = self._level_tweak_data.contractor and string.format("%1s: %2s", utf8.to_upper(self._level_tweak_data.contractor), utf8.to_upper(self._level_tweak_data.level or self._level_tweak_data.name)) or ""
		local level_text = background_safepanel:text({
			h = 45,
			text = level_name,
			font_size = 35,
			font = "fonts/font_large_mf",
			layer = 5,
			color = Color.white
		})
		make_fine_text(level_text)
		level_text:set_center_x(level_text:parent():w() / 2)
		local level_briefing = background_safepanel:text({
			text = self._level_tweak_data.briefing,
			font_size = 15,
			width = 300,
			align = "right",
			wrap = true,
			font = "fonts/font_small_mf",
			layer = 5,
		})
		level_briefing:set_right(level_briefing:parent():w())
		local tweak_risk = self._level_tweak_data.risk
		if tweak_risk then
			local risk_panel = background_safepanel:panel()
			local risk_level = utf8.to_upper(tweak_risk.name or "")
			local risk_text = risk_panel:text({
				text = risk_level,
				font_size = 25,
				y = 2,
				font = "fonts/font_large_mf",
				layer = 5,
				color = tweak_risk.color or Color.white
			})
			make_fine_text(risk_text)
			local current_dif = tweak_risk.current
			if tweak_risk.difficulties then
				for i = 1, #tweak_risk.difficulties - 2 do
					local difficulty_name = tweak_risk.difficulties[i + 2]
					local texture = tweak_risk.risk_textures[difficulty_name] or "guis/textures/pd2/risklevel_blackscreen"
					last_risk_level = risk_panel:bitmap({
						texture = texture,
						color = tweak_risk.color or Color.white,
						w = 25,
						h = 25
					})
					last_risk_level:set_color(i <= current_dif and tweak_risk.color or Color.white)
					last_risk_level:set_alpha(i <= current_dif and 1 or 0.20)
					last_risk_level:move(risk_text:w() + (i - 1) * last_risk_level:w(), 0)
				end
				if last_risk_level then
					risk_panel:set_size(last_risk_level:right(), last_risk_level:bottom())
				end
			else
				risk_panel:set_size(risk_text:right(), risk_text:bottom())
			end
			risk_panel:set_center_x(level_text:center_x())
			risk_panel:set_top(level_text:bottom())
		end
		local days = self._level_tweak_data.days
		if days ~= "" then
			background_safepanel:text({
				text = utf8.to_upper(days),
				font_size = 20,
				font = "fonts/font_medium_mf",
				layer = 5,
			})
		end
		local peer_names = self._level_tweak_data.peers
		if peer_names then
			local peer_names_count = #peer_names
			local additional_players = self._level_tweak_data.additional_players
			local player_count = self._level_tweak_data.player_count
			for id, peer in pairs(peer_names) do
				background_safepanel:text({
					text = peer.name or "",
					font_size = 18,
					y = (id - (days ~= "" and 0 or 1)) * 16 + 2,
					font = "fonts/font_medium_mf",
					layer = 5,
					color = self._level_tweak_data.chat_colors[peer.id]
				})
			end
			if player_count ~= peer_names_count then
				background_safepanel:text({
					text = additional_players,
					font_size = 15,
					y = (peer_names_count + (days ~= "" and 1 or 0)) * 16 + 2,
					font = "fonts/font_medium_mf",
					layer = 5,
					color = self._level_tweak_data.chat_colors[#self._level_tweak_data.chat_colors or 5]
				})
			end
		end
		self._back_drop_gui._workspace:panel():animate(callback(self, self, "_animate_fade"))
	end
	function LevelLoadingScreenGuiScript:_animate_fade(workspace)
		workspace:set_alpha(0)
		wait(0.2)
		local t = 0
		local TOTAL_T = 0.5
		while TOTAL_T > t do
			local dt = coroutine.yield()
			t = t + dt
			workspace:set_alpha(math.min(math.lerp(0, 1, t / TOTAL_T), 1))
			self._fade:set_alpha(2)
		end
		workspace:set_alpha(1)
	end

	local make_loading_hint = LevelLoadingScreenGuiScript._make_loading_hint
	function LevelLoadingScreenGuiScript:_make_loading_hint(parent, tip)
		if self._level_tweak_data.loading_enabled == false then
			return make_loading_hint(self, parent, tip)
		end
		
		local container = parent:panel({h = 145})
		local hint_text_width = 450
		local font = "fonts/font_medium_mf"
		local font_size = 20
		local hint_image = container:bitmap({
			height = 128,
			width = 128,
			texture = "guis/textures/loading/hints/" .. tip.image
		})
		hint_image:set_bottom(container:h())
		local hint_title = container:text({
			text = string.format("%1s #%d / %d", tip.title, tip.index, tip.total),
			x = 22,
			font = font,
			font_size = font_size,
			color = Color.white
		})
		local hint_box = container:panel({y = 10, h = 128})
		hint_box:set_bottom(container:h() - 6)
		local hint_text = hint_box:text({
			wrap = true,
			word_wrap = true,
			x = 128,
			vertical = "center",
			text = tip.text,
			font = font,
			font_size = font_size,
			color = Color.white,
			width = hint_text_width
		})

		make_fine_text(hint_title)
		hint_box:set_width(hint_text_width + 187 + 16)
		container:set_bottom(parent:height())

		return container
	end
	function LevelLoadingScreenGuiScript:update(progress, t, dt)
		if self._level_tweak_data.loading_enabled then
			self._indicator:set_alpha(math.abs(math.sin(60 * t)))
		else 
			self._indicator:rotate(180 * dt)
		end
	end
elseif RequiredScript == "lib/utils/lightloadingscreenguiscript" then
	function LightLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer, is_win32)
		self._base_layer = base_layer
		self._is_win32 = is_win32
		self._scene_gui = scene_gui
		self._res = res
		self._ws = scene_gui:create_screen_workspace()
		self._safe_rect_pixels = self:get_safe_rect_pixels(res)
		self._saferect = self._scene_gui:create_screen_workspace()

		self:layout_saferect()

		local panel = self._ws:panel()
		self._panel = panel
		self._bg_gui = panel:rect({
			visible = true,
			color = Color.black,
			layer = base_layer
		})
		self._saferect_panel = self._saferect:panel()
		self._gui_tweak_data = {
			upper_saferect_border = 64,
			border_pad = 8
		}
		self._title_text = self._saferect_panel:text({
			y = 0,
			h = 24,
			text_id = "debug_loading_level",
			font_size = 30,
			align = "left",
			font = "fonts/font_large_mf",
			halign = "left",
			color = Color.white,
			layer = self._base_layer + 1
		})
		self._title_text:set_text(string.upper(self._title_text:text()))
		
		local extras = "guis/textures/VoidUI/hud_extras"
		self._indicator = self._saferect_panel:bitmap({
			texture = extras,
			name = "indicator",
			texture_rect = {
				1085,
				174,
				55,
				54
			},
			layer = self._base_layer + 1
		})
		self._logo = self._saferect_panel:bitmap({
			texture = extras,
			name = "logo",
			texture_rect = {
				1149,
				201,
				37,
				37
			},
			layer = self._base_layer + 2
		})
		self._dot_count = 0
		self._max_dot_count = 4
		self._init_progress = 0
		self._fake_progress = 0
		self._max_bar_width = 0
		self._t = 0

		self:setup(res, progress)
		
	end
	
	local setup = LightLoadingScreenGuiScript.setup
	function LightLoadingScreenGuiScript:setup(res, progress)
		self._gui_tweak_data = {
			upper_saferect_border = 64,
			border_pad = 8
		}
		
		make_fine_text(self._title_text)
		self._indicator:set_rightbottom(self._indicator:parent():w(), self._indicator:parent():h())
		self._logo:set_center(self._indicator:center())
		self._title_text:set_right(self._indicator:left())
		self._title_text:set_center_y(self._indicator:center_y() + 2)
		self._bg_gui:set_size(res.x, res.y)

		if progress > 0 then
			self._init_progress = progress
		end
	end
	
	function LightLoadingScreenGuiScript:update(progress, dt)
		self._t = self._t + dt
		self._indicator:set_alpha(math.abs(math.sin(60 * self._t)))

		if self._init_progress < 100 and progress == -1 then
			self._fake_progress = self._fake_progress + 20 * dt

			if self._fake_progress > 100 then
				self._fake_progress = 100
			end

			progress = self._fake_progress
		end
	end
	
elseif RequiredScript == "lib/setups/setup" then
	--Totally didn't steal some part of this. Shut up!
	local _start_loading_screen = Setup._start_loading_screen
	function Setup:_start_loading_screen(...)
		if Global.load_level then
			local level_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
			if level_tweak_data then			
				if VoidUI.options.enable_loadingscreen then
					if level_tweak_data.risk == nil then level_tweak_data.risk = {} end
					if VoidUI.options.loading_heistinfo then
						if managers.crime_spree:is_active()then
							local mission = managers.crime_spree:get_mission()
							local level_data = managers.job:current_level_data()
							level_tweak_data.risk.color = tweak_data.screen_colors.crime_spree_risk
							level_tweak_data.risk.name = managers.localization:to_upper_text("cn_crime_spree").." "..managers.localization:to_upper_text("menu_cs_level", {
								level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
							level_tweak_data.contractor	= managers.localization:text(level_data.name_id)
							level_tweak_data.level = "+" .. managers.localization:text("menu_cs_level", {level = mission and mission.add or 0})
						else
							local contract_data = managers.job and managers.job:current_contact_data()
							local job_data = managers.job and managers.job:current_job_data()
							local job_chain = managers.job and managers.job:current_job_chain_data()
							local day = managers.job and managers.job:current_stage() or 0
							local days = job_chain and #job_chain or 0
							
							level_tweak_data.risk.name = Global.game_settings and managers.localization:text(tweak_data.difficulty_name_ids[Global.game_settings.difficulty]) or "normal"
							level_tweak_data.risk.color = tweak_data.screen_colors.risk
							level_tweak_data.risk.current = managers.job:current_difficulty_stars()
							level_tweak_data.risk.difficulties = tweak_data.difficulties
							level_tweak_data.risk.risk_textures = tweak_data.gui.blackscreen_risk_textures
							level_tweak_data.contractor = contract_data and managers.localization:text(contract_data.name_id) or ""
							level_tweak_data.days = days > 1 and managers.localization:text(job_data.name_id).." "..managers.localization:text("hud_days_title", {DAY = day, DAYS = days}) or ""
						end
					end
					level_tweak_data.briefing = VoidUI.options.loading_briefing and managers.localization:text(level_tweak_data.briefing_id) or ""
					if VoidUI.LoadingScreenInfo and VoidUI.options.loading_players then
						level_tweak_data.peers = VoidUI.LoadingScreenInfo.peers
						level_tweak_data.additional_players = VoidUI.LoadingScreenInfo.additional_players
						level_tweak_data.player_count = VoidUI.LoadingScreenInfo.player_count
						level_tweak_data.chat_colors = tweak_data.chat_colors
						VoidUI.LoadingScreenInfo = nil
					end
					level_tweak_data.loading_enabled = true
				else
					level_tweak_data.loading_enabled = false
				end
			end
		end
		return _start_loading_screen(self, ...)
	end
elseif RequiredScript == "lib/network/base/clientnetworksession" then
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
			if not alive(lobby_handler) or lobby_handler.get_lobby_data == nil then
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
	end
end