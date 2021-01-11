LIP = require "lib/LIP"
local *
config = {
	audio: {music: 100, sound: 100}
	font: {override_font: false}
}
on "config_menu", ->
	copy = deepcopy(config)
	create_listbox({
		choices: {
			range(copy, "audio", "music", => "Music Volume #{@audio.music}%")
			range(copy, "audio", "sound", => "Sound Volume #{@audio.sound}%")
			toggle(copy, "font", "override_font", "Using System Font", "Using Novel Font")
			{
				text: "Save Settings",
				action: (choice, close) ->
					close!
					dispatch "save_config", copy
			}
		},
		closable: true
		onclose: -> dispatch "config", config
	})
on "load", ->
	new_config = LIP.load("config.ini")
	for key, value in pairs new_config --override defaults with config
		_.extend(config[key], new_config[key])
	dispatch "config", config

on "save_config", (new_config) ->
	config = new_config
	LIP.save('config.ini', config)
range = (copy, section, key, text) ->
	return {
		text: text(copy)
		action: ->
		right: =>
			copy[section][key] = math.min(copy[section][key] + 10, 100)
			@text = text(copy)
			dispatch "config", copy
		left: =>
			copy[section][key] = math.max(copy[section][key] - 10, 0)
			@text = text(copy)
			dispatch "config", copy
	}
toggle = (copy, section, key, true_text, false_text) ->
	text = -> if copy[section][key] then true_text else false_text
	return {
		text: text!
		action: =>
			copy[section][key] = not copy[section][key]
			@text = text!
			dispatch "config", copy
	}
