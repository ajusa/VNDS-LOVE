sound = nil
music = nil
clear = =>
	if @ != nil
		@.file\stop!
		@ = nil
exists = => @\sub(-1) != "~" and love.filesystem.getInfo(@)
on "sound", =>
	clear sound
	if exists @path
		file = with love.audio.newSource(@path, "stream")
			\setLooping(@n == 0)
			\play!
		sound = {:file, n: @n or -1}
on "music", =>
	clear music
	if exists @path
		file = with love.audio.newSource(@path, "stream")
			\setLooping(true)
			\play!
		music = {:file}
on "update", ->
	if sound != nil and not sound.file\isPlaying! and sound.n > 0
		sound.file\play!
		sound.n -= 1
