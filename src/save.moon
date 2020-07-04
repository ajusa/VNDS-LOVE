json = require "lib/json"
local *
input_handler = => 
	if @ == "x"
		saving\register!
		save_table = {interpreter: script.save(interpreter)}
		dispatch_often "save", save_table
		with love.filesystem.newFile(interpreter.base_dir.."/save.json", "w")
			\write(json.encode(save_table))
			\flush!
			\close!
		Timer.after(1.5, -> saving\remove!)

on "load_novel", ->
	save = love.filesystem.read(interpreter.base_dir.."/save.json")
	if save
		save_table = json.decode(save)
		dispatch "restore", save_table
		export interpreter = script.load(interpreter.base_dir, interpreter.fs, save_table.interpreter)
	on "input", input_handler
		
saving = on "draw_ui", ->
	love.graphics.print("Saving...", 5,5)

saving\remove!