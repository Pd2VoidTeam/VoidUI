HUDChat.line_height = 18
function HUDChat:init(ws, hud)
	self._ws = ws
	self._hud_panel = hud.panel
	self._scale = VoidUI.options.hud_chat_scale
	self:set_channel_id(ChatManager.GAME)
	self._input_width = 1200 * self._scale
	self._output_width = 400 * self._scale
	self._panel_width = 415 * self._scale
	self._scroll = 0
	self._lines_count = 0
	self._lines = {}
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
	self._skip_first = false
	self._mouse = managers.mouse_pointer:get_id()
	self._panel = self._hud_panel:panel({
		name = "chat_panel",
		x = 0,
		h = (10 * HUDChat.line_height + 25) * self._scale,
		w = self._panel_width,
		halign = "left",
		valign = "bottom"
	})
	self._panel:set_bottom(self._panel:parent():h() / 2 + 140)
	local output_panel = self._panel:panel({
		name = "output_panel",
		x = 0,
		h = 10 * self._scale,
		w = self._output_width,
		layer = 1
	})
	self._panel:text({
		name = "debug",
		text = "",
		font = "fonts/font_medium_mf",
		font_size = tweak_data.menu.pd2_small_font_size * 0.8 * self._scale,
		x = 0,
		y = 0,
		color = Color.white,
		alpha = 1,
		layer = 1,
	})
	self._panel:bitmap({
		name = "output_bg",
		layer = -1,
		w = self._output_width,
		color = Color(0.05,0.05,0.05),
		alpha = 0,
		h = (10 * HUDChat.line_height ) * self._scale
	})
	
	local scrollbar_panel = self._panel:panel({
		name = "scrollbar_panel",
		w = 15 * self._scale,
		h = (10 * HUDChat.line_height) * self._scale,
		layer = 2,
		alpha = 0
	})
	local scrollbar = scrollbar_panel:bitmap({
		name = "scrollbar",
		color = Color(0.8,0.8,0.8),
		alpha = 0.6,
		x = 5 * self._scale,
		y = 5 * self._scale
	})
	scrollbar:set_size(scrollbar_panel:w() - 10 * self._scale, scrollbar_panel:h() - 10 * self._scale)
	self:_create_input_panel()
	self:_layout_input_panel()
	self:_layout_output_panel()
end

function HUDChat:_create_input_panel()
	self._input_panel = self._panel:panel({
		alpha = 0,
		name = "input_panel",
		x = 0,
		h = 25 * self._scale,
		w = self._output_width,
		layer = 1
	})
	self._input_panel:rect({
		name = "focus_indicator",
		color = Color.black:with_alpha(0.8),
		w = self._input_width,
		layer = 0
	})
	local input_text = self._input_panel:text({
		name = "input_text",
		text = "",
		font = "fonts/font_medium_mf",
		font_size = tweak_data.menu.pd2_small_font_size * 0.8 * self._scale,
		x = 2,
		y = 0,
		align = "left",
		halign = "left",
		vertical = "center",
		hvertical = "center",
		color = Color.white,
		layer = 1,
		wrap = true,
		word_wrap = false
	})
	local caret = self._input_panel:rect({
		name = "caret",
		layer = 2,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
		color = Color(0.05, 1, 1, 1)
	})
end

function HUDChat:_layout_input_panel()
	self._input_panel:set_w(self._input_width)
	local input_text = self._input_panel:child("input_text")
	input_text:set_w(self._input_width - 4 * self._scale)
	input_text:set_h(self._input_panel:h() - 2 * self._scale)
	self._input_panel:set_y(self._input_panel:parent():h() - self._input_panel:h())
end

function HUDChat:update_caret()
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()
	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x()
		end
		y = text:world_y() + 3
	end
	h = text:h()
	if w < 2 then
		w = 2 * self._scale
	end
	if not self._focus then
		y = 1 * self._scale
		w = 0
		h = 0
	end
	caret:set_world_shape(x, y, w, h - 4 * self._scale)
	if caret:x() > self._panel_width - 4 then 
		text:set_x(text:x() - (caret:x() - (self._panel_width)) - 4 * self._scale)
		caret:set_x(caret:x() - (caret:x() - (self._panel_width)) - 4 * self._scale)
	elseif caret:x() < 2 then 
		text:set_x(text:x() + (2 * self._scale - caret:x()))
		caret:set_x(caret:x() + (2 * self._scale - caret:x()))
	end
	self:set_blinking(s == e and self._focus)
end

