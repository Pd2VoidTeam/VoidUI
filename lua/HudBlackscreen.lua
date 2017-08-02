function HUDBlackScreen:init(hud)
	self._hud_panel = hud.panel
	if self._hud_panel:child("blackscreen_panel") then
		self._hud_panel:remove(self._hud_panel:child("blackscreen_panel"))
	end
	self._blackscreen_panel = self._hud_panel:panel({
		visible = true,
		name = "blackscreen_panel",
		y = 0,
		valign = "grow",
		halign = "grow",
		layer = 200
	})
	local mid_text = self._blackscreen_panel:text({
		name = "mid_text",
		visible = true,
		text = "000",
		layer = 1,
		color = Color.white,
		y = 0,
		valign = {0.4, 0},
		align = "center",
		vertical = "center",
		font_size = tweak_data.hud.default_font_size * 2,
		font = tweak_data.hud.medium_font,
		w = self._blackscreen_panel:w()
	})
	local _, _, _, h = mid_text:text_rect()
	mid_text:set_h(h)
	mid_text:set_center_x(self._blackscreen_panel:center_x())
	mid_text:set_center_y(self._blackscreen_panel:h() / 2.5)
	local is_server = Network:is_server()
	local continue_button = managers.menu:is_pc_controller() and "ENTER" or nil
	local text = managers.localization:text("hud_skip_blackscreen", {BTN_ACCEPT = continue_button})
	if continue_button == nil then continue_button = utf8.char(57344) end
	local start, _ = string.find(text, continue_button)
	if start then text = string.sub(text, start - 1) end
	local skip_text = self._blackscreen_panel:text({
		name = "skip_text",
		visible = is_server,
		text = text,
		layer = 1,
		color = Color.white,
		y = 0,
		align = "right",
		vertical = "bottom",
		font_size = nil,
		font = tweak_data.hud.medium_font_noshadow
	})

	local loading_text = managers.localization:text("menu_loading_progress", {prog = 0})
	local loading_text_object = self._blackscreen_panel:text({
		name = "loading_text",
		visible = false,
		text = loading_text,
		layer = 1,
		color = Color.white,
		y = 0,
		align = "right",
		vertical = "bottom",
		font_size = nil,
		font = tweak_data.hud.medium_font_noshadow
	})
	skip_text:set_y(skip_text:y() - 5)
	loading_text_object:set_y(loading_text_object:y() - 5)
end

function HUDBlackScreen:set_skip_circle(current, total)
end

function HUDBlackScreen:skip_circle_done()
	self._blackscreen_panel:child("skip_text"):set_visible(false)
end

local update = IngameWaitingForPlayersState.update
function IngameWaitingForPlayersState:update(t, dt)
	if self._skip_data then self._skip_data.total = 0 end
	return update(self, t, dt)
end