class_name Grid
extends Sprite2D

var dig_radius = 20

@export
var max_dig = 300_000

var editable_image: Image
var editable_texture: ImageTexture

const AIR_COLOR = Color("FFFFFF")
var AIR_LUMINANCE = AIR_COLOR.get_luminance()

const DIRT_COLOR = Color("FF6A00")
var DIRT_LUMINANCE = DIRT_COLOR.get_luminance()
const HARD_DIRT_COLOR = Color("FF0000")
var HARD_DIRT_LUMINANCE = HARD_DIRT_COLOR.get_luminance()

const STONE_COLOR = Color("404040")
var STONE_LUMINANCE = STONE_COLOR.get_luminance()
const HARD_STONE_COLOR = Color("000000")
var HARD_STONE_LUMINANCE = HARD_STONE_COLOR.get_luminance()

enum GridMaterial { AIR, DIRT, HARD_DIRT, STONE, HARD_STONE }

@onready
var dig_meter_remaining = max_dig
var draw_disabled = false

func _ready() -> void:
	editable_image = texture.get_image()
	editable_image.convert(Image.FORMAT_L8)
	editable_texture = ImageTexture.create_from_image(editable_image)
	texture = editable_texture
	add_to_group("Grids")
	GlobalEvents.level_advance.connect(func(): draw_disabled = false)
	GlobalEvents.level_complete.connect(func(): draw_disabled = true)
	GlobalEvents.dig_usage.emit(dig_meter_remaining, max_dig)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			draw_dig()
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			draw_dig()

# Dig at the global mouse position
func draw_dig():
	if not draw_disabled and dig_meter_remaining > 0:
		var position = InputUtil.get_global_mouse_position(self)
		dig_meter_remaining -= dig_circle(position, dig_radius)
		GlobalEvents.dig_usage.emit(dig_meter_remaining, max_dig)
		update_image()

func update_image():
	editable_texture.update(editable_image)

# Get the luminance for the given GridMaterial
func get_luminance(material: GridMaterial) -> float:
	match material:
		GridMaterial.AIR:
			return AIR_LUMINANCE
		GridMaterial.DIRT:
			return DIRT_LUMINANCE
		GridMaterial.HARD_DIRT:
			return HARD_DIRT_LUMINANCE
		GridMaterial.STONE:
			return STONE_LUMINANCE
		GridMaterial.HARD_STONE:
			return HARD_STONE_LUMINANCE
	return AIR_LUMINANCE

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
	if point.x < 0 or point.y < 0 or point.x >= editable_image.get_width() or point.y >= editable_image.get_height():
		return GridMaterial.AIR
	var pixel = editable_image.get_pixelv(point)
	for material in GridMaterial.values():
		if abs(get_luminance(material) - pixel.r) < 0.01:
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
func dig_at(point: Vector2i) -> int:
	var target_material = get_grid_material_local(point)
	if target_material == GridMaterial.DIRT or target_material == GridMaterial.STONE:
		var luminance = get_luminance(GridMaterial.AIR)
		editable_image.set_pixelv(point, Color(luminance, luminance, luminance))
		return 1
	return 0

# Remove any diggable material at ever point in a circle with the given center and radius
func dig_circle(global_center: Vector2, radius: int) -> int:
	var num_dug = 0
	var int_center = to_local_int(global_center)
	for  y in range(int_center.y - radius, int_center.y + radius + 1):
		for x in range(int_center.x - radius, int_center.x + radius + 1):
			if x < 0 or y < 0 or x >= editable_image.get_width() or y >= editable_image.get_height():
				continue
			if Vector2i(x, y).distance_squared_to(int_center) > radius * radius:
				continue
			num_dug += dig_at(Vector2i(x, y))
	return num_dug
