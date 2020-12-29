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

first_bg = true
on "bgload", =>
	if @frames ~= nil
		alpha.value = 0
		Timer.tween(@frames/60, {
			[alpha]: { value: 1 },
		})
	if @path\sub(-1) == "~" then background = {}
	background = {path: @path, img: lg.newImage(@path)}
	if first_bg
		export original_width, original_height = background.img\getDimensions()
		love.resize(lg.getWidth!, lg.getHeight!)
		first_bg = false
	images = {}

on "setimg", =>
	table.insert(images, {path: @path, img: lg.newImage(@path), x: @x, y: @y})

on "draw_background", ->
	lg.setColor(1, 1, 1, alpha.value)
	scale = math.min(sx, sy)
	if next(background)
		lg.draw(background.img,lg.getWidth!/2, lg.getHeight!/2,0, scale, scale, background.img\getWidth!/2, background.img\getHeight!/2)

on "draw_foreground", ->
	scale = math.min(sx, sy)
	pscale = math.min(px, py)
	offsetX = lg.getWidth!/2 - original_width*scale/2
	offsetY = lg.getHeight!/2 - original_height*scale/2
	_.each(images, =>
		lg.draw(@img, @x*pscale + offsetX, @y*pscale + offsetY, 0, scale, scale)
	)
