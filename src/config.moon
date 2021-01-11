LIP = require "lib/LIP"
data = {
	audio: {music: 50, sound: 50}
	font: {override_font: true}
}
-- Data saving
LIP.save('config.ini', data)
