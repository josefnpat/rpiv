states.resist = {}

function states.resist.load(self)
  self.deaths = 0
end

function states.resist.enter(self)
  self.continue = true
  self.fadein = 0
  self.fadeout = nil
  self.deaths += 1
  load_ss('level1')
end

function states.resist.draw(self)
  cls()
  spr(0,0,0,16,16)
  printc("you are shot down in",32-4)
  printc("hostile territory",32+4)

  if hard then
    printc("lives remaining: "..(4-self.deaths),60)
  end

  printc("resist? "..(self.continue and "yes" or "no"),96-4)
end

function states.resist.update(self)
  if not self.fadein and not self.fadeout then
    if btnp(4) or btnp(5) then
      self.fadeout = 100
      sfx(sfxdata.pushstart)
    end
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      sfx(sfxdata.menuscroll)
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
