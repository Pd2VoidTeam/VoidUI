HUDHint = HUDHint or class()
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
		valign = {0.3125, 0},
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
		font = "fonts/font_large_mf",
		color = Color.white,
		align = "center",
		vertical = "center",
		layer = 1,
		wrap = false,
		word_wrap = false
	})
	clip_panel:text({
		name = "hint_text_shadow",
		text = "",
		font_size = 25,
		font = "fonts/font_large_mf",
		x = 1,
		y = 1,
		color = Color.black,
		align = "center",
		vertical = "center",
		layer = 0,
		wrap = false,
		word_wrap = false
	})
end
function HUDHint:show(params)
	local text = params.text
	local clip_panel = self._hint_panel:child("clip_panel")
	self._stop = false
	self._hint_panel:stop()
	self._hint_panel:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), params.time or 3, text)
end
function HUDHint:stop()
	self._stop = true
end
function HUDHint:_animate_show(hint_panel, done_cb, seconds, text)
	local clip_panel = hint_panel:child("clip_panel")
	local hint_text = clip_panel:child("hint_text")
	local hint_text_shadow = clip_panel:child("hint_text_shadow")
	hint_panel:set_visible(true)
	hint_panel:set_alpha(1)
	local target_s = 25
	local start_s = hint_text:text() ~= text and 0 or target_s
	hint_text:set_text(text)
	hint_text_shadow:set_text(text)
	hint_text:set_color(Color.white)
	hint_text:set_font_size(target_s + 5)
	hint_text_shadow:set_font_size(target_s + 5)
	local _, _, w, h = hint_text:text_rect()
	hint_text:set_w(w)
	hint_text_shadow:set_w(w)
	clip_panel:set_w(w)
	clip_panel:set_center_x(clip_panel:parent():w() / 2)
	clip_panel:set_w(w)
		
	for peer_id, peer in pairs(managers.network:session():all_peers()) do
		if peer then
			local name = peer:name()
			if string.find(hint_text:text(), name) ~= nil then 
				local length = utf8.len(name)
				local x = select(1, string.find(hint_text:text(), name, 1, true)) - 1
				if x > 5 then x = x - ((#text - utf8.len(text)) - (#name - length)) end
				hint_text:set_range_color(x, x + length, tweak_data.chat_colors[managers.criminals:character_color_id_by_unit(peer:unit())])
			end
		end
	end	
	
	local s = 0
	local t = seconds
	local forever = t == -1
	local st = 1
	local cs = 0
	local speed = 150
	local presenting = true
	while presenting do
		local dt = coroutine.yield()
		s = math.clamp(s + dt * speed, start_s, target_s + 5)
		presenting = s ~= target_s + 5
		hint_text:set_font_size(s)
		hint_text_shadow:set_font_size(s)
	end
	presenting = true
	while presenting do
		local dt = coroutine.yield()
		s = math.clamp(s - dt * speed / 5, target_s, target_s + 5)
		presenting = s ~= target_s
		hint_text:set_font_size(s)
		hint_text_shadow:set_font_size(s)
	end
	while (t > 0 or forever) and not self._stop do
		local dt = coroutine.yield()
		t = t - dt
	end
	self._stop = false
	local removing = true
	while removing do
		local dt = coroutine.yield()
		s = math.clamp(s + dt * speed / 5, target_s, target_s + 5)
		removing = s ~= target_s + 5
		hint_text:set_font_size(s)
		hint_text_shadow:set_font_size(s)
	end
	removing = true
	while removing do
		local dt = coroutine.yield()
		s = math.clamp(s - dt * speed, 0, target_s + 3)
		hint_text:set_font_size(s)
		hint_text_shadow:set_font_size(s)
		removing = s ~= 0
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