class_name Sensor
extends LightObject

@export var dir: LightData.Dir
@onready var label: Label = %"SensorReadout"

func _ready():
	super._ready()
	var builder = owner as Controller
	builder.register_obj(self)

func process_light(light_in: LightData):
	if light_in.dir != dir:
		return null
	var text_lines: Array[String] = []
	text_lines.append("Intensity: %.2f" % light_in.intensity)
	text_lines.append("Polarization: %.2f" % light_in.polar)
	label.text = "\n".join(text_lines)
