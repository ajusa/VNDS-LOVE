export *
import dispatch, dispatch_often, on, remove, register from require 'event'
script = require "script"
Moan = require "lib/Moan"
pprint = require "lib/pprint"
Timer = require 'lib/timer'
interpreter = nil
require "audio"
require "debugging"
require "images"
require "text"
require "choose"
require "save"
require "input"
love.filesystem.setIdentity("VNDS-LOVE")
sx, sy = 0,0
px, py = 0,0
original_width, original_height = love.graphics.getWidth!,love.graphics.getHeight! 
--based on img.ini file in root of directory


love.resize = (w, h) ->
	sx, sy = w / original_width, h / original_height
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
		when "text" --still need to handle @, replace Moan with custom code for that
			if ins.text == "~" or ins.text == "!" or ins.text == "@" then next_msg!
			else dispatch "text", ins
		when "choice"
			dispatch "choice", ins
		when "delay"
			Timer.after(ins.frames/60, -> next_msg!)
		--when "cleartext"
		else
			dispatch ins.type, ins
			next_msg!
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
			dispatch "load_novel"
			contents = lfs.read(base_dir.."/img.ini")
			original_width = tonumber(contents\match("width=(%d+)"))
			original_height = tonumber(contents\match("height=(%d+)"))
			love.resize(love.graphics.getWidth!, love.graphics.getHeight!)
			next_msg!
		})
	if next(opts) == nil
		Moan.speak("", 
			{"No novels found in this directory:\n"..lfs.getSaveDirectory().."/novels", 
			"Add one and restart the program"})
	else dispatch "choose", opts
love.draw = ->
	dispatch_often "draw_background"
	dispatch_often "draw_foreground"
	dispatch_often "draw_text"
	Moan.draw!
	dispatch_often "draw_ui"
	dispatch_often "draw_debug"

love.update = (dt) ->
	dispatch_often "update", dt
	Moan.update(dt)
	Timer.update(dt)

is_fullscreen = false
love.keypressed = (key) ->
	dispatch_often "keyboard_input", key
	if key == "f11" then
		love.window.setFullscreen(is_fullscreen, "desktop")
		is_fullscreen = not is_fullscreen

love.gamepadpressed = (joy, button) -> dispatch_often "gamepad_input", button
	