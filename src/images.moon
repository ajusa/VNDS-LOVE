Timer = require 'lib/timer'
background = {}
images = {}
alpha = value: 1

on "save", =>
	@background = {path: background.path}
	@images = _.map(images, => {path: @path, x: @x, y: @y})

on "restore", => 
	dispatch "bgload", @background
	for image in *@images do dispatch "setimg", image
on "bgload", =>
	if @frames ~= nil
		alpha.value = 0
		Timer.tween(@frames/60, {
			[alpha]: { value: 1 },
		})
	if @path\sub(-1) == "~" then background = {}
	background = {path: @path, img: love.graphics.newImage(@path)}
	images = {}

on "setimg", =>
	table.insert(images, {path: @path, img: love.graphics.newImage(@path), x: @x, y: @y})

on "draw_background", ->
	love.graphics.setColor(255, 255, 255, alpha.value)
	if next(background) then love.graphics.draw(background.img,0,0,0,sx,sy)

on "draw_foreground", ->
	_.each(images, => love.graphics.draw(@img, @x*px, @y*py, 0, sx, sy))