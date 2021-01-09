json = require "lib/json"
local *
on "save_slot", ->
	base_dir = interpreter.base_dir
	write_slot = (fn) ->
		save_table = {interpreter: script.save(interpreter)}
		dispatch_often "save", save_table
		with love.filesystem.newFile(fn, "w")
			\write(json.encode(save_table))
			\flush!
			\close!
		return false
	slot_ui(base_dir, write_slot, write_slot)
on "load_slot", (base_dir) ->
	slot_ui(base_dir,
		(_, save) ->
			dispatch "restore", save
			export interpreter = script.load(base_dir, lfs.read, save.interpreter)
			return true
		->
			dispatch "restore", {}
			export interpreter = script.load(base_dir, lfs.read)
			dispatch "next_ins"
			return true
	)
slot_ui = (base_dir, existing_slot, new_slot) ->
	choices = {}
	media = font\getHeight! * 3
	for i = 1, 10
		fn = base_dir.."/save#{i}.json"
		info = lfs.getInfo(fn)
		if info
			save = json.decode(lfs.read(fn))
			bg_path = save.background.path
			preview = ->
			if save.background and save.background.path
				img = lg.newImage(save.background.path)
				s = math.min(media/img\getWidth!, media/img\getHeight!)
				preview = (x, y) -> lg.draw(img, x, y, 0, s, s)
			table.insert(choices, {
				text: "Save #{i}\n#{os.date("%x %H:%M", info.modtime)}"
				action: -> existing_slot(fn, save)
				media: preview
			})
		else
			table.insert(choices, {
				text: "Save #{i} --"
				action: -> new_slot(fn)
			})
	create_listbox({:choices, closable: true, :media})
