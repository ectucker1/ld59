class_name Grid
extends Sprite2D

var editable_image: Image
var editable_texture: ImageTexture

const AIR_COLOR = Color("FFFFFF")

const DIRT_COLOR = Color("FF6A00")
const HARD_DIRT_COLOR = Color("FF0000")

const STONE_COLOR = Color("404040")
const HARD_STONE_COLOR = Color("000000")

enum GridMaterial { AIR, DIRT, HARD_DIRT, STONE, HARD_STONE }

func _ready() -> void:
	editable_image = texture.get_image()
	editable_texture = ImageTexture.create_from_image(editable_image)
	texture = editable_texture
	add_to_group("Grids")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			draw_dig()
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			draw_dig()

# Dig at the global mouse position
func draw_dig():
	var position = InputUtil.get_global_mouse_position(self)
	dig_circle(position, 20)
	editable_texture.update(editable_image)

# Get the color for the given GridMaterial
func get_color(material: GridMaterial) -> Color:
	match material:
		GridMaterial.AIR:
			return AIR_COLOR
		GridMaterial.DIRT:
			return DIRT_COLOR
		GridMaterial.HARD_DIRT:
			return HARD_DIRT_COLOR
		GridMaterial.STONE:
			return STONE_COLOR
		GridMaterial.HARD_STONE:
			return HARD_STONE_COLOR
	return AIR_COLOR

# Convert a position from global space to the image coordinates
func to_local_int(global_point: Vector2) -> Vector2i:
	var local_point = to_local(global_point)
	var int_point = Vector2i(roundi(local_point.x), roundi(local_point.y))
	return int_point

# Get the grid material at the given global coordinate
func get_grid_material_global(point: Vector2) -> GridMaterial:
	return get_grid_material_local(to_local_int(point))

# Get the grid material at the given local coordinate
func get_grid_material_local(point: Vector2i) -> GridMaterial:
	var pixel = editable_image.get_pixelv(point)
	for material in GridMaterial.values():
		if get_color(material).is_equal_approx(pixel):
			return material
	return GridMaterial.AIR

# Estimate the normal vector away from the stone at the given global coordinate
func get_stone_normal_global(point: Vector2) -> Vector2:
	return get_stone_normal_local(to_local_int(point))

# Estimate the normal vector away from the stone at the given local coordinate
func get_stone_normal_local(center: Vector2i) -> Vector2:
	var normal := Vector2.ZERO
	for y in range(center.y - 2, center.y + 3):
		for x in range(center.x - 2, center.x + 3):
			if x == center.x and y == center.y:
				continue
			if x < 0 or y < 0 or x >= editable_image.get_width() or y >= editable_image.get_height():
				continue
			var material := get_grid_material_local(Vector2i(x, y))
			if material == GridMaterial.STONE or material == GridMaterial.HARD_STONE:
				normal += Vector2(center) - Vector2(x, y)
	return normal.normalized() if normal.length_squared() > 0.0 else Vector2.ZERO

# Remove any diggable material at the given point
func dig_at(point: Vector2i) -> bool:
	var target_material = get_grid_material_local(point)
	if target_material == GridMaterial.DIRT or target_material == GridMaterial.STONE:
		editable_image.set_pixelv(point, get_color(GridMaterial.AIR))
	return false

# Remove any diggable material at ever point in a circle with the given center and radius
func dig_circle(global_center: Vector2, radius: int):
	var int_center = to_local_int(global_center)
	for  y in range(int_center.y - radius, int_center.y + radius + 1):
		for x in range(int_center.x - radius, int_center.x + radius + 1):
			if x < 0 or y < 0 or x >= editable_image.get_width() or y >= editable_image.get_height():
				continue
			if Vector2i(x, y).distance_squared_to(int_center) > radius * radius:
				continue
			dig_at(Vector2i(x, y))
