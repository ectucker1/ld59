extends Control

func _ready() -> void:
	GlobalEvents.signal_received.connect(check_win)
	GlobalEvents.level_advance.connect(hide)

func check_win() -> void:
	var won = true
	for receiver in get_tree().get_nodes_in_group("Recievers"):
		if not receiver.received:
			won = false
	
	if won:
		GlobalEvents.level_complete.emit()
		show()
