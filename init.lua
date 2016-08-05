local lg, la, lm
do
  local _obj_0 = love
  lg, la, lm = _obj_0.graphics, _obj_0.audio, _obj_0.mouse
end
math.randomseed(os.time())
for i = 1, 8 do
  math.random()
end
local width, height = 60 * 11, 60 * 4
local intro = 0
local sound_stage = 0
local circles
do
  local _accum_0 = { }
  local _len_0 = 1
  for i = 0, 3 do
    lg.setLineWidth(7)
    local _value_0
    do
      local canvas = lg.newCanvas(40, 40)
      lg.setCanvas(canvas)
      lg.setColor(255, 255, 255)
      lg.setBlendMode("alpha")
      lg.circle("line", 20, 20, 16, 26)
      lg.setColor(0, 0, 0, 0)
      lg.setBlendMode("replace")
      lg.push()
      lg.translate(20, 20)
      lg.rotate(i * math.pi / 2)
      lg.line(0, 0, 20, 0)
      lg.pop()
      _value_0 = canvas
    end
    _accum_0[_len_0] = _value_0
    _len_0 = _len_0 + 1
  end
  circles = _accum_0
end
do
  local canvas = lg.newCanvas(40, 40)
  lg.setCanvas(canvas)
  lg.setColor(255, 255, 255)
  lg.setBlendMode("alpha")
  lg.circle("fill", 20, 20, 16)
  lg.circle("line", 20, 20, 16, 26)
  circles.locked = canvas
end
lg.setCanvas()
lg.setBlendMode("alpha")
lg.setNewFont(40)
local icons = lg.newImage("icons.png")
local logo = lg.newImage("logo.png")
local thursday_soft = lg.newImage("thursday_soft.png")
local intro_sound = la.newSource("intro.wav")
local connect_sound = la.newSource("connect.wav")
local move_sound = la.newSource("move.wav")
local rows = true
local ax, ay = 1, 1
local flash, score, game_over, loops, multiplier, Loop
love.load = function()
  flash = 0
  multiplier = 1
  score = {
    rotates = 0,
    connects = 0,
    remaining = math.huge
  }
  game_over = false
  do
    local _accum_0 = { }
    local _len_0 = 1
    for x = 1, 11 do
      do
        local _accum_1 = { }
        local _len_1 = 1
        for y = 1, 4 do
          _accum_1[_len_1] = Loop(x, y, math.random(4))
          _len_1 = _len_1 + 1
        end
        _accum_0[_len_0] = _accum_1
      end
      _len_0 = _len_0 + 1
    end
    loops = _accum_0
  end
  for i = 1, 8 do
    while true do
      local loop = loops[math.random(11)][math.random(4)]
      if loop and not loop.locked then
        loop.locked = true
        break
      end
    end
  end
end
do
  local _class_0
  local SPACING, ROT_SPEED
  local _base_0 = {
    rotate = function(self, dir)
      if self.locked or self.paired then
        return 
      end
      self.orientation = (self.orientation + dir - 1) % 4 + 1
      self.anim = -dir
    end,
    connect = function(self)
      if self.paired or self.locked then
        return 
      end
      local other
      local _exp_0 = self.orientation
      if 4 == _exp_0 then
        other = loops[self.x][self.y - 1]
      elseif 2 == _exp_0 then
        other = loops[self.x][self.y + 1]
      elseif 3 == _exp_0 then
        other = (loops[self.x - 1] or { })[self.y]
      elseif 1 == _exp_0 then
        other = (loops[self.x + 1] or { })[self.y]
      end
      if not other or other.locked or other.paired then
        return 
      end
      if other.orientation ~= self.orientation and other.orientation % 2 == self.orientation % 2 then
        self.paired = other
        other.paired = self
        return true
      end
    end,
    update = function(self, dt)
      if self.anim then
        if self.anim > 0 then
          self.anim = self.anim - (dt * ROT_SPEED)
          if self.anim < 0 then
            self.anim = nil
          end
        else
          self.anim = self.anim + (dt * ROT_SPEED)
          if self.anim > 0 then
            self.anim = nil
          end
        end
      end
    end,
    draw = function(self)
      local x
      if self.paired then
        x = (self.x + self.paired.x) / 2
      else
        x = self.x
      end
      local scale = 0.3 + x / (10 / 0.7)
      scale = math.min(multiplier * scale, 1)
      lg.push()
      lg.translate(self.x * SPACING, self.y * SPACING)
      lg.scale(scale)
      lg.rotate((self.orientation - 1 + (self.anim or 0)) * math.pi / 2)
      if self.locked then
        lg.setColor(120, 120, 120)
        lg.draw(circles.locked, -20, -20)
      else
        lg.setColor((function()
          if self.paired then
            return 24, 120, 24
          else
            return 24, 24, 24
          end
        end)())
        lg.draw(circles[1], -20, -20)
        lg.setLineWidth(8)
        if self.paired then
          lg.line(19.5, 0, 30 / scale, 0)
        end
      end
      return lg.pop()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, orientation)
      self.x, self.y, self.orientation = x, y, orientation
    end,
    __base = _base_0,
    __name = "Loop"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  SPACING = 60
  ROT_SPEED = 9
  Loop = _class_0
