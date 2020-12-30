local *
selected = 1
choices = {}
pad = 10
on "choose", =>
	choices = @
	selected = 1
	register(choose_events)
choose_events = {
	on "input", =>
		selected = switch @
			when "up" then (selected-2) % #choices + 1
			when "down" then selected % #choices + 1
		if @ == "a"
			remove(choose_events)
			choices[selected][2]()
	on "draw_choice", ->
		w = pad + _(choices)\map(=> font\getWidth(@[1]))\max!\value! + pad
		font_height = font\getHeight!
		h = pad + (font_height + pad) * #choices
		lg.setColor(.18,.204,.251, .8)
		x, y = center(w, lg.getWidth!), center(h, lg.getHeight!)
		y_selected = y + selected * (font_height + pad)
		y = y + lg.getHeight!/2 - y_selected
		lg.rectangle("fill", x, y, w, h)
		i = 1
		lg.setColor(1, 1, 1)
		_.reduce(choices, y + pad, (a, e) ->
			text_width = font\getWidth(e[1])
			text_x = center(text_width, lg.getWidth!)
			if i == selected then lg.setColor(.506, .631, .757)
			lg.print(e[1], text_x, a)
			lg.setColor(1, 1, 1)
			i += 1
			return a + font_height + pad
		)
}
remove(choose_events)

on "choice", => --This is the VNDS choice event
	opts = {}
	for i,choice in ipairs @choices
		table.insert(opts, {choice, 
		() -> 
			script.choose(interpreter, i)
			dispatch "next_ins"
		})
	dispatch "choose", opts
