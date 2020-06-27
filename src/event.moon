Event = require 'lib/event'

dispatch = (name, ...) ->
	Event.dispatch "event", name, ...
	Event.dispatch(name, ...)

dispatch_often = Event.dispatch --ignored in logs

remove = =>
	for e in *@ do 
		Event.dispatch "event", "remove_handler", e.name
		e\remove!
register = =>
	for e in *@ 
		Event.dispatch "event", "register_handler", e.name
		e\register!

return {:dispatch, :dispatch_often, on: Event.on, hook: Event.hook, :remove, :register}