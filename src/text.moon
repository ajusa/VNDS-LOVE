-- have this handle all of the text related events
local *
buffer = {}
needs_input = false
pos = 1
speed = 0.1


on "text", =>
	Moan.speak("Text", {@text}, {oncomplete: () -> dispatch "next_ins"})
