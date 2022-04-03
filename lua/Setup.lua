Hooks:PreHook(Setup, "start_boot_loading_screen", "void_start_boot_loading_screen", function(self)
    tweak_data.gui.LOADING_SCREEN_LAYER = VoidUI and VoidUI.options.enable_loadingscreen and 1001 or tweak_data.gui.LOADING_SCREEN_LAYER
end)

Hooks:PreHook(Setup, "init_game", "void_init_game", function(self)
    tweak_data.gui.LOADING_SCREEN_LAYER = VoidUI and VoidUI.options.enable_loadingscreen and 1001 or tweak_data.gui.LOADING_SCREEN_LAYER
end)

Hooks:PreHook(Setup, "_start_loading_screen", "void_start_loading_screen", function(self)
    if VoidUI and VoidUI.options.enable_loadingscreen then
        Hooks:PreHook(getmetatable(LoadingEnvironment), "start", "void_start_loading_environment", function(self, setup, load, data)
            if Global.load_level and managers.job then    
                local level = managers.job:current_level_data()
                if VoidUI.options.loading_heistinfo then
                    if managers.crime_spree and managers.crime_spree:is_active() then
                        local mission = managers.crime_spree:get_mission()

                        data.void = {
                            contractor	= managers.localization:to_upper_text(level.name_id),
                            job =  "+" .. managers.localization:to_upper_text("menu_cs_level", {level = mission and mission.add or 0}),
                            risk = {
                                color = tweak_data.screen_colors.crime_spree_risk,
                                name = managers.localization:to_upper_text("cn_crime_spree").." "..managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
                            }
                        }
                    else
                        local contract = managers.job:current_contact_data()
                        local job_data = managers.job:current_job_data()
                        local job_chain = managers.job:current_job_chain_data()
                        local day = managers.job:current_stage() or 0
                        if day and job_data and job_data.name_id == "heist_rvd" then
                            day = 3 - day
                        end
                        local days = job_chain and #job_chain or 0

                        data.void = {
                            contractor = contract and managers.localization:to_upper_text(contract.name_id),
                            level = level and managers.localization:to_upper_text(level.name_id),
                            job = job_data and managers.localization:to_upper_text(job_data.name_id),
                            days = days > 1 and managers.localization:to_upper_text("hud_days_title", {DAY = day, DAYS = days}),
                            risk = {
                                name = Global.game_settings and managers.localization:to_upper_text(tweak_data.difficulty_name_ids[Global.game_settings.difficulty]) or "NORMAL",
                                color = Global.game_settings.one_down and tweak_data.screen_colors.one_down or tweak_data.screen_colors.risk,
                                current = managers.job:current_difficulty_stars(),
                                difficulties = tweak_data.difficulties,
                                risk_textures = tweak_data.gui.blackscreen_risk_textures
                            }
                        }
                    end
                end
                
                if VoidUI.options.loading_briefing then
                    data.void.briefing = level.briefing_id and managers.localization:text(level.briefing_id) or ""
                end
            end
        end)
    end
end)