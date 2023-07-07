if VoidUI.options.enable_voice then
    if RequiredScript == "lib/managers/hudmanagerpd2" then
        HUDVoice = HUDVoice or class()

        function HUDVoice:init(hud)
            self._hud_panel = hud.panel
            if self._hud_panel:child("voice_chat_panel") then
                self._hud_panel:remove(self._hud_panel:child("voice_chat_panel"))
            end
            self._speakers = {}  
            self._main_scale = VoidUI.options.hud_main_scale
            self._scale = VoidUI.options.voice_scale
            self._voice_panel = self._hud_panel:panel({name = "voice_chat_panel"})
        end

        function HUDVoice:set_voice(data, active)
            self._scale = VoidUI.options.voice_scale
            if active then
                local name = managers.network:session():peer(data.peer_id):name()
                local color = tweak_data.chat_colors[data.peer_id] or Color.white
                local panel = self:add_panel(data.peer_id, name, color)
            else
                self:remove_panel(data.peer_id)
            end
        end
        function HUDVoice:remove_panel(id)
            local panel
            for j, k in ipairs(self._speakers) do 
                if k.id == id then
                    panel = j
                end
            end
            if panel then
                self._voice_panel:remove(self._speakers[panel].panel)
                table.remove(self._speakers, panel)
            end
            self:align_panels()
        end
        function HUDVoice:add_panel(id, name, color)
            if self._voice_panel:child("voice_"..id) then
                return self._voice_panel:child("voice_"..id)
            end
            local panel = self._voice_panel:panel({name = "voice_"..id})
            local text = panel:text({
                layer = 1,
                font_size = 20 * self._scale,
                font = "fonts/font_medium_mf",
                text = VoidUI.options.voice_name and tostring(name) or " ",
                color = color
            })
            local text_bg = panel:text({
                x = 1,
                y = 1,
                layer = 0,
                font_size = 20 * self._scale,
                font = "fonts/font_medium_mf",
                text = text:text(),
                color = Color.black
            })
            managers.hud:make_fine_text(text)
            managers.hud:make_fine_text(text_bg)
            local image = panel:bitmap({
                x = text:right() + 2,
                texture = "guis/textures/VoidUI/hud_extras",
                texture_rect = {834,0,40,40},
                w = text:h(),
                h = text:h(),
                color = color
            })
            panel:set_size(image:right(), image:bottom())
            panel:set_right(self._hud_panel:w() - (220 * self._main_scale))

            table.insert(self._speakers, {id = id, panel = panel})
            self:align_panels()
            return panel
        end

        function HUDVoice:align_panels()
            for j, k in ipairs(self._speakers) do 
                k.panel:set_bottom(self._hud_panel:h() - ((j-1) * 22 * self._main_scale)) 
            end
        end
    elseif RequiredScript == "lib/network/matchmaking/networkvoicechatsteam" then
        Hooks:PostHook(NetworkVoiceChatSTEAM, "set_recording", "set_player_voice", function(self, enabled)
            if managers.hud and (self._voice_enabled == nil or self._voice_enabled ~= enabled) and managers.network and managers.network.session and managers.network:session():local_peer() and managers.network:session():local_peer():id() and SystemInfo:distribution() == Idstring("STEAM") then
                self._voice_enabled = enabled
                managers.hud:set_voice({peer_id = managers.network:session():local_peer():id()}, enabled)
            end
        end)
    end
end