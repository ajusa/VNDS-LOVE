json = require "lib/json"
local *
media = 0
on "resize", -> media = font\getHeight! * 3
on "save_slot", ->
	base_dir = interpreter.base_dir
	write_slot = =>
		save_table = {interpreter: script.save(interpreter)}
		dispatch_often "save", save_table
		with love.filesystem.newFile(@data.fn, "w")
			\write(json.encode(save_table))
			\flush!
			\close!
		choice = preview_slot(@data.i, @data.fn, save_table, lfs.getInfo(@data.fn))
		@text = choice.text
		@action = write_slot
		@media = choice.media
		return false
	slot_ui(base_dir, write_slot, write_slot)
on "load_slot", (base_dir, closable = true) ->
	slot_ui(base_dir,
		=>
			dispatch "restore", @data.save
			export interpreter = script.load(base_dir, lfs.read, @data.save.interpreter)
			dispatch "next_ins"
			return true
		=>
			dispatch "restore", {}
			export interpreter = script.load(base_dir, lfs.read)
			dispatch "next_ins"
			return true
		closable
	)
preview_slot = (i, fn, save, info) ->
	bg_path = save.background.path
	preview = ->
	if save.background and save.background.path
		img = lg.newImage(save.background.path)
		s = math.min(media/img\getWidth!, media/img\getHeight!)
		preview = (x, y) -> lg.draw(img, x, y, 0, s, s)
	return {
		text: "Save #{i}\n#{os.date("%x %H:%M", info.modtime)}"
		media: preview
		data: {:save, :fn, :i}
	}
slot_ui = (base_dir, existing_slot, new_slot, closable = true) ->
	choices = {}
	for i = 1, 10
		fn = base_dir.."/save#{i}.json"
		info = lfs.getInfo(fn)
		if info
			save = json.decode(lfs.read(fn))
			choice = preview_slot(i, fn, save, info)
			choice.action = existing_slot
			table.insert(choices, choice)
		else
			table.insert(choices, {
				text: "Save #{i} --"
				action: new_slot
				data: {:fn, :i}
			})
	create_listbox({:choices, :closable, :media})
