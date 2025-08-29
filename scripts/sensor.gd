class_name Sensor
extends LightObject

@export var dir: LightData.Dir
@onready var label: Label = %"SensorReadout"

func _process_light():
	if beams_in.size() == 0:
		return []
	
	var data = beams_in[0].data
	if data.dir != dir:
		return []
	
	var text_lines: Array[String] = []
	text_lines.append("Intensity: %.2f" % data.intensity)
	text_lines.append("Polarization: %.2f" % data.polar)
	label.text = "\n".join(text_lines)
	return []
