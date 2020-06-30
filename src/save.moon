json = require "lib/json"
saving = 0.0
on "input", =>
	if @ == "x"
		saving = 100
		save_table = {interpreter: script.save(interpreter)}
		dispatch_often "save", save_table
		with love.filesystem.newFile(interpreter.base_dir.."/save.json", "w")
			\write(json.encode(save_table))
			\flush!
			\close!
		saving = 1.5

on "load_novel", ->
	if love.filesystem.getInfo(interpreter.base_dir.."/save.json")
		save = love.filesystem.read(interpreter.base_dir.."/save.json")
		save_table = json.decode(save)
		dispatch "restore", save_table
		export interpreter = script.load(interpreter.base_dir, interpreter.fs, save_table.interpreter)
on "draw_ui", ->
	if saving > 0.0 then do love.graphics.print("Saving...", 5,5)

on "update", =>
	if saving > 0.0 then saving -= @