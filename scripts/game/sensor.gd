class_name Sensor
extends LightObject

@export var dir: LightData.Dir
@onready var label: Label = %"GUI".get_node("MarginContainer/SensorReadout")

func _process_light():
	return []

func get_hover_info() -> String:
	if beams_in.size() == 0:
		return ""
	
	beams_in.sort_custom(func(a, b): return LightData.compare(a.data, b.data))

	var blocks: Array[String] = []
	for b in beams_in:
		if b.data.dir == dir:
			blocks.append(b.data.format_readout())
	
	return "\n---\n".join(blocks)
