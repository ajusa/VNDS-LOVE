local *
buffer = {}
needs_input = false
speed = 0.1
lines = 3
text_buffer = ""
line_number = 1
char = 1
pad = 10
-- Timer.every(0.1, advance_msg)
done = () ->
	pprint buffer
	buffer = _.rest(buffer, lines + 1)
	pprint buffer
	text_buffer = _.join(buffer, " ")
on "text", =>
	text_buffer ..= @text.." "
	--pprint text_buffer
	buffer = word_wrap(text_buffer, lg.getWidth! - 2*pad)
	if #buffer > lines 
		needs_input = true
	--Moan.speak("Text", {@text}, {oncomplete: () -> dispatch "next_ins"})
on "input", =>
	if @ == "a"
		if needs_input 
			done!
			needs_input = false
		else
			dispatch "next_ins" --Moan.keypressed("space")
on "draw_text", ->
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
	_.reduce(words, "", (a, e) ->
		line = a.." "..e
		if font\getWidth(line) > max_width
			_.push(list, a)
			return e
		return line
	)
	return list

