class_name Filter
extends LightObject

@export var dir: LightData.Dir
@export var polar: int

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
