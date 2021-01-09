puremagic = require "lib/puremagic"
local *
sound = {}
music = {}
filetype = {
	"audio/x-aiff": "file.aiff"
	"audio/x-flac": "file.flac"
	"audio/mp4": "file.m4a"
	"audio/x-matroska": "file.mka"
	"audio/mpeg": "file.mp3"
	"audio/vorbis": "file.ogg"
	"audio/ogg": "file.ogg"
	"audio/x-wav": "file.wav"
	"audio/webm": "file.webm"
	"audio/x-ms-wma": "file.wma"
}
load_source = =>
	success, source = pcall(love.audio.newSource, @, "stream")
	if success then return source
	mime = puremagic.via_path(@)
	original = love.filesystem.newFileData(@)
	actual = love.filesystem.newFileData(original\getString(), filetype[mime])
	return love.audio.newSource(actual, "stream")

on "save", =>
	@music = {path: music.path}
	@sound = {path: sound.path, n: sound.n}

on "restore", =>
	clear music
	clear sound
	if @music and @music.path then dispatch "music", @music
	if @sound and @sound.path then dispatch "sound", @sound
clear = =>
	if next(@)
		@file\stop!
		@ = {}
exists = => @\sub(-1) != "~"
on "sound", =>
	clear sound
	if exists(@path) and @n != 0
		file = with load_source(@path)
			\setLooping(@n == -1)
			\play!
		sound = {path: @path, :file, n: @n or 0}
on "music", =>
	clear music
	if exists @path
		file = with load_source(@path)
			\setLooping(true)
			\play!
		music = {path: @path, :file}
on "update", ->
	if next(sound) and not sound.file\isPlaying! and sound.n > 1
		sound.file\play!
		sound.n -= 1
