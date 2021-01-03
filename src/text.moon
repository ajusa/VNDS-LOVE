import colorify from require "text_color"
local *
buffer = {}
lines = 3
if love._console_name == "3DS" then lines = 7
pad = 10
focused = false
done = () -> buffer = _.rest(buffer, lines + 1)
on "choose", => focused = false
on "text", =>
	focused = true
	no_input = false
	if @text\sub(1, 1) == "@"
		@text = @text\sub(2, -1)
		no_input = true
	add = word_wrap(@text, lg.getWidth! - 2*pad)
	if #buffer == lines and not no_input
		buffer = add
	else
		buffer = concat(buffer, add)
		if no_input then dispatch "next_ins"
on "input", =>
	if @ == "a" and focused
		if #buffer > lines then done!
		else dispatch "next_ins"
on "draw_text", ->
	if #buffer > 0
		w, h = lg.getWidth! - 2*pad, pad + (font\getHeight! + pad) * lines
		x, y = pad, lg.getHeight! - h - pad
		lg.setColor(.18,.204,.251, .8)
		lg.rectangle("fill", x, y, w, h)
		lg.setColor(1, 1, 1)
		y_pos = y + pad
		draw_buffer = _.first(buffer, lines)
		for line in *draw_buffer
			lg.print(line, 2*pad, y_pos)
			y_pos += font\getHeight! + pad
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
				if font\getWidth(tmp) > max_width
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
