states.upgrade = {}

function states.upgrade.load(self)
  self.m = {
    {x=20,y=20,name="fire",exec=function() end,},
    {x=84,y=20,name="speed",exec=function() end,},
    {x=20,y=84,name="shield",exec=function() end,},
    {x=84,y=84,name="cloak",exec=function() end,},
  }
end

function states.upgrade.enter(self)
  self.fadein = 0
  self.fadeout = nil
  self.selected = 1

  for x = 0,127 do
    for y = 0,127 do
      sset(x,y,spr_orig[x][y])
    end
  end

end

function states.upgrade.draw(self)
  cls()
  for i,v in pairs(self.m) do
    if i == self.selected then
      rect(v.x-2,v.y-2,v.x+24+2,v.y+24+2)
    end
    spr(ss.ui.upgrade[i],v.x,v.y,3,3)
  end
end

function states.upgrade.update(self)
  if not self.fadein and not self.fadeout then
    if btnp(0) then
      self.selected -= 1
    end
    if btnp(1) then
      self.selected += 1
    end
    if btnp(2) then
      self.selected += 2
    end
    if btnp(3) then
      self.selected -= 2
    end
    if self.selected > 4 then
      self.selected -= 4
    elseif self.selected < 1 then
      self.selected += 4
    end
    if btnp(4) or btnp(5) then
      self.fadeout = 100
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
      changeState(states.game)
    end
  end
end
