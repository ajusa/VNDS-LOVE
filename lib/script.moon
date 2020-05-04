require "lib/util"
pprint = require "lib/pprint"
export *
add = (a, b) -> --adds two strings, two ints, or an int and a string
	if a == nil and type(b) == "string" then a = ""
	if a == nil and type(b) == "number" then a = 0
	return if type(a) == "string" or type(b) == "string" then tostring(a) .. tostring(b)
	else a + b

rest = (c, index) -> table.concat([item for i, item in ipairs c when i > index], " ")
getvalue = (chunks, index) ->
	toret = {literal: nil, var: nil} --literal is string or num, var means we need to check memory
	remain = rest(chunks, index)
	toret.literal = if remain\sub(1,1) == '"' then remain\sub(2, -2) --removes the quotation marks
	else if num(remain) then num(remain)
	else toret.var = remain
	return toret

parse = (line) ->
	c = split(line, " ") --each word is an element of c
	return if c[1]\find("bgload") then {type: "bgload", path: "background/"..c[2], fadetime: num(c[3])}
	else if c[1]\find("setimg") then {type: "setimg", path: "foreground/"..c[2], x: num(c[3]), y: num(c[4])}
	else if c[1]\find("sound") then {type: "sound", path: "sound/"..c[2], n: num(c[3])}
	else if c[1]\find("music") then {type: "music", path: "sound/"..c[2]}
	else if c[1]\find("text") then {type: "text", text: line\sub(6)}
	else if c[1]\find("choice") then {type: "choice", choices: split(line\sub(8), "|")}
	else if c[1]\find("gsetvar") then {type: "gsetvar", var: c[2], modifier: c[3], value: getvalue(c, 3)}  
	else if c[1]\find("setvar") then {type: "setvar", var: c[2], modifier: c[3], value: getvalue(c, 3)}
	else if c[1]\find("if") then {type: "if", var: c[2], modifier: c[3], value: getvalue(c, 3)}  
	else if c[1]\find("fi") then {type: "fi"}
	else if c[1]\find("jump") then {type: "jump", filename: c[2], label: c[3]}
	else if c[1]\find("delay") then {type: "delay", time: num(c[2])}
	else if c[1]\find("random") then {type: "random", var: num(c[2]), low: num(c[3], high: num(c[4]))} 
	else if c[1]\find("label") then {type: "label", label: c[2]} 
	else if c[1]\find("goto") then {type: "goto", label: c[2]}
	else if c[1]\find("cleartext") then {type: "cleartext", modifier: c[2]}

class Interpreter
	new: (base_dir, filename, filesystem) => 
		@filesystem = filesystem --a way to access filesystem for script files
		@base_dir = base_dir
		@n = 1
		@global = {}
		@vars = {}
		@labels = {}
		@current_file = ""
		@read_file(filename)
	save: () => {global: @global, vars: @vars, n: @n, current_file: @current_file}
	load: (save) =>
		@read_file(save.current_file)
		@global = save.global
		@vars = save.vars
		@n = save.n - 1 --want to save the current action
	interpolate: (text) =>
		for var in text\gmatch("$(%a+)")
			MEM = @getMem(var)
			text = text\gsub("$"..var, tostring(MEM[var]))
		return text

	--reads a file and returns a list of instructions
	read_file: (filename) =>
		lines = split(self.filesystem("#{@base_dir}/script/#{filename}"), "\n")
		@ins = {} --clear instruction table
		@current_file = filename --need this to make a save file
		for line in *lines
			trim = line\match "^%s*(.-)%s*$"
			continue if trim == '' or trim\sub(1, 1) == '#'
			table.insert(@ins, trim)
		for i, line in ipairs @ins --populate the label table
			command = parse(line)
			if command.type == "label" then @labels[command.label] = i
	choose: (value) =>
		@vars["selected"] = value
	getMem: (key) => --returns which memory table the variable belongs to
		if @global[key] ~= nil then return @global
		return @vars
	next_instruction: () =>
		if not @ins[@n] then return nil
		ins = parse(@ins[@n])
		@n += 1
		if ins.path then ins.path = "#{@base_dir}/#{ins.path}"
		MEM = if ins.var then @getMem(ins.var) else {}
		switch ins.type
			when "bgload", "setimg", "sound", "music", "delay", "cleartext"
				return ins --no processing needed
			when "setvar", "gsetvar"
				if ins.type == "gsetvar" then MEM = @global
				switch ins.modifier
					when "=" then MEM[ins.var] = ins.value.literal
					when "+" then MEM[ins.var] = add(MEM[ins.var], ins.value.literal)
					when "-" then MEM[ins.var] = add(MEM[ins.var], -ins.value.literal)
					when "~" then 
						if ins.type == "setvar" then @vars = {} --clear the table
						else @global = {} 
			when "text"
				ins.text = @interpolate(ins.text)
			when "choice"
				ins.choices = [@interpolate(choice) for choice in *ins.choices]
			when "random"
				MEM[ins.var] = math.random(ins.low, ins.high)
				return @next_instruction!
			when "if"
				if ins.value.var then 
					if MEM[ins.value.var] == nil then MEM[ins.value.var] = 0 --default to 0
					ins.value.literal = MEM[ins.value.var]
				if MEM[ins.var] == nil then MEM[ins.var] = 0 --default to 0
				lhs = MEM[ins.var]
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
						count += switch parse(@ins[@n]).type
							when "if" then 1
							when "fi" then -1
							else 0
					return @next_instruction! --our index is currently at the last fi
			when "goto"
				@n = @labels[ins.label]
				return @next_instruction!
			when "jump"
				@n = 1
				@read_file(ins.filename)
				if ins.label then @n = @labels[ins.label]
				return @next_instruction!
			else return @next_instruction!
		return ins