Event = require 'lib/event'
pprint = require 'lib/pprint'
audio = {}
Event.on "audio", =>
	audio[@type] or= {} 
	if @path\sub(-1) == "~" then Event.dispatch("clearAudio", @type)
	else if love.filesystem.getInfo(@path)
		file = with love.audio.newSource(@path, "stream")
			\setLooping(@n == 0)
			\play!
		_(audio[@type])\push({:file, n: @n or -1})
Event.on "clearAudio", => audio[@] = _.map(audio[@], => @file\stop!)
Event.on "update", ->
	with wrap _(audio)\values!\flatten!
		\reject => @file\isPlaying! or @n < 1
		\each =>
			@file\play!
			@n -= 1