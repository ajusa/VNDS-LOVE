-- have this handle all of the text related events
-- it should also handle choices if possible
import dispatch, on from require 'event'
pprint = require "lib/pprint"
buffer = {}
needs_input = false
pos = 1
speed = 0.1
selected = 1
choices = {}

on "text", =>
	return nil

on "choose", =>
	pprint(@)
	choices = @
	return nil

on "choice", =>
	return nil

on "input", =>
	switch @
		when "up" then selected -= 1
		when "down" then selected += 1

on "draw_text", ->
	love.graphics.setColor(1, 1, 1)
	text = ""
	for i, choice in ipairs choices
		text ..= "->" if i == selected
		text ..= choice[1].."\n"
	love.graphics.printf(text, 0, 0, love.graphics.getWidth!, "center")