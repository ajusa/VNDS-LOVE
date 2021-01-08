local *
pad = 10
create_listbox = =>
	@selected = 1
	@closable = @closable or false
	@allow_menu = @allow_menu or false
	local *
	close = ->
		input_event\remove!
		draw_event\remove!
	input_event = on "input", (input) ->
		@selected = switch input
			when "up" then (@selected-2) % #@choices + 1
			when "down" then @selected % #@choices + 1
		if input == "a"
			close!
			@choices[@selected][2]!
		else if input == "start" and @allow_menu
			return true
		else if input == "b" and @closable
			close!
		return false
	draw_event = on "draw_choice", ->
		w = 2 * pad + _(@choices)\map(=> font\getWidth(@[1]))\max!\value!
		font_height = font\getHeight!
		h = pad + (font_height + pad) * #@choices
		lg.setColor(.18,.204,.251, .8)
		x, y = center(w, lg.getWidth!), center(h, lg.getHeight!)
		y_selected = y + @selected * (font_height + pad)
		y = y + lg.getHeight!/2 - y_selected
		lg.rectangle("fill", x, y, w, h)
		i = 1
		lg.setColor(1, 1, 1)
		_.reduce(@choices, y + pad, (a, e) ->
			text_width = font\getWidth(e[1])
			text_x = center(text_width, lg.getWidth!)
			if i == @selected then lg.setColor(.506, .631, .757)
			lg.print(e[1], text_x, a)
			lg.setColor(1, 1, 1)
			i += 1
			return a + font_height + pad
		)
		return false
return {:create_listbox}
