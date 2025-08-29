class_name Source
extends LightObject

@export var dir: LightData.Dir
@export var intensity: int
@export var polar: int

func _process_light():
	return [LightData.new(dir, intensity, polar)]
