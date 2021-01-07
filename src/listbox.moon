local *
listboxes = {} -- All listboxes, operates like a stack
pad = 10
create_listbox = =>
	@selected = 1
	table.insert(listboxes, @)
	input_event\register!
	draw_event\register!
close = ->
	table.remove(listboxes) -- Pop off the listbox
	if #listboxes == 0 then disengage!
disengage = ->
	input_event\remove!
	draw_event\remove!
input_event = on "input", =>
	lb = listboxes[#listboxes]
	lb.selected = switch @
		when "up" then (lb.selected-2) % #lb.choices + 1
		when "down" then lb.selected % #lb.choices + 1
	if @ == "a"
		lb.choices[lb.selected][2]()
		close!
draw_event = on "draw_choice", ->
	for lb in *listboxes
		w = pad + _(lb.choices)\map(=> font\getWidth(@[1]))\max!\value! + pad
		font_height = font\getHeight!
		h = pad + (font_height + pad) * #lb.choices
		lg.setColor(.18,.204,.251, .8)
		x, y = center(w, lg.getWidth!), center(h, lg.getHeight!)
		y_selected = y + lb.selected * (font_height + pad)
		y = y + lg.getHeight!/2 - y_selected
		lg.rectangle("fill", x, y, w, h)
		i = 1
		lg.setColor(1, 1, 1)
		_.reduce(lb.choices, y + pad, (a, e) ->
			text_width = font\getWidth(e[1])
			text_x = center(text_width, lg.getWidth!)
			if i == lb.selected then lg.setColor(.506, .631, .757)
			lg.print(e[1], text_x, a)
			lg.setColor(1, 1, 1)
			i += 1
			return a + font_height + pad
		)

-- Remove events until there is a listbox
disengage!
return {:create_listbox}
