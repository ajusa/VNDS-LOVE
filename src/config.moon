LIP = require "lib/LIP"
local *
data = {
	audio: {music: 1.0, sound: 1.0}
	font: {override_font: true}
}
on "load", ->
	new_data = LIP.load("config.ini")
	for key, value in *new_data --override defaults with config
		_.extend(data[key], new_data[key])
	dispatch "config", data

on "save_config", -> LIP.save('config.ini', data)
