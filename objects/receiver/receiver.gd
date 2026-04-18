extends Area2D

var received := false

@export
var color = 1

func _ready() -> void:
	area_entered.connect(_area_entered)
	add_to_group("Recievers")

func _area_entered(area: Area2D) -> void:
	if area is Laser and area.color == color:
		area.received()
		received = true
		GlobalEvents.signal_received.emit()
		GlobalSounds.play("Receive")
