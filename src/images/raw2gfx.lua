map = {
  ["000000"] = 0,
  ["1D2B53"] = 1,
  ["7E2553"] = 2,
  ["008751"] = 3,
  ["AB5236"] = 4,
  ["5F574F"] = 5,
  ["C2C3C7"] = 6,
  ["FFF1E8"] = 7,
  ["FF004D"] = 8,
  ["FFA300"] = 9,
  ["FFEC27"] = "a",
  ["00E436"] = "b",
  ["29ADFF"] = "c",
  ["83769C"] = "d",
  ["FF77A8"] = "e",
  ["FFCCAA"] = "f",
}

data = {}

for line in io.lines(arg[1]) do
  -- 117,127: (65535,61937,59624)  #FFF1E8  srgb(255,241,232)
  --print(string.match(line,'^(%d+),(%d+):%s*%(%s*(%d+),%s*(%d+),%s'))
  local rx,ry,_,_,_,hex,_ = string.match(line,'^(%d+),(%d+):%s+%(%s*(%d+),%s*(%d+),%s*(%d+)%)%s+#(%x+)%s+(.+)$')
  --print(line)
  --print("what:",rx,ry)
  mx,my = tonumber(rx)+1,tonumber(ry)+1
  assert(map[hex],'invalid color: '..hex)
  if not data[my] then
    data[my] = {}
  end
  data[my][mx] = map[hex]
end

for x,n in ipairs(data) do
  for y,v in ipairs(n) do
    io.write(v)
  end
  io.write("\n")
end
