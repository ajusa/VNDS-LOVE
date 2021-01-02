pprint = require "lib/pprint"
import get_color from require "text_color"
color = "x1b[32;1mdemon"
color = "x1b[0m"
pprint(get_color(color))
