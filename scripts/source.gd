class_name Source
extends LightObject

@export var dir: LightData.Dir
@export var intensity: int
@export var polar: int
@export var color: LightColor.LightColorEnum

func _process_light():
	return [LightData.new(dir, intensity, polar, LightColor.from_enum(color))]
