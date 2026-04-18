extends Node

static var levels = [
	"res://levels/zoo.tscn",
	"res://levels/zoo.tscn",
]

const win = "res://gui/game_win/game_win.tscn"

var curr_level = 0

func first_level():
	curr_level = -1
	next_level()

func next_level():
	curr_level += 1
	if curr_level < levels.size():
		get_tree().change_scene_to_file(levels[curr_level])
		GlobalEvents.level_advance.emit()
	else:
		get_tree().change_scene_to_file(win)
		GlobalEvents.level_advance.emit()
