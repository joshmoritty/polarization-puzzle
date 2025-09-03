class_name Junction
extends LightObject

@export var in_dirs: Array[LightData.Dir] = []
@export var out_dirs: Array[LightData.Dir] = []

func _process_light():
	var lights_out: Array[LightData] = []
	
	if in_dirs.size() == 1:
		for beam in beams_in:
			if beam.data.dir != in_dirs[0]:
				continue
			
			for dir in out_dirs:
				var data = LightData.new(
					dir,
					beam.data.intensity,
					beam.data.polar,
					beam.data.color
				)
				lights_out.push_back(data)
	else:
		for beam in beams_in:
			if beam.data.dir in in_dirs:
				var data = LightData.new(
					out_dirs[0],
					beam.data.intensity,
					beam.data.polar,
					beam.data.color
				)
				lights_out.push_back(data)

	return lights_out

func get_hover_info() -> String:
	return ""
