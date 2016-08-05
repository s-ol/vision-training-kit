local lg, la
do
  local _obj_0 = love
  lg, la = _obj_0.graphics, _obj_0.audio
end
math.randomseed(os.time())
for i = 1, 8 do
  math.random()
end
Font = lg.setNewFont("assets/warownia.otf", 30)
Sprite = {
  rotate = lg.newImage("assets/rotate.png"),
  rotate_active = lg.newImage("assets/rotate_active.png"),
  connect = lg.newImage("assets/connect.png"),
  connect_active = lg.newImage("assets/connect_active.png"),
  move = lg.newImage("assets/move.png"),
  move_active = lg.newImage("assets/move_active.png"),
  switch_column = lg.newImage("assets/switch_column.png"),
  switch_row = lg.newImage("assets/switch_row.png"),
  logo = lg.newImage("assets/logo.png"),
  thursday_soft = lg.newImage("assets/thursday_soft.png")
}
Sound = {
  intro = la.newSource("assets/intro.wav"),
  connect = la.newSource("assets/connect.wav"),
  move = la.newSource("assets/move.wav")
}
local state
LoadState = function(new, ...)
  state = new
  if state.enter then
    return state.enter(...)
  end
end
love.draw = function()
  if state.draw then
    return state.draw()
  end
end
love.update = function(...)
  if state.update then
    return state.update(...)
  end
end
love.keypressed = function(key, ...)
  if key == "escape" then
    return love.event.push("quit")
  elseif key == "p" then
    return LoadState(require("score"), { })
  elseif state.keypressed then
    return state.keypressed(key, ...)
  end
end
return LoadState(require("title"))
