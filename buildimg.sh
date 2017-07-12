TARGET=src/

cd ${TARGET}images

echo "Cleaning up"
rm *.raw
rm *.gfx
rm *.rle
echo "done"


echo "RAW build [threaded]"
pids=""
for file in *.png ; do
  echo "[$file] png -> raw"
  sh png2raw.sh ${file%.*}.png > ${file%.*}.raw &
  pids="$pids $!"
done
wait $pids
echo "done"

echo "GFX build [threaded]"
pids=""
for file in *.raw ; do
  echo "[$file] raw -> gfx"
  lua raw2gfx.lua ${file%.*}.raw > ${file%.*}.gfx &
  pids="$pids $!"
done
wait $pids
echo "done"

echo "GFX combine [threaded]"
pids=""
lua gfx2dmg.lua mss.gfx infested.gfx > mssinfested.gfx &
lua gfx2dmg.lua alita.gfx hugo.gfx > alitahugo.gfx &
#lua gfx2dmg.lua level1.gfx level2.gfx > level1level2.gfx &
wait $pids
echo "done"

echo "GFX cleanup"
rm mss.gfx
rm infested.gfx
rm alita.gfx
rm hugo.gfx
rm test.gfx
cp ss.gfx ../gfx
rm ss.gfx
#rm level1.gfx
#rm level2.gfx
echo "done"

echo "RLE build [threaded]"
pids=""
for file in *.gfx ; do
  echo "[$file] gfx -> rle"
  lua gfx2rle.lua ${file%.*}.gfx > ${file%.*}.rle &
  pids="$pids $!"
done
wait $pids
echo "done"
