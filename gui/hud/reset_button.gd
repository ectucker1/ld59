extends Button

func _ready() -> void:
	GlobalEvents.level_complete.connect(func(): disabled = true)
	GlobalEvents.level_advance.connect(func(): disabled = false)

func _pressed() -> void:
	reset()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("reset") and not disabled:
		reset()

func reset():
	get_tree().reload_current_scene()
