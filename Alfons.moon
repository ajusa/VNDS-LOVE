tasks:
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
		sh "love vnds"
	test: => --runs off of src directly
		tasks.compile!
		sh "busted -m ./vnds/?.lua"