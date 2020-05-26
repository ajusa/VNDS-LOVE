all:
	moonc main.moon
	moonc lib/*.moon
	love .

test: compile
	busted

compile:
	pushd src
	for f in `find . -name '*.moon'`; do
	  moonc -t ../build "$f"
	done
	popd