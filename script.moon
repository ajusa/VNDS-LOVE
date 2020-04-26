num = tonumber
export *
split = (inputstr, sep) ->
        if sep == nil then sep = "%s"
        return [str for str in string.gmatch(inputstr, "([^"..sep.."]+)")]

getvalue = (chunks, index) ->
	toret = {literal: nil, var: nil} --literal is string or num, var means we need to check memory
	rest = table.concat([item for i, item in ipairs chunks when i > index], " ")
	toret.literal = if rest\sub(1,1) == '"' then rest\sub(2, -2) --removes the quotation marks
	else if num(rest) then num(rest)
	else toret.var = rest
	return toret

parse = (line) ->
	c = split(line, " ") --each word is an element of c
	return if c[1]\find("bgload") then {type: "bgload", path: c[2], fadetime: num(c[3])}
	else if c[1]\find("setimg") then {type: "setimg", path: c[2], x: num(c[3]), y: num(c[4])}
	else if c[1]\find("sound") then {type: "sound", path: c[2], n: num(c[3])}
	else if c[1]\find("music") then {type: "music", path: c[2]}
	else if c[1]\find("text") then {type: "text", text: line\sub(6)}
	else if c[1]\find("choice") then {type: "choice", choices: split(line\sub(8), "|")}
	else if c[1]\find("setvar") then {type: "setvar", var: c[2], modifier: c[3], value: getvalue(c, 3)}
	else if c[1]\find("gsetvar") then {type: "gsetvar", var: c[2], modifier: c[3], value: getvalue(c, 3)}  
	else if c[1]\find("if") then {type: "if", var: c[2], modifier: c[3], value: getvalue(c, 3)}  
	else if c[1]\find("fi") then {type: "fi"}
	else if c[1]\find("jump") then {type: "jump", filename: c[2], label: c[3]}
	else if c[1]\find("delay") then {type: "delay", time: num(c[2])}
	else if c[1]\find("random") then {type: "random", var: num(c[2]), low: num(c[3], high: num(c[4]))} 
	else if c[1]\find("label") then {type: "label", label: c[2]} 
	else if c[1]\find("goto") then {type: "goto", label: c[2]}
	else if c[1]\find("cleartext") then {type: "cleartext", modifier: c[2]}

class Interpreter
	new: (base_dir, filename) =>
		@base_dir = base_dir
		@n = 0
		@MEM = {}
		@labels = {}
		@read_file(filename)

	interpolate: (text) =>
		for var in text\gmatch("$(%a+)")
			text = text\gsub("$"..var, tostring(@MEM[var]))
		return text

	--reads a file and returns a list of instructions
	read_file: (filename) =>
		file = io.open("#{@base_dir}/script/#{filename}", "r")
		@ins = {}
		for line in file\lines!
			trim = line\match "^%s*(.-)%s*$"
			continue if trim == '' or trim\sub(1, 1) == '#'
			table.insert(@ins, trim)
		for i, line in ipairs @ins --populate the label table
			command = parse(line)
			if command.type == "label" then @labels[command.label] = i
	choose: (value) =>
		@MEM["selected"] = value

	next_instruction: () =>
		@n += 1
		if not @ins[@n] then return nil
		ins = parse(@ins[@n])
		switch ins.type
			when "bgload", "setimg", "sound", "music", "delay", "cleartext"
				return ins --no processing needed
			when "setvar", "gsetvar"
				if not @MEM[ins.var] then @MEM[ins.var] = 0 --if the var isn't defined, assume it to be 0
				switch ins.modifier
					when "=" then @MEM[ins.var] = ins.value.literal
					when "+" then @MEM[ins.var] += ins.value.literal
					when "-" then @MEM[ins.var] -= ins.value.literal
			when "text"
				ins.text = @interpolate(ins.text)
			when "choice"
				ins.choices = [@interpolate(choice) for choice in *ins.choices]
			when "random"
				@MEM[ins.var] = math.random(ins.low, ins.high)
			when "if"
				if not @MEM[ins.var] then @MEM[ins.var] = 0 --if the var isn't defined, assume it to be 0
				lhs = @MEM[ins.var]
				if ins.value.var then ins.value.literal = @MEM[ins.value.var]
				rhs = ins.value.literal
				value = switch ins.modifier
					when "==" then lhs == rhs
					when "!=" then lhs ~= rhs
					when ">=" then lhs >= rhs
					when "<=" then lhs <= rhs
					when "<" then lhs < rhs
					when ">" then lhs > rhs
				if value then return @next_instruction!
				else
					count = 1
					while count > 0
						@n += 1
						next_ins = parse(@ins[@n])
						if next_ins.type == "if" then count += 1
						if next_ins.type == "fi" then count -= 1
					--our index is currently at the last fi, so we can call next instruction
					return @next_instruction!
			when "goto"
				@n = @labels[ins.label]
				return @next_instruction!
			when "jump"
				@n = 0
				@read_file(ins.filename)
				if ins.label then @n = @labels[ins.label]
				return @next_instruction!
			else return @next_instruction!
		return ins