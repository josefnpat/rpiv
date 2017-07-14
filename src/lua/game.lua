states.game = {}

function states.game.init(self)

  self.firing_pattern = {
    [0] = {0},
    [1] = {-1,1},
    [2] = {-1,1},
    [3] = {-2,0,2},
  }

  self.player = {
    score = 0,
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
    function(sx,sy)
      for i = 0,1 do
        spr(128,i*64+sx,-64+self.bgoffset+sy,8,8)
        spr(128,i*64+sx,0+self.bgoffset+sy,8,8)
        spr(128,i*64+sx,64+self.bgoffset+sy,8,8)
      end
    end,
    function(sx,sy)
      for i = 0,1 do
        spr(136,i*64+sx,-64+self.bgoffset+sy,8,4)
        spr(136,i*64+sx,-32+self.bgoffset+sy,8,4)
        spr(136,i*64+sx,0+self.bgoffset+sy,8,4)
        spr(136,i*64+sx,32+self.bgoffset+sy,8,4)
        spr(136,i*64+sx,64+self.bgoffset+sy,8,4)
        spr(136,i*64+sx,96+self.bgoffset+sy,8,4)
      end
    end,
    function(sx,sy)
      for i = 0,1 do
        spr(200,i*64+sx,-64+self.bgoffset+sy,8,4,i==1)
        spr(200,i*64+sx,-32+self.bgoffset+sy,8,4,i==1)
        spr(200,i*64+sx,0+self.bgoffset+sy,8,4,i==1)
        spr(200,i*64+sx,32+self.bgoffset+sy,8,4,i==1)
        spr(200,i*64+sx,64+self.bgoffset+sy,8,4,i==1)
        spr(200,i*64+sx,96+self.bgoffset+sy,8,4,i==1)
      end
    end
  }

end

function states.game.enter(self)

  music(musicdata.level[self.level])

  self.player.x = 64
  self.player.y = 96
  self.player.shield = self.player.upgrades.shield
  self.player.cloak = 0
  self.player.cloak_reload = 0
  self.player.bullets = {}

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
    for i = 1,10 do
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_small())
    end
  elseif self.level == 2 then
    add(self.enemies_stack,enemy_boss(2))
    for i = 1,15 do
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
    end
  else--if self.level == 3 then
    add(self.enemies_stack,enemy_boss(3))
    for i = 1,20 do
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
      add(self.enemies_stack,enemy_large())
      add(self.enemies_stack,enemy_small())
    end
  end

  self.enemy_spawn = 120

  self.explosions = {}
  self.bullets = {}
  self.bgoffset = 0
  self.shakeinten = 0
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
  self.shakeinten = 30
  self.player.cloak = 60
end

function enemy_small()
  return {
    hp = 2,
    x = flr(rnd(120))+4,
    y = -8,
    reload = 0,
    direction = flr(rnd(2))*2-1,
    type = {
      sprite = ss.enemy.small[flr(rnd(#ss.enemy.small))+1],
      offset = 4,
      size = 1,
      death = function(self)
        states.game.player.score += 5
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
    hp = 8,
    x = flr(rnd(120))+4,
    y = -16,
    reload = 0,
    direction = flr(rnd(2))*2-1,
    type = {
      sprite = ss.enemy.large[flr(rnd(#ss.enemy.large))+1],
      offset = 8,
      size = 2,
      death = function(self)
        states.game.player.score += 20
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
    hp = offset[n]*20,
    x = 63,
    y = -128,
    reload = 0,
    direction = flr(rnd(2))*2-1,
    type = {
      sprite = ss.enemy.boss[n],
      offset = offset[n],
      size = size[n],
      spawn = function(self)
        music(musicdata.boss[n])
      end,
      death = function(self)
        states.game.player.score += 50*offset[n]
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
        self.direction = self.x < 16 and 1 or (self.x > 96 and -1 or self.direction)
        if self.y == 32 then
          self.x += self.direction*n
        end
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

  self.shakeinten = max(0,self.shakeinten-1)

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
    self.enemy_spawn = hard and 10-self.level*3 or 60-self.level*15
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
    if intersect(enemy,self.player,8) then
      self:damage()
    end
  end

  for _,bullet in pairs(self.bullets) do
    bullet.y += 2
    if bullet.y > 128 then
      del(self.bullets,bullet)
    elseif intersect(bullet,self.player,8) then
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
      if intersect(enemy,bullet,enemy.type.size*4) then
        if enemy.hp > 1 then
          enemy.hp -= 1
          local explosion = {
            x = bullet.x,
            y = bullet.y,
            time = 30,
          }
          add(self.explosions,explosion)
        else
          del(self.enemies,enemy)
          enemy.type.death(enemy)
        end
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
    self.player.x -= (self.player.upgrades.speed/2+1.5)
  end
  if btn(1) then
    self.player.x += (self.player.upgrades.speed/2+1.5)
  end
  if btn(2) then
    self.player.y -= (self.player.upgrades.speed/2+1.5)
  end
  if btn(3) then
    self.player.y += (self.player.upgrades.speed/2+1.5)
  end

  if self.gameover then
    self.player.y += 4
    self.player.y += 4
  else
    self.player.x = clamp(self.player.x,4,124)
    self.player.y = clamp(self.player.y,4+32,124)
  end

  self.player.bullets_reload = max(0,self.player.bullets_reload-1)
  if self.player.bullets_reload == 0 and btn(4) then
    sfx(sfxdata.weapon)
    self.player.bullets_reload = 8-self.player.upgrades.fire
    for _,v in pairs(self.firing_pattern[self.player.upgrades.fire]) do
      local bullet = {
        x = self.player.x+v*4,
        y = self.player.y,
      }
      add(self.player.bullets,bullet)
    end
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

function states.game.s(self)--shake
  return (flr(rnd(5))-2)*(self.shakeinten/10)
end

function states.game.draw(self)
  cls()
  self.level_bg[self.level](self:s(),self:s())
  palt(7,true)
  palt(0,false)
  for _,bullet in pairs(self.bullets) do
    spr(ss.enemy_bullet,bullet.x-4+self:s(),bullet.y-4+self:s())
  end
  for _,bullet in pairs(self.player.bullets) do
    spr(ss.player_bullet,bullet.x-4+self:s(),bullet.y-4+self:s())
  end
  for _,enemy in pairs(self.enemies) do
    spr(enemy.type.sprite,
      enemy.x-enemy.type.offset+self:s(),
      enemy.y-enemy.type.offset+self:s(),
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
    spr(sprite,explosion.x-4+self:s(),explosion.y-4+self:s())
  end
  if self.player.cloak > 0 then
    spr(ss.player[2],self.player.x-8+self:s(),self.player.y-8+self:s(),2,2)
  else
    spr(ss.player[1],self.player.x-8+self:s(),self.player.y-8+self:s(),2,2)
  end
  if self.player.cloak_reload == 0 then
    spr(ss.ui.cloak[2],4+self:s(),116+self:s())
  else
    spr(ss.ui.cloak[1],4+self:s(),116+self:s())
  end
  for i = 1,self.player.upgrades.shield do
    if self.player.shield < i then
      spr(ss.ui.shield[1],i*8+8+self:s(),116+self:s())
    else
      spr(ss.ui.shield[2],i*8+8+self:s(),116+self:s())
    end
  end
  palt()
  printc(self.player.score.."",2+self:s())
  if hard then
    printc("!easy mode!",28)
  end
end
