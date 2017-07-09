function changeState(state)
  _update = state.update
  _draw = state.draw
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
  changeState(states.splash)
end
