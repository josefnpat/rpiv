function changeState(state)
  _update = function() state:update() end
  _draw = function() state:draw() end
  if not state.__loaded then
    state.__loaded = true
    if state.load then
      state:load()
    end
  end
  if state.enter then
    state:enter()
  end
end

function _init()

  if not images['ss.rle'] then
    spr_orig = {}
    for x = 0,127 do
      spr_orig[x] = {}
      for y = 0,127 do
        spr_orig[x][y] = sget(x,y)
      end
    end
  end

  changeState(states.splash)

end

function _validate_color(col)
  assert(col == 0 or col == 3 or col == 7 or col == 11 or col == nil)
end

_color = color
function color(col)
  _validate_color(col)
  _color(col)
end
_pal = pal
function pal(c0,c1,p)
  _validate_color(c0)
  _validate_color(c1)
  if c0 then
    _pal(c0,c1,p)
  else
    _pal()
  end
end
