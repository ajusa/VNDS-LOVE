Event = require 'lib/event'
pprint = require "lib/pprint"

audio = {}
Event.on("audio", (ins) ->
	audio[ins.type] or= {} 
	if ins.path\sub(-1) == "~" then Event.dispatch("clearAudio", ins.type)
	else if love.filesystem.getInfo(ins.path)
		file = with love.audio.newSource(ins.path, "stream")
			\setLooping(true) if ins.n == 0
			\play!
		u(audio[ins.type])\push(:file, n: ins.n or -1)
)

Event.on("clearAudio",(c) ->
	audio[c] = u(audio[c])\each((t) -> t.file\stop!)\select(() -> false)\value!
)

Event.on("update", () ->
	with u(audio)
		\values!\flatten!
		\reject((t) -> t.file\isPlaying! or t.n < 1)
		\each((t) ->
			t.file\play!
			t.n -= 1
			
		)
)