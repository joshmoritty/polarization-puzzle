class_name SingleSource
extends Source

@export var intensity: int
@export var polar: int
@export var color: LightColor.LightColorEnum

func _process_light():
	return [LightData.new(dir, intensity, polar, color)]
