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
	on "draw_text", ->
		font = love.graphics.getFont!
		w = pad + _(choices)\map(=> font\getWidth(@[1]))\max!\value! + pad
		font_height = font\getHeight!
		h = pad + (font_height + pad) * #choices
		love.graphics.setColor(0, 0, 0, .5)
		x = center(w, love.graphics.getWidth!)
		y = center(h, love.graphics.getHeight!)
		love.graphics.rectangle("fill", x, y, w, h)
		i = 1
		love.graphics.setColor(1, 1, 1)
		_.reduce(choices, y + pad, (a, e) ->
			text_width = font\getWidth(e[1])
			text_x = center(text_width, love.graphics.getWidth!)
			if i == selected then love.graphics.setColor(1, 0, 0)
			love.graphics.print(e[1], text_x, a)
			love.graphics.setColor(1, 1, 1)
			i += 1
			return a + font_height + pad
		)
		--love.graphics.printf(text, 0, y, love.graphics.getWidth!, "center")
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