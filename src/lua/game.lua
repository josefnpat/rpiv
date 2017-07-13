states.game = {}

function states.game.init(self)

  self.player = {
    x = 64,
    y = 96,
    bullets = {},
    bullets_reload = 0,
    cloak = 0,
    cloak_reload = 0,
    shield = 3,
    upgrades = {
      fire = 0,
      speed = 0,
      shield = 0,
      cloak = 0,
    },
  }

  self.level = 1

  self.level_bg = {
    function()
      for i = 0,1 do
        spr(128,i*64,-64+self.bgoffset,8,8)
        spr(128,i*64,0+self.bgoffset,8,8)
        spr(128,i*64,64+self.bgoffset,8,8)
      end
    end,
    function()
      for i = 0,1 do
        spr(136,i*64,-64+self.bgoffset,8,4)
        spr(136,i*64,-32+self.bgoffset,8,4)
        spr(136,i*64,0+self.bgoffset,8,4)
        spr(136,i*64,32+self.bgoffset,8,4)
        spr(136,i*64,64+self.bgoffset,8,4)
        spr(136,i*64,96+self.bgoffset,8,4)
      end
    end,
    function()
      for i = 0,1 do
        spr(200,i*64,-64+self.bgoffset,8,4,i==1)
        spr(200,i*64,-32+self.bgoffset,8,4,i==1)
        spr(200,i*64,0+self.bgoffset,8,4,i==1)
        spr(200,i*64,32+self.bgoffset,8,4,i==1)
        spr(200,i*64,64+self.bgoffset,8,4,i==1)
        spr(200,i*64,96+self.bgoffset,8,4,i==1)
      end
    end
  }

end

