extends Node

static var levels = [
	"res://levels/level_0.tscn",
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn",
	"res://levels/level_3.tscn",
	"res://levels/level_4.tscn",
	"res://levels/level_5.tscn",
	"res://levels/level_6.tscn",
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
