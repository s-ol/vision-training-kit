local lg
lg = love.graphics
local score, escore, time
return {
  enter = function(passed_score)
    score = passed_score
    escore = { }
    time = -0.5
  end,
  update = function(dt)
    time = time + dt
    escore.rotates = math.floor(score.rotates * math.sqrt(math.min(1, math.max(0, time))))
    escore.connects = math.floor(score.connects * math.sqrt(math.min(1, math.max(0, time - 1.5))))
    escore.remaining = math.floor(score.remaining * math.sqrt(math.min(1, math.max(0, time - 3))))
    escore.points = escore.rotates + escore.connects * 2 + escore.remaining * 5
    if time > 1 and time - dt <= 1 then
      Sound.connect:play()
    end
    if time > 2.5 and time - dt <= 2.5 then
      Sound.connect:play()
    end
    if time > 4 and time - dt <= 4 then
      Sound.connect:play()
    end
    if time > 4.4 and time - dt <= 4.4 then
      return Sound.score:play()
    end
  end,
  draw = function()
    lg.setColor(255, 255, 255)
    lg.setBlendMode("multiply")
    lg.draw(Sprite.thursday_soft, 575, 5)
    lg.setBlendMode("alpha")
    lg.setColor(255, 255, 255)
    lg.draw(Sprite.logo, 5, 5)
    lg.draw(Sprite.score_icons, 60, 130)
    lg.draw(Sprite.restart, 630, 340)
    lg.setFont(Font)
    lg.setColor(120, 120, 120)
    lg.printf(escore.rotates, 60 + 70, 130 + 0 * 50, 60, "right")
    if time > 1.5 then
      lg.printf(escore.connects, 60 + 70, 130 + 1 * 50, 60, "right")
    end
    if time > 1.5 then
      lg.print("×2", 60 + 70 + 65, 130 + 1 * 50)
    end
    if time > 3 then
      lg.printf(escore.remaining, 60 + 70, 130 + 2 * 50, 60, "right")
    end
    if time > 3 then
      lg.print("×5", 60 + 70 + 65, 130 + 2 * 50)
    end
    local hit = math.max(0, math.min(1, (time - 4.4) * 4))
    lg.setFont(BigFont)
    lg.setColor(24, 24, 24)
    lg.print(escore.points, 350, 40)
    local w = BigFont:getWidth(tostring(escore.points))
    lg.setLineWidth(15)
    return lg.line(350 + w / 2 - hit * w / 2, 290, 350 + w / 2 + hit * w / 2, 290)
  end,
  keypressed = function(key)
    if key == "r" then
      LoadState(require("game"))
      return Sound.connect:play()
    end
  end
}
