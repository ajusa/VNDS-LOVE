require "lib/script"
pprint = require "lib/pprint"
Talkies = require "lib/talkies"
Talkies.font = love.graphics.newFont("inter.otf", 32)
Talkies.padding = 20
export *
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = {}

getScaling = (drawable,canvas) ->
	canvas = canvas or nil

	drawW = drawable\getWidth()
	drawH = drawable\getHeight()

	canvasW = 0
	canvasH = 0
		
	if canvas then
		canvasW = canvas\getWidth()
		canvasH = canvas\getHeight()
	else
		canvasW = love.graphics.getWidth()
		canvasH = love.graphics.getHeight()

	scaleX = canvasW / drawW
	scaleY = canvasH / drawH

	return scaleX, scaleY


next_msg = () ->
	ins = interpreter\next_instruction!
	pprint(ins)
	switch ins.type
		when "bgload"
			if ins.path == "~" then background = nil
			else if love.filesystem.exists(ins.path)
				background = love.graphics.newImage(ins.path)
			next_msg!
		when "text"
			if ins.text == "~"
				Talkies.say("", "", {oncomplete: () -> next_msg!})
			else
				Talkies.say("", ins.text, {oncomplete: () -> next_msg!})
		when "choice"
			
			opts = {}
			for i,choice in ipairs ins.choices
				table.insert(opts, {choice, 
				() -> 
					interpreter\choose(i)
					next_msg!
				})
			Talkies.say("", "Choose", {options: opts})

		else next_msg!
		--when "setimg"
		--when "sound"
		--when "music"
		--when "delay"
		--when "cleartext"

love.load = ->
	next_msg!

love.draw = ->
	if background then 
		sx, sy = getScaling(background)
		love.graphics.draw(background, 0,0,0,sx,sy)
    Talkies.draw!

love.update = (dt) ->
	Talkies.update(dt)

love.keypressed = (key) ->
  if key == "space" then Talkies.onAction()
  else if key == "up" then Talkies.prevOption()
  else if key == "down" then Talkies.nextOption()