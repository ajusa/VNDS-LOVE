require "lib/script"
require "lib/audio"
Moan = require "lib/Moan"
pprint = require "lib/pprint"
json = require "lib/json"
Event = require 'lib/event'
lovebird = require "lib/lovebird"
lovebird.whitelist = nil
export *
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

love.filesystem.setIdentity("VNDS-LOVE")
interpreter = nil
background = nil
images = {}
saving = 0.0
sx, sy = 0,0
debug = false
px, py = 0,0
original_width, original_height = love.graphics.getWidth!,love.graphics.getHeight! 
--based on img.ini file in root of directory

save_game = () ->
	save_table = interpreter\save! 
	save_table.images = {k,v for k,v in pairs images when k != "img"} --don't copy over image data
	save_table.images = images
	save_table.background = {path: background.path}
	file = love.filesystem.newFile(interpreter.base_dir.."/save.json", "w")
	file\write(json.encode(save_table))
	file\flush!
	file\close!
	saving = 1.5

load_game = () ->
	if love.filesystem.getInfo(interpreter.base_dir.."/save.json")
		save = love.filesystem.read(interpreter.base_dir.."/save.json")
		save_table = json.decode(save)
		interpreter\load(save_table)
		background = {path: save_table.background.path, img: love.graphics.newImage(save_table.background.path)}
		images = save_table.images
		for image in *images do image.img = love.graphics.newImage(image.path)

love.resize = (w, h) ->
	sx = w / original_width
	sy = h / original_height
	px, py = w/256, h/192 --resolution of the DS
	font_size = 32 -- fix the font scaling to work based on resolution
	if w < 600 then font_size = 20
	Moan.font = love.graphics.newFont(font_size)
	love.graphics.setNewFont(font_size)

next_msg = () ->
	ins = interpreter\next_instruction!
	if ins.path and love._console_name == "3DS" then ins.path = ins.path\gsub(".jpg", ".t3x")
	if ins.path and not ins.path\sub(-1) == "~" and not love.filesystem.getInfo(ins.path) then next_msg!
	switch ins.type
		when "bgload"
			if ins.path\sub(-1) == "~" then background = nil
			else if love.filesystem.getInfo(ins.path)
				background = {path: ins.path, img: love.graphics.newImage(ins.path)}
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
				table.insert(images, {path: ins.path, img: love.graphics.newImage(ins.path), x: ins.x, y: ins.y})
				next_msg!
		when "sound", "music"
			Event.dispatch("audio", ins)
			next_msg!
		--when "delay"
		--when "cleartext"
			else next_msg!

love.load = ->
	--love.window.setMode(1280, 720)
	love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
	lfs = love.filesystem
	lfs.createDirectory("/novels")
	opts = {}
	for i,choice in ipairs lfs.getDirectoryItems("/novels")
		table.insert(opts, {choice, 
		() -> 
			base_dir = "/novels/"..choice.."/"
			files = lfs.getDirectoryItems(base_dir)
			zips = [f for f in *files when f\match("^.+(%..+)$") == ".zip"]
			for zip in *zips
				folder = zip\gsub(".zip", "") --remove .zip
				if u.include(files, () -> folder) then continue
				else lfs.mount(base_dir..zip, base_dir)

			interpreter = Interpreter(base_dir, "main.scr", lfs.read)
			load_game!
			undo_choice_ui!
			contents = lfs.read(base_dir.."/img.ini")
			original_width = tonumber(contents\match("width=(%d+)"))
			original_height = tonumber(contents\match("height=(%d+)"))
			love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
			next_msg!
		})
	choice_ui!
	if next(opts) == nil
		Moan.speak("", 
			{"No novels found in this directory:\n"..lfs.getSaveDirectory().."/novels", 
			"Add one and restart the program"})
	else Moan.speak("", {"Novel Directory:\n"..lfs.getSaveDirectory().."/novels", "Select a novel"}, {options: opts})
	--next_msg!
love.draw = ->
	if background then 
		love.graphics.draw(background.img,0,0,0,sx,sy)
	for fg in *images do love.graphics.draw(fg.img, fg.x*px, fg.y*py, 0, sx, sy)
	if saving > 0.0 then do love.graphics.print("Saving...", 5,5)
    Moan.draw!
    if debug 
		love.graphics.print(love.graphics.getWidth!, 1, 1)
		love.graphics.print(love.graphics.getHeight!,1, 20)
		love.graphics.print(sx, 1, 40)
		love.graphics.print(sy, 1, 60)

love.update = (dt) ->
	Event.dispatch("update", dt)
	lovebird.update()
	Moan.update(dt)
	if saving > 0.0 then saving -= dt
love.keypressed = (key) ->
	if key == "x" and interpreter then save_game!
	Moan.keypressed(key)

love.gamepadpressed = (joy, button) ->
	if button == "a" then Moan.keypressed("space")
	else if button == "dpup" then Moan.keypressed("up")
	else if button == "dpdown" then Moan.keypressed("down")
	else if button == "x" 
		saving = 100.0
		save_game!

