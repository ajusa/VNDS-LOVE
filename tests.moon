require "lib/script"
pprint = require "lib/pprint"
run_scr = (code) -> 
	i = Interpreter("", "", -> code)
	instructions = {}
	while true
		ins = i\next_instruction!
		if ins then table.insert(instructions, ins)
		else break
	return i, instructions

describe "VNDS Interpreter Tests", ->
	describe "Assignment", ->
		it "Local Number Assignment", ->
			i, ins = run_scr('setvar test = 5')
			assert.are.equal(i.vars["test"], 5)
			i = run_scr('setvar test = 5.0')
			assert.are.equal(i.vars["test"], 5.0)
			i = run_scr('setvar test = 5.01')
			assert.are.equal(i.vars["test"], 5.01)
		it "Local String Assignment", ->
			i = run_scr('setvar test = "test, string"')
			assert.are.equal(i.vars["test"], "test, string")
		it "Global Number Assignment", ->
			i = run_scr('gsetvar test = 5')
			assert.are.equal(i.global["test"], 5)
			i = run_scr('gsetvar test = 5.0')
			assert.are.equal(i.global["test"], 5.0)
			i = run_scr('gsetvar test = 5.01')
			assert.are.equal(i.global["test"], 5.01)
		it "Global String Assignment", ->
			i = run_scr('gsetvar test = "test, string"')
			assert.are.equal(i.global["test"], "test, string")
	describe "Operations", ->
		it "Number Addition", ->
			i = run_scr('setvar test + 2')
			assert.are.equal(i.vars["test"], 2)
			i = run_scr('
				setvar test + 2
				setvar test + 4
			')
			assert.are.equal(i.vars["test"], 6)
		it "Number Subtraction", ->
			i = run_scr('setvar test - 2')
			assert.are.equal(i.vars["test"], -2)
			i = run_scr('
				setvar test + 2
				setvar test - 4
			')
			assert.are.equal(i.vars["test"], -2)
		it "String Concat", ->
			i = run_scr('setvar test + "hello there"')
			assert.are.equal(i.vars["test"], "hello there")
			i = run_scr('
				setvar test + "hello "
				setvar test + "there"
			')
			assert.are.equal(i.vars["test"], "hello there")
		it "Number and String Concat", ->
			i = run_scr('
				setvar test + 5
				setvar test + " there"
			')
			assert.are.equal(i.vars["test"], "5 there")

	describe "Text Interpolation", ->
		it "Number Interpolation", ->
			i, ins = run_scr('
				setvar test = 2
				text hello there $test
			')
			assert.are.equal(ins[2].text, "hello there 2")
		it "String Interpolation", ->
			i, ins = run_scr('
				setvar test = "hello"
				text $test there 2
			')
			assert.are.equal(ins[2].text, "hello there 2")

	describe "Labels", ->
		it "Single File", ->
			i, ins = run_scr('
				goto hello
				text not run
				label hello
				text run
			')
			assert.are.equals(ins[1].text, "run")

	--todo nested if statements, different comparison operators, mutli file labels, selection