-- have this handle all of the text related events
import dispatch, on, register, remove from require 'event'
pprint = require "lib/pprint"
local *
buffer = {}
needs_input = false
pos = 1
speed = 0.1


on "text", =>
	return nil
