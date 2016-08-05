{ graphics: lg, audio: la } = love

math.randomseed os.time!
for i=1,8 do math.random!

export ^

Font = lg.setNewFont "assets/warownia.otf", 30
BigFont = lg.newFont "assets/warownia.otf", 200

Sprite =
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

  score_icons: lg.newImage "assets/score_icons.png"
  restart: lg.newImage "assets/restart.png"

Sound =
  intro: la.newSource "assets/intro.wav"
  connect: la.newSource "assets/connect.wav"
  move: la.newSource "assets/move.wav"
  score: la.newSource "assets/score.wav"

local state
LoadState = (new, ...) ->
  state = new
  if state.enter
    state.enter ...

love.draw = -> state.draw! if state.draw
love.update = (...) -> state.update ... if state.update
love.keypressed = (key, ...) ->
  if key == "escape" then love.event.push "quit"
  elseif key == "p" then LoadState require("score"), { rotates: 14, connects: 7, remaining: 4, points: 14 + 7*2 + 4*5 }
  elseif state.keypressed then state.keypressed key, ...

LoadState require "title"
