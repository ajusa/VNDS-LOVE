local *
buffer = {}
lines = 3
if love._console_name == "3DS"
	lines = 7
pad = 10
focused = false
-- Timer.every(0.1, advance_msg)
done = () ->
	buffer = _.rest(buffer, lines + 1)
on "choose", =>
	focused = false
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
		if #buffer > lines
			done!
		else
			dispatch "next_ins"
on "draw_text", ->
	if focused
		w = lg.getWidth! - 2*pad
		h = pad + (font\getHeight! + pad) * lines
		x = pad
		y = lg.getHeight! - h - pad
		lg.setColor(.18,.204,.251, .8)
		lg.rectangle("fill", x, y, w, h)
		lg.setColor(1, 1, 1)
		visible_buffer = _.first(buffer, lines)
		_.reduce(visible_buffer, y + pad, (a, e) ->
			lg.print(e, 2*pad, a)
			return a + font\getHeight! + pad
		)
word_wrap = (text, max_width) ->
	-- Come up with a way to handle a single word that is longer than the width
	list = {}
	words = split(text, " ")
	last_line = _.reduce(_.rest(words), words[1], (a, e) ->
		line = a.." "..e
		if font\getWidth(line) > max_width
			_.push(list, a)
			a = e
			return e
		return line
	)
	_.push(list, last_line)
	return list

concat = (t1,t2) ->
	for i=1,#t2
		t1[#t1+1] = t2[i]
	return t1
