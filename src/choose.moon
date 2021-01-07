local *
on "choice", => --This is the VNDS choice event
	choices = {}
	for i,choice in ipairs @choices
		table.insert(choices, {choice,
		() ->
			script.choose(interpreter, i)
			dispatch "next_ins"
		})
	create_listbox {:choices}
