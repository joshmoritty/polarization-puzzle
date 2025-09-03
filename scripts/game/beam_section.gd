class_name BeamSection
extends Sprite2D

static var POLY_POINTS: PackedVector2Array = [
	Vector2(1, 8),
	Vector2(17, 16),
	Vector2(17, 23),
	Vector2(10, 27),
	Vector2(-6, 19),
	Vector2(-6, 12)
]

var beam: Beam
var area: Area2D
var poly: CollisionPolygon2D

func _init(p_beam: Beam, pos: Vector2, tex: Texture2D):
	beam = p_beam
	position = pos
	texture = tex

func _ready() -> void:
	# Create an Area2D with a rectangle shape matching the sprite for physics picking
	area = Area2D.new()
	# Use layer bit 4 (1<<3) so controller can query with a specific mask
	area.collision_layer = 1 << 3
	area.collision_mask = 0
	add_child(area)

	poly = CollisionPolygon2D.new()
	poly.polygon = POLY_POINTS
	poly.position = Vector2(-6, -18)
	area.add_child(poly)

func get_hover_info() -> String:
	if beam and beam.data:
		return beam.data.format_readout()
	return ""
