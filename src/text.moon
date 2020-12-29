local *
buffer = {}
speed = 0.1
lines = 3
line_number = 1
char = 1
pad = 10
focused = false
-- Timer.every(0.1, advance_msg)
done = () ->
	buffer = _.rest(buffer, lines + 1)
on "choose", =>
	focused = false
on "text", =>
	focused = true
	add = word_wrap(@text, lg.getWidth! - 2*pad)
	-- _.push(buffer, @text)
	buffer = concat(buffer, add)
	if #buffer > lines
		buffer = add
		-- done!
on "input", =>
	if @ == "a" and focused
		dispatch "next_ins" --Moan.keypressed("space")
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
	last_line = _.reduce(words, "", (a, e) ->
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
