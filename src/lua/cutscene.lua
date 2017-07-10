states.cutscene = {}

function states.cutscene.load(self)
  self.c = {
    -- intro [1]
    {
      {place='level1.rle'},
      {placetext='earth is all but lost!'},
      {place='level2.rle'},
      {placetext='level 2'},
      {place='level3.rle'},
      {placetext='level 3'},
      {person='alita.rle'},
      {persontext='i will save it!'},
      {person='hugo.rle'},
      {persontext='no, i will save it!'},
      {person='infested.rle'},
      {persontext='i will destroy it!'},
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
  spr(0,0,0,16,self.place and 8 or 16)
  pal()
  local frame = self.c[self.current][self.frame]
  if frame.placetext or frame.persontext then
    local text = sub(frame.placetext or frame.persontext,1,self.textlen)
    local xoffset = (128 - #text*4)/2
    local yoffset = 128-8-4
    if frame.placetext then
      yoffset = 96-4
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
    if frame.place or frame.person then
      self.fadein = 0
      self.place = frame.place or false
      str2img(images[frame.place or frame.person])
    end
  else
    changeState(previousState or states.menu)
  end
end
