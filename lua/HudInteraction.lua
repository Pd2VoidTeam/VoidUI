function HUDInteraction:init(hud, child_name)
	self._hud_panel = hud.panel
	self._scale = VoidUI.options.interact_scale
	self._circle_radius = 0
	self._child_name_text = (child_name or "interact") .. "_text"
	self._child_name_bg = (child_name or "interact") .. "_bg"
	self._child_ivalid_name_text = (child_name or "interact") .. "_invalid_text"
	if self._hud_panel:child(self._child_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	end
	if self._hud_panel:child(self._child_name_bg) then
		self._hud_panel:remove(self._hud_panel:child(self._child_name_bg))
	end
	if self._hud_panel:child(self._child_ivalid_name_text) then
		self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))
	end
	local interact_bg = self._hud_panel:text({
		name = self._child_name_bg,
		alpha = 0,
		x = 1,
		y = 1,
		text = "HELLO",
		vertical = "bottom",
		align = "center",
		layer = 11,
		color = Color.black,
		font = "fonts/font_large_mf",
		font_size = tweak_data.hud_present.text_size / 1.2 * self._scale,
		h = 64 * self._scale
	})
	local interact_text = self._hud_panel:text({
		name = self._child_name_text,
		alpha = 0,
		text = "HELLO",
		vertical = "bottom",
		align = "center",
		layer = 12,
		font = "fonts/font_large_mf",
		font_size = tweak_data.hud_present.text_size / 1.2 * self._scale,
		h = 64 * self._scale
	})
	local invalid_text = self._hud_panel:text({
		name = self._child_ivalid_name_text,
		visible = false,
		alpha = 0,
		text = "HELLO",
		vertical = "bottom",
		align = "center",
		layer = 13,
		color = Color(1, 0.3, 0.3),
		blend_mode = "normal",
		font = "fonts/font_large_mf",
		font_size = tweak_data.hud_present.text_size / 1.2 * self._scale,
		h = 32 * self._scale
	})
	local interaction_time = self._hud_panel:text({
		name = "interaction_time",
		alpha = 1,
		visible = false,
		text = "1s",
		valign = "center",
		align = "center",
		layer = 2,
		color = Color.white,
		font = "fonts/font_medium_shadow_mf",
		font_size = tweak_data.hud_present.text_size / 1.4 * self._scale,
		h = 32 * self._scale
	})
	
	interact_text:set_y(self._hud_panel:h() / 2 + VoidUI.options.interact_y)
	invalid_text:set_bottom(interact_text:bottom())
	interaction_time:set_top(interact_text:bottom() + 10 * self._scale)
end

function HUDInteraction:show_interact(data)
	self._hud_panel:child(self._child_name_bg):set_y(self._hud_panel:h() / 2 + VoidUI.options.interact_y + 1)
	self._hud_panel:child(self._child_name_text):set_y(self._hud_panel:h() / 2 + VoidUI.options.interact_y)
	self._hud_panel:child(self._child_ivalid_name_text):set_bottom(self._hud_panel:child(self._child_name_text):bottom())
	self._hud_panel:child("interaction_time"):set_top(self._hud_panel:child(self._child_name_text):bottom() + 10 * self._scale)
	
	local text = utf8.to_upper(data.text or "Press 'F' to pay respects")
	self._hud_panel:child(self._child_name_text):set_visible(true)
	self._hud_panel:child(self._child_name_text):set_text(text)
	self._hud_panel:child(self._child_name_bg):set_text(text)
		
	self._hud_panel:child(self._child_name_text):stop()
	self._hud_panel:child(self._child_name_text):animate(callback(self, self, "_animate_interaction"),self._hud_panel:child(self._child_name_bg), self._hud_panel:child(self._child_ivalid_name_text), 1)
end

function HUDInteraction:remove_interact()
	if not alive(self._hud_panel) then
		return
	end
	self._hud_panel:child(self._child_name_text):stop()
	self._hud_panel:child(self._child_name_text):animate(callback(self, self, "_animate_interaction"),self._hud_panel:child(self._child_name_bg), self._hud_panel:child(self._child_ivalid_name_text), 0)
end

function HUDInteraction:_animate_interaction(interact_text, interact_bg, invalid_text, goal)
	local current = self._hud_panel:child(self._child_name_text):alpha()
	local TOTAL_T = 0.2
	local t = 0
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		local a = math.lerp(current,goal, t / TOTAL_T)
		interact_text:set_alpha(a)
		interact_bg:set_alpha(a)
		invalid_text:set_alpha(a)
	end
