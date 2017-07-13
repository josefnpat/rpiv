-- idk fuck you pico8
sub = string.sub

plookup = "abcdefghijklmnop"
--clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"
clookup = [[-!"#$%()*,./:;?[^_{}+<=>0123456789qrstuvwxyz]]

map = {
 ["a"] = 10,
 ["b"] = 11,
 ["c"] = 12,
 ["d"] = 13,
 ["e"] = 14,
 ["f"] = 15,
}

data = {}
local xmax,ymax = 0,0
for line in io.lines(arg[1]) do
  data[xmax] = {}
  for y = 1,#line do
    local hex = sub(line,y,y)
    data[xmax][y-1] = tonumber(hex) or map[hex]
    ymax = math.max(ymax,y)
  end
  xmax = xmax + 1
end

sget = function(y,x)
  assert(data[x] and data[x][y],"No data: x:"..tostring(x).." y:"..tostring(y))
  return data[x][y]
end


--outputs string to host os
--(make sure to open pico-8 from a terminal)
--(x,y,max x, max y, printh)
function img2str(sx,sy,sx2,sy2)
  local p = -1
  local c = 1
  local img = ""
  for y = sy,sy2 do
    for x = sx,sx2 do
      local px = sget(x,y)+1
      if (px ~= p or c>=#clookup) then
        if (p ~= -1) then
          img = img..sub(plookup,p,p)
          if (c>1) then
           img = img..sub(clookup,c,c)
          end
        end
        p = px
        c = 1
      else
        c = c + 1
      end
    end
  end
  img = img..sub(plookup,p,p)..sub(clookup,c,c)
  return img
end

print(img2str(0,0,ymax-1,xmax-1))
