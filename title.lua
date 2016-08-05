local lg
lg = love.graphics
local time
return {
  enter = function()
    time = 0
    lg.setBackgroundColor(240, 240, 240)
    return Sound.intro:play()
  end,
  draw = function()
    lg.setColor(255, 255, 255, math.min(time, 1) * 255)
    lg.setBlendMode("multiply")
    lg.draw(Sprite.thursday_soft, 575, 5)
    lg.setBlendMode("alpha")
    local alpha
    if time < 2 then
      alpha = math.min(1, time)
    else
      alpha = 2 - time
    end
    lg.setColor(255, 255, 255, alpha * 255)
    return lg.draw(Sprite.logo, 420, 320)
  end,
  update = function(dt)
    if time then
      time = time + dt
      if time > 2 and time - dt <= 2 then
        Sound.connect:play()
        return LoadState(require("game"))
      end
    end
  end
}
