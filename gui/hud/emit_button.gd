extends Button

@export
var cooldown := 0.1

var last_pressed := INF

func _ready() -> void:
	GlobalEvents.level_complete.connect(func(): disabled = true)
	GlobalEvents.level_advance.connect(func(): disabled = false)

func _pressed() -> void:
	do_emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("emit") and not disabled:
		do_emit()

func _process(delta: float) -> void:
	last_pressed += delta

func do_emit():
	if last_pressed > cooldown:
		GlobalEvents.emit_pressed.emit()
		last_pressed = 0.0
