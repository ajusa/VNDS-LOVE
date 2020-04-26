num = tonumber
split = function(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local _accum_0 = { }
  local _len_0 = 1
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    _accum_0[_len_0] = str
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
