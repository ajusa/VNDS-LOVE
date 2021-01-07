choose = (i) -> () ->
		script.choose(interpreter, i)
		dispatch "next_ins"
on "choice", => --This is the VNDS choice event
	choices = [{c, choose(i)} for i, c in ipairs @choices]
	create_listbox {:choices}
