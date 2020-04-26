require "lib/script"
pprint = require "lib/pprint"
Talkies = require "lib/talkies"
export *
interpreter = Interpreter("/home/ajusa/Downloads/fsn", "main.scr")
background = nil
images = {}

next_msg = () ->
	ins = interpreter\next_instruction!
	pprint(ins)
	switch ins.type
		when "bgload"
			if ins.path == "~" then background = nil
			else background = love.graphics.newImage(ins.path)
		when "text"
			if ins.text == "~"
				Talkies.say("", "", {oncomplete: () -> next_msg!})
			else
				Talkies.say("", ins.text, {oncomplete: () -> next_msg!})
		else next_msg(ins)
		--when "setimg"
		--when "sound"
		--when "music"
		--when "delay"
		--when "cleartext"

love.load = ->
	next_msg!
    Talkies.say("", "Hello World!")

love.draw = ->
	if background then love.graphics.draw(background)
    Talkies.draw!

love.update = (dt) ->
	Talkies.update(dt)

love.keypressed = (key) ->
  if key == "space" then Talkies.onAction()
  else if key == "up" then Talkies.prevOption()
  else if key == "down" then Talkies.nextOption()