require("lib/script")
local pprint = require("lib/pprint")
local Talkies = require("lib/talkies")
interpreter = Interpreter("/home/ajusa/Downloads/fsn", "main.scr")
background = nil
images = { }
next_msg = function()
  local ins = interpreter:next_instruction()
  pprint(ins)
  local _exp_0 = ins.type
  if "bgload" == _exp_0 then
    if ins.path == "~" then
      background = nil
    else
      background = love.graphics.newImage(ins.path)
    end
  elseif "text" == _exp_0 then
    if ins.text == "~" then
      return Talkies.say("", "", {
        oncomplete = function()
          return next_msg()
        end
      })
    else
      return Talkies.say("", ins.text, {
        oncomplete = function()
          return next_msg()
        end
      })
    end
  else
    return next_msg(ins)
  end
end
love.load = function()
  next_msg()
  return Talkies.say("", "Hello World!")
end
love.draw = function()
  if background then
    love.graphics.draw(background)
  end
  return Talkies.draw()
end
love.update = function(dt)
  return Talkies.update(dt)
end
love.keypressed = function(key)
  if key == "space" then
    return Talkies.onAction()
  else
    if key == "up" then
      return Talkies.prevOption()
    else
      if key == "down" then
        return Talkies.nextOption()
      end
    end
  end
end
