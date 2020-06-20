-- have this handle all of the text related events
-- it should also handle choices if possible

buffer = {}
needs_input = false
pos = 1
speed = 0.1

on "text", =>
	return nil

on "choice", =>
	return nil

on "draw", =>
	return nil