class_name Filter
extends LightObject

@export var dir: LightData.Dir
@export var polar: int

func _ready():
	super._ready()
	var builder = owner as Controller
	builder.register_obj(self)

func process_light(light_in: LightData):
	if light_in.dir != dir:
		return null
	
	var theta = deg_to_rad(light_in.polar - polar) # relative angle between light and polarizer
	var intensity = light_in.intensity * pow(cos(theta), 2)
	return LightData.new(dir, intensity, polar)
