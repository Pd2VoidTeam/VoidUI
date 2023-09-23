if VoidUI.options.enable_hint then
	function HUDHint:init(hud)
		self._hud_panel = hud.panel
		if self._hud_panel:child("hint_panel") then
			self._hud_panel:remove(self._hud_panel:child("hint_panel"))
		end
		self._hint_panel = self._hud_panel:panel({
			visible = false,
			name = "hint_panel",
			h = 30,
			y = 0,
			layer = 3
		})
		local y = self._hud_panel:h() / 3.5
		self._hint_panel:set_center_y(y)
		local clip_panel = self._hint_panel:panel({name = "clip_panel"})
		clip_panel:rect({
			name = "bg",
			visible = true,
			color = Color.black:with_alpha(0)
		})
		clip_panel:text({
			name = "hint_text",
			text = "",
			font_size = 25,
			font = tweak_data.menu.pd2_large_font,
			color = Color.white,
			align = "center",
			vertical = "center",
			layer = 1,
			rotation = 360,
			wrap = false,
			word_wrap = false
		})
		clip_panel:text({
			name = "hint_text_shadow",
			text = "",
			font_size = 25,
			font = tweak_data.menu.pd2_large_font,
			x = 1,
			y = 1,
			color = Color.black,
			align = "center",
			vertical = "center",
			layer = 0,
			rotation = 360,
			wrap = false,
			word_wrap = false
		})
	end
	function HUDHint:show(params)
		local clip_panel = self._hint_panel:child("clip_panel")
		self._stop = false
		self._hint_panel:stop()
		self._hint_panel:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), params)
	end
	
	function HUDHint:stop()
		self._stop = true
	end
	
	function HUDHint:color_by_names(hint_text, text)
		if VoidUI.options.hint_color then
			for _, data in pairs(managers.criminals:characters()) do
				if data.unit and alive(data.unit) and data.unit.base and data.unit:base().nick_name and (data.peer_id or data.data.ai) then
					local name = string.format(" %1s", data.unit:base():nick_name())
					local x = select(1, hint_text:text():find(name.." ", 1, true)) or select(1, hint_text:text():find(name.."! ", 1, true))
					local length = utf8.len(name)
					if x and length then
						x = x > 5 and x - 1 - ((#text - utf8.len(text)) - (#name - length)) or x - 1
						local color = data.peer_id
						hint_text:set_range_color(x, x + length, tweak_data.chat_colors[color] or tweak_data.chat_colors[#tweak_data.chat_colors])
					end
				end
			end
		end
	end
	
	function HUDHint:color_by_name(hint_text, name, color)
		if VoidUI.options.hint_color then
			local x = select(1, hint_text:text():find(name, 1, true)) - 1
			local length = utf8.len(name)
			hint_text:set_range_color(x, x + length, color)
		end
	end
	
	function HUDHint:_animate_show(hint_panel, done_cb, params)
		local text = string.format(" %1s ",params.text)
		local seconds = params.time or 3
		local scale = VoidUI.options.hint_scale
		local clip_panel = hint_panel:child("clip_panel")
		local hint_text = clip_panel:child("hint_text")
		local hint_text_shadow = clip_panel:child("hint_text_shadow")
		hint_panel:set_visible(true)
		hint_panel:set_alpha(1)
		local target_s = 25 * scale
		local start_s = hint_text:text() ~= text and 0 or target_s
		local add = 5 * scale
		hint_text:set_text(text)
		hint_text_shadow:set_text(text)
		hint_text:set_color(Color.white)
		hint_text:set_font_size(target_s + add)
		hint_text_shadow:set_font_size(target_s + add)
		local _, _, w, h = hint_text:text_rect()
		hint_text:set_w(w)
		hint_text_shadow:set_w(w)
		clip_panel:set_w(w)
		clip_panel:set_center_x(clip_panel:parent():w() / 2)
		clip_panel:set_w(w)
		hint_panel:set_h(h)
		clip_panel:set_h(h)
		hint_text:set_h(h)
		hint_text_shadow:set_h(h)
		
		if params.name and params.color then
			self:color_by_name(hint_text, params.name, params.color)
		else
			self:color_by_names(hint_text, text)
		end
		
		local s = start_s
		local t = seconds
		local forever = t == -1
		if VoidUI.options.hint_anim then
			local speed = 150 * scale
			while s < target_s + add do
				local dt = coroutine.yield()
				s = s + dt * speed
				hint_text:set_font_size(s)
				hint_text_shadow:set_font_size(s)
			end
			hint_text:set_font_size(target_s + add)
			hint_text_shadow:set_font_size(target_s + add)
			while s > target_s do
				local dt = coroutine.yield()
				s = s - dt * (speed / 5)
				hint_text:set_font_size(s)
				hint_text_shadow:set_font_size(s)
			end
			hint_text:set_font_size(target_s)
			hint_text_shadow:set_font_size(target_s)
			while (t > 0 or forever) and not self._stop do
				local dt = coroutine.yield()
				t = t - dt
			end
			self._stop = false
			while s < target_s + add do
				local dt = coroutine.yield()
				s = s + dt * speed / 5
				hint_text:set_font_size(s)
				hint_text_shadow:set_font_size(s)
			end
			hint_text:set_font_size(target_s + add)
			hint_text_shadow:set_font_size(target_s + add)
			while s > 0 do
				local dt = coroutine.yield()
				s = s - dt * speed
				hint_text:set_font_size(s)
				hint_text_shadow:set_font_size(s)
			end
			hint_text:set_font_size(0)
			hint_text_shadow:set_font_size(0)
		else
			local speed = 400
			hint_text:set_font_size(target_s)
			hint_text_shadow:set_font_size(target_s)
			while s < 100 do
				local dt = coroutine.yield()
				s = math.clamp(s + dt * speed, 0, 100)
				hint_panel:set_alpha(s/100)
			end
			while (t > 0 or forever) and not self._stop do
				local dt = coroutine.yield()
				t = t - dt
			end
			self._stop = false
			while s > 0 do
				local dt = coroutine.yield()
				s = math.clamp(s - dt * speed, 0, 100)
				hint_panel:set_alpha(s/100)
			end
		end
		hint_panel:set_visible(false)
		hint_text:set_font_size(25)
		hint_text_shadow:set_font_size(25)
		hint_text:set_text("")
		hint_text_shadow:set_text("")
		done_cb()
	end

	function HUDHint:show_done()
	end
end