require("lib/script")
local pprint = require("lib/pprint")
local Talkies = require("lib/talkies")
Talkies.font = love.graphics.newFont("inter.otf", 32)
Talkies.padding = 20
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = { }
getScaling = function(drawable, canvas)
  canvas = canvas or nil
  local drawW = drawable:getWidth()
  local drawH = drawable:getHeight()
  local canvasW = 0
  local canvasH = 0
  if canvas then
    canvasW = canvas:getWidth()
    canvasH = canvas:getHeight()
  else
    canvasW = love.graphics.getWidth()
    canvasH = love.graphics.getHeight()
  end
  local scaleX = canvasW / drawW
  local scaleY = canvasH / drawH
  return scaleX, scaleY
end
next_msg = function()
  local ins = interpreter:next_instruction()
  pprint(ins)
  local _exp_0 = ins.type
  if "bgload" == _exp_0 then
    if ins.path == "~" then
      background = nil
    else
      if love.filesystem.exists(ins.path) then
        background = love.graphics.newImage(ins.path)
      end
    end
    return next_msg()
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
  elseif "choice" == _exp_0 then
    local opts = { }
    for i, choice in ipairs(ins.choices) do
      table.insert(opts, {
        choice,
        function()
          interpreter:choose(i)
          return next_msg()
        end
      })
    end
    return Talkies.say("", "Choose", {
      options = opts
    })
  else
    return next_msg()
  end
end
love.load = function()
  return next_msg()
end
love.draw = function()
  if background then
    local sx, sy = getScaling(background)
    love.graphics.draw(background, 0, 0, 0, sx, sy)
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
