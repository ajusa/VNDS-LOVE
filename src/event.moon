Event = require 'lib/event'

dispatch = (name, ...) ->
	Event.dispatch "event", name, ...
	Event.dispatch(name, ...)

dispatch_often = Event.dispatch --ignored in logs

return {:dispatch, :dispatch_often, on: Event.on, hook: Event.hook}