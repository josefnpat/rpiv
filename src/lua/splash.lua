states.splash = {}

function states.splash.enter(self)
  if images['mss.rle'] then
    rle(images['mss.rle'])
  end
  self.fadein = 0
end

function states.splash.draw(self)
  cls()
  pallight(self.fadein or self.fadeout or 100)
  if images['mss.rle'] then
    spr(0,0,0,16,16)
  else
    printb("missing sentinel software",12,64-4)
    printb("presents",44,64+4)
  end
end

function states.splash.update(self)
  if btnp(4) or btnp(5) then
    self.fadein = nil
    self.fadeout = self.fadeout or 100
  end
  if self.fadein then
    self.fadein += 2
    if self.fadein > 100 then
      self.fadein = nil
      self.fadeout = 100
    end
  end
  if self.fadeout then
    self.fadeout -= 2
    if self.fadeout <= 0 then
      changeState(states.menu)
    end
  end
end
