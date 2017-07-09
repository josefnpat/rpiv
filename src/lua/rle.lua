function decomp(src, dest, len)
  local dest0=dest
  local pos = 0
  for i=0,len/2 do
    local a=peek(src)
    local b=peek(src+1)
    src += 2
    if (a == 0) then
      poke(dest, b)
      dest += 1
    else
      memcpy(dest,dest-a,b)
      dest += b
    end
  end
  return dest-dest0
end

plookup = "abcdefghijklmnop"
clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"

datlen={1582,1876,2274,22,2480,1048,1450,1136}
ss=plookup..clookup

function indexof(s,s2)
  local ret=-1
  for i=1, #s do
    if (sub(s,i,i)==s2) then
      return i
    end
  end
  return ret
end

--converts string to image &
--draws it to the sprite sheet
function str2img(str,sx,sy,sw,trans,flip)
  sx = sx or 0
  sy = sy or 0
  sw = sw or 128
  local img={}
  local i=1
  local transparent
  if trans == nil then
    transparent = -1
  elseif type(trans) == "number" then
    transparent = trans
  end
  while (i<#str) do
    local p=indexof(plookup,sub(str,i,i))
    if transparent == nil then
      transparent = p
    end
    local c=indexof(clookup,sub(str,i+1,i+1))
    if (c==-1) then
      c=1
      i+=1
    else
      i+=2
    end
    for k=1,c do
      add(img,p)
    end
  end
  local x=sx
  local y=sy
  local offsetx = 0
  i=1
  while (i<=#img)do
    if img[i] ~= transparent then
      if flip then
        sset(sx+sw-offsetx,y,img[i]-1)
      else
        sset(x,y,img[i]-1)
      end
    end
    x+=1
    offsetx += 1
    if (x>sx+sw-1) then
      x=sx
      offsetx = 0
      y+=1
    end
    text = nil
    i+=1
  end
end
