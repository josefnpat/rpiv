states.resist = {}

function states.resist.enter(self)
  self.continue = true
  self.fadein = 0
  self.fadeout = nil
  load_ss('level1')
end

function states.resist.draw(self)
  cls()
  spr(0,0,0,16,16)
  printc("you are shot down in",32-4)
  printc("hostile territory",32+4)
  printc("resist? "..(self.continue and "yes" or "no"),96-4)
end

function states.resist.update(self)
  if not self.fadein and not self.fadeout then
    if btnp(4) or btnp(5) then
      self.fadeout = 100
    end
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      self.continue = not self.continue
    end
  end
  if self.fadein then
    self.fadein = min(100,self.fadein + 4)
    pallight(self.fadein)
    if self.fadein == 100 then
      self.fadein = nil
    end
  elseif self.fadeout then
    self.fadeout = max(0,self.fadeout - 4)
    pallight(self.fadeout)
    if self.fadeout == 0 then
      self.fadeout = nil
      if self.continue then
        states.game.level = 1
        states.cutscene.current = 1
        changeState(states.upgrade)
      else
        nextState = nil
        changeState(states.menu)
      end
    end
  end
end
