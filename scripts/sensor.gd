class_name Sensor
extends LightObject

@export var dir: LightData.Dir
@onready var label: Label = %"SensorReadout"

func _process_light():
	if beams_in.size() == 0:
		return []
	
	beams_in.sort_custom(_compare_color)
	var text_lines: Array[String] = []

	for beam in beams_in:
		var data = beam.data
		if data.dir != dir:
			continue
		
		if beams_in.size() > 1:
			text_lines.append("Color: %s" % LightColor.enum_to_string(data.color))
		text_lines.append("Intensity: %.2f" % data.intensity)
		text_lines.append("Polarization: %.2f" % data.polar)
	
	label.text = "\n".join(text_lines)
	return []

func _compare_color(a: Beam, b: Beam):
	return a.data.color < b.data.color
