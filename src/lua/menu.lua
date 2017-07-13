function printb(t,x,y,c)
  color(3)
  for _,v in pairs({{-1,0},{1,0},{0,-1},{0,1}}) do
    print(t,x+v[1],y+v[2])
  end
  color(0)
  for _,v in pairs({{-1,-1},{1,1},{1,-1},{-1,1}}) do
    print(t,x+v[1],y+v[2])
  end
  color(c or 7)
  print(t,x,y)
end

function printc(t,y,c)
  printb(t,(128-#t*4)/2,y,c)
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
        states.game:init()
        states.cutscene.current = 1
        changeState(states.cutscene)
      end,
    },
    {
      text = function() return "story" end,
      exec = function()
        load_ss('alitahugo',1)
        self:changeMenu("story")
      end,
    },
    {
      text = function() return "options" end,
      exec = function()
        load_ss('mssinfested',1)
        self:changeMenu("options")
      end,
    },
    {
      text = function() return "music" end,
      exec = function()
        load_ss('alitahugo',1)
        self:changeMenu("sound")
      end,
    },
    {
      text = function() return "credits" end,
      exec = function()
        load_ss('alitahugo',0)
        self:changeMenu("credits")
      end,
    },
  }

  local return_to_menu = {
    text = function() return "back" end,
    exec = function()
      load_ss('alitahugo',0)
      self:changeMenu("main")
    end,
  }

  local ls = " (locked)"

  self.m.story = {
    {
      text = function()
        return "level 1"..(unlocked[1] and "" or ls)
      end,
      exec = function()
        if not unlocked[1] then return end
        states.cutscene.current = 1
        nextState = states.menu
        changeState(states.cutscene)
      end
    },
    {
      text = function() return "level 2 (locked)" end,
      text = function()
        return "level 2"..(unlocked[2] and "" or ls)
      end,
      exec = function()
        if not unlocked[2] then return end
        states.cutscene.current = 2
        nextState = states.menu
        changeState(states.cutscene)
      end
    },
    {
      text = function()
        return "level 3"..(unlocked[3] and "" or ls)
      end,
      exec = function()
        if not unlocked[3] then return end
        states.cutscene.current = 3
        nextState = states.menu
        changeState(states.cutscene)
      end
    },
    {
      text = function()
        return "ending"..(unlocked[4] and "" or ls)
      end,
      exec = function()
        if not unlocked[4] then return end
        states.cutscene.current = 4
        nextState = states.menu
        changeState(states.cutscene)
      end
    },
    return_to_menu,
  }

  self.diff_joke = "difficulty: hard"

  self.m.options = {
    {
      text = function() return self.diff_joke end,
      exec = function() self.diff_joke = "difficulty: still hard" end,
    },
    return_to_menu,
  }

  self.m.sound = {
    {
      text = function() return "level ["..self.music_level.."]" end,
      qexec = function() self.music_level = self.music_level%4+1 end,
    },
    {
      text = function() return "play cutscene "..self.music_level end,
      qexec = function()
        local pattern = musicdata.cutscene[self.music_level]
        if pattern then 
          music(pattern)
        end
      end,
    },
    {
      text = function() return "play level "..self.music_level end,
      qexec = function()
        local pattern = musicdata.level[self.music_level]
        if pattern then 
          music(pattern)
        end
      end,
    },
    {
      text = function() return "play boss "..self.music_level end,
      qexec = function()
        local pattern = musicdata.boss[self.music_level]
        if pattern then 
          music(pattern)
        end
      end,
    },
    return_to_menu,
  }

  self.m.credits = {
    {text = function() return "#fc_jam + #awfuljams" end,},
    {text = function() return "git:v"..git_count.."["..git.."]" end,},
    {text = function() return "code: josefnpat" end,},
    {text = function() return "art: bytedesigning" end,},
    {text = function() return "music/sfx: johnplzplaybass" end,},
    return_to_menu,
  }

  self.subtitles = {
    "collector's edition box set",
    "pre-order bonus dlc",
    "early access prerelease alpha",
    "not steam edition",
    "game of the year edition",
    "virtual reality release",
    "internal preview copy",
    "do not distribute",
    "pirated version",
    "insert subtitle here",
  }
  self.title = "r e d  p l a n e t  i v"
  unlocked = {}
end

function states.menu.enter(self)
  self.curm = self.m.main
  self.cur = 1
  self.fadeout = nil
  self.fadein = 100
  load_ss('alitahugo',0)
  self.music_level = 1
  music(musicdata.menu)
  local subindex = flr(rnd(#self.subtitles)+1)
  self.subtitle = self.subtitles[subindex]
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
  color(0)
  for x = -2,2,2 do
    for y = -10,0 do
      print(self.title,16+x,32+y)
    end
  end
  printb(self.title,16,32)
  printc(self.subtitle,40,3)
end

function states.menu.update(self)
  if not self.fadeout then
    if btnp(2) then
      self.cur -= 1
      sfx(sfxdata.menuscroll)
    elseif btnp(3) then
      self.cur += 1
      sfx(sfxdata.menuscroll)
    end
    if self.cur == 0 then
      self.cur = #self.curm
    end
    if self.cur > #self.curm then
      self.cur = 1
    end
  end

  if btnp(4) or btn(5) then
    if self.curm[self.cur].exec and not self.fadeout and not self.fadein then
      sfx(sfxdata.pushstart)
      self.fadeout = 0
    elseif self.curm[self.cur].qexec then
      sfx(sfxdata.pushstart)
      self.curm[self.cur].qexec()
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
