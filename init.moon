{ graphics: lg, audio: la, keyboard: lk } = love

math.randomseed os.time!
for i=1,8 do math.random!

width, height = 60 * 11, 60 * 4
intro = 0
sound_stage = 0

circles = for i=0,3
  lg.setLineWidth 7
  with canvas = lg.newCanvas 40, 40
    lg.setCanvas canvas
    lg.setColor 255, 255, 255
    lg.setBlendMode "alpha"
    lg.circle "line", 20, 20, 16, 26
    lg.setColor 0, 0, 0, 0
    lg.setBlendMode "replace"
    lg.push!
    lg.translate 20, 20
    lg.rotate i * math.pi/2
    lg.line 0, 0, 20, 0
    lg.pop!

circles.locked = with canvas = lg.newCanvas 40, 40
  lg.setCanvas canvas
  lg.setColor 255, 255, 255
  lg.setBlendMode "alpha"
  lg.circle "fill", 20, 20, 16
  lg.circle "line", 20, 20, 16, 26

lg.setCanvas!
lg.setBlendMode "alpha"
font = lg.setNewFont "assets/warownia.otf", 30

icon =
  rotate: lg.newImage "assets/rotate.png"
  rotate_active: lg.newImage "assets/rotate_active.png"
  connect: lg.newImage "assets/connect.png"
  connect_active: lg.newImage "assets/connect_active.png"
  move: lg.newImage "assets/move.png"
  move_active: lg.newImage "assets/move_active.png"
  switch_column: lg.newImage "assets/switch_column.png"
  switch_row: lg.newImage "assets/switch_row.png"

  logo: lg.newImage "assets/logo.png"
  thursday_soft: lg.newImage "assets/thursday_soft.png"

intro_sound = la.newSource "assets/intro.wav"
connect_sound = la.newSource "assets/connect.wav"
move_sound = la.newSource "assets/move.wav"

-- cursor
rows = true
ax, ay = 1, 1

local flash, score, game_over, loops, multiplier, Loop
love.load = ->
  -- flash timer
  flash = 0

  multiplier = 1
  score = rotates: 0, connects: 0, remaining: 4 * 11 - 8, points: (4 * 11 - 8) * 5
  game_over = false

  loops = [ [Loop x, y, math.random(4) for y=1,4] for x=1,11 ]
  for i=1,8
    while true
      loop = loops[math.random 11][math.random 4]
      if loop and not loop.locked
        loop.locked = true
        break

class Loop
  SPACING = 60
  ROT_SPEED = 9

  new: (@x, @y, @orientation) =>

  rotate: (dir) =>
    return if @locked or @paired
    @orientation = (@orientation + dir - 1) % 4 + 1
    @anim = -dir

  connect: =>
    return if @paired or @locked

    local other
    switch @orientation
      when 4 then other = loops[@x][@y - 1]
      when 2 then other = loops[@x][@y + 1]
      when 3 then other = (loops[@x - 1]or{})[@y]
      when 1 then other = (loops[@x + 1]or{})[@y]

    return if not other or other.locked or other.paired
    if other.orientation ~= @orientation and other.orientation % 2 == @orientation % 2
      @paired = other
      other.paired = @
      true

  update: (dt) =>
    if @anim
      if @anim > 0
        @anim -= dt * ROT_SPEED
        if @anim < 0 then @anim = nil
      else
        @anim += dt * ROT_SPEED
        if @anim > 0 then @anim = nil

  draw: =>
    x = if @paired then (@x + @paired.x) / 2 else @x
    scale = 0.3 + x / (10 / 0.7)
    scale = math.min multiplier * scale, 1
    lg.push!
    lg.translate @x * SPACING, @y * SPACING
    lg.scale scale
    lg.rotate (@orientation-1 + (@anim or 0)) * math.pi/2

    if @locked
      lg.setColor 120, 120, 120
      lg.draw circles.locked, -20, -20
    else
      lg.setColor if @paired then 24, 120, 24 else 24, 24, 24
      lg.draw circles[1], -20, -20
      lg.setLineWidth 8
      lg.line 19.5, 0, 30/scale, 0 if @paired
    lg.pop!

