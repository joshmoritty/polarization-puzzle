class_name Source
extends LightObject

@export var dir: LightData.Dir
@export var intensity: int
@export var polar: int

func _ready():
	var builder = owner as Controller
	builder.register_obj(self)

func process_light(_light_in: LightData):
	return LightData.new(dir, intensity, polar)
