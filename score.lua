local lg
lg = love.graphics
local score
return {
  enter = function(passed_score)
    score = passed_score
  end,
  draw = function()
    lg.setColor(255, 255, 255)
    lg.setBlendMode("multiply")
    lg.draw(Sprite.thursday_soft, 575, 5)
    lg.setBlendMode("alpha")
    lg.setColor(255, 255, 255)
    lg.draw(Sprite.logo, 5, 5)
    lg.setColor(24, 24, 24)
    lg.print("score: " .. tostring(score.points) .. " (less = better)", 40, 120)
    return lg.print("r to restart", 40, 160)
  end,
  keypressed = function(key)
    if key == "r" then
      return LoadState(require("game"))
    end
  end
}
