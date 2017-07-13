function load_ss(image,index)

  local map = {
    [0] = 0,
    [1] = 3,
    [2] = 7,
    [3] = 11,
  }

  for x = 0,127 do
    for y = 0,127 do
      sset(x,y,flr(rnd(15)))
    end
  end

  reload(0,0,0x2000,image..".p8")

  if index then
    for x = 0,127 do
      for y = 0,127 do
        local img_val = sget(x,y)
        if index == 0 then
          img_val = map[img_val%4]
        elseif index == 1 then
          img_val = map[flr(img_val/4)]
        end -- don't do anything on nil
        sset(x,y,img_val)
      end
    end
  end

  return true -- fuck you pico8
end
