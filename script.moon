pprint = require('pprint')
num = tonumber
export *
split = (inputstr, sep) ->
        if sep == nil then sep = "%s"
        return [str for str in string.gmatch(inputstr, "([^"..sep.."]+)")]

getvalue = (chunks, index) ->
	toret = {literal: nil, var: nil} --literal is string or num, var means we need to check memory
	rest = table.concat([item for i, item in ipairs chunks when i > index], " ")
	if rest\sub(1,1) == '"' then toret.literal = rest\sub(2, -2) --removes the quotation marks
	else if num(rest) ~= nil then toret.literal = num(rest)
	else toret.var = rest
	return toret

parse = (line) ->
	chunks = split(line, " ")
	if chunks[1]\find("bgload")
		return {type: "bgload", path: chunks[2], fadetime: num(chunks[3])}
	if chunks[1]\find("setimg")
		return {type: "setimg", path: chunks[2], x: num(chunks[3]), y: num(chunks[4])}
	if chunks[1]\find("sound")
		return {type: "sound", path: chunks[2], n: num(chunks[3])}
	if chunks[1]\find("music")
		return {type: "music", path: chunks[2]}
	if chunks[1]\find("text")
		return {type: "text", text: line\sub(6)}
	if chunks[1]\find("choice")
		return {type: "choice", choices: split(line\sub(8), "|")}
	if chunks[1]\find("setvar")
		return {type: "setvar", var: chunks[2], modifier: chunks[3], value: getvalue(chunks, 3)}
	if chunks[1]\find("gsetvar")
		return {type: "gsetvar", var: chunks[2], modifier: chunks[3], value: getvalue(chunks, 3)}  
	if chunks[1]\find("if")
		return {type: "if", var: chunks[2], modifier: chunks[3], value: getvalue(chunks, 3)}  
	if chunks[1]\find("fi")
		return {type: "fi"}
	if chunks[1]\find("jump")
		return {type: "jump", filename: chunks[2], label: chunks[3]}
	if chunks[1]\find("delay")
		return {type: "delay", time: num(chunks[2])}
	if chunks[1]\find("random")
		return {type: "random", var: num(chunks[2]), low: num(chunks[3], high: num(chunks[4]))} 
	if chunks[1]\find("label")
		return {type: "label", label: chunks[2]} 
	if chunks[1]\find("goto")
		return {type: "goto", label: chunks[2]}
	if chunks[1]\find("cleartext")
		return {type: "cleartext", modifier: chunks[2]}

class Interpreter
	new: (filename) =>
		@n = 0
		@MEM = {}
		@ins = @read_file(filename)

	interpolate: (text) =>
		for var in text\gmatch("$(%a+)")
			text = text\gsub("$"..var, tostring(@MEM[var]))
		return text

	--reads a file and returns a list of instructions
	read_file: (filename) =>
		file = io.open(filename, "r")
		arr = {}
		for line in file\lines!
			trim = line\match "^%s*(.-)%s*$"
			continue if trim == '' or trim\sub(1, 1) == '#'
			table.insert(arr, trim)
		return arr

	next_instruction: () =>
		@n += 1
		if not @ins[@n] then return nil
		command = parse(@ins[@n])
		switch command.type
			when "bgload", "setimg", "sound", "music", "delay"
				return command --no processing needed
			when "setvar", "gsetvar"
				switch command.modifier
					when "=" then @MEM[command.var] = command.value.literal
					when "+" then @MEM[command.var] += command.value.literal
					when "-" then @MEM[command.var] -= command.value.literal
			when "text"
				command.text = @interpolate(command.text)
			when "choice"
				command.choices = [@interpolate(choice) for choice in *command.choices]
			when "random"
				@MEM[command.var] = math.random(command.low, command.high)
			when "jump"
				n = 0
				--ins = read_file(command.filename)
				if command.label then print("goto label")
			--else
				--here we choose not to return if possible, such as in the case of label

		return command

interpreter = Interpreter("test.scr")
while true
	i = interpreter\next_instruction!
	if not i then break
	pprint(i)
