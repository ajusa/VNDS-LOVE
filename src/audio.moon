audio = {}
audio_handler = =>
	audio[@type] or= {} 
	if @path\sub(-1) == "~" then dispatch "clear_audio", @type
	else if love.filesystem.getInfo(@path)
		file = with love.audio.newSource(@path, "stream")
			\setLooping(@n == 0)
			\play!
		_(audio[@type])\push({:file, n: @n or -1})
on "sound", audio_handler
on "music", audio_handler
on "clear_audio", => audio[@] = _.map(audio[@], => @file\stop!)
on "update", ->
	with wrap _(audio)\values!\flatten!
		\reject => @file\isPlaying! or @n < 1
		\each =>
			@file\play!
			@n -= 1