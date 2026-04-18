extends Area2D

var radius = 80

var received := false

@export
var color = 1

func _ready() -> void:
	area_entered.connect(_area_entered)

func _area_entered(area: Area2D) -> void:
	if area is Laser and area.color == color:
		area.received()
		received = true
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		visible = false
		call_deferred("explode")

func explode():
	var grid: Grid = get_tree().get_nodes_in_group("Grids")[0]
	var int_center = grid.to_local_int(global_position)
	for  y in range(int_center.y - radius, int_center.y + radius + 1):
		for x in range(int_center.x - radius, int_center.x + radius + 1):
			if x < 0 or y < 0 or x >= grid.editable_image.get_width() or y >= grid.editable_image.get_height():
				continue
			if Vector2i(x, y).distance_squared_to(int_center) > radius * radius:
				continue
			var luminance = grid.get_luminance(Grid.GridMaterial.AIR)
			grid.editable_image.set_pixelv(Vector2i(x, y), Color(luminance, luminance, luminance))
	grid.update_image()
	GlobalSounds.play("Bomb")
