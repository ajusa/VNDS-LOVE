all:
	moonc main.moon
	moonc lib/*.moon
	love .

test:
	moon script.moon