{ graphics: lg, mouse: lm } = love

math.randomseed os.time!
for i=1,8 do math.random!

width, height = 60 * 11, 60 * 4

multiplier = 1
score = rotates: 0, connects: 0

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
lg.setNewFont 40

icons = lg.newImage "icons.png"

local loops

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

-- cursor
rows = true
ax, ay = 1, 1

-- flash timer
flash = 0

loops = [ [Loop x, y, math.random(4) for y=1,4] for x=1,11 ]
for i=1,8
  while true
    loop = loops[math.random 11][math.random 4]
    if loop and not loop.locked
      loop.locked = true
      break


love.draw = ->
  lg.translate -10, -10
  for x, row in ipairs loops
    for y, loop in ipairs row
      loop\draw!

  lg.setLineWidth 6

  lg.setColor if rows then 24, 24, 24 else 120, 120, 120
  lg.line 15, ay*60, 30, ay*60
  lg.line width + 30, ay*60, width + 45, ay*60

  lg.setColor if not rows then 24, 24, 24 else 120, 120, 120
  lg.line ax*60, 15, ax*60, 30
  lg.line ax*60, height + 30, ax*60, height + 45

  --lg.setColor 24, 24, 24
  --lg.print "rotates: #{score.rotates}, connects: #{score.connects}", 40, 290
  lg.setColor 255, 255, 255
  lg.draw icons, 0, 320

love.update = (dt) ->
  if flash > 0
    flash -= dt
    if flash < 0 then flash = 0

  rate = 10 * math.pow flash / 0.8, .8
  lg.setBackgroundColor 240/rate, 240/rate, 240/rate

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
    return for row in *loops do row[ay]
  else
    loops[ax]

love.keypressed = (key) ->
  switch key
    when "escape" then love.event.push "quit"
    when "q"
      for loop in *getLoops! do loop\rotate -1
      score.rotates += 1
    when "e"
      for loop in *getLoops! do loop\rotate 1
      score.rotates += 1
    when "space"
      flash = 0.6
      for row in *loops
        for loop in *row
          loop\connect!
      score.connects += 1
    when "up"
      rows = true
      ay = math.max 1, ay - 1
    when "down"
      rows = true
      ay = math.min #loops[1], ay + 1
    when "left"
      rows = false
      ax = math.max 1, ax - 1
    when "right"
      rows = false
      ax = math.min #loops, ax + 1
    when "lshift"
      rows = not rows
