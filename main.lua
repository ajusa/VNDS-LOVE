require("lib/script")
local pprint = require("lib/pprint")
local serialize = require('lib/ser')
local TESound = require("lib/tesound")
local Moan = require("lib/Moan")
Moan.font = love.graphics.newFont("inter.ttf", 32)
choice_ui = function()
  Moan.UI.messageboxPos = "top"
  Moan.height = original_height * .75 * sy
  Moan.width = original_width * .75 * sx
  Moan.center = true
end
undo_choice_ui = function()
  Moan.UI.messageboxPos = "bottom"
  Moan.height = 150
  Moan.width = nil
  Moan.center = false
end
interpreter = nil
background = nil
images = { }
saving = 0.0
sx, sy = 0, 0
px, py = 0, 0
original_width, original_height = love.graphics.getWidth(), love.graphics.getHeight()
save_game = function()
  local save_table = interpreter:save()
  do
    local _tbl_0 = { }
    for k, v in pairs(images) do
      if k ~= "img" then
        _tbl_0[k] = v
      end
    end
    save_table.images = _tbl_0
  end
  save_table.images = images
  save_table.background = {
    path = background.path
  }
  local file = love.filesystem.newFile(interpreter.base_dir .. "/save.lua", "w")
  file:write(serialize(save_table))
  file:flush()
  file:close()
  saving = 1.5
end
load_game = function()
  if love.filesystem.getInfo(interpreter.base_dir .. "/save.lua") then
    local save = love.filesystem.read(interpreter.base_dir .. "/save.lua")
    local save_table = loadstring(save)()
    interpreter:load(save_table)
    background = {
      path = save_table.background.path,
      img = love.graphics.newImage(save_table.background.path)
    }
    images = save_table.images
    for _index_0 = 1, #images do
      local image = images[_index_0]
      image.img = love.graphics.newImage(image.path)
    end
  end
end
love.resize = function(w, h)
  sx = w / original_width
  sy = h / original_height
  px, py = w / 256, h / 192
  return love.graphics.setNewFont("inter.ttf", 32)
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
        background = {
          path = ins.path,
          img = love.graphics.newImage(ins.path)
        }
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
        path = ins.path,
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
          TEsound.playLooping(ins.path, "stream", {
            "sound"
          })
        else
          TEsound.playLooping(ins.path, "stream", {
            "sound"
          }, ins.n)
        end
      else
        TEsound.play(ins.path, "stream", {
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
  love.resize(love.graphics.getWidth(), love.graphics.getHeight())
  local lfs = love.filesystem
  lfs.createDirectory("/novels")
  local games
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = lfs.getDirectoryItems("/novels")
    for _index_0 = 1, #_list_0 do
      local file = _list_0[_index_0]
      _accum_0[_len_0] = file
      _len_0 = _len_0 + 1
    end
    games = _accum_0
  end
  local opts = { }
  for i, choice in ipairs(games) do
    table.insert(opts, {
      choice,
      function()
        interpreter = Interpreter("/novels/" .. choice, "main.scr")
        load_game()
        undo_choice_ui()
        local contents = lfs.read(interpreter.base_dir .. "/img.ini")
        original_width = tonumber(contents:match("width=(%d+)"))
        original_height = tonumber(contents:match("height=(%d+)"))
        love.resize(love.graphics.getWidth(), love.graphics.getHeight())
        return next_msg()
      end
    })
  end
  choice_ui()
  if next(opts) == nil then
    return Moan.speak("", {
      "No novels found in this directory:\n" .. lfs.getSaveDirectory() .. "/novels",
      "Add one and restart the program"
    })
  else
    return Moan.speak("", {
      "Novel Directory:\n" .. lfs.getSaveDirectory() .. "/novels",
      "Select a novel"
    }, {
      options = opts
    })
  end
end
love.draw = function()
  if background then
    love.graphics.draw(background.img, 0, 0, 0, sx, sy)
  end
  for _index_0 = 1, #images do
    local fg = images[_index_0]
    love.graphics.draw(fg.img, fg.x * px, fg.y * py, 0, sx, sy)
  end
  if saving > 0.0 then
    do
      love.graphics.print("Saving...", 5, 5)
    end
  end
  return Moan.draw()
end
love.update = function(dt)
  Moan.update(dt)
  TEsound.cleanup()
  if saving > 0.0 then
    saving = saving - dt
  end
end
love.keypressed = function(key)
  if key == "x" and interpreter then
    save_game()
  end
  return Moan.keypressed(key)
end
love.gamepadpressed = function(joy, button)
  if button == "a" then
    return Moan.keypressed("space")
  else
    if button == "dpup" then
      return Moan.keypressed("up")
    else
      if button == "dpdown" then
        return Moan.keypressed("down")
      else
        if button == "x" then
          saving = 100.0
          return save_game()
        end
      end
    end
  end
end
