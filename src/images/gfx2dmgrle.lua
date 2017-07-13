map = {
 ["a"] = 10,
 ["b"] = 11,
 ["c"] = 12,
 ["d"] = 13,
 ["e"] = 14,
 ["f"] = 15,
}

val_map = {
  [0] = 0, -- 00XXXX -- black
  [3] = 2^4, -- 01XXXX -- dark green
  [7] = 2^5, -- 10XXXX -- white
  [11] = 2^4+2^5, -- 11XXXX -- light green
}

-- 64 characters
lookup = [[abcdefghijklmnopqrstuvwxyz 1234567890=-+~/{};:'<,.>?!@#%^*()_"{}]]

map_max = 4 -- 6 - 2

sub = string.sub

data = {}
local ymax,xmax = 0,0
for line in io.lines(arg[1]) do
  data[ymax] = {}
  for y = 1,#line do
    local hex = sub(line,y,y)
    data[ymax][y-1] = tonumber(hex) or map[hex]
    xmax = math.max(xmax,y)
  end
  ymax = ymax + 1
end

sget = function(y,x)
  assert(data[x] and data[x][y],"No data: x:"..tostring(x).." y:"..tostring(y))
  --print("read:",data[x][y])
  return data[x][y]
end

--outputs string to host os
--(make sure to open pico-8 from a terminal)
--(x,y,max x, max y, printh)
function img2str(sx,sy,sx2,sy2)
  local ccount = 0
  local current_color = sget(sx,sy)
  local current_count = 0
  for y = sy,sy2 do
    for x = sx,sx2 do
      if current_color == sget(x,y) then
        current_count = current_count + 1
      else
        img2str_encode_color(current_color,current_count)
        current_color = sget(x,y)
        current_count = 1
        ccount = ccount + 1
      end
    end
  end
  img2str_encode_color(current_color,current_count)
  --print("color:",current_color,"count:",current_count)
  ccount = ccount + 1
end

global_c = 0

function img2str_encode_color(color,len)
  assert(val_map[color],"Character not in mapping: "..tostring(color))
  local color_val = val_map[color]
  local cur_len = len
  local rep_count = 1
  while cur_len > map_max^2 do
    cur_len = cur_len - map_max^2
    rep_count = rep_count + 1
    --print("rep:",color_val,"len:",map_max^2)
    img2str_encode_color_single(color_val,map_max^2-1)
  end
  --print("color:",color_val,"len:",cur_len)
  img2str_encode_color_single(color_val,cur_len-1)
end

function img2str_encode_color_single(color,len)
  local index = color + len
  io.write(sub(lookup,index+1,index+1))
end

img2str(0,0,xmax-1,ymax-1)
