require "script"

interpreter = Interpreter("/home/ajusa/Downloads/fsn", "main.scr")
while true
	command = interpreter\next_instruction!
	if not command then break
	switch command.type
		when "text"
			if command.text == "~" or command.text == "!" then print()
			else print(command.text)
		when "choice"
			for i, choice in ipairs command.choices
				print(i, choice)
			resp = io.read()
			interpreter\choose(tonumber(resp))