export *
u = require 'lib/underscore' --u since _ is used as throwaway

num = tonumber
split = (str, sep = "%s") -> --splits on sep and trims each output
	[s\match "^%s*(.-)%s*$" for s in str\gmatch("([^#{sep}]+)")]

ascii = (str) ->
	s = ""
	for i=1, str\len!
		if str\byte(i) >= 32 and str\byte(i) <= 126 then
			s = s .. str\sub(i,i)
	return s