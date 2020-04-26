export *
num = tonumber
split = (inputstr, sep) ->
        if sep == nil then sep = "%s"
        return [str for str in string.gmatch(inputstr, "([^"..sep.."]+)")]