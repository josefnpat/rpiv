width = 128

map = {
 ["a"] = 10,
 ["b"] = 11,
 ["c"] = 12,
 ["d"] = 13,
 ["e"] = 14,
 ["f"] = 15,
}

rev_val_map = {
  [0] = 0, -- black
  [16] = 3, -- dark green
  [32] = 7, -- white
  [48] = 'b', -- light green
}

-- 64 characters
lookup = [[abcdefghijklmnopqrstuvwxyz 1234567890=-+~/{};:'<,.>?!@#%^*()_"{}]]

sub = string.sub

rev_map = {}
for i,v in pairs(map) do
  rev_map[v] = i
end

rev_lookup = {}
for i = 1,#lookup do
  rev_lookup[sub(lookup,i,i)] = i
end

map_max = 4 -- 6 - 2

file = io.open(arg[1])

cwidth = 0
repeat
  local c = file:read(1)
  if c then
    local rc = rev_lookup[c]-1
    --print("::input:",c,"rev:",rc)
    local b0 = math.floor(rc/32) > 0 and true or false
    --print("remainder:",rc-(b0 and 32 or 0))
    local b1 = math.floor((rc - (b0 and 32 or 0))/16) > 0 and true or false
    --print("bitmask:",b0,b1)
    local color = (b0 and 32 or 0) + (b1 and 16 or 0)
    --print(rev_val_map[color])
    local count = rc%16
    for i = 1,count+1 do
      local rcolor = rev_val_map[color]
      assert(rcolor)
      local ncolor = rev_map[rcolor] or rcolor
      --print("color["..i.."]: "..ncolor)
      io.write(rev_map[rcolor] or rcolor)
      cwidth = cwidth + 1
      if cwidth >= width then
        io.write("\n")
        cwidth = 0
      end
    end
  end
until c == nil

--[[
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

function img2str_encode_color(color,len)
  assert(val_map[color],"Character not in mapping: "..tostring(color))
  local color_val = val_map[color]
  local cur_len = len
  local rep_count = 1
  while cur_len > map_max^2 do
    cur_len = cur_len - map_max^2
    rep_count = rep_count + 1
    --print("rep:",color_val,"len:",map_max^2)
    img2str_encode_color_single(color_val,map_max^2)
  end
  --print("color:",color_val,"len:",cur_len)
  img2str_encode_color_single(color_val,cur_len)
end

function img2str_encode_color_single(color,len)
  local index = color + len
  io.write(sub(lookup,index,index))
end

img2str(0,0,xmax-1,ymax-1)
--]]
