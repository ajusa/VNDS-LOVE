pprint = require "lib/pprint"
_G.love = {
	filesystem: {
		getDirectoryItems: => {""}
	}
}
script = require "script"
run_scr = (code) ->
	i = script.load("", -> code)
	instructions = {}
	while true
		i, ins = script.next_instruction(i)
		if ins then table.insert(instructions, ins)
		else break
	return i, instructions

describe "VNDS Interpreter Tests", ->
	describe "Assignment", ->
		it "Local Number Assignment", ->
			i = run_scr('setvar test = 5')
			assert.are.equal(i.locals["test"], 5)
			i = run_scr('setvar test = 5.0')
			assert.are.equal(i.locals["test"], 5.0)
			i = run_scr('setvar test = 5.01')
			assert.are.equal(i.locals["test"], 5.01)
		it "Local String Assignment", ->
			i = run_scr('setvar test = "test, string"')
			assert.are.equal(i.locals["test"], "test, string")
		it "Global Number Assignment", ->
			i = run_scr('gsetvar test = 5')
			assert.are.equal(i.globals["test"], 5)
			i = run_scr('gsetvar test = 5.0')
			assert.are.equal(i.globals["test"], 5.0)
			i = run_scr('gsetvar test = 5.01')
			assert.are.equal(i.globals["test"], 5.01)
		it "Global String Assignment", ->
			i = run_scr('gsetvar test = "test, string"')
			assert.are.equal(i.globals["test"], "test, string")
	describe "Operations", ->
		it "Number Addition", ->
			i = run_scr('setvar test + 2')
			assert.are.equal(i.locals["test"], 2)
			i, ins = run_scr('
				setvar test + 2
				setvar test + 4
			')
			assert.are.equal(i.locals["test"], 6)
		it "Number Subtraction", ->
			i = run_scr('setvar test - 2')
			assert.are.equal(i.locals["test"], -2)
			i = run_scr('
				setvar test + 2
				setvar test - 4
			')
			assert.are.equal(i.locals["test"], -2)
		it "String Concat", ->
			i = run_scr('setvar test + "hello there"')
			assert.are.equal(i.locals["test"], "hello there")
			i = run_scr('
				setvar test + "hello "
				setvar test + "there"
			')
			assert.are.equal(i.locals["test"], "hello there")
		it "Number and String Concat", ->
			i = run_scr('
				setvar test + 5
				setvar test + " there"
			')
			assert.are.equal(i.locals["test"], "5 there")

	describe "Text Interpolation", ->
		it "Number Interpolation", ->
			i, ins = run_scr('
				setvar test = 2
				text hello there $test
			')
			assert.are.equal(ins[1].text, "hello there 2")
		it "String Interpolation", ->
			i, ins = run_scr('
				setvar test = "hello"
				text $test there 2
			')
			assert.are.equal(ins[1].text, "hello there 2")
			i, ins = run_scr('
				setvar strS[1903] = "Stay in bed."
				setvar strS[1904] = "Get up."
				choice $strS[1903]|$strS[1904]
			')
			assert.are.equal(ins[1].choices[1], "Stay in bed.")

	describe "Labels", ->
		it "Single File", ->
			i, ins = run_scr('
				goto hello
				text not run
				label hello
				text run
			')
			assert.are.equals(ins[1].text, "run")
		it "Label Interpolation", ->
			i, ins = run_scr('
				setvar RETLABEL = "hello"
				goto $RETLABEL
				text not run
				label hello
				text run
			')
			assert.are.equals(ins[1].text, "run")


	--todo 
		--nested if statements
		--different comparison operators
		--multi file labels
		--selection
		--Saving format
