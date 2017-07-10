states.cutscene = {}

function states.cutscene.load(self)
  self.c = {
    -- intro [1]
    {
      {draw='level1.rle'},
      {middle='earth is all but lost'},
      {draw='alita.rle'},
      {bottom='i will save it!'},
    },
  }
end

function states.cutscene.enter(self)
  self.current = self.current or 1
  self.frame = 0
  self:nextframe()
end

function states.cutscene.draw(self)
  cls()
  pallight(self.fadein or 100)
  spr(0,0,0,16,16)
  pal()
  local frame = self.c[self.current][self.frame]
  if frame.middle or frame.bottom then
    local text = sub(frame.middle or frame.bottom,1,self.textlen)
    local xoffset = (128 - #text*4)/2
    local yoffset = 128-8-4
    if frame.middle then
      yoffset = 64-4
    end
    printb(text,xoffset,yoffset)
  end
end

function states.cutscene.update(self)
  self.textlen += 1
  if self.fadein then
    self.fadein += 4
    if self.fadein >= 100 then
      self.fadein = nil
      self:nextframe()
    end
  end
  if btnp(4) or btnp(5) then
    self:nextframe()
  end
end

function states.cutscene.nextframe(self)
  self.textlen = 0
  self.frame += 1
  local frame = self.c[self.current][self.frame]
  if frame then
    if frame.draw then
      self.fadein = 0
      str2img(images[frame.draw])
    end
  else
    changeState(previousState or states.menu)
  end
end
