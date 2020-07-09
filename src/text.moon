-- have this handle all of the text related events
local *
buffer = {}
needs_input = false
pos = 1
speed = 0.1
lines = 4
font = lg.getFont!
text_buffer = ""
done = () ->
	buffer = _.rest(buffer, lines)
	text_buffer = _.join(buffer, " ")
on "text", =>
	_.push(buffer, @text)
	text_buffer ..= @text.." "
	buffer = word_wrap(text_buffer, 300)
	Moan.speak("Text", {@text}, {oncomplete: () -> dispatch "next_ins"})
on "input", =>
	if @ == "a" then Moan.keypressed("space")

on "draw_text", ->
	_(buffer)\each(=>
		--lg.print(@, 1, 1)
	)
	
word_wrap = (text, max_width) ->
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

