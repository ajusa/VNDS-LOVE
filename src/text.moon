-- have this handle all of the text related events
local *
buffer = {}
needs_input = false
pos = 1
speed = 0.1
lines = 4
font = lg.getFont!
text_buffer = ""
on "text", =>
	_.push(buffer, @text)
	text_buffer ..= @text.." "
	pprint(word_wrap(text_buffer, 300))
	Moan.speak("Text", {@text}, {oncomplete: () -> dispatch "next_ins"})
on "input", =>
	if @ == "a" then Moan.keypressed("space")
	else Moan.keypressed(@)

on "draw_text", ->
	_(buffer)\each(=>
		--lg.print(@, 1, 1)
	)
	
word_wrap = (text, max_width) ->
	list = {text}
	words = split(text, " ")
	i = 1
	len = 1
	while i + len - 1 <= #words 
		line = _(words)\slice(i, len)\join(" ")\value!
		width = font\getWidth(line)
		len += 1
		if width <= max_width
			list[#list] = line
		else 
			_.push(list, "")
			i += len - 2
			len = 1
	return list

