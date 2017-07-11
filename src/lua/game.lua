states.game = {}

function states.game.enter()

  music()

  if images['ss.rle'] then
    rle(images['ss.rle'])
  else
    for x = 0,127 do
      for y = 0,127 do
        sset(x,y,spr_orig[x][y])
      end
    end
  end

  player = {
    x = 64,
    y = 96,
    bullets = {},
    bullets_reload = 0,
    cloak = 0,
    cloak_reload = 0,
    shield = 1,
    upgrades = {
      fire = 0,
      speed = 0,
      shield = 2,
      cloak = 0,
    },
  }

  enemies = {}
  enemy_spawn = 0

  explosions = {}
  bullets = {}
  bgoffset = 0
end

function clamp(i,mini,maxi)
  return max(mini,min(maxi,i))
end

function intersect(a,b,range)
  return abs(a.x - b.x) < range and abs(a.y - b.y) < range
end

function damage()
  if player.shield == 0 then
    -- gameover
  else
    player.shield -= 1
  end
end

function states.game.update()

  bgoffset = (bgoffset + 1)%64

  enemy_spawn = max(0,enemy_spawn-1)
  if enemy_spawn == 0 then
    enemy_spawn = 15
    local enemy = {
      x = rnd(127),
      y = 0,
      reload = 0,
      direction = flr(rnd(1))*2-1,
      type = {
        sprite = 5,
        offset = 4,
        update = function(self)
          self.reload = max(0,self.reload-1)
          self.direction = self.x < 4 and 1 or (self.x > 124 and -1 or self.direction)
          self.x += self.direction
          if self.reload == 0 then
            self.reload = 30
            local bullet = {
              x = self.x,
              y = self.y,
            }
            add(bullets,bullet)
          end
        end,
      }
    }
    add(enemies,enemy)
  end

  for _,enemy in pairs(enemies) do
    enemy.type.update(enemy)
    enemy.y += 1
    if enemy.y > 128 then
      del(enemies,enemy)
    end
    if intersect(enemy,player,4) then
      del(enemies,enemy)
      damage()
    end
  end

  for _,bullet in pairs(bullets) do
    bullet.y += 2
    if bullet.y > 128 then
      del(bullets,bullet)
    elseif intersect(bullet,player,4) then
      damage()
      del(bullets,bullet)
    end
  end

  for _,bullet in pairs(player.bullets) do
    bullet.y -= 4
    if bullet.y < 0 then
      del(player.bullets,bullet)
    end
    for _,enemy in pairs(enemies) do
      if intersect(enemy,bullet,4) then
        del(enemies,enemy)
        del(bullets,bullet)
        local explosion = {
          x = bullet.x,
          y = bullet.y,
          time = 30,
        }
        add(explosions,explosion)
      end
    end
  end

  for _,explosion in pairs(explosions) do
    explosion.time = max(0,explosion.time-1)
    if explosion.time == 0 then
      del(explosions,explosion)
    end
  end

  if btn(0) then
    player.x -= 1
  end
  if btn(1) then
    player.x += 1
  end
  if btn(2) then
    player.y -= 1
  end
  if btn(3) then
    player.y += 1
  end

  player.x = clamp(player.x,4,124)
  player.y = clamp(player.y,4,128)

  player.bullets_reload = max(0,player.bullets_reload-1)
  if player.bullets_reload == 0 and btn(4) then
    player.bullets_reload = 2
    local bullet = {
      x = player.x,
      y = player.y,
    }
    add(player.bullets,bullet)
  end

  player.cloak_reload = max(0,player.cloak_reload-1)
  player.cloak = max(0,player.cloak-1)
  if player.cloak_reload == 0 and btn(5) then
    player.cloak_reload = 360
    player.cloak = 60
  end

end

function states.game.draw()
  cls()
  spr(128,0,-64+bgoffset,16,8)
  spr(128,0,0+bgoffset,16,8)
  spr(128,0,64+bgoffset,16,8)
  for _,bullet in pairs(bullets) do
    spr(4,bullet.x-4,bullet.y-4)
  end
  for _,bullet in pairs(player.bullets) do
    spr(4,bullet.x-4,bullet.y-4)
  end
  for _,enemy in pairs(enemies) do
    spr(enemy.type.sprite,enemy.x-enemy.type.offset,enemy.y-enemy.type.offset)
  end
  for _,explosion in pairs(explosions) do
    local sprite = 12
    if explosion.time > 20 then
      sprite = 10
    elseif explosion.time > 10 then
      sprite = 11
    end
    spr(sprite,explosion.x-4,explosion.y-4)
  end
  if player.cloak > 0 then
    spr(2,player.x-8,player.y-8,2,2)
  else
    spr(0,player.x-8,player.y-8,2,2)
  end
  if player.cloak_reload == 0 then
    spr(9,0,120)
  else
    spr(8,0,120)
  end
  for i = 1,player.upgrades.shield do
    if player.shield < i then
      spr(6,i*8,120)
    else
      spr(7,i*8,120)
    end
  end
end
