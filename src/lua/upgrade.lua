states.upgrade = {}

function states.upgrade.enter(self)
  self.fadein = 0
  self.fadeout = nil
end

function states.upgrade.draw(self)
  cls()
  print"this is upgradez"
end

function states.upgrade.update(self)
  if not self.fadein and not self.fadeout then
    self.fadeout = 100
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
      changeState(states.game)
    end
  end
end