love.draw = ->
  lg.setColor 255, 255, 255, math.min(intro or 1, 1) * 255
  lg.setBlendMode "multiply"
  lg.draw icon.thursday_soft, 575, 5
  lg.setBlendMode "alpha"

  if intro
    lg.setColor 255, 255, 255, math.min(intro - 1, 1) * 255
    lg.draw icon.logo, 420, 320
  elseif game_over
    lg.setColor 255, 255, 255
    lg.draw icon.logo, 5, 5

    lg.setColor 24, 24, 24
    lg.print "score: #{score.points} (less = better)", 40, 120
    lg.print "r to restart", 40, 160
  else
    lg.setColor 24, 24, 24
    lg.print "#{score.points}", 5, -5

    lg.translate -10, 20
    for x, row in ipairs loops
      for y, loop in ipairs row
        loop\draw!

    lg.setLineWidth 6

    if rows
      lg.setColor 120, 120, 120
      lg.line 15, ay*60, 30, ay*60
      lg.line width+30, ay*60, width+45, ay*60

      lg.setColor 24, 24, 24
      lg.polygon "line", ax*60-3, 25, ax*60, 30, ax*60+3, 25
      lg.polygon "line", ax*60, height+30, ax*60-3, height+35, ax*60+3, height+35
    else
      lg.setColor 24, 24, 24
      lg.polygon "line", 25, ay*60-3, 30, ay*60, 25, ay*60+3
      lg.polygon "line", width+30, ay*60, width+35, ay*60-3, width+35, ay*60+3

      lg.setColor 120, 120, 120
      lg.line ax*60, 15, ax*60, 30
      lg.line ax*60, height+30, ax*60, height+45

    lg.setColor 255, 255, 255
    lg.translate 0, 320
    lg.draw if lk.isDown "q", "e" then icon.rotate_active else icon.rotate
    lg.draw icon.connect
    lg.draw if lk.isDown "up", "down", "left", "right" then icon.move_active else icon.move
    lg.draw if rows then icon.switch_row else icon.switch_column

love.update = (dt) ->
  if flash > 0
    flash -= dt
    if flash < 0 then flash = 0

  rate = 10 * math.pow flash / 0.8, .8
  lg.setBackgroundColor 240/rate, 240/rate, 240/rate

  if intro
    intro += dt

    if intro > 0.2 and sound_stage < 1
      connect_sound\play!
      sound_stage = 1

    if intro > 1.2 and sound_stage < 2
      intro_sound\play!
      sound_stage = 2

    if intro > 3 then intro = nil
    return

  paired, pairable = 0, 0
  for x, row in ipairs loops
    for y, loop in ipairs row
      if loop.paired then paired += 1
      if not loop.locked then pairable += 1

  new_multiplier = 1 + paired/pairable * 1.7
  multiplier += (new_multiplier - multiplier) / 8

  for x, row in ipairs loops
    for y, loop in ipairs row
      loop\update dt

getLoops = ->
  if rows
    loops[ax]
  else
    [row[ay] for row in *loops]

love.keypressed = (key) ->
  if key == "escape" then love.event.push "quit"
  elseif key == "p" then game_over = true
  elseif key == "r" then love.load!

  return if game_over

  switch key
    when "q"
      for loop in *getLoops! do loop\rotate -1
      score.rotates += 1
      score.points = score.rotates + score.connects * 2 + score.remaining * 5
      move_sound\play!
    when "e"
      for loop in *getLoops! do loop\rotate 1
      score.rotates += 1
      score.points = score.rotates + score.connects * 2 + score.remaining * 5
      move_sound\play!
    when "space"
      flash = 0.6

      game_over = true
      score.remaining = 0
      for row in *loops
        for loop in *row
          if loop\connect!
            connect_sound\play!

          if not (loop.paired or loop.locked)
            score.remaining += 1
            if game_over
              for x=-1,1
                for y=-1,1
                  continue if math.abs(x) + math.abs(y) ~= 1
                  other = (loops[loop.x + x]or{})[loop.y + y]
                  if other and not (other.paired or other.locked)
                    game_over = false

      score.connects += 1
      score.points = score.rotates + score.connects * 2 + score.remaining * 5
    when "up" then ay = math.max 1, ay - 1
    when "down" then ay = math.min #loops[1], ay + 1
    when "left" then ax = math.max 1, ax - 1
    when "right" then ax = math.min #loops, ax + 1
    when "lshift" then rows = not rows
