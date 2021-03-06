states.upgrade = {}

function states.upgrade.load(self)
  self.m = {
    {x=20,y=20,name="fire"},
    {x=84,y=20,name="speed"},
    {x=20,y=84,name="shield"},
    {x=84,y=84,name="cloak"},
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

  self.cost = hard and {250,1000,2500} or {100,500,1000}
end

function states.upgrade.draw(self)
  cls()
  printc("buy upgrade",0)
  for i,v in pairs(self.m) do
    if i == self.selected then
      rect(v.x-2,v.y-2,v.x+25,v.y+25)
    end
    spr(ss.ui.upgrade[i],v.x,v.y,3,3)
    local name = self.m[i].name.." $"..(self:getupcost(i) or "max")
    printf(name,v.x,v.y-8-1,24)
    printf(self:getup(i).."/3",v.x,v.y+24+3,24)
  end
  printc("credits: $"..states.game.player.score,120)
end

function states.upgrade.getup(self,sel)
  sel = sel or self.selected
  return states.game.player.upgrades[self.m[sel].name]
end

function states.upgrade.getupcost(self,sel)
  self = self or self.selected
  local upl = self:getup(sel)+1
  return self.cost[upl]
end

function states.upgrade.setup(self,val,sel)
  sel = sel or self.selected
  states.game.player.upgrades[self.m[sel].name] = val
end

function states.upgrade.incup(self)
  self:setup(min(3,self:getup()+1))
end

function states.upgrade.update(self)
  if not self.fadein and not self.fadeout then
    if btnp(0) then
      self.selected -= 1
      sfx(sfxdata.menuscroll)
    end
    if btnp(1) then
      self.selected += 1
      sfx(sfxdata.menuscroll)
    end
    if btnp(2) then
      self.selected += 2
      sfx(sfxdata.menuscroll)
    end
    if btnp(3) then
      self.selected -= 2
      sfx(sfxdata.menuscroll)
    end
    if self.selected > 4 then
      self.selected -= 4
    elseif self.selected < 1 then
      self.selected += 4
    end
    if not self.fadeout then
      if btnp(4) or btnp(5) then
        local upcost = self:getupcost(self.selected)
        if upcost and upcost <= states.game.player.score then
          states.game.player.score -= self:getupcost(self.selected)
          sfx(sfxdata.upgrade)
          self:incup()
        else
          self.fadeout = 100
        end
      end
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
