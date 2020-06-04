Event = require 'lib/event'
pprint = require "lib/pprint"

audio = {}
Event.on("audio", (ins) ->
	audio[ins.type] or= {} 
	if ins.path\sub(-1) == "~" then Event.dispatch("clearAudio", ins.type)
    else if love.filesystem.getInfo(ins.path)
    	track = love.audio.newSource(ins.path, "stream")
    	track\setLooping(true) if ins.n == 0
    	track\play!
    	table.insert(audio[ins.type], {file: track, n: ins.n or -1})
)

Event.on("clearAudio",(channel) ->
	for track in *audio[channel] do track.file\stop!
	audio[channel] = {}
)

Event.on("update", () ->
	for channel in *audio
		loops = [track for track in channel when not track.file\isPlaying and track.n > 0]
		for loop in loops
			loop.file\play!
			loop.n -= 1
)