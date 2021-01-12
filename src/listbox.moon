local *
pad = 10
-- can also provide "data" as a part of choices
create_listbox = =>
	@selected = @selected or 1
	if @choices[@selected].onchange
		@choices[@selected].onchange(@choices[@selected])
	for choice in *@choices
		choice.text = lg.newText(font, choice.text)
	@closable = @closable or false
	@allow_menu = @allow_menu or false
	@onclose = @onclose or ->
	@media = @media or -pad
	local *
	dispatch "pause"
	font_height = (text) ->
		return math.max(text\getHeight!, @media)
	close = ->
		input_event\remove!
		draw_event\remove!
		dispatch "play"
	input_event = on "input", (input) ->
		@selected = switch input
			when "up" then (@selected-2) % #@choices + 1
			when "down" then @selected % #@choices + 1
		chosen = @choices[@selected]
		if input == "up" or input == "down"
			if chosen.onchange then chosen.onchange(chosen)
		if input == "a"
			outcome = chosen.action(chosen, close)
			if @closable and outcome then close!
			if not @closable then close!
		else if input == "start" and @allow_menu
			return true --passes it to the below layer
		else if input == "b" and @closable
			close!
			@onclose!
		else if input == "right"
			if chosen.right then chosen.right(chosen)
		else if input == "left"
			if chosen.left then chosen.left(chosen)
		return false
	draw_event = on "draw_choice", ->
		w = 3 * pad + _.max([c.text\getWidth! for c in *@choices]) + @media
		h, y_selected = pad, 0
		for i, c in ipairs @choices
			h += font_height(c.text) + pad
			if i == @selected then y_selected += h
		x, y = center(w, lg.getWidth!), center(h, lg.getHeight!)
		y = lg.getHeight!/2 - y_selected
		lg.setColor(.18,.204,.251, .8)
		lg.rectangle("fill", x, y, w, h)
		text_y = y + pad
		for i, c in ipairs @choices
			lg.setColor(1, 1, 1)
			if c.media then c.media(x+pad, text_y)
			if i == @selected then lg.setColor(.506, .631, .757)
			lg.draw(c.text, x + 2*pad + @media, text_y)
			text_y += pad + font_height(c.text)
		return false
return {:create_listbox}
