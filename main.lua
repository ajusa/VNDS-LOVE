require("lib/script")
local pprint = require("lib/pprint")
local TESound = require("lib/tesound")
local Talkies = require("lib/talkies")
Talkies.font = love.graphics.newFont("inter.otf", 32)
Talkies.padding = 20
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = { }
sx, sy = 0, 0
getScaling = function(drawable, canvas)
  sx = love.graphics.getWidth() / drawable:getWidth()
  sy = love.graphics.getHeight() / drawable:getHeight()
  return sx, sy
end
next_msg = function()
  local ins = interpreter:next_instruction()
  local _exp_0 = ins.type
  if "bgload" == _exp_0 then
    if ins.path:sub(-1) == "~" then
      background = nil
    else
      if love.filesystem.getInfo(ins.path) then
        background = love.graphics.newImage(ins.path)
      end
    end
    return next_msg()
  elseif "text" == _exp_0 then
    if ins.text == "~" or ins.text == "!" then
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
  elseif "setimg" == _exp_0 then
    if love.filesystem.getInfo(ins.path) then
      return table.insert(images, love.graphics.newImage(ins.path))
    end
  elseif "sound" == _exp_0 then
    if ins.path:sub(-1) == "~" then
      TEsound.stop("sound")
    else
      if ins.n then
        if ins.n == -1 then
          TEsound.playLooping(ins.path, "static", {
            "sound"
          })
        else
          TEsound.playLooping(ins.path, "static", {
            "sound"
          }, ins.n)
        end
      else
        TEsound.play(ins.path, "static", {
          "sound"
        })
      end
    end
    return next_msg()
  elseif "music" == _exp_0 then
    if ins.path:sub(-1) == "~" then
      TEsound.stop("music")
    else
      if love.filesystem.getInfo(ins.path) then
        TEsound.playLooping(ins.path, "stream", {
          "music"
        })
      end
    end
    return next_msg()
  else
    return next_msg()
  end
end
love.load = function()
  return next_msg()
end
love.draw = function()
  if background then
    sx, sy = getScaling(background)
    love.graphics.draw(background, 0, 0, 0, sx, sy)
  end
  for _index_0 = 1, #images do
    local image = images[_index_0]
    love.graphics.draw(image)
  end
  return Talkies.draw()
end
love.update = function(dt)
  Talkies.update(dt)
  return TEsound.cleanup()
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
love.gamepadpressed = function(joy, button)
  if button == "a" then
    return Talkies.onAction()
  else
    if button == "dpup" then
      return Talkies.prevOption()
    else
      if button == "dpdown" then
        return Talkies.nextOption()
      end
    end
  end
end
