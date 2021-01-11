export *
_ = require 'lib/underscore'
wrap = => --credit to https://github.com/leafo/moonscript/issues/347#issuecomment-640084617
	setmetatable {_val: @},
		__index: (k) =>
			(_, ...) -> @_val=@_val[k] @_val, ...
unwrap = => @_val

num = tonumber
split = (str, sep = "%s") -> --splits on sep and trims each output
	[s\match "^%s*(.-)%s*$" for s in str\gmatch("([^#{sep}]+)")]

ascii = (str) ->
	s = {}
	for i=1, str\len!
		byte = str\byte(i)
		if byte >= 32 and byte <= 126 then
			s[#s+1] = string.char(byte)
	return table.concat(s)
get = (t, ...) ->
	for _, k in ipairs{...} do
		t = t[k]
		if not t then return nil
	return t
center = (size, bounds) -> (bounds - size)/2
deepcopy = (orig) -> -- http://lua-users.org/wiki/CopyTable
    orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    return copy
