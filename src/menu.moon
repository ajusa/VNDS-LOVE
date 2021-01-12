input_event = on "input", (input) ->
	if input == "start"
		create_listbox({
			choices: {
				{text: "Save", action: -> dispatch "save_slot"}
				{text: "Load", action: -> dispatch "load_slot", interpreter.base_dir}
				{text: "Settings", action: -> dispatch "config_menu"}
				{text: "Main Menu", action: -> love.event.quit("restart")}
				{text: "Quit", action: love.event.quit}
			},
			closable: true
		})
