require("lib/util")
local pprint = require("lib/pprint")
commands = { }
add = function(a, b)
  if a == nil and type(b) == "string" then
    a = ""
  end
  if a == nil and type(b) == "number" then
    a = 0
  end
  if type(a) == "string" or type(b) == "string" then
    return tostring(a) .. tostring(b)
  else
    return a + b
  end
end
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
  if c[1]:find("bgload") then
    return {
      type = "bgload",
      path = "background/" .. c[2],
      fadetime = num(c[3])
    }
  else
    if c[1]:find("setimg") then
      return {
        type = "setimg",
        path = "foreground/" .. c[2],
        x = num(c[3]),
        y = num(c[4])
      }
    else
      if c[1]:find("sound") then
        return {
          type = "sound",
          path = "sound/" .. c[2],
          n = num(c[3])
        }
      else
        if c[1]:find("music") then
          return {
            type = "music",
            path = "sound/" .. c[2]
          }
        else
          if c[1]:find("text") then
            return {
              type = "text",
              text = line:sub(6)
            }
          else
            if c[1]:find("choice") then
              return {
                type = "choice",
                choices = split(line:sub(8), "|")
              }
            else
              if c[1]:find("gsetvar") then
                return {
                  type = "gsetvar",
                  var = c[2],
                  modifier = c[3],
                  value = getvalue(c, 3)
                }
              else
                if c[1]:find("setvar") then
                  return {
                    type = "setvar",
                    var = c[2],
                    modifier = c[3],
                    value = getvalue(c, 3)
                  }
                else
                  if c[1]:find("if") then
                    return {
                      type = "if",
                      var = c[2],
                      modifier = c[3],
                      value = getvalue(c, 3)
                    }
                  else
                    if c[1]:find("fi") then
                      return {
                        type = "fi"
                      }
                    else
                      if c[1]:find("jump") then
                        return {
                          type = "jump",
                          filename = c[2],
                          label = c[3]
                        }
                      else
                        if c[1]:find("delay") then
                          return {
                            type = "delay",
                            time = num(c[2])
                          }
                        else
                          if c[1]:find("random") then
                            return {
                              type = "random",
                              var = num(c[2]),
                              low = num(c[3], {
                                high = num(c[4])
                              })
                            }
                          else
                            if c[1]:find("label") then
                              return {
                                type = "label",
                                label = c[2]
                              }
                            else
                              if c[1]:find("goto") then
                                return {
                                  type = "goto",
                                  label = c[2]
                                }
                              else
                                if c[1]:find("cleartext") then
                                  return {
                                    type = "cleartext",
                                    modifier = c[2]
                                  }
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
do
  local _class_0
  local _base_0 = {
    save = function(self)
      return {
        global = self.global,
        vars = self.vars,
        n = self.n,
        current_file = self.current_file
      }
    end,
    load = function(self, save)
      self:read_file(save.current_file)
      self.global = save.global
      self.vars = save.vars
      self.n = save.n - 1
    end,
    interpolate = function(self, text)
      for var in text:gmatch("$(%a+)") do
        text = text:gsub("$" .. var, tostring(self.MEM[var]))
      end
      return text
    end,
    read_file = function(self, filename)
      local text = self.filesystem(tostring(self.base_dir) .. "/script/" .. tostring(filename))
      local lines = split(text, "\n")
      self.ins = { }
      self.current_file = filename
      for _index_0 = 1, #lines do
        local _continue_0 = false
        repeat
          local line = lines[_index_0]
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
      self.vars["selected"] = value
    end,
    getMem = function(self, key)
      if self.global[key] ~= nil then
        return self.global
      end
      return self.vars
    end,
    next_instruction = function(self)
      if not self.ins[self.n] then
        return nil
      end
      local ins = parse(self.ins[self.n])
      self.n = self.n + 1
      if ins.path then
        ins.path = tostring(self.base_dir) .. "/" .. tostring(ins.path)
      end
      local MEM
      if ins.var then
        MEM = self:getMem(ins.var)
      else
        MEM = { }
      end
      local _exp_0 = ins.type
      if "bgload" == _exp_0 or "setimg" == _exp_0 or "sound" == _exp_0 or "music" == _exp_0 or "delay" == _exp_0 or "cleartext" == _exp_0 then
        return ins
      elseif "setvar" == _exp_0 or "gsetvar" == _exp_0 then
        if ins.type == "gsetvar" then
          MEM = self.global
        end
        local _exp_1 = ins.modifier
        if "=" == _exp_1 then
          MEM[ins.var] = ins.value.literal
        elseif "+" == _exp_1 then
          MEM[ins.var] = add(MEM[ins.var], ins.value.literal)
        elseif "-" == _exp_1 then
          MEM[ins.var] = add(MEM[ins.var], -ins.value.literal)
        elseif "~" == _exp_1 then
          if ins.type == "setvar" then
            self.vars = { }
          else
            self.global = { }
          end
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
        MEM[ins.var] = math.random(ins.low, ins.high)
        return self:next_instruction()
      elseif "if" == _exp_0 then
        if ins.value.var then
          if MEM[ins.value.var] == nil then
            MEM[ins.value.var] = 0
          end
          ins.value.literal = MEM[ins.value.var]
        end
        if MEM[ins.var] == nil then
          MEM[ins.var] = 0
        end
        local lhs = MEM[ins.var]
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
        self.n = 1
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
    __init = function(self, base_dir, filename, filesystem)
      self.filesystem = filesystem
      self.base_dir = base_dir
      self.n = 1
      self.global = { }
      self.vars = { }
      self.labels = { }
      self.current_file = ""
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
