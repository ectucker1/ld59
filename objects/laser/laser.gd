class_name Laser
extends Area2D

var speed := 200.0

var direction: Vector2

@onready
var target: Node2D = $Target

var grid: Grid

@export
var color := 1

func _ready() -> void:
	grid = get_tree().get_nodes_in_group("Grids")[0]
	area_entered.connect(_area_entered)

func _physics_process(delta: float) -> void:
	# Move forwards
	global_position += direction * delta * speed
	# Sample the material at the front position
	var hit_material = grid.get_grid_material_global(target.global_position)
	# Absorb when we hit dirt
	if hit_material == Grid.GridMaterial.DIRT or hit_material == Grid.GridMaterial.HARD_DIRT:
		queue_free()
	# Bounce when we hit stone
	elif hit_material == Grid.GridMaterial.STONE or hit_material == Grid.GridMaterial.HARD_STONE:
		var normal = grid.get_stone_normal_global(target.global_position)
		if normal != Vector2.ZERO:
			DebugOverlay.draw_vector_from(target.global_position, normal * 50, Color.AQUA)
			global_position = target.global_position
			direction = direction.bounce(normal)
			rotation = direction.angle()

func _area_entered(area: Area2D):
	if area is Laser and area.color != color:
		received()
		GlobalSounds.play("Fizzle")

func received():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	queue_free()
