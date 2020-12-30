sound = nil
music = nil
clear = =>
	if @ != nil
		@.file\stop!
		@ = nil
exists = => @\sub(-1) != "~"
on "sound", =>
	clear sound
	if exists(@path) and @n != 0
		file = with love.audio.newSource(@path, "stream")
			\setLooping(@n == -1)
			\play!
		sound = {:file, n: @n or 0}
on "music", =>
	clear music
	if exists @path
		file = with love.audio.newSource(@path, "stream")
			\setLooping(true)
			\play!
		music = {:file}
on "update", ->
	if sound != nil and not sound.file\isPlaying! and sound.n > 1
		sound.file\play!
		sound.n -= 1