end
love.draw = function()
  if intro then
    lg.setColor(255, 255, 255, math.min(intro, 1) * 255)
    lg.draw(thursday_soft, 560, 20)
    lg.setColor(255, 255, 255, math.min(intro - 1, 1) * 255)
    return lg.draw(logo, 400, 280)
  elseif game_over then
    lg.setColor(255, 255, 255)
    lg.draw(thursday_soft, 20, 20)
    lg.setColor(24, 24, 24)
    local points = score.rotates + score.connects * 2 + score.remaining * 10
    return lg.print("score: " .. tostring(points) .. " (less = better)", 40, 120)
  else
    lg.translate(-10, -10)
    for x, row in ipairs(loops) do
      for y, loop in ipairs(row) do
        loop:draw()
      end
    end
    lg.setLineWidth(6)
    lg.setColor((function()
      if rows then
        return 24, 24, 24
      else
        return 120, 120, 120
      end
    end)())
    lg.line(15, ay * 60, 30, ay * 60)
    lg.line(width + 30, ay * 60, width + 45, ay * 60)
    lg.setColor((function()
      if not rows then
        return 24, 24, 24
      else
        return 120, 120, 120
      end
    end)())
    lg.line(ax * 60, 15, ax * 60, 30)
    lg.line(ax * 60, height + 30, ax * 60, height + 45)
    lg.setColor(255, 255, 255)
    return lg.draw(icons, 0, 320)
  end
end
love.update = function(dt)
  if flash > 0 then
    flash = flash - dt
    if flash < 0 then
      flash = 0
    end
  end
  local rate = 10 * math.pow(flash / 0.8, .8)
  lg.setBackgroundColor(240 / rate, 240 / rate, 240 / rate)
  if intro then
    intro = intro + dt
    if intro > 0.2 and sound_stage < 1 then
      connect_sound:play()
      sound_stage = 1
    end
    if intro > 1.2 and sound_stage < 2 then
      intro_sound:play()
      sound_stage = 2
    end
    if intro > 3 then
      intro = nil
    end
    return 
  end
  local paired, pairable = 0, 0
  for x, row in ipairs(loops) do
    for y, loop in ipairs(row) do
      if loop.paired then
        paired = paired + 1
      end
      if not loop.locked then
        pairable = pairable + 1
      end
    end
  end
  local new_multiplier = 1 + paired / pairable * 1.7
  multiplier = multiplier + ((new_multiplier - multiplier) / 8)
  for x, row in ipairs(loops) do
    for y, loop in ipairs(row) do
      loop:update(dt)
    end
  end
end
local getLoops
getLoops = function()
  if rows then
    return (function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #loops do
        local row = loops[_index_0]
        _accum_0[_len_0] = row[ay]
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()
  else
    return loops[ax]
  end
end
love.keypressed = function(key)
  if key == "escape" then
    love.event.push("quit")
  elseif key == "r" then
    love.load()
  end
  if game_over then
    return 
  end
  local _exp_0 = key
  if "q" == _exp_0 then
    local _list_0 = getLoops()
    for _index_0 = 1, #_list_0 do
      local loop = _list_0[_index_0]
      loop:rotate(-1)
    end
    score.rotates = score.rotates + 1
    return move_sound:play()
  elseif "e" == _exp_0 then
    local _list_0 = getLoops()
    for _index_0 = 1, #_list_0 do
      local loop = _list_0[_index_0]
      loop:rotate(1)
    end
    score.rotates = score.rotates + 1
    return move_sound:play()
  elseif "space" == _exp_0 then
    flash = 0.6
    game_over = true
    score.remaining = 0
    for _index_0 = 1, #loops do
      local row = loops[_index_0]
      for _index_1 = 1, #row do
        local loop = row[_index_1]
        if loop:connect() then
          connect_sound:play()
        end
        if game_over and not (loop.paired or loop.locked) then
          score.remaining = score.remaining + 1
          for x = -1, 1 do
            for y = -1, 1 do
              local _continue_0 = false
              repeat
                if math.abs(x) + math.abs(y) ~= 1 then
                  _continue_0 = true
                  break
                end
                local other = (loops[loop.x + x] or { })[loop.y + y]
                if other and not (other.paired or other.locked) then
                  game_over = false
                end
                _continue_0 = true
              until true
              if not _continue_0 then
                break
              end
            end
          end
        end
      end
    end
    score.connects = score.connects + 1
  elseif "up" == _exp_0 then
    rows = true
    ay = math.max(1, ay - 1)
  elseif "down" == _exp_0 then
    rows = true
    ay = math.min(#loops[1], ay + 1)
  elseif "left" == _exp_0 then
    rows = false
    ax = math.max(1, ax - 1)
  elseif "right" == _exp_0 then
    rows = false
    ax = math.min(#loops, ax + 1)
  elseif "lshift" == _exp_0 then
    rows = not rows
  end
end