function HUDChat:receive_message(name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local scrollbar = self._panel:child("scrollbar_panel"):child("scrollbar")
	local peer = (managers.network and managers.network:session() and managers.network:session():local_peer():name() == name and managers.network:session():local_peer()) or (managers.network and managers.network:session() and managers.network:session():peer_by_name(name))
	local character = peer and " (".. managers.localization:text("menu_" ..peer:character())..")" or ""
	local full_message = name .. (VoidUI.options.show_charactername and peer and peer:character() and character or "") .. ": " .. message
	if name == managers.localization:to_upper_text("menu_system_message") then 
		name = message
		full_message = name
	end
	if VoidUI.options.chattime > 1 and managers.game_play_central then
		local time = VoidUI.options.chattime == 2 and "[".. os.date('!%X', managers.game_play_central:get_heist_timer()) .. "] " or "[".. os.date('%X') .. "] "
		full_message =  time .. full_message
		name = time .. name
	end
	local len = utf8.len(name) + (VoidUI.options.show_charactername and utf8.len(character) or 0) + 1 
	local panel = output_panel:panel({
		name = tostring(#self._lines),
		w = self._output_width
	})
	local line = panel:text({
		name = "line",
		text = full_message,
		font = "fonts/font_medium_mf",
		font_size = tweak_data.menu.pd2_small_font_size * 0.85 * self._scale,
		x = 0,
		y = 0,
		align = "left",
		halign = "left",
		vertical = "bottom",
		hvertical = "top",
		blend_mode = "normal",
		wrap = true,
		word_wrap = true,
		color = color,
		layer = 0
	})
	line:set_w(output_panel:w() - line:left())
	local line_shadow = panel:text({
		name = "line_shadow",
		text = full_message,
		font = "fonts/font_medium_mf",
		font_size = tweak_data.menu.pd2_small_font_size * 0.85 * self._scale,
		x = 1,
		y = 1,
		align = "left",
		halign = "left",
		vertical = "bottom",
		hvertical = "top",
		blend_mode = "normal",
		wrap = true,
		word_wrap = true,
		color = Color.black,
		alpha = 0.9,
		layer = -1
	})
	line_shadow:set_w(output_panel:w() - line:left())
	
	local total_len = utf8.len(line:text())
	local line_height = HUDChat.line_height
	local lines_count = line:number_of_lines()
	self._lines_count = self._lines_count + lines_count
	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)
	panel:set_h(HUDChat.line_height * self._scale * lines_count)
	line:set_h(panel:h())
	line_shadow:set_h(panel:h())
	panel:set_bottom(self._input_panel:bottom())
	table.insert(self._lines, {
		panel = panel,
		message = message,
		name = name,
		character = character
	})
	line:set_kern(line:kern())
	self:_layout_output_panel()
	line:animate(callback(self, self, "_animate_message_recieved"), line_shadow)
	if not self._focus then
		local output_panel = self._panel:child("output_panel")
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
end
function HUDChat:_animate_message_recieved(line, line_shadow)
	local h = line:h()
	local TOTAL_T = 0.2
	local t = 0
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		line:set_size(math.lerp(0, self._output_width, t / TOTAL_T), math.lerp(0, h, t / TOTAL_T))
		line_shadow:set_size(math.lerp(0, self._output_width, t / TOTAL_T), math.lerp(0, h, t / TOTAL_T))
		line:set_font_size(math.lerp(0, tweak_data.menu.pd2_small_font_size * 0.85 * self._scale, t / TOTAL_T))
		line_shadow:set_font_size(math.lerp(0, tweak_data.menu.pd2_small_font_size * 0.85 * self._scale, t / TOTAL_T))
	end
	line:set_size(self._output_width, h)
	line_shadow:set_size(self._output_width, h)
	line:set_font_size(tweak_data.menu.pd2_small_font_size * 0.85 * self._scale)
	line_shadow:set_font_size(tweak_data.menu.pd2_small_font_size * 0.85 * self._scale)
end

function HUDChat:scroll_chat(dir)
	if self._lines_count > 10 * self._scale then
		self._scroll = math.clamp(self._scroll + dir * self._scale, -(HUDChat.line_height * self._scale * (self._lines_count - 10)), 0)
		self:_layout_output_panel()	
	end
end

function HUDChat:set_chat_scroll(dir)
	if self._lines_count > 10 * self._scale then
		self._scroll = math.clamp(dir * self._scale, -(HUDChat.line_height * self._scale * (self._lines_count - 10)), 0)
		self:_layout_output_panel()	
	end
end
function HUDChat:_layout_output_panel()
	local output_panel = self._panel:child("output_panel")
	local scrollbar_panel = self._panel:child("scrollbar_panel")
	local scrollbar = scrollbar_panel:child("scrollbar")	
	output_panel:set_w(self._output_width)
	local line_height = HUDChat.line_height * self._scale
	if self._lines_count < (10 * self._scale) then 
		output_panel:set_h(line_height * math.max(10, self._lines_count))
	else
		output_panel:set_h(line_height * math.min(10, self._lines_count))
	end
	local y = 0 + self._scroll
	for i = #self._lines, 1, -1 do
		local panel = self._lines[i].panel
		local b = panel:bottom()
		local b2 = output_panel:h() - y
		panel:stop()
		panel:animate(function(o)
			over(0.2, function(p)
				if alive(panel) then
					panel:set_bottom(math.lerp(b,b2, p))
				end
			end)
		end)
		y = y + panel:h()
	end
	if self._lines_count > 9 * self._scale then 
		scrollbar:set_h((10 * line_height - 10 * self._scale) * (10 / self._lines_count))
		scrollbar:set_bottom(math.clamp((scrollbar_panel:h() - 4 * self._scale) * (1 -(-self._scroll / line_height) / self._lines_count), scrollbar:h() + 4, scrollbar_panel:h() - 4 ))
	end
	output_panel:set_bottom(self._input_panel:top())
end

function HUDChat:_on_focus()
	if self._focus then
		return
	end
	local output_panel = self._panel:child("output_panel")
	output_panel:stop()
	output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_focus"), true, self._panel:child("output_bg"):alpha(), output_panel:x(), self._panel:child("output_bg"):w())
	self._focus = true
	self:_layout_output_panel()
	self._ws:connect_keyboard(Input:keyboard())
	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))
	self._enter_text_set = false
	self:set_layer(1100)
	self:update_caret()
	if VoidUI.options.chat_mouse then
		managers.mouse_pointer:use_mouse{
			id = self._mouse,
			mouse_press = callback(self, self, 'mouse_pressed'),
			mouse_release = callback(self, self, "mouse_released"),
			mouse_move = callback(self, self, "mouse_moved"),
		}
	end
