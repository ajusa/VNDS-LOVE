pprint = require('pprint')
num = tonumber
export *
n = 0


--reads a file and returns a list of instructions
read_file = (filename) ->
	file = io.open("test.scr", "r")
	arr = {}
	for line in file\lines!
		trim = line\match "^%s*(.-)%s*$"
		continue if trim == '' or trim\sub(1, 1) == '#'
		table.insert(arr, trim)
	return arr



next_instruction = (choice) ->
	n += 1
	chunks = [word for word in ins[n]\gmatch("%S+")]
	if chunks[1]\find("bgload")
		return {type: "bgload", path: chunks[2], fadetime: num(chunks[3])}
	if chunks[1]\find("setimg")
		return {type: "setimg", path: chunks[2], x: num(chunks[3]), y: num(chunks[4])}
	if chunks[1]\find("sound")
		return {type: "sound", path: chunks[2], n: num(chunks[3])}
	if chunks[1]\find("music")
		return {type: "music", path: chunks[2]}
	if chunks[1]\find("text")
		--needs to do the text interpolation with $
		return {type: "text", text: ins[n]\sub(6)}
	if chunks[1]\find("choice")
		print("wip")   
	if chunks[1]\find("setvar")
		print("wip")
	if chunks[1]\find("gsetvar")
		print("wip")    
	if chunks[1]\find("if")
		print("wip")
	if chunks[1]\find("fi")
		print("wip")
	if chunks[1]\find("jump")
		print("wip") 
	if chunks[1]\find("delay")
		print("wip")  
	if chunks[1]\find("random")
		print("wip")   
	if chunks[1]\find("label")
		print("wip")
	if chunks[1]\find("goto")
		print("wip")
	return {wip: "wip"}

ins = read_file("test.scr")
for line in *ins 
	pprint(next_instruction!)
