export *
--interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
sx, sy = 0,0
px, py = 0,0
original_width, original_height = 800,600 --based on img.ini file in root of directory

love.resize = (w, h) ->
	sx = w / original_width
	sy = h / original_height
	px, py = w/256, h/192 --resolution of the DS
	--love.graphics.setNewFont("inter.ttf", 32)


love.load = ->
	--love.window.setMode(400, 240)
	print(love.filesystem.getSaveDirectory())
	love.filesystem.createDirectory("/novels")
	--contents = love.filesystem.read(interpreter.base_dir.."/img.ini")
	--original_width = tonumber(contents\match("width=(%d+)"))
	--original_height = tonumber(contents\match("height=(%d+)"))
	love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
	background = love.graphics.newImage("novels/fsn/background/special/title2.jpg")

love.draw = ->
	if background then love.graphics.draw(background,0,0,0,sx,sy)
	love.graphics.print("hello world!")
    --Moan.draw!

