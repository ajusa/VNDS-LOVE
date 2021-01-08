input_event = on "input", (input) ->
	if input == "start"
		create_listbox({
			choices: {
				{"Quit", love.event.quit}
			},
			closable: true
		})
