import dispatch, dispatch_often, on from require 'event'
script = require "script"
require "audio"
require "debugging"
require "images"
require "text"
Moan = require "lib/Moan"
pprint = require "lib/pprint"
json = require "lib/json"
Timer = require 'lib/timer'
export *
love.filesystem.setIdentity("VNDS-LOVE")
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
interpreter = nil
saving = 0.0
sx, sy = 0,0
px, py = 0,0
original_width, original_height = love.graphics.getWidth!,love.graphics.getHeight! 
--based on img.ini file in root of directory

save_game = () ->
	save_table = {interpreter: script.save(interpreter)}
	dispatch_often "save", save_table
	with love.filesystem.newFile(interpreter.base_dir.."/save.json", "w")
		\write(json.encode(save_table))
		\flush!
		\close!
	saving = 1.5

load_game = () ->
	if love.filesystem.getInfo(interpreter.base_dir.."/save.json")
		save = love.filesystem.read(interpreter.base_dir.."/save.json")
		save_table = json.decode(save)
		dispatch "restore", save_table
		interpreter = script.load(interpreter.base_dir, interpreter.fs, save_table.interpreter)

love.resize = (w, h) ->
	sx = w / original_width
	sy = h / original_height
	px, py = w/256, h/192 --resolution of the DS
	font_size = 32 -- fix the font scaling to work based on resolution
	if w < 600 then font_size = 20
	Moan.font = love.graphics.newFont(font_size)
	love.graphics.setNewFont(font_size)
	dispatch "resize", {:sx, :sy, :px, :py}
next_msg = () ->
	intepreter, ins = script.next_instruction(interpreter)
	if ins.path --verify path exists before trying to run an instruction
		if ins.path\sub(-1) ~= "~" and not love.filesystem.getInfo(ins.path) 
			return next_msg!
	switch ins.type
		when "bgload"
			dispatch "bgload", ins
			next_msg!
		when "text" --still need to handle @, replace Moan with custom code for that
			if ins.text == "~" or ins.text == "!" or ins.text == "@"
				next_msg!
				--Moan.speak("", {""}, {oncomplete: () -> next_msg!})
			else
				Moan.speak("Text", {ins.text}, {oncomplete: () -> next_msg!})
		when "choice"
			opts = {}
			for i,choice in ipairs ins.choices
				table.insert(opts, {choice, 
				() -> 
					script.choose(interpreter, i)
					undo_choice_ui!
					next_msg!
				})
			choice_ui!
			Moan.speak("", {"Choose\n"}, {options: opts})
		
		when "setimg"
			dispatch "setimg", ins
			next_msg!
		when "sound", "music"
			dispatch "audio", ins
			next_msg!
		when "delay"
			Timer.after(ins.frames/60, -> next_msg!)
		--when "cleartext"
		else next_msg!
on "next_ins", next_msg
love.load = ->
	--love.window.setMode(1280, 720)
	dispatch "load"
	love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
	lfs = love.filesystem
	lfs.createDirectory("/novels")
	opts = {}
	for i,choice in ipairs lfs.getDirectoryItems("/novels")
		table.insert(opts, {choice, 
		() -> 
			base_dir = "/novels/"..choice.."/"
			files = lfs.getDirectoryItems(base_dir)
			with wrap _(files)
				\filter => @match("^.+(%..+)$") == ".zip"
				\map => @gsub(".zip", "")
				\reject => _.include(files, @)
				\each => lfs.mount(base_dir..@..".zip", base_dir)

			interpreter = script.load(base_dir, lfs.read)
			load_game!
			undo_choice_ui!
			contents = lfs.read(base_dir.."/img.ini")
			original_width = tonumber(contents\match("width=(%d+)"))
			original_height = tonumber(contents\match("height=(%d+)"))
			love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
			next_msg!
		})
	choice_ui!
	dispatch "choose", opts
	if next(opts) == nil
		Moan.speak("", 
			{"No novels found in this directory:\n"..lfs.getSaveDirectory().."/novels", 
			"Add one and restart the program"})
	--else Moan.speak("", {"Novel Directory:\n"..lfs.getSaveDirectory().."/novels", "Select a novel"}, {options: opts})
	--next_msg!
love.draw = ->
	dispatch_often "draw_background"
	dispatch_often "draw_foreground"
	dispatch_often "draw_text"
	Moan.draw!
	dispatch_often "draw_ui"
	if saving > 0.0 then do love.graphics.print("Saving...", 5,5)
	dispatch_often "draw_debug"

love.update = (dt) ->
	dispatch_often "update", dt
	Moan.update(dt)
	Timer.update(dt)
	if saving > 0.0 then saving -= dt

is_fullscreen = false
love.keypressed = (key) ->
	dispatch_often "input", key
	if key == "f11" then 
		love.window.setFullscreen(is_fullscreen, "desktop")
		is_fullscreen = not is_fullscreen
	if key == "x" and interpreter then save_game!
	Moan.keypressed(key)

love.gamepadpressed = (joy, button) ->
	dispatch_often "input", button
	if button == "a" then Moan.keypressed("space")
	else if button == "dpup" then Moan.keypressed("up")
	else if button == "dpdown" then Moan.keypressed("down")
	else if button == "x" 
		saving = 100.0
		save_game!