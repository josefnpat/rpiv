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
      fire = 3,
      speed = 3,
      shield = 3,
      cloak = 3,
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

  for x = 0,127 do
    for y = 0,127 do
      sset(x,y,spr_orig[x][y])
    end
  end

  self.enemies = {}
  self.enemy_spawn = 0

  self.explosions = {}
  self.bullets = {}
  self.bgoffset = 0

  self.gameover = nil
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
  if self.player.shield == 0 then
    self.gameover = 100
  else
    self.player.shield -= 1
  end
end

function states.game.update(self)

  if self.fadein then
    self.fadein = min(100,self.fadein + 4)
    pallight(self.fadein)
    if self.fadein >= 100 then
      self.fadein = nil
    end
  end

  self.bgoffset = (self.bgoffset + 1)%64

  self.enemy_spawn = max(0,self.enemy_spawn-1)
  if self.enemy_spawn == 0 then
    self.enemy_spawn = 15
    local enemy = {
      x = rnd(127),
      y = 0,
      reload = 0,
      direction = flr(rnd(1))*2-1,
      type = {
        sprite = ss.enemy.small[flr(rnd(#ss.enemy.small))+1],
        offset = 4,
        update = function(self)
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
    add(self.enemies,enemy)
  end

  for _,enemy in pairs(self.enemies) do
    enemy.type.update(enemy)
    enemy.y += 1
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
        del(self.enemies,enemy)
        del(self.bullets,bullet)
        local explosion = {
          x = bullet.x,
          y = bullet.y,
          time = 30,
        }
        add(self.explosions,explosion)
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
    self.player.x -= self.player.upgrades.speed
  end
  if btn(1) then
    self.player.x += self.player.upgrades.speed
  end
  if btn(2) then
    self.player.y -= self.player.upgrades.speed
  end
  if btn(3) then
    self.player.y += self.player.upgrades.speed
  end

  self.player.x = clamp(self.player.x,4,124)
  self.player.y = clamp(self.player.y,4,124)

  self.player.bullets_reload = max(0,self.player.bullets_reload-1)
  if self.player.bullets_reload == 0 and btn(4) then
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
    self.player.cloak_reload = 360
    self.player.cloak = 60
  end

  if self.gameover then
    self.gameover = max(0,self.gameover - 4)
    pallight(self.gameover)
    if self.gameover == 0 then
      self.gameover = nil
      changeState(states.resist)
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
    spr(enemy.type.sprite,enemy.x-enemy.type.offset,enemy.y-enemy.type.offset)
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
    spr(ss.ui.cloak[1],0,120)
  else
    spr(ss.ui.cloak[2],0,120)
  end
  for i = 1,self.player.upgrades.shield do
    if self.player.shield < i then
      spr(ss.ui.shield[1],i*8,120)
    else
      spr(ss.ui.shield[2],i*8,120)
    end
  end
  palt()
end
