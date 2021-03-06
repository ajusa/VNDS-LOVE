#!/bin/sh
#shopt -s globstar

find -name '*.jpg' | parallel "echo 'Converting {} to png' && convert {} {.}.png && rm {}"
find -name '*.png' | parallel "echo 'Resizing {} pngs' && convert {} -resize 40% {}"
find -name '*.png' | parallel "echo 'Converting {.} to t3x' && tex3ds {} -f rgba8888 -z auto -o {.}.t3x && rm {}"
# Below is for backgrounds since no transparency
find -name '*.png' | parallel "echo 'Converting {.} to t3x' && tex3ds {} -f rgb565 -z auto -o {.}.t3x && rm {}"
find -name '*.ttf' | parallel "echo 'Converting {} to 3ds font' && mkbcfnt {} -o {.}.fnt && rm {}"

for file in $(find -name '*.jpg') ; do
	echo "Converting $file to png"
	convert "$file" "${file%.jpg}".png &&
	rm "$file"
done

for file in $(find -name '*.png') ; do
	echo "Converting $file to t3x"
	tex3ds "$file" -f rgba8888 -z auto -o "${file%.png}".t3x &&
	rm "$file"
done

for file in $(find -name '*.ttf') ; do
	echo "Converting $file to 3ds font"
	mkbcfnt "$file" -o "${file%.ttf}".bcfnt &&
	rm "$file"
done

find -name '*.jpg' | parallel "echo 'Upscaling {}' && Anime4KCPP_CLI -i {} -o {} -z 2 -a -b"
ftp 192.168.1.106 5000 < ftp.in
