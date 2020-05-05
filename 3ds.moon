bgs = {"/novels/fsn/background/special/title2.jpg", "/novels/fsn/background/special/title.jpg", "/novels/fsn/background/special/tigerdojo.jpg"}
bg_i = 1
background = love.graphics.newImage(bgs[1])
sx, sy = 0,0
original_width, original_height = 800, 600

love.resize = (w, h) ->
	sx = w / original_width
	sy = h / original_height

love.load = ->
	love.resize(love.graphics.getWidth!, love.graphics.getHeight!)

love.draw = ->
	if background then love.graphics.draw(background,0,0,0,sx,sy)


love.gamepadpressed = (joy, button) ->
	if button == "a" then 
		bg_i = (bg_i) % 3 + 1
		background\release!
		background = love.graphics.newImage(bgs[bg_i])


