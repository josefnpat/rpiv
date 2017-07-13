function dmgrle(str,sx,sy,width)
  sx = sx or 0
  sy = sy or 0
  width = width or 128

  local map = {
   ["a"] = 10,
   ["b"] = 11,
   ["c"] = 12,
   ["d"] = 13,
   ["e"] = 14,
   ["f"] = 15,
  }

  local rev_val_map = {
    [0] = 0, -- black
    [16] = 3, -- dark green
    [32] = 7, -- white
    [48] = 'b', -- light green
  }

  -- 64 characters
  local lookup = [[abcdefghijklmnopqrstuvwxyz 1234567890=-+~/{};:'<,.>?!@#%^*()_"{}]]

  local rev_map = {}
  for i,v in pairs(map) do
    rev_map[v] = i
  end

  local rev_lookup = {}
  for i = 1,#lookup do
    rev_lookup[sub(lookup,i,i)] = i
  end

  local map_max = 4 -- 6 - 2

  local x,y = sx,sy

  local cwidth = 0
  for stri = 1,#str do
    local c = sub(str,stri,stri)
    local rc = rev_lookup[c]-1
    --print("::input:",c,"rev:",rc)
    local b0 = flr(rc/32) > 0 and true or false
    --print("remainder:",rc-(b0 and 32 or 0))
    local b1 = flr((rc - (b0 and 32 or 0))/16) > 0 and true or false
    --print("bitmask:",b0,b1)
    local color = (b0 and 32 or 0) + (b1 and 16 or 0)
    --print(rev_val_map[color])
    local count = rc%16
    for i = 0,count do
      local rcolor = rev_val_map[color]
      assert(rcolor)
      local ncolor = rev_map[rcolor] or rcolor
      --print("color["..i.."]: "..ncolor)
      --io.write(rev_map[rcolor] or rcolor)
      sset(x,y,ncolor)
      x = x + 1
      cwidth = cwidth + 1
      if cwidth >= width then
        --io.write("\n")
        x = sx
        y = y + 1
        cwidth = 0
      end
    end
  end

end
