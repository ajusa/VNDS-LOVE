import dispatch, on from require "event"
pprint = require "lib/pprint"
on "load", -> love.filesystem.remove('log.txt')
on "event", (name, ...) ->
	return if name == "load"
	log = "#{os.date('%H:%M:%S')} #{name} #{pprint.pformat(...)}\n"
	love.filesystem.append('log.txt', log)

should_debug = on "draw_debug", ->
	love.graphics.print(love.graphics.getWidth!, 1, 1)
	love.graphics.print(love.graphics.getHeight!,1, 20)
	love.graphics.print(sx, 1, 40)
	love.graphics.print(sy, 1, 60)

should_debug\remove!