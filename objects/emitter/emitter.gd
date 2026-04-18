extends Node2D

@onready
var laser: PackedScene = load("res://objects/laser/laser.tscn")

func _ready() -> void:
	GlobalEvents.emit_pressed.connect(emit)

func emit():
	spawn_laser(Vector2.LEFT)
	spawn_laser(Vector2.RIGHT)
	spawn_laser(Vector2.UP)
	spawn_laser(Vector2.DOWN)
	spawn_laser(Vector2.UP + Vector2.RIGHT)
	spawn_laser(Vector2.UP + Vector2.LEFT)
	spawn_laser(Vector2.DOWN + Vector2.RIGHT)
	spawn_laser(Vector2.DOWN + Vector2.LEFT)
	
func spawn_laser(direction: Vector2):
	direction = direction.normalized()
	var spawn: Node2D = laser.instantiate()
	spawn.global_position = global_position + direction * 50.0
	spawn.rotation = direction.angle()
	spawn.direction = direction
	get_parent().add_child(spawn)
	
