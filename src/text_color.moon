pprint = require "lib/pprint"
color_map = {
	"x1b[;1m": {1, 1, 1, 1} --White
}
get_color = (str) ->
	i, j = str\find("x1b%[%d*;*%dm")
	if i == nil then return nil
	code = str\sub(i, j)
	return code

{:get_color}
