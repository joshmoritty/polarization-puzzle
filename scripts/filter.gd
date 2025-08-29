class_name Filter
extends LightObject

@export var dir: LightData.Dir
@export var polar: int

func _process_light():
	var light_out: LightData = null

	for beam in beams_in:
		var data = beam.data
		if data.dir != dir:
			return null
		
		var theta = deg_to_rad(data.polar - polar)
		var intensity = data.intensity * pow(cos(theta), 2)
		if not light_out:
			light_out = LightData.new(dir, intensity, polar)
		else:
			light_out.intensity += intensity

	return [light_out]