function states.game.enter(self)

  music()

  self.player.x = 64
  self.player.y = 96
  self.player.shield = self.player.upgrades.shield
  self.player.cloak = 0
  self.player.cloak_reload = 0

  for x = 0,127 do
    for y = 0,127 do
      sset(x,y,spr_orig[x][y])
    end
  end

  self.enemies = {}
  self.enemies_stack = {}

  -- stack is backwards so i can use a[#a] as pop
  if self.level == 1 then
    add(self.enemies_stack,enemy_boss(1))
    add(self.enemies_stack,enemy_large())
    add(self.enemies_stack,enemy_small())
    add(self.enemies_stack,enemy_small())
    add(self.enemies_stack,enemy_small())
    add(self.enemies_stack,enemy_small())
  elseif self.level == 2 then
    add(self.enemies_stack,enemy_boss(2))
  else--if self.level == 3 then
    add(self.enemies_stack,enemy_boss(3))
  end

  self.enemy_spawn = 0

  self.explosions = {}
  self.bullets = {}
  self.bgoffset = 0

  self.gameover = nil
  self.nextlevel = nil
  self.fadein = 0
  pallight(self.fadein)

end

function clamp(i,mini,maxi)
  return max(mini,min(maxi,i))
end

function intersect(a,b,range)
  return abs(a.x - b.x) < range and abs(a.y - b.y) < range
end

function states.game.damage(self)
  if self.player.cloak > 0 then
    return
  elseif self.player.shield == 0 then
    if not self.gameover then
      sfx(sfxdata.playerdeath)
      self.gameover = 100
    end
  else
    self.player.shield -= 1
  end
end

function enemy_small()
  return {
    x = flr(rnd(120))+4,
    y = -8,
    reload = 0,
    direction = flr(rnd(1))*2-1,
    type = {
      sprite = ss.enemy.small[flr(rnd(#ss.enemy.small))+1],
      offset = 4,
      size = 1,
      death = function(self)
        sfx(sfxdata.explosion)
        local explosion = {
          x = self.x,
          y = self.y,
          time = 30,
        }
        add(states.game.explosions,explosion)
      end,
      update = function(self)
        self.y += 2
        self.reload = max(0,self.reload-1)
        self.direction = self.x < 4 and 1 or (self.x > 124 and -1 or self.direction)
        self.x += self.direction
        if self.reload <= 0 then
          self.reload = 30
          local bullet = {
            x = self.x,
            y = self.y,
          }
          add(states.game.bullets,bullet)
        end
      end,
    }
  }
end

function enemy_large()
  return {
    x = flr(rnd(120))+4,
    y = -16,
    reload = 0,
    direction = flr(rnd(1))*2-1,
    type = {
      sprite = ss.enemy.large[flr(rnd(#ss.enemy.large))+1],
      offset = 8,
      size = 2,
      death = function(self)
        sfx(sfxdata.explosion)
        for _,v in pairs({{-1,-1},{-1,1},{1,-1},{1,1},{0,0}}) do
          local explosion = {
            x = self.x+v[1]*8,
            y = self.y+v[2]*8,
            time = 30,
          }
          add(states.game.explosions,explosion)
        end
      end,
      update = function(self)
        self.y += 1
        self.reload = max(0,self.reload-1)
        self.direction = self.x < 4 and 1 or (self.x > 124 and -1 or self.direction)
        self.x += self.direction
        if self.reload <= 0 then
          self.reload = 30
          for i = -1,1 do
            local bullet = {
              x = self.x+i*8,
              y = self.y,
            }
            add(states.game.bullets,bullet)
          end
        end
      end,
    }
  }
end

function enemy_boss(n)
  local offset = {12,16,24}
  local size = {3,4,6}
  return {
    x = 63,
    y = -128,
    reload = 0,
    type = {
      sprite = ss.enemy.boss[n],
      offset = offset[n],
      size = size[n],
      spawn = function(self)
        music(musicdata.boss[n])
      end,
      death = function(self)
        sfx(sfxdata.bigexplosion)
        for _,v in pairs({{-1,-1},{-1,1},{1,-1},{1,1},{0,0}}) do
          local explosion = {
            x = self.x+v[1]*12,
            y = self.y+v[2]*12,
            time = 30,
          }
          add(states.game.explosions,explosion)
        end
      end,
      update = function(self)
        self.y = min(self.y + 1,32)
        self.reload = max(0,self.reload-1)
        if self.reload <= 0 then
          self.reload = 85 - n*15
          for i = -n,n do
            local bullet = {
              x = self.x+i*8,
              y = self.y,
            }
            add(states.game.bullets,bullet)
          end
        end
      end,
    }
  }

end

function states.game.update(self)

  if self.fadein then
    self.fadein = min(100,self.fadein + 4)
    pallight(self.fadein)
    if self.fadein >= 100 then
      self.fadein = nil
    end
  end

  if not self.nextlevel and #self.enemies == 0 and #self.enemies_stack == 0 then
    self.nextlevel = 100
  end

  self.bgoffset = (self.bgoffset + 1)%64

  self.enemy_spawn = max(0,self.enemy_spawn-1)
  if self.enemy_spawn == 0 then
    self.enemy_spawn = 15
    local enemy = self.enemies_stack[#self.enemies_stack]
    if enemy then
      del(self.enemies_stack,enemy)
      add(self.enemies,enemy)
      if enemy.type.spawn then
        enemy.type.spawn(enemy)
      end
    end
  end

  for _,enemy in pairs(self.enemies) do
    enemy.type.update(enemy)
    if enemy.y > 128 then
      del(self.enemies,enemy)
    end
    if intersect(enemy,self.player,4) then
      del(self.enemies,enemy)
      self:damage()
    end
  end

  for _,bullet in pairs(self.bullets) do
    bullet.y += 2
    if bullet.y > 128 then
      del(self.bullets,bullet)
    elseif intersect(bullet,self.player,4) then
      self:damage()
      del(self.bullets,bullet)
    end
  end

  for _,bullet in pairs(self.player.bullets) do
    bullet.y -= 4
    if bullet.y < 0 then
      del(self.player.bullets,bullet)
    end
    for _,enemy in pairs(self.enemies) do
      if intersect(enemy,bullet,4) then
        enemy.type.death(enemy)
        del(self.enemies,enemy)
        del(self.bullets,bullet)
      end
    end
  end

  for _,explosion in pairs(self.explosions) do
    explosion.time = max(0,explosion.time-1)
    if explosion.time == 0 then
      del(self.explosions,explosion)
    end
  end

  if btn(0) then
    self.player.x -= (self.player.upgrades.speed*0.5+1)
  end
  if btn(1) then
    self.player.x += (self.player.upgrades.speed*0.5+1)
  end
  if btn(2) then
    self.player.y -= (self.player.upgrades.speed*0.5+1)
  end
  if btn(3) then
    self.player.y += (self.player.upgrades.speed*0.5+1)
  end

  if self.gameover then
    self.player.y += 4
    self.player.y += 4
  else
    self.player.x = clamp(self.player.x,4,124)
    self.player.y = clamp(self.player.y,4,124)
  end

  self.player.bullets_reload = max(0,self.player.bullets_reload-1)
  if self.player.bullets_reload == 0 and btn(4) then
    sfx(sfxdata.weapon)
    self.player.bullets_reload = 6-self.player.upgrades.fire
    local bullet = {
      x = self.player.x,
      y = self.player.y,
    }
    add(self.player.bullets,bullet)
  end

  self.player.cloak_reload = max(0,self.player.cloak_reload-1)
  self.player.cloak = max(0,self.player.cloak-1)
  if self.player.cloak_reload == 0 and btn(5) then
    sfx(sfxdata.cloaking)
    self.player.cloak_reload = 60*5-self.player.upgrades.cloak*60
    self.player.cloak = 60
  end

  if self.gameover then
    self.gameover = max(0,self.gameover - 4)
    pallight(self.gameover)
    if self.gameover == 0 then
      self.gameover = nil
      nextState = states.cutscene
      changeState(states.resist)
    end
  end

  if self.nextlevel then
    self.nextlevel = max(0,self.nextlevel - 4)
    pallight(self.nextlevel)
    if self.nextlevel == 0 then
      self.level += 1
      states.cutscene.current += 1
      changeState(states.cutscene)
    end
  end

end

function states.game.draw(self)
  cls()
  self.level_bg[self.level]()
  palt(7,true)
  palt(0,false)
  for _,bullet in pairs(self.bullets) do
    spr(ss.enemy_bullet,bullet.x-4,bullet.y-4)
  end
  for _,bullet in pairs(self.player.bullets) do
    spr(ss.player_bullet,bullet.x-4,bullet.y-4)
  end
  for _,enemy in pairs(self.enemies) do
    spr(enemy.type.sprite,
      enemy.x-enemy.type.offset,
      enemy.y-enemy.type.offset,
      enemy.type.size,
      enemy.type.size)
  end
  for _,explosion in pairs(self.explosions) do
    local sprite = ss.explosion[3]
    if explosion.time > 20 then
      sprite = ss.explosion[2]
    elseif explosion.time > 10 then
      sprite = ss.explosion[1]
    end
    spr(sprite,explosion.x-4,explosion.y-4)
  end
  if self.player.cloak > 0 then
    spr(ss.player[2],self.player.x-8,self.player.y-8,2,2)
  else
    spr(ss.player[1],self.player.x-8,self.player.y-8,2,2)
  end
  if self.player.cloak_reload == 0 then
    spr(ss.ui.cloak[2],4,116)
  else
    spr(ss.ui.cloak[1],4,116)
  end
  for i = 1,self.player.upgrades.shield do
    if self.player.shield < i then
      spr(ss.ui.shield[1],i*8+8,116)
    else
      spr(ss.ui.shield[2],i*8+8,116)
    end
  end
  palt()
end
