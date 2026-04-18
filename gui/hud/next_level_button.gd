extends Button

func _ready() -> void:
	GlobalEvents.connect("level_complete", func(): disabled = false)
	GlobalEvents.connect("level_advance", func(): disabled = true)

func _pressed() -> void:
	LevelSequence.next_level()
	disabled = true
