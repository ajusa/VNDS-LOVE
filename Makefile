all:
	moonc main.moon
	moonc lib/*.moon
	love .

test:
	moonc lib/*.moon
	busted