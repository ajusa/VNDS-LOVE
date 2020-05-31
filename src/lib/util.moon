export *
num = tonumber
split = (inputstr, sep) ->
		if sep == nil then sep = "%s"
		return [str for str in string.gmatch(inputstr, "([^"..sep.."]+)")]
ascii = (str) ->
	s = ""
	for i=1, str\len!
		if str\byte(i) >= 32 and str\byte(i) <= 126 then
			s = s .. str\sub(i,i)
	return s

contains = (list, value) ->
	for _, v in ipairs list
		return true if v == value
	return false