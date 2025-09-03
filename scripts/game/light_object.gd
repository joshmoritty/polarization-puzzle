class_name LightObject
extends Sprite2D

# Common hover collider for all light objects
const HOVER_LAYER_BIT := 4 # Objects on layer bit 5
const HOVER_LAYER := 1 << HOVER_LAYER_BIT

var pos: Vector2i
var hover_area: Area2D
var hover_shape: CollisionShape2D
var beams_in: Array[Beam] = []
var beams_out: Array[Beam] = []

func _process_light() -> Array[LightData]:
	push_error("Not implemented")
	return []

func build_beams():
	var light_out = _process_light()

	if beams_out.size() == 0:
		for data in light_out:
			_build_beam(data)
		return
	
	light_out.sort_custom(_compare_light)
	beams_out.sort_custom(func(a, b): return _compare_light(a.data, b.data))

	var used_beams = []
	for i in range(beams_out.size()):
		used_beams.push_back(false)
	
	var curr_beam_i = 0
	# Reuse same dir beams, if not existing, build new beams
	for data in light_out:
		while (curr_beam_i < used_beams.size()
				and data.dir > beams_out[curr_beam_i].data.dir):
				curr_beam_i += 1
		if curr_beam_i >= used_beams.size() or data.dir < beams_out[curr_beam_i].data.dir:
			_build_beam(data)
		elif data.equals(beams_out[curr_beam_i].data):
			used_beams[curr_beam_i] = true
			curr_beam_i += 1
		elif data.dir == beams_out[curr_beam_i].data.dir:
			beams_out[curr_beam_i].update(data)
			used_beams[curr_beam_i] = true
			curr_beam_i += 1
			
	# Remove unused beams
	for i in range(used_beams.size() - 1, -1, -1):
		if not used_beams[i]:
			beams_out[i].delete()
			beams_out.remove_at(i)

func _build_beam(data: LightData):
	var beam = Beam.new(data, pos + Controller.dir_to_vec(data.dir), owner)
	beams_out.push_back(beam)

func _compare_light(a: LightData, b: LightData):
	return (a.dir < b.dir or
		(a.dir == b.dir and (a.color < b.color or
		(a.color == b.color and (a.intensity < b.intensity or
		(a.intensity == b.intensity and a.polar < b.polar))))))

func _ready() -> void:
	pos = (owner as Controller).register_obj(self)

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
