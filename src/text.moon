local *
buffer = {}
needs_input = false
speed = 0.1
lines = 3
line_number = 1
char = 1
pad = 10
listen = false
-- Timer.every(0.1, advance_msg)
done = () ->
	buffer = _.rest(buffer, lines + 1)
on "choose", =>
	listen = false
on "text", =>
	listen = true
	_.push(buffer, @text)
	if #buffer > lines 
		needs_input = true
		done!
on "input", =>
	if @ == "a" and listen
		if needs_input 
			needs_input = false
		else
			dispatch "next_ins" --Moan.keypressed("space")
on "draw_text", ->
	if listen
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
