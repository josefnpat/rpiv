sub = string.sub

function getData(filename)
  local map = {
   ["a"] = 10,
   ["b"] = 11,
   ["c"] = 12,
   ["d"] = 13,
   ["e"] = 14,
   ["f"] = 15,
  }
  local data = {}
  local ymax,xmax = 0,0
  for line in io.lines(filename) do
    data[ymax] = {}
    for y = 1,#line do
      local hex = sub(line,y,y)
      data[ymax][y-1] = tonumber(hex) or map[hex]
      xmax = math.max(xmax,y)
    end
    ymax = ymax + 1
  end
  return data,xmax,ymax
end

sgetd = function(data,y,x)
  assert(data[x] and data[x][y],"No data: x:"..tostring(x).." y:"..tostring(y))
  return data[x][y]
end

function combineData(d0,d1)

  local val_map = {
    [0] = 0,
    [3] = 1,
    [7] = 2,
    [11] = 3,
  }

  --      p1,p0
  -- 0 .. 00,00
  -- 1 .. 00,01
  -- 2 .. 00,10
  -- 3 .. 00,11
  -- 4 .. 01,00
  -- etc
  --15 .. 11,11

  local ndata = {}

  --for x,n in pairs(d0) do
  for x = 0,127 do
    ndata[x] = {}
    for y = 0,127 do
    --for y,v in pairs(n) do
      --assert(d1[x] and d1[x][y],"data set d0 does not match d1")
      local color0,color1 = val_map[d0[x][y]],val_map[d1[x][y]]
      ndata[x][y] = color0 + color1*4
    end
  end
  --[[
  for x,n in pairs(d1) do
    for y,v in pairs(n) do
      assert(d0[x] and d0[x][y],"data set d1 does not match d0")
    end
  end
  --]]
  return ndata
end

local rev_map = {
 [10] = "a",
 [11] = "b",
 [12] = "c",
 [13] = "d",
 [14] = "e",
 [15] = "f",
}

local data1 = getData(arg[1])
local data2 = getData(arg[2])
local cdata = combineData(data1,data2)
--for x,n in pairs(cdata) do
for x = 0,127 do
  --for y,v in pairs(n) do
  for y = 0,127 do
    local v = cdata[x][y]
    io.write(rev_map[v] or v)
  end
  io.write("\n")
end
