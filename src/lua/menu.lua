function printb(t,x,y)
  color(0)
  for _,v in pairs({{-1,-1},{1,1},{1,-1},{-1,1}}) do
    print(t,x+v[1],y+v[2])
  end
  color(7)
  print(t,x,y)
end

function pallight(i)
  i = i or 100
  if i > 75 then
    pal(0,0) pal(3,3) pal(11,11) pal(7,7)
  elseif i > 50 then
    pal(0,0) pal(3,0) pal(11,3) pal(7,11)
  elseif i > 25 then
    pal(0,0) pal(3,0) pal(11,0) pal(7,3)
  else
    pal(0,0) pal(3,0) pal(11,0) pal(7,0)
  end
end

states.menu = {}

function states.menu.changeMenu(self,menu)
  self.curm = self.m[menu]
end

function states.menu.load(self)
  self.m = {}

  self.m.main= {
    {
      text = function() return "new game" end,
      exec = function()
        changeState(states.game)
      end,
    },
    {
      text = function() return "story" end,
      exec = function()
        str2img(images['hugo.rle'])
        self:changeMenu("story")
      end,
    },
    {
      text = function() return "options" end,
      exec = function()
        str2img(images['infested.rle'])
        self:changeMenu("options")
      end,
    },
    {
      text = function() return "credits" end,
      exec = function()
        str2img(images['alita.rle'])
        self:changeMenu("credits")
        self.cur = #self.curm
      end,
    },
  }

  local return_to_menu = {
    text = function() return "back" end,
    exec = function()
      str2img(images['alita.rle'])
      self:changeMenu("main")
    end,
  }

  self.m.story = {
    {
      text = function() return "intro" end,
      exec = function() end
    },
    {
      text = function() return "level 1 (locked)" end,
      exec = function() end
    },
    {
      text = function() return "level 2 (locked)" end,
      exec = function() end
    },
    {
      text = function() return "level 3 (locked)" end,
      exec = function() end
    },
    {
      text = function() return "ending 1 (locked)" end,
      exec = function() end
    },
    {
      text = function() return "ending 2 (locked)" end,
      exec = function() end
    },
    return_to_menu,
  }

  self.m.options = {
    {
      text = function() return "difficulty" end,
    },
    return_to_menu,
  }

  self.m.credits = {
    {text = function() return "#fc_jam & #awfuljams" end,},
    {text = function() return "code: @josefnpat" end,},
    {text = function() return "art: @bytedesigning" end,},
    {text = function() return "music/sfx: @johnplzplaybass" end,},
    return_to_menu,
  }


end

function states.menu.enter(self)
  self.curm = self.m.main
  self.cur = 1
  self.fadeout = nil
  self.fadein = 100
  str2img(images['alita.rle'])
end

function states.menu.draw(self)
  cls()
  pallight(74-(self.fadeout or self.fadein or 0))
  spr(0,0,0,16,16)
  pal()
  color(0)
  local offset = 128-8*(#self.curm+2)
  for i,v in pairs(self.curm) do
    local wrap = self.cur == i and "- " or ""
    local textoffset = (self.fadeout or self.fadein or 0)*(self.cur == i and 1 or -1)
    printb(wrap..v.text(),8+textoffset*2,8*(i-1)+offset)
  end
  local title = "r e d  p l a n e t  i v"
  color(0)
  for x = -2,2,2 do
    for y = -10,0 do
      print(title,16+x,32+y)
    end
  end
  printb(title,16,32)
end

function states.menu.update(self)
  if btnp(2) then
    self.cur -= 1
  elseif btnp(3) then
    self.cur += 1
  end
  if self.cur == 0 then
    self.cur = #self.curm
  end
  if self.cur > #self.curm then
    self.cur = 1
  end

  if btnp(4) or btn(5) then
    if self.curm[self.cur].exec and not self.fadeout and not self.fadein then
      self.fadeout = 0
    end
  end

  if self.fadeout then
    self.fadeout = self.fadeout + 4
    if self.fadeout > 100 then
      self.curm[self.cur].exec()
      self.fadein = 100
      self.cur = 1
      self.fadeout = nil
    end
  end

  if self.fadein then
    self.fadein = self.fadein - 4
    if self.fadein <= 0 then
      self.fadein = nil
    end
  end
end
