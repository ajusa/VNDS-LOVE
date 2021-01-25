export *
import dispatch, dispatch_often, on, remove, register from require 'event'
import create_listbox from require 'listbox'
script = require "script"
pprint = require "lib/pprint"
Timer = require 'lib/timer'
profile = require 'lib/profile'
profile.setclock(love.timer.getTime)
lfs = love.filesystem
lg = love.graphics
interpreter = nil
-- require "lovelog"
require "audio"
require "debugging"
require "images"
require "text/text"
require "choose"
require "save"
require "input"
require "menu"
require "config"
os.setlocale("", "time") --Needed for the correct time
lfs.setIdentity("VNDS-LOVE")
sx, sy = 0,0
px, py = 0,0
original_width, original_height = lg.getWidth!,lg.getHeight!
-- on "input", =>
-- 	if @ == "y"
-- 		love.filesystem.write('profile.txt', profile.report(40))

font = nil
love.resize = (w, h) ->
	sx, sy = w / original_width, h / original_height
	px, py = w/256, h/192 --resolution of the DS
	font_size = 32 -- fix the font scaling to work based on resolution
	if w < 600 then font_size = 20
	lg.setNewFont(font_size)
	font = lg.getFont!
	dispatch "resize", {:sx, :sy, :px, :py}
next_msg = () ->
	intepreter, ins = script.next_instruction(interpreter)
	if ins.path --verify path exists before trying to run an instruction
		if ins.path\sub(-1) ~= "~" and not lfs.getInfo(ins.path)
			return next_msg!
	switch ins.type
		when "text"
			if ins.text == "~" then next_msg!
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
	-- love.window.setMode(400, 240)
	love.resize(lg.getWidth!, lg.getHeight!)
	dispatch "load"
	lfs.createDirectory("/novels")
	novels = lfs.getDirectoryItems("/novels")
	opts = {}
	media = font\getHeight! * 3
	for i,novel in ipairs novels
		base_dir = "/novels/"..novel.."/"
		if lfs.getInfo(base_dir, "file") then continue
		icons = {"icon-high.png", "icon-high.jpg", "icon.png", "icon.jpg"}
		thumbnails = {"thumbnail-high.png", "thumbnail-high.jpg", "thumbnail.png", "thumbnail.jpg"}
		preview = ->
		for icon in *icons
			if lfs.getInfo(base_dir..icon)
				img = lg.newImage(base_dir..icon)
				s = math.min(media/img\getWidth!, media/img\getHeight!)
				preview = (x, y) -> lg.draw(img, x, y, 0, s, s)
				break
		path = "~"
		for thumb in *thumbnails
			if lfs.getInfo(base_dir..thumb)
				path = base_dir..thumb
				break
		table.insert(opts, {
			text: novel,
			media: preview
			onchange: () -> dispatch "bgload", {:path}
			action: () ->
				files = lfs.getDirectoryItems(base_dir)
				with wrap _(files)
					\filter => @match("^.+(%..+)$") == ".zip"
					\map => @gsub(".zip", "")
					\reject => _.include(files, @)
					\each => lfs.mount(base_dir..@..".zip", base_dir)
				dispatch "load_slot", base_dir, false
		})
	if next(opts) == nil
		dispatch "text", {text: "No novels found in this directory: "}
		dispatch "text", {text: lfs.getSaveDirectory!.."/novels"}
		dispatch "text", {text: "Add one and restart the program"}
	else create_listbox(choices: opts, :media)
love.draw = ->
	dispatch_often "draw_background"
	dispatch_often "draw_foreground"
	dispatch_often "draw_text"
	dispatch_often "draw_choice"
	dispatch_often "draw_ui"
	dispatch_often "draw_debug"

if love._console_name == "3DS"
	love.draw = =>
		if @ ~= "bottom"
			dispatch_often "draw_text"
			dispatch_often "draw_choice"
		else
			dispatch_often "draw_background"
			dispatch_often "draw_foreground"
			dispatch_often "draw_ui"
			dispatch_often "draw_debug"
paused = 0
on "pause", -> paused += 1
on "play", -> paused -= 1
love.update = (dt) ->
	dispatch_often "update", dt
	if paused == 0 then Timer.update(dt)

is_fullscreen = false
love.keypressed = (key) ->
	dispatch_often "keyboard_input", key
	if key == "f11" then
		love.window.setFullscreen(is_fullscreen, "desktop")
		is_fullscreen = not is_fullscreen

love.gamepadpressed = (joy, button) -> dispatch_often "gamepad_input", button
	
