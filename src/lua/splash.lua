states.splash = {}

function states.splash.enter()
  img = {'mss.rle','alita.rle','hugo.rle','infested.rle','level1.rle','level2.rle','level3.rle'}
  cimg = 1
end

function states.splash.draw()
  cls()
  spr(0,0,0,16,16)
end

function states.splash.update()
  if btnp(4) then
    cimg = (cimg)%#img+1
    str2img(images[img[cimg]])    
  end
  if btnp(5) then
    str2img(images['ss.rle'])
    changeState(states.game)
  end
end
