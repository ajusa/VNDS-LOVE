local *
selected = 1
choices = {}
on "choose", =>
	choices = @
	register(choose_events)
choose_events = {
	on "input", =>
		switch @
			when "up"
				selected = (selected-2) % #choices + 1
			when "down"
				selected %= #choices + 1
			when "space"
				remove(choose_events)
				choices[selected][2]()
	on "draw_text", ->
		font = love.graphics.getFont!
		text = ""
		for i, choice in ipairs choices
			text ..= "->" if i == selected
			text ..= choice[1].."\n"
		love.graphics.setColor(0, 0, 0, .5)
		w = font\getWidth(text)
		love.graphics.rectangle("fill", ((love.graphics.getWidth! - w)/2) - 10, 200 - 10, w +10, (font\getHeight! * #choices) + 10)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(text, 0, 200, love.graphics.getWidth!, "center")
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