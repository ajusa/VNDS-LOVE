import dispatch, on, register, remove from require 'event'
script = require "script"
pprint = require "lib/pprint"
local *
selected = 1
choices = {}
on "choose", =>
	register(choose_events)
	choices = @
choose_events = {
	on "input", =>
		switch @
			when "up"
				selected = (selected-2) % #choices + 1
			when "down"
				selected %= #choices + 1
			when "space" then 
				choices[selected][2]()
				remove(choose_events),
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
			next_msg!
		})
	dispatch "choose", opts