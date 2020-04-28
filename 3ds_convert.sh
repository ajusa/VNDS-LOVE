#!/bin/sh
#shopt -s globstar

find -name '*.jpg' | parallel "echo 'Converting {} to png' && convert {} {.}.png && rm {}"
find -name '*.png' | parallel "echo 'Converting {.} to t3x' && tex3ds {} -f rgba8888 -z auto -o {.}.t3x && rm {}"
find -name '*.ttf' | parallel "echo 'Converting {} to 3ds font' && mkbcfnt {} -o {.}.bcfnt && rm {}"

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
