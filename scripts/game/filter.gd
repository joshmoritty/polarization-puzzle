class_name Filter
extends LightObject

@export var dir: LightData.Dir
@export var polar: int

var _filter_outline_shader := load("res://assets/shaders/filter_outline.gdshader")
var _filter_outline_material: ShaderMaterial

func _ready():
	super._ready()
	# Apply pulsating cyan-white outline
	_filter_outline_material = ShaderMaterial.new()
	_filter_outline_material.shader = _filter_outline_shader
	material = _filter_outline_material

func _process_light():
	var lights_out: Array[LightData] = []

	for beam in beams_in:
		var data = beam.data
		if data.dir != dir:
			continue
		
		var theta = deg_to_rad(data.polar - polar)
		var intensity = data.intensity * pow(cos(theta), 2)
		lights_out.push_back(LightData.new(dir, intensity, polar, data.color))

	return lights_out

func get_hover_info() -> Array[Dictionary]:
	return [ {"text": "Polarization: %d°" % polar, "color": Color.WHITE}]
