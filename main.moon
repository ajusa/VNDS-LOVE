require "lib/script"
pprint = require "lib/pprint"
TESound = require "lib/tesound"
Moan = require "lib/Moan"
Moan.font = love.graphics.newFont("inter.ttf", 32)
choice_ui = () ->
	Moan.UI.messageboxPos = "top"
	Moan.height = original_height * .75 * sy
	Moan.width = original_width * .75 * sx
	Moan.center = true

undo_choice_ui = () ->
	Moan.UI.messageboxPos = "bottom"
	Moan.height = 150
	Moan.width = nil
	Moan.center = false
export *
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = {}
sx, sy = 0,0
px, py = 0,0
original_width, original_height = 0,0 --based on img.ini file in root of directory

love.resize = (w, h) ->
	sx = w / original_width
	sy = h / original_height
	px, py = w/256, h/192 --resolution of the DS
	love.graphics.setNewFont("inter.ttf", 32)

next_msg = () ->
	ins = interpreter\next_instruction!
	if ins.path and not ins.path\sub(-1) == "~" and not love.filesystem.getInfo(ins.path) then next_msg!
	switch ins.type
		when "bgload"
			if ins.path\sub(-1) == "~" then background = nil
			else if love.filesystem.getInfo(ins.path)
				background = love.graphics.newImage(ins.path)
				images = {}
			next_msg!
		when "text"
			if ins.text == "~" or ins.text == "!"
				next_msg!
				--Moan.speak("", {""}, {oncomplete: () -> next_msg!})
			else
				Moan.speak("Text", {ins.text}, {oncomplete: () -> next_msg!})
		when "choice"
			opts = {}
			for i,choice in ipairs ins.choices
				table.insert(opts, {choice, 
				() -> 
					interpreter\choose(i)
					undo_choice_ui!
					next_msg!
				})
			choice_ui!
			Moan.speak("", {"Choose\n"}, {options: opts})
		
		when "setimg"
			if love.filesystem.getInfo(ins.path)
				table.insert(images, {img: love.graphics.newImage(ins.path), x: ins.x, y: ins.y})
				next_msg!
		when "sound"
			if ins.path\sub(-1) == "~" then TEsound.stop("sound")
			else if ins.n
				if ins.n == -1 then TEsound.playLooping(ins.path, "static", {"sound"})
				else TEsound.playLooping(ins.path, "static", {"sound"}, ins.n)
			else TEsound.play(ins.path, "static",{"sound"})
			next_msg!
		when "music"
			if ins.path\sub(-1) == "~" then TEsound.stop("music")
			else if love.filesystem.getInfo(ins.path)
				TEsound.playLooping(ins.path, "stream", {"music"})
			next_msg!
		--when "delay"
		--when "cleartext"
			else next_msg!

love.load = ->
	print(love.filesystem.getSaveDirectory())
	love.filesystem.createDirectory("/novels")
	contents = love.filesystem.read(interpreter.base_dir.."/img.ini")
	original_width = tonumber(contents\match("width=(%d+)"))
	original_height = tonumber(contents\match("height=(%d+)"))
	love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
	next_msg!

love.draw = ->
	if background then love.graphics.draw(background,0,0,0,sx,sy)
	for fg in *images do love.graphics.draw(fg.img, fg.x*px, fg.y*py, 0, sx, sy)
    Moan.draw!

love.update = (dt) ->
	Moan.update(dt)
	TEsound.cleanup()

love.keypressed = (key) ->
	Moan.keypressed(key)

love.gamepadpressed = (joy, button) ->
	print(button)
	if button == "a" then Moan.keypressed("space")
	else if button == "dpup" then Moan.keypressed("up")
	else if button == "dpdown" then Moan.keypressed("down")

