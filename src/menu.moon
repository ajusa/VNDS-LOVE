input_event = on "input", (input) ->
	if input == "start"
		dispatch "pause"
		create_listbox({
			choices: {
				{text: "Save\ntest", action: -> dispatch "save_slot"}
				{text: "Load", action: -> dispatch "load_slot", interpreter.base_dir}
				{text: "Quit", action: love.event.quit}
			},
			closable: true
			onclose: -> dispatch "play"
		})