end

function HUDChat:_animate_focus(input_panel, open, start_alpha, start_x, start_w)
	local output_panel = self._panel:child("output_panel")
	local output_bg = self._panel:child("output_bg")
	local scrollbar_panel = self._panel:child("scrollbar_panel")
	local TOTAL_T = 0.25
	local t = 0
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		output_panel:set_x(math.lerp(start_x, open and 15 * self._scale or 0,  t / TOTAL_T))
		input_panel:set_alpha(math.lerp(start_alpha, open and 1 or 0, t / TOTAL_T))
		output_bg:set_alpha(math.lerp(start_alpha, open and 0.5 or 0, t / TOTAL_T))
		scrollbar_panel:set_alpha(math.lerp(start_alpha, open and 1 or 0, t / TOTAL_T))
		
		output_bg:set_w(math.lerp(start_w, open and self._panel_width or self._output_width, t / TOTAL_T))
		input_panel:set_w(math.lerp(start_w, open and self._panel_width or self._output_width, t / TOTAL_T))
	end
	output_panel:set_x(open and 15 * self._scale or 0)
	input_panel:set_alpha(open and 1 or 0)
	scrollbar_panel:set_alpha(open and 1 or 0)
	output_bg:set_alpha(open and 0.5 or 0)
	output_bg:set_w(open and self._panel_width or self._output_width)
	input_panel:set_w(open and self._panel_width or self._output_width)
end

function HUDChat:_loose_focus()
	if not self._focus then
		return
	end
	self._focus = false
	self._scroll = 0
	self:_layout_output_panel()
	self._ws:disconnect_keyboard()
	self._input_panel:key_press(nil)
	self._input_panel:enter_text(nil)
	self._input_panel:key_release(nil)
	if self._mouse then 
		managers.mouse_pointer:set_pointer_image("arrow")
		managers.mouse_pointer:remove_mouse(self._mouse) 
	end
	self._panel:child("output_panel"):stop()
	self._panel:child("output_panel"):animate(callback(self, self, "_animate_fade_output"))
	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_focus"), false, self._panel:child("output_bg"):alpha(), self._panel:child("output_panel"):x(), self._panel:child("output_bg"):w())
	local text = self._input_panel:child("input_text")
	for i = #self._lines, 1, -1 do
		local panel = self._lines[i].panel
		panel:set_alpha(1)
	end
	text:stop()
	self:set_layer(1)
	self:update_caret()
end

