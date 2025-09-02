class_name MultiSource
extends Source

@export_group("Light 1")
@export var intensity_1: int
@export var polar_1: int
@export var color_1: LightColor.LightColorEnum

@export_group("Light 2")
@export var enabled_2: bool
@export var intensity_2: int
@export var polar_2: int
@export var color_2: LightColor.LightColorEnum

@export_group("Light 3")
@export var enabled_3: bool
@export var intensity_3: int
@export var polar_3: int
@export var color_3: LightColor.LightColorEnum

func _process_light():
	var lights_out = [LightData.new(dir, intensity_1, polar_1, color_1)]
	if enabled_2:
		lights_out.push_back(LightData.new(dir, intensity_2, polar_2, color_2))
	if enabled_3:
		lights_out.push_back(LightData.new(dir, intensity_3, polar_3, color_3))
	
	return lights_out
