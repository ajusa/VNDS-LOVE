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
			moonc file
			fs.delete file
	run: =>
		tasks.compile!
		shfail "love vnds"
	test: => --runs off of src directly
		tasks.compile!
		shfail "busted -m ./vnds/?.lua"
	build: =>
		tasks.compile!
		shfail "love-release -W -M --uti 'ajusa.vnds' build vnds/"

--sudo docker run -v /home/ajusa/Documents/tmp:/vnds devkitpro/devkita64_devkitarm make
--docker command for building 3dsx and nro files