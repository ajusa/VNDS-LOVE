keyboard_map = {
	"down": "down",
	"j": "down",
	"k": "up",
	"up": "up",
	"left": "left",
	"right": "right",
	"space": "a",
	"return": "a",
	"x": "x"
	"y": "y"
	"m": "start"
	"b": "b"
}

on "keyboard_input", =>
	if keyboard_map[@] then dispatch "input", keyboard_map[@]

gamepad_map = {
	"dpdown": "down"
	"dpup": "up"
	"dpleft": "left"
	"dpright": "right"
	"a": "a"
	"b": "b"
	"y": "y"
	"x": "x"
	"start": "start"
}

on "gamepad_input", =>
	if gamepad_map[@] then dispatch "input", gamepad_map[@]
