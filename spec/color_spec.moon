pprint = require "lib/pprint"
import colorify from require "text/text_color"

describe "Basic Colors", ->
	it "Single Color", ->
		assert.are.equal("demon", colorify("x1b[32;1mdemon")[2])
	it "No Color", ->
		assert.are.equal("hello", colorify("hello")[2])
