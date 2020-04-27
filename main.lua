require("lib/script")
local pprint = require("lib/pprint")
local TESound = require("lib/tesound")
local Moan = require("lib/Moan")
Moan.font = love.graphics.newFont("inter.otf", 32)
local choice_ui
choice_ui = function()
  Moan.UI.messageboxPos = "top"
  Moan.height = original_height * .75 * sy
  Moan.width = original_width * .75 * sx
  Moan.center = true
end
local undo_choice_ui
undo_choice_ui = function()
  Moan.UI.messageboxPos = "bottom"
  Moan.height = 150
  Moan.width = nil
  Moan.center = false
end
interpreter = Interpreter("novels/fsn", "main.scr")
background = nil
images = { }
sx, sy = 0, 0
px, py = 0, 0
original_width, original_height = 0, 0
love.resize = function(w, h)
  sx = w / original_width
  sy = h / original_height
  px, py = w / 256, h / 192
  return love.graphics.setNewFont("inter.otf", 32)
end
next_msg = function()
  local ins = interpreter:next_instruction()
  if ins.path and not ins.path:sub(-1) == "~" and not love.filesystem.getInfo(ins.path) then
    next_msg()
  end
  local _exp_0 = ins.type
  if "bgload" == _exp_0 then
    if ins.path:sub(-1) == "~" then
      background = nil
    else
      if love.filesystem.getInfo(ins.path) then
        background = love.graphics.newImage(ins.path)
        images = { }
      end
    end
    return next_msg()
  elseif "text" == _exp_0 then
    if ins.text == "~" or ins.text == "!" then
      return next_msg()
    else
      return Moan.speak("Text", {
        ins.text
      }, {
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
          undo_choice_ui()
          return next_msg()
        end
      })
    end
    choice_ui()
    return Moan.speak("", {
      "Choose\n"
    }, {
      options = opts
    })
  elseif "setimg" == _exp_0 then
    if love.filesystem.getInfo(ins.path) then
      table.insert(images, {
        img = love.graphics.newImage(ins.path),
        x = ins.x,
        y = ins.y
      })
      return next_msg()
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
  print(love.filesystem.getSaveDirectory())
  love.filesystem.createDirectory("/novels")
  local contents = love.filesystem.read(interpreter.base_dir .. "/img.ini")
  original_width = tonumber(contents:match("width=(%d+)"))
  original_height = tonumber(contents:match("height=(%d+)"))
  love.resize(love.graphics.getWidth(), love.graphics.getHeight())
  return next_msg()
end
love.draw = function()
  if background then
    love.graphics.draw(background, 0, 0, 0, sx, sy)
  end
  for _index_0 = 1, #images do
    local fg = images[_index_0]
    love.graphics.draw(fg.img, fg.x * px, fg.y * py, 0, sx, sy)
  end
  return Moan.draw()
end
love.update = function(dt)
  Moan.update(dt)
  return TEsound.cleanup()
end
love.keypressed = function(key)
  return Moan.keypressed(key)
end
love.gamepadpressed = function(joy, button)
  print(button)
  if button == "a" then
    return Moan.keypressed("space")
  else
    if button == "dpup" then
      return Moan.keypressed("up")
    else
      if button == "dpdown" then
        return Moan.keypressed("down")
      end
    end
  end
end
