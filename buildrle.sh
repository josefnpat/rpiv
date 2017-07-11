TARGET=src/

cd ${TARGET}images

pids=""

for file in *.png ; do
  sh full.sh ${file%.*} &
  pids="$pids $!"
done

wait $pids

echo "RLE Build Complete"
