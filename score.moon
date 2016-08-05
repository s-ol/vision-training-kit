{ graphics: lg } = love

local score

{
  enter: (passed_score) ->
    score = passed_score

  draw: ->
    lg.setColor 255, 255, 255
    lg.setBlendMode "multiply"
    lg.draw Sprite.thursday_soft, 575, 5
    lg.setBlendMode "alpha"

    lg.setColor 255, 255, 255
    lg.draw Sprite.logo, 5, 5

    lg.setColor 24, 24, 24
    lg.print "score: #{score.points} (less = better)", 40, 120
    lg.print "r to restart", 40, 160

  keypressed: (key) ->
    if key == "r" then LoadState require "game"
}
