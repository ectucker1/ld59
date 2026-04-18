extends Area2D

var received := false

func _ready() -> void:
	area_entered.connect(_area_entered)
	add_to_group("Recievers")

func _area_entered(area: Area2D) -> void:
	if area is Laser:
		area.received()
		received = true
		GlobalEvents.signal_received.emit()
