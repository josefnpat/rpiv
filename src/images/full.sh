echo "[$1] png -> raw"
sh png2raw.sh $1.png > $1.raw
echo "[$1] raw -> gfx"
lua raw2gfx.lua $1.raw > $1.gfx
echo "[$1] gfx -> rle"
lua gfx2rle.lua $1.gfx > $1.rle
#echo "[$1] gfx -> [dmg]lre"
#lua gfx2dmgrle.lua $1.gfx > $1.rle
echo "[$1] done"
