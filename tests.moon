require "lib/script"
pprint = require "lib/pprint"
run_scr = (code) -> 
	i = Interpreter("", "", -> code)
	while i\next_instruction! do "nothing"
	return i

describe "VNDS Parser Tests", ->
	describe "Assignment", ->
		it "Local Number Assignment", ->
			i = run_scr('setvar test = 5')
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
		it "Addition", ->
			i = run_scr('setvar test + 2')
			assert.are.equal(i.vars["test"], 2)
			i = run_scr('setvar test + "hello there"')
			assert.are.equal(i.vars["test"], "hello there")
			i = run_scr('
				setvar test + 2
				setvar test + 4
			')
			assert.are.equal(i.vars["test"], 6)