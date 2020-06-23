Event = require 'lib/event'

dispatch = (name, ...) ->
	Event.dispatch "event", name, ...
	Event.dispatch(name, ...)

dispatch_often = Event.dispatch --ignored in logs

remove = =>
	for e in *@ do e\remove!
register = =>
	for e in *@ do e\register!

return {:dispatch, :dispatch_often, on: Event.on, hook: Event.hook, :remove, :register}