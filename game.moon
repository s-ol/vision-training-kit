{ graphics: lg, keyboard: lk } = love

local flash, score, loops, multiplier, rows, ax, ay, fade

class Loop
  SPACING = 60
  ROT_SPEED = 9
  circle = with canvas = lg.newCanvas 40, 40
      lg.setLineWidth 7
      lg.setCanvas canvas
      lg.setColor 255, 255, 255
      lg.setBlendMode "alpha"
      lg.circle "line", 20, 20, 16, 26
      lg.setColor 0, 0, 0, 0
      lg.setBlendMode "replace"
      lg.push!
      lg.translate 20, 20
      lg.line 0, 0, 20, 0
      lg.pop!

  circle_locked = with canvas = lg.newCanvas 40, 40
    lg.setCanvas canvas
    lg.setColor 255, 255, 255
    lg.setBlendMode "alpha"
    lg.circle "fill", 20, 20, 16
    lg.circle "line", 20, 20, 16, 26

  lg.setCanvas!
  lg.setBlendMode "alpha"

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
    rot = (@orientation-1 + (@anim or 0)) * math.pi/2
    h = math.sqrt 3/2 * math.max(0, math.sqrt(fade) - 1/3)
    lg.rotate h * rot + (1 - h) * -math.pi/2 * (@x/9 + @y/3)

    if @locked
      lg.setColor 120, 120, 120, fade * 255
      lg.draw circle_locked, -20, -20
    else
      lg.setColor if @paired then 24, 120, 24, fade * 255 else 24, 24, 24, fade * 255
      lg.draw circle, -20, -20
      lg.setLineWidth 8
      lg.line 19.5, 0, 30/scale, 0 if @paired
    lg.pop!

getLoops = ->
  if rows
    loops[ax]
  else
    [row[ay] for row in *loops]
{
  enter: ->
    fade = 0

    -- cursor
    rows = true
    ax, ay = 1, 1

    -- flash timer
    flash = 0

    multiplier = 1
    score = rotates: 0, connects: 0, remaining: 4 * 11 - 8, points: (4 * 11 - 8) * 5

    loops = [ [Loop x, y, math.random(4) for y=1,4] for x=1,11 ]
    for i=1,8
      while true
        loop = loops[math.random 11][math.random 4]
        if loop and not loop.locked
          loop.locked = true
          break
  draw: ->
    lg.setColor 255, 255, 255
    lg.setBlendMode "multiply"
    lg.draw Sprite.thursday_soft, 575, 5
    lg.setBlendMode "alpha"

    lg.setColor 24, 24, 24, fade * 255
    lg.print "#{score.points}", 5, -5

    lg.translate -10, 20
    for x, row in ipairs loops
      for y, loop in ipairs row
        loop\draw!

    lg.setLineWidth 6

    width, height = 60 * 11, 60 * 4
    if rows
      lg.setColor 120, 120, 120, fade * 255
      lg.line 15, ay*60, 30, ay*60
      lg.line width+30, ay*60, width+45, ay*60

      lg.setColor 24, 24, 24, fade * 255
      lg.polygon "line", ax*60-3, 25, ax*60, 30, ax*60+3, 25
      lg.polygon "line", ax*60, height+30, ax*60-3, height+35, ax*60+3, height+35
    else
      lg.setColor 24, 24, 24, fade * 255
      lg.polygon "line", 25, ay*60-3, 30, ay*60, 25, ay*60+3
      lg.polygon "line", width+30, ay*60, width+35, ay*60-3, width+35, ay*60+3

      lg.setColor 120, 120, 120, fade * 255
      lg.line ax*60, 15, ax*60, 30
      lg.line ax*60, height+30, ax*60, height+45

    lg.setColor 255, 255, 255, fade * 255
    lg.translate 0, 320
    lg.draw if lk.isDown "q", "e" then Sprite.rotate_active else Sprite.rotate
    lg.draw Sprite.connect
    lg.draw if lk.isDown "up", "down", "left", "right" then Sprite.move_active else Sprite.move
    lg.draw if rows then Sprite.switch_row else Sprite.switch_column

  update: (dt) ->
    if fade < 1
      fade += dt
      multiplier = 1/fade
      if fade > 1 then fade = 1

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
    multiplier += (new_multiplier - multiplier) / 8 unless fade < 1

    for x, row in ipairs loops
      for y, loop in ipairs row
        loop\update dt

  keypressed: (key) ->
    switch key
      when "q"
        for loop in *getLoops! do loop\rotate -1
        score.rotates += 1
        score.points = score.rotates + score.connects * 2 + score.remaining * 5
        Sound.move\play!
      when "e"
        for loop in *getLoops! do loop\rotate 1
        score.rotates += 1
        score.points = score.rotates + score.connects * 2 + score.remaining * 5
        Sound.move\play!
      when "space"
        flash = 0.6

        game_over = true
        score.remaining = 0
        for row in *loops
          for loop in *row
            if loop\connect!
              Sound.connect\play!

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

        if game_over
          LoadState require("score"), score
      when "up" then ay = math.max 1, ay - 1
      when "down" then ay = math.min #loops[1], ay + 1
      when "left" then ax = math.max 1, ax - 1
      when "right" then ax = math.min #loops, ax + 1
      when "lshift" then rows = not rows
}
