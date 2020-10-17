switch_url = "https://github.com/TurtleP/LovePotion/releases/download/2.0.0-pre3/LovePotion-Switch-9751a2c.zip"
shfail = (command) -> --stop execution if a command failes
    _, _, code = sh command
    os.exit(code) unless code == 0
tasks:
	icons: =>
		sh "convert icons/icon.svg -resize 48x48 icons/icon.png"
		sh "convert icons/icon.svg -resize 256x256 icons/icon.jpg"
	clean: =>
		fs.delete "vnds/" if fs.exists "vnds/"
	compile: =>
		tasks.clean!
		fs.copy "src/", "vnds/"
		for file in wildcard "vnds/**.moon"
			shfail "moonc #{file}"
			fs.delete file
	run: =>
		tasks.compile!
		shfail "love vnds"
	test: => --runs off of src directly
		shfail "busted -C src ../spec"
	build: =>
		tasks.compile!
		shfail "love-release -W -M --uti 'ajusa.vnds' build vnds/"
	lovebrew: =>
		tasks.compile!
		print(tasks.fetch(switch_url))
