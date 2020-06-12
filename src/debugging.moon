import dispatch, on from require "event"
pprint = require "lib/pprint"
on "load", -> love.filesystem.remove('log.txt')
on "event", (name, ...) ->
	return if name == "load"
	log = "#{os.date('%H:%M:%S')} #{name} #{pprint.pformat(...)}\n"
	love.filesystem.append('log.txt', log)