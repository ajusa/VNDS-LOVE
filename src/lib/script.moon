require "lib/util"
pprint = require "lib/pprint"
add = (a, b) -> --adds two strings, two ints, or an int and a string
	return b if a == nil
	return if type(a) == "string" or type(b) == "string" then tostring(a) .. tostring(b)
	else a + b
rest = (chunks, i) -> u.join(u.rest(chunks, i), " ")
getvalue = (chunks, index) ->
	r = rest(chunks, index)
	literal: if r\sub(1,1) == '"' then r\sub(2, -2) else num(r), var: r
parse = (line) ->
	c = split(line, " ") --each word is an element of c
	c[1] = ascii(c[1]) --strip non-ascii values from the instruction, since it is english
	ret = switch c[1]
		when "bgload" then path: "background/"..c[2], fadetime: num(c[3])
		when "setimg" then path: "foreground/"..c[2], x: num(c[3]), y: num(c[4])
		when "sound","music" then path: "sound/"..c[2], n: num(c[3]) --if n doesn't exist, nil
		when "text" then text: rest(c, 2) 
		when "choice" then choices: split(rest(c, 2), "|")
		when "gsetvar", "setvar", "if" then var: c[2], modifier: c[3], value: getvalue(c, 4)  
		when "jump" then filename: c[2], label: c[3]
		when "delay" then time: num(c[2])
		when "random" then var: c[2], low: num(c[3], high: num(c[4])) 
		when "label", "goto" then label: c[2] 
		when "cleartext" then modifier: c[2]
		else {} 
	ret.type = c[1]
	return ret

export class Interpreter
	new: (base_dir, filename, filesystem) => 
		@filesystem = filesystem --a way to access filesystem for script files
		@base_dir = base_dir 
		@global = {}
		@vars = {}
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
	read_file: (filename) => --reads a file and creates a list of instructions
		@n = 1
		lines = split(self.filesystem("#{@base_dir}script/#{filename}"), "\n")
		@current_file = filename --need this to make a save file
		@ins = [parse(l) for l in *lines when l ~= '' and l\sub(1, 1) ~= '#']
		@labels = {ins.label, i for i, ins in ipairs @ins when ins.type == "label" }
	choose: (value) =>  @vars["selected"] = value
	getMem: (key) => @global if @global[key] ~= nil else @vars
	getMemType: (type) => @vars if type == "setvar" else @global
	next_instruction: () =>
		ins = @ins[@n]
		return ins if ins == nil --means novel is finished
		@n += 1
		if ins.path then ins.path = @base_dir..ins.path
		MEM = @getMem(ins.var) if ins.var
		switch ins.type
			when "bgload", "setimg", "sound", "music", "delay", "cleartext", "text", "choice"
				ins.text = @interpolate(ins.text) if ins.type == "text"
				ins.choices = [@interpolate(c) for c in *ins.choices] if ins.type == "choice"
				return ins
			when "setvar", "gsetvar"
				MEM = @getMemType(ins.type)
				MEM[ins.var] = switch ins.modifier
					when "=" then ins.value.literal
					when "+" then add(MEM[ins.var], ins.value.literal)
					when "-" then add(MEM[ins.var], -ins.value.literal)
				if ins.modifer ==  "~" then MEM = {}
			when "random" then MEM[ins.var] = math.random(ins.low, ins.high)
			when "if"
				lhs = (MEM[ins.var] or 0) --default to 0
				rhs = (ins.value.literal or MEM[ins.value.var] or 0)
				value = switch ins.modifier
					when "==" then lhs == rhs
					when "!=" then lhs ~= rhs
					when ">=" then lhs >= rhs
					when "<=" then lhs <= rhs
					when "<" then lhs < rhs
					when ">" then lhs > rhs
				if not value   
					count = 1
					while count > 0
						@n += 1
						count += switch @ins[@n].type
							when "if" then 1
							when "fi" then -1
							else 0
			when "goto" then @n = @labels[ins.label]
			when "jump"
				@read_file(ins.filename)
				@n = (@labels[ins.label] or @n)
		return @next_instruction!