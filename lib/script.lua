require("lib/util")
commands = {
  ["bgload"] = function(c, line)
    return {
      path = "background/" .. c[2],
      fadetime = num(c[3])
    }
  end,
  ["setimg"] = function(c, line)
    return {
      path = "foreground/" .. c[2],
      x = num(c[3]),
      y = num(c[4])
    }
  end,
  ["sound"] = function(c, line)
    return {
      path = "sound/" .. c[2],
      n = num(c[3])
    }
  end,
  ["music"] = function(c, line)
    return {
      path = "sound/" .. c[2]
    }
  end,
  ["text"] = function(c, line)
    return {
      text = line:sub(6)
    }
  end,
  ["choice"] = function(c, line)
    return {
      choices = split(line:sub(8), "|")
    }
  end,
  ["setvar"] = function(c, line)
    return {
      var = c[2],
      modifier = c[3],
      value = getvalue(c, 3)
    }
  end,
  ["gsetvar"] = function(c, line)
    return {
      var = c[2],
      modifier = c[3],
      value = getvalue(c, 3)
    }
  end,
  ["if"] = function(c, line)
    return {
      var = c[2],
      modifier = c[3],
      value = getvalue(c, 3)
    }
  end,
  ["fi"] = function(c, line)
    return { }
  end,
  ["jump"] = function(c, line)
    return {
      filename = c[2],
      label = c[3]
    }
  end,
  ["delay"] = function(c, line)
    return {
      time = num(c[2])
    }
  end,
  ["random"] = function(c, line)
    return {
      var = num(c[2]),
      low = num(c[3], {
        high = num(c[4])
      })
    }
  end,
  ["label"] = function(c, line)
    return {
      label = c[2]
    }
  end,
  ["goto"] = function(c, line)
    return {
      label = c[2]
    }
  end,
  ["cleartext"] = function(c, line)
    return {
      modifier = c[2]
    }
  end
}
rest = function(c, index)
  return table.concat((function()
    local _accum_0 = { }
    local _len_0 = 1
    for i, item in ipairs(c) do
      if i > index then
        _accum_0[_len_0] = item
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)(), " ")
end
getvalue = function(chunks, index)
  local toret = {
    literal = nil,
    var = nil
  }
  local remain = rest(chunks, index)
  if remain:sub(1, 1) == '"' then
    toret.literal = remain:sub(2, -2)
  else
    if num(remain) then
      toret.literal = num(remain)
    else
      toret.var = remain
    end
  end
  return toret
end
parse = function(line)
  local c = split(line, " ")
  for k, v in pairs(commands) do
    if c[1]:find(k) then
      local toret = v(c, line)
      toret.type = k
      return toret
    end
  end
end
do
  local _class_0
  local _base_0 = {
    interpolate = function(self, text)
      for var in text:gmatch("$(%a+)") do
        text = text:gsub("$" .. var, tostring(self.MEM[var]))
      end
      return text
    end,
    read_file = function(self, filename)
      local file = io.open(tostring(self.base_dir) .. "/script/" .. tostring(filename), "r")
      self.ins = { }
      for line in file:lines() do
        local _continue_0 = false
        repeat
          local trim = line:match("^%s*(.-)%s*$")
          if trim == '' or trim:sub(1, 1) == '#' then
            _continue_0 = true
            break
          end
          table.insert(self.ins, trim)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      for i, line in ipairs(self.ins) do
        local command = parse(line)
        if command.type == "label" then
          self.labels[command.label] = i
        end
      end
    end,
    choose = function(self, value)
      self.MEM["selected"] = value
    end,
    next_instruction = function(self)
      self.n = self.n + 1
      if not self.ins[self.n] then
        return nil
      end
      local ins = parse(self.ins[self.n])
      if ins.path then
        ins.path = tostring(self.base_dir) .. "/" .. tostring(ins.path)
      end
      if ins.var and not self.MEM[ins.var] then
        self.MEM[ins.var] = 0
      end
      local _exp_0 = ins.type
      if "bgload" == _exp_0 or "setimg" == _exp_0 or "sound" == _exp_0 or "music" == _exp_0 or "delay" == _exp_0 or "cleartext" == _exp_0 then
        return ins
      elseif "setvar" == _exp_0 or "gsetvar" == _exp_0 then
        local _exp_1 = ins.modifier
        if "=" == _exp_1 then
          self.MEM[ins.var] = ins.value.literal
        elseif "+" == _exp_1 then
          self.MEM[ins.var] = self.MEM[ins.var] + ins.value.literal
        elseif "-" == _exp_1 then
          self.MEM[ins.var] = self.MEM[ins.var] - ins.value.literal
        elseif "~" == _exp_1 then
          self.MEM = { }
        end
      elseif "text" == _exp_0 then
        ins.text = self:interpolate(ins.text)
      elseif "choice" == _exp_0 then
        do
          local _accum_0 = { }
          local _len_0 = 1
          local _list_0 = ins.choices
          for _index_0 = 1, #_list_0 do
            local choice = _list_0[_index_0]
            _accum_0[_len_0] = self:interpolate(choice)
            _len_0 = _len_0 + 1
          end
          ins.choices = _accum_0
        end
      elseif "random" == _exp_0 then
        self.MEM[ins.var] = math.random(ins.low, ins.high)
      elseif "if" == _exp_0 then
        local lhs = self.MEM[ins.var]
        if ins.value.var then
          ins.value.literal = self.MEM[ins.value.var]
        end
        local rhs = ins.value.literal
        local value
        local _exp_1 = ins.modifier
        if "==" == _exp_1 then
          value = lhs == rhs
        elseif "!=" == _exp_1 then
          value = lhs ~= rhs
        elseif ">=" == _exp_1 then
          value = lhs >= rhs
        elseif "<=" == _exp_1 then
          value = lhs <= rhs
        elseif "<" == _exp_1 then
          value = lhs < rhs
        elseif ">" == _exp_1 then
          value = lhs > rhs
        end
        if value then
          return self:next_instruction()
        else
          local count = 1
          while count > 0 do
            self.n = self.n + 1
            count = count + (function()
              local _exp_2 = parse(self.ins[self.n]).type
              if "if" == _exp_2 then
                return 1
              elseif "fi" == _exp_2 then
                return -1
              else
                return 0
              end
            end)()
          end
          return self:next_instruction()
        end
      elseif "goto" == _exp_0 then
        self.n = self.labels[ins.label]
        return self:next_instruction()
      elseif "jump" == _exp_0 then
        self.n = 0
        self:read_file(ins.filename)
        if ins.label then
          self.n = self.labels[ins.label]
        end
        return self:next_instruction()
      else
        return self:next_instruction()
      end
      return ins
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, base_dir, filename)
      self.base_dir = base_dir
      self.n = 0
      self.MEM = { }
      self.labels = { }
      return self:read_file(filename)
    end,
    __base = _base_0,
    __name = "Interpreter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Interpreter = _class_0
  return _class_0
end