end
function HUDInteraction:show_interaction_bar(current, total)
	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end
	if self._interact_bar and self._interact_bar_bg then
		self._hud_panel:remove(self._interact_bar_bg)
		self._hud_panel:remove(self._interact_bar)
		self._interact_bar_bg = nil
		self._interact_bar = nil
	end
	local _, _, text_w, _ = self._hud_panel:child(self._child_name_text):text_rect()
	self._interact_bar_bg = self._hud_panel:bitmap({
		layer = 12,
		w = text_w,
		h = 10 * self._scale,
		color = Color.black:with_alpha(1)
	})	
	self._interact_bar = self._hud_panel:bitmap({
		layer = 13,
		w = 0,
		h = 6 * self._scale,
		color = Color.white:with_alpha(1)
	})
	self._interact_circle = CircleBitmapGuiObject:new(self._hud_panel, {
		use_bg = true,
		radius = 0,
		sides = 0,
		current = 0,
		total = 0,
		color = Color.white,
		alpha = 0,
		blend_mode = "add",
		layer = 2
	})
	self._interact_bar_bg:set_position(self._hud_panel:w() / 2 - (text_w / 2), self._hud_panel:child(self._child_name_text):y() + 64 * self._scale)
	self._interact_bar:set_position(self._hud_panel:w() / 2 - ((text_w - 4) / 2), self._hud_panel:child(self._child_name_text):y() + 66 * self._scale)
end
function HUDInteraction:set_interaction_bar_width(current, total)
	if not self._interact_circle then
		return
	end
	local _, _, text_w, _ = self._hud_panel:child(self._child_name_text):text_rect()
	self._interact_bar_bg:set_w(text_w)
	self._interact_bar:set_w((text_w - (4 * self._scale)) * (current / total))
	self._interact_bar_bg:set_x(self._hud_panel:w() / 2 - (text_w / 2))
	if VoidUI.options.center_interaction and VoidUI.options.center_interaction or false then 
		self._interact_bar:set_center_x(self._interact_bar_bg:center_x())
	else
		self._interact_bar:set_x(self._hud_panel:w() / 2 - ((text_w - (4 * self._scale)) / 2))
	end
	self._hud_panel:child("interaction_time"):set_visible(total - current > 0 and VoidUI.options.show_interact or false)
	if total - current > 0 then self._hud_panel:child("interaction_time"):set_text(string.format("%.1fs", total - current)) end
	local bg = self._interact_circle._bg_circle
	if self._interact_circle_locked and self._interact_circle_locked._circle:alpha() > 0 then
		self._interact_bar_bg:set_color(Color(0.015,0.1,0.015))
	elseif bg and alive(bg) and bg:alpha() ~= 1 then
		self._interact_bar_bg:set_color(Color(bg:alpha(),0,0))
	end
end
function HUDInteraction:hide_interaction_bar(complete)
	if complete then
		local _, _, text_w, _ = self._hud_panel:child(self._child_name_text):text_rect()	
		local bar = self._hud_panel:bitmap({
			layer = 5,
			w = text_w - 4,
			h = 6,
			color = Color.white:with_alpha(1)
		})
		bar:set_position(self._hud_panel:w() / 2 - ((text_w - 4) / 2), self._hud_panel:child(self._child_name_text):y() + 66 * self._scale)
		bar:animate(callback(self, self, "_animate_interaction_complete"), bar)
	end
	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end
	
	if self._interact_bar and self._interact_bar_bg then
		self._hud_panel:remove(self._interact_bar_bg)
		self._hud_panel:remove(self._interact_bar)
		self._interact_bar_bg = nil
		self._interact_bar = nil

	end
	self._hud_panel:child("interaction_time"):set_visible(false)
	
end
function HUDInteraction:set_bar_valid(valid, text_id)
	local color = valid and Color.white or Color(1, 0.3, 0.3)
	self._interact_bar:set_color(color)
	self._hud_panel:child(self._child_name_text):set_visible(valid)
	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
	local valid_text = self._hud_panel:child(self._child_name_text)
	if text_id then
		invalid_text:set_text(managers.localization:to_upper_text(text_id))
	end
	invalid_text:set_visible(not valid)
	self._hud_panel:child(self._child_name_bg):set_text(valid and valid_text:text() or invalid_text:text())
end
function HUDInteraction:destroy()
	self._hud_panel:remove(self._hud_panel:child(self._child_name_text))
	self._hud_panel:remove(self._hud_panel:child(self._child_ivalid_name_text))
	if self._interact_bar and self._interact_bar_bg then
		self._hud_panel:remove(self._interact_bar_bg)
		self._hud_panel:remove(self._interact_bar)
		self._interact_bar_bg = nil
		self._interact_bar = nil
	end
end
function HUDInteraction:_animate_interaction_complete(bar)
	local TOTAL_T = 0.2
	local t = 0
	local w = bar:w()
	local y = bar:center_y()
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		bar:set_size(math.lerp(w, w * 2, t / TOTAL_T), math.lerp(6, 1, t / TOTAL_T))
		bar:set_x(self._hud_panel:w() / 2 - ((bar:w() - 4) / 2))
		bar:set_center_y(y)
	end
	self._hud_panel:remove(bar)
end