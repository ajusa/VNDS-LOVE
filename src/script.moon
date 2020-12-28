require "util"
pprint = require "lib/pprint"
local *
load = (base_dir, fs, data = file: "main.scr") ->
	s = {:base_dir, :fs, locals: {}, globals: {}}
	s = _.extend(s, read_file(s, data.file))
	_.extend(s, data)
save = (s) -> {file: s.file, locals: s.locals, globals: s.globals, n: s.n-2}
mem = (s, key) -> s.locals if s.locals[key] ~= nil else s.globals
mem_type = (s, type) -> s.locals if type == "setvar" else s.globals
choose = (s, val) -> s.locals["selected"] = val
find_script = (s, file) ->
	files = love.filesystem.getDirectoryItems("#{s.base_dir}script/")
	for script_file in *files
		if script_file\lower! == file\lower!
			return script_file
read_file = (s, file) ->
	file = find_script(s, file)
	lines = _(split(s.fs("#{s.base_dir}script/#{file}"), "\n"))
	ins = lines\reject(=> @ == '' or @sub(1, 1) == '#')\map(parse)\value!
	labels = {ins.label, i for i, ins in ipairs ins when ins.type == "label" }
	{:file, :ins, :labels, n: 1}
interpolate = (s, text) ->
	for var in text\gmatch("$(%a+)")
		text = text\gsub("$"..var, tostring(mem(s, var)[var]))
	return text
ops = 
	"==": (a,b) -> a == b
	"!=": (a,b) -> a ~= b
	">=": (a,b) -> a >= b
	"<=": (a,b) -> a <= b
	"<": (a,b) -> a < b
	">": (a,b) -> a > b
	"+": (a,b) -> add(b, a)
	"-": (a,b) -> add(b, -a)
	"=": => @
	"~": => nil
	"if": 1, "fi": -1

next_instruction = (s) ->
	ins = s.ins[s.n]
	return s, ins if ins == nil --means novel is finished
	s.n += 1
	if ins.path then ins.path = s.base_dir..ins.path
	MEM = mem(s, ins.var) if ins.var
	switch ins.type
		when "bgload", "setimg", "sound", "music", "delay", "cleartext", "text", "choice"
			ins.text = interpolate(s, ins.text) if ins.type == "text"
			ins.choices = _.map(ins.choices,=> interpolate(s,@)) if ins.type == "choice"
			return s, ins
		when "setvar", "gsetvar"
			MEM = mem_type(s, ins.type)
			MEM[ins.var] = ops[ins.modifier](ins.value.literal, MEM[ins.var])
			if ins.modifer ==  "~" then MEM = {}
		when "random" then MEM[ins.var] = math.random(ins.low, ins.high)
		when "if"
			lhs = MEM[ins.var] or 0 --default to 0
			rhs = ins.value.literal or MEM[ins.value.var] or 0
			if not ops[ins.modifier](lhs, rhs)
				count = 1
				while count > 0
					s.n += 1
					count += ops[s.ins[s.n].type] or 0
		when "goto" then s.n = s.labels[ins.label]
		when "jump" --see if I can reuse load here
			s = _.extend(s, read_file(s, ins.filename))
			s.n = s.labels[ins.label] or s.n
	return next_instruction(s)
rest = (chunks, i) -> _.join(_.rest(chunks, i), " ")
getvalue = (chunks, index) ->
	r = rest(chunks, index)
	literal: if r\sub(1,1) == '"' then r\sub(2, -2) else num(r), var: r
add = (a, b) -> --adds two strings, two ints, or an int and a string
	if a == nil then b
	else if _.any({a,b}, => type(@) == "string") then a..b 
	else a + b
parse = (line) ->
	c = split(line, " ") --each word is an element of c
	c[1] = ascii(c[1]) --strip non-ascii values from the instruction, since it is english
	_.extend type: c[1], switch c[1]
		when "bgload" then path: "background/"..c[2], frames: num(c[3])
		when "setimg" then path: "foreground/"..c[2], x: num(c[3]), y: num(c[4])
		when "sound","music" then path: "sound/"..c[2], n: num(c[3]) --if n doesn't exist, nil
		when "text" then text: rest(c, 2) 
		when "choice" then choices: split(rest(c, 2), "|")
		when "gsetvar", "setvar", "if" then var: c[2], modifier: c[3], value: getvalue(c, 4)
		when "jump" then filename: c[2], label: c[3]
		when "delay" then frames: num(c[2])
		when "random" then var: c[2], low: num(c[3], high: num(c[4])) 
		when "label", "goto" then label: c[2] 
		when "cleartext" then modifier: c[2]
		else {} 
return {:load, :save, :next_instruction, :choose}
