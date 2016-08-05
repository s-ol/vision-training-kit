{ graphics: lg } = love

local time

{
  enter: ->
    time = 0
    lg.setBackgroundColor 240, 240, 240
    Sound.intro\play!

  draw: ->
    lg.setColor 255, 255, 255, math.min(time, 1) * 255
    lg.setBlendMode "multiply"
    lg.draw Sprite.thursday_soft, 575, 5
    lg.setBlendMode "alpha"

    local alpha
    if time < 2
      alpha = math.min 1, time
    else
      alpha = 2 - time

    lg.setColor 255, 255, 255, alpha * 255
    lg.draw Sprite.logo, 420, 320
  update: (dt) ->
    if time
      time += dt

      if time > 2 and time - dt <= 2
        Sound.connect\play!

      --if time > 3 then
        LoadState require "game"
}