function HUDChat:key_press(o, k)
	if self._skip_first then
		self._skip_first = false
		return
	end
	if not self._enter_text_set then
		self._input_panel:enter_text(callback(self, self, "enter_text"))
		self._enter_text_set = true
	end
	local text = self._input_panel:child("input_text")
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k
	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)
	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end
		text:replace_text("")
		if not (utf8.len(text:text()) < 1) or type(self._esc_callback) ~= "number" then
		end
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end
		text:replace_text("")
		if not (utf8.len(text:text()) < 1) or type(self._esc_callback) ~= "number" then
		end
	elseif k == Idstring("insert") then
		local clipboard = Application:get_clipboard() or ""
		text:replace_text(clipboard)
		local lbs = text:line_breaks()
		if #lbs > 1 then
			local s = lbs[2]
			local e = utf8.len(text:text())
			text:set_selection(s, e)
			text:replace_text("")
		end
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif self._key_pressed == Idstring("up")	then
		self:scroll_chat(-HUDChat.line_height * self._scale)
	elseif self._key_pressed == Idstring("down") then
		self:scroll_chat(HUDChat.line_height * self._scale)
	elseif self._key_pressed == Idstring("page up") and self._lines_count > 10 * self._scale then
		self._scroll = -(HUDChat.line_height * self._scale * (self._lines_count - 10))
		self:_layout_output_panel()
	elseif self._key_pressed == Idstring("page down") then
		self._scroll = 0
		self:_layout_output_panel()
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		text:set_text("")
		text:set_selection(0, 0)
		self._esc_callback()
	end
	self:update_caret()
end
function HUDChat:mouse_pressed(o, button, x, y)
	x = x - (managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:w() - self._hud_panel:w()) / 2
	y = y - (managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:h() - self._hud_panel:h()) / 2
	local scrollbar_panel = self._panel:child("scrollbar_panel")
	if button == Idstring("mouse wheel up")	then
		self:scroll_chat(-HUDChat.line_height)
	elseif button == Idstring("mouse wheel down") then
		self:scroll_chat(HUDChat.line_height)
	elseif button == Idstring("0") then
		if scrollbar_panel:inside(x, y) then
			self._scrollbar = true
			self:set_chat_scroll(-(self._lines_count * HUDChat.line_height) * (1 - ((y - scrollbar_panel:world_y()) / (scrollbar_panel:h() - scrollbar_panel:child("scrollbar"):h()))))
			if o then managers.mouse_pointer:set_pointer_image("grab") end
		end
	elseif button == Idstring("1") then
		if self._input_panel:inside(x, y) then
			local text = self._input_panel:child("input_text")
			local clipboard = Application:get_clipboard() or ""
			text:replace_text(clipboard)
			local lbs = text:line_breaks()
			if #lbs > 1 then
				local s = lbs[2]
				local e = utf8.len(text:text())
				text:set_selection(s, e)
				text:replace_text("")
			end
		elseif VoidUI.options.chat_copy > 1 and self._panel:child("output_bg"):inside(x, y) then
			for i = #self._lines, 1, -1 do
				local panel = self._lines[i].panel
				if panel:inside(x, y) then
					local line = self._lines[i].message
					if VoidUI.options.chat_copy == 3 then line = self._lines[i].name .. ": " .. line
					elseif VoidUI.options.chat_copy == 4 then line = self._lines[i].character .. ": " .. line
					elseif VoidUI.options.chat_copy == 5 then line = self._lines[i].name .. self._lines[i].character .. ": " .. line end
					
					Application:set_clipboard(line)
					managers.hud:show_hint({text = managers.localization:text("VoidUI_chat_clipboard"), time = 1})
				end
			end
		end
	end
end

function HUDChat:mouse_released(o, button, x, y)
	if button == Idstring("0") and self._scrollbar then
		self._scrollbar = false
		self:mouse_moved(o, x, y)
	end
end

function HUDChat:mouse_moved(o, x, y)
	x = x - (managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:w() - self._hud_panel:w()) / 2
	y = y - (managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2).panel:h() - self._hud_panel:h()) / 2
	local scrollbar_panel = self._panel:child("scrollbar_panel")
	if self._scrollbar then
		self:set_chat_scroll(-(self._lines_count * HUDChat.line_height) * (1 - ((y - scrollbar_panel:world_y()) / (scrollbar_panel:h() - scrollbar_panel:child("scrollbar"):h()))))
		if o then managers.mouse_pointer:set_pointer_image("grab") end
	elseif scrollbar_panel:inside(x, y) and o then
		managers.mouse_pointer:set_pointer_image("hand")
	elseif VoidUI.options.chat_copy > 1 and self._panel:child("output_panel"):inside(x, y) then
		local inside = false
		for i = #self._lines, 1, -1 do
			local panel = self._lines[i].panel
			if inside == false then inside = panel:inside(x, y) end
			panel:set_alpha(panel:inside(x, y) and 1 or 0.5)
		end
		if o then managers.mouse_pointer:set_pointer_image(inside and "link" or "arrow") end
	elseif not self._panel:child("output_panel"):inside(x, y) then
		for i = #self._lines, 1, -1 do
			local panel = self._lines[i].panel
			panel:set_alpha(1)
		end
		if o then managers.mouse_pointer:set_pointer_image("arrow") end
	end
end