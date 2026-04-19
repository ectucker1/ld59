extends Area2D

var received := false

@export
var color = 1

func _ready() -> void:
	area_entered.connect(_area_entered)
	add_to_group("Recievers")

func _area_entered(area: Area2D) -> void:
	if area is Laser and area.color == color and not received:
		area.received()
		received = true
		GlobalEvents.signal_received.emit()
		GlobalSounds.play("Receive")
		match color:
			1:
				$Sprite2D.texture = load("res://objects/receiver/bat_on.png")
			2:
				$Sprite2D.texture = load("res://objects/receiver_2/bat_on.png")
