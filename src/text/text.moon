import colorify from require "text/text_color"
local *
buffer = {}
backlog = {}
lines = 3
if love._console_name == "3DS" then lines = 7
pad = 10
override_font = nil
update_font = ->
	if interpreter and not override_font
		font_path = interpreter.base_dir.."default.ttf"
		if lfs.getInfo(font_path) then love.text_font = lg.newFont(font_path, 32)
	else love.text_font = font
on "config", =>
	override_font = @font.override_font
	update_font!
on "resize", -> update_font!
on "restore", ->
	update_font!
	buffer = {} --clear text state when restoring
	backlog = {}
	if fast_forward
		fast_forward\remove!
		fast_forward = nil
done = () -> buffer = _.rest(buffer, lines + 1)
on "text", =>
	no_input = false
	if @text\sub(1, 1) == "@"
		@text = @text\sub(2, -1)
		no_input = true
	if @text == '' or @text == '!' then return
	add = word_wrap(@text, lg.getWidth! - 2*pad)
	for line in *add do table.insert(backlog, line)
	if #buffer == lines and not no_input
		buffer = add
	else
		buffer = concat(buffer, add)
		if no_input then dispatch "next_ins"
on "sfx", => table.insert(backlog, @)
fast_forward = nil
on "input", =>
	if @ == "a"
		if #buffer > lines then done!
		else dispatch "next_ins"
	else if @ == "y"
		if fast_forward then
			fast_forward\remove!
			fast_forward = nil
		else
			fast_forward = Timer.every(0.2, ->
				if #buffer > lines then done!
				else dispatch "next_ins"
			)
	else if @ == "x"
		last_ins = {}
		images = {}
		file, line = interpreter.file, interpreter.n
		cancelled = deepcopy(interpreter)
		while true
			interpreter, ins = script.next_instruction(interpreter)
			export interpreter = interpreter
			if interpreter.file == file and interpreter.n == line
				export interpreter = cancelled
				break
			switch ins.type
				when "setimg"
					table.insert(images, ins)
				when "text", "sound", "music", "bgload"
					last_ins[ins.type] = ins
					if ins.type == "bgload" then images = {}
			if ins.type == "choice"
				export interpreter = interpreter
				buffer = {} --clear text state when skipping
				for img in *images do dispatch "next_ins", img
				for key, value in *last_ins
					dispatch "next_ins", value
				dispatch "next_ins", ins
				break
	else if @ == "up"
		choices = {}
		-- choices = [text: t, action: -> for t in *backlog]
		for line in *backlog
			if line.file
				table.insert(choices, {
					text: "[SFX]"
					action: ->
						line.file\play!
						return false
				})
			else
				table.insert(choices, {text: line, action: ->})
		create_listbox(:choices, closable: true, selected: #choices)
	return false
on "draw_text", ->
	if #buffer > 0
		lg.setFont(love.text_font)
		w, h = lg.getWidth! - 2*pad, pad + (love.text_font\getHeight! + pad) * lines
		x, y = pad, lg.getHeight! - h - pad
		lg.setColor(.18,.204,.251, .8)
		lg.rectangle("fill", x, y, w, h)
		lg.setColor(1, 1, 1)
		y_pos = y + pad
		draw_buffer = _.first(buffer, lines)
		for line in *draw_buffer
			lg.print(line, 2*pad, y_pos)
			y_pos += love.text_font\getHeight! + pad
		lg.setFont(font)
word_wrap = (text, max_width) ->
	-- Come up with a way to handle a single word that is longer than the width
	-- This code is complex
	colored = colorify(text)
	colors, words, last_color = {}, {}, {}
	list = {{}}
	l = 1
	line = ""
	for i=2, #colored, 2 -- Skip over the colors themselves
		words = split(colored[i], " ")
		if #words > 0
			line = line..words[1]
			last_color = colored[i-1]
			for j=2, #words
				tmp = line.." "..words[j]
				if love.text_font\getWidth(tmp) > max_width
					table.insert(list[l], last_color)
					table.insert(list[l], line)
					l += 1
					table.insert(list, {})
					line = words[j]
				else line = tmp
			if #words > 1 then line = line.." "
		table.insert(list[l], last_color)
		table.insert(list[l], line)
		line = ""
	return list

concat = (t1,t2) ->
	for i=1,#t2 do t1[#t1+1] = t2[i]
	return t1
