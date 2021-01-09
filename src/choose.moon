choose = (i) -> () ->
		script.choose(interpreter, i)
		dispatch "next_ins"
on "choice", => --This is the VNDS choice event
	choices = [{text: c, action: choose(i)} for i, c in ipairs @choices]
	create_listbox {:choices, allow_menu: true}
