sound = {}
music = {}
on "save", =>
	@music = {path: music.path}
	@sound = {path: sound.path, n: sound.n}

on "restore", =>
	if @music and @sound
		if @music.path then dispatch "music", @music
		if @sound.path then dispatch "sound", @sound
clear = =>
	if next(@)
		@file\stop!
		@ = {}
exists = => @\sub(-1) != "~"
on "sound", =>
	clear sound
	if exists(@path) and @n != 0
		success, file = pcall(love.audio.newSource, @path, "stream")
		if success
			file\setLooping(@n == -1)
			file\play!
			sound = {path: @path, :file, n: @n or 0}
on "music", =>
	clear music
	if exists @path
		success, file = pcall(love.audio.newSource, @path, "stream")
		if success
			file\setLooping(true)
			file\play!
			music = {path: @path, :file}
on "update", ->
	if next(sound) and not sound.file\isPlaying! and sound.n > 1
		sound.file\play!
		sound.n -= 1
