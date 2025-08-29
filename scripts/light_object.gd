class_name LightObject
extends Sprite2D

func process_light(_light_in: LightData):
	pass

# Common hover collider for all light objects
const HOVER_LAYER_BIT := 4 # Objects on layer bit 5
const HOVER_LAYER := 1 << HOVER_LAYER_BIT

var hover_area: Area2D
var hover_shape: CollisionShape2D

func _ready() -> void:
	# Create an Area2D that matches the sprite bounds for physics picking
	if texture:
		hover_area = Area2D.new()
		hover_area.collision_layer = HOVER_LAYER
		hover_area.collision_mask = 0
		add_child(hover_area)

		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(texture.get_image())

		var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture.get_size()))
		for poly in polys:
			var collision_poly = CollisionPolygon2D.new()
			collision_poly.polygon = poly
			hover_area.add_child(collision_poly)

			if centered:
				collision_poly.position -= Vector2(bitmap.get_size()) / 2
