states.cutscene = {}

function states.cutscene.load(self)
  self.c = {
    -- demo
    {
      {place='level1'},
      {placetext='earth is all but lost!'},
      {place='level2'},
      {placetext='level 2'},
      {place='level3'},
      {placetext='level 3'},
      {person0='alitahugo',},
      {persontext='i will save it!'},
      {person1='alitahugo'},
      {persontext='no, i will save it!'},
      {person1='mssinfested'},
      {persontext='i will destroy it!'},
    },
  }
  self.c = story
end

function states.cutscene.enter(self)
  self.frame = 0
  self:nextframe()
  music(musicdata.cutscene[self.current])
  menuitem(1,"skip cutscene",function()
    self.frame = #self.c[self.current]
    self.fadein = 100
  end)
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
    self.fadein = min(100,self.fadein + 4)
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
  if not frame then
    if nextState and nextState ~= states.cutscene then
      changeState(nextState)
    elseif self.current == 4 then
      changeState(states.menu)
    else
      changeState(states.game)
    end
    menuitem(1)
  else
    if frame.place or frame.person0 or frame.person1 then
      self.fadein = 0
      self.place = frame.place or false
      load_ss(
        frame.place or frame.person0 or frame.person1,
        frame.person0 and 0 or (frame.person1 and 1 or nil))
    end
  end
end
