class_name Sensor
extends LightObject

@export var dir: LightData.Dir

@export var min_polar: int
@export var max_polar: int
@export var use_total_intensity: bool
@export var min_total_intensity: float
@export var use_color: bool = true
@export var use_polar: bool = true

@export_group("UI")
@export var objective_panel_on_left: bool = false

@export_group("Requirement 1")
@export var req_1_color: LightColor.LightColorEnum
@export var req_1_min_intensity: float

@export_group("Requirement 2")
@export var req_2_used: bool
@export var req_2_color: LightColor.LightColorEnum
@export var req_2_min_intensity: float

@export_group("Requirement 3")
@export var req_3_used: bool
@export var req_3_color: LightColor.LightColorEnum
@export var req_3_min_intensity: float

var _sensor_outline_shader := load("res://assets/shaders/sensor_outline.gdshader")
var _sensor_outline_material: ShaderMaterial

func _ready():
	super._ready()
	# Apply sensor outline (starts as red)
	_sensor_outline_material = ShaderMaterial.new()
	_sensor_outline_material.shader = _sensor_outline_shader
	_sensor_outline_material.set_shader_parameter("outline_color", Color.RED)
	material = _sensor_outline_material

func _process(_delta):
	# Update outline color based on requirement fulfillment
	_update_outline_color()

func _update_outline_color():
	if not _sensor_outline_material:
		return
	
	# Check if all requirements are fulfilled
	var all_fulfilled = true
	var reqs = get_requirements()
	for req in reqs:
		if not req.is_successful(beams_in):
			all_fulfilled = false
			break
	
	# Set outline color: green if all fulfilled, red if not
	var outline_color = Color.GREEN if all_fulfilled else Color.RED
	_sensor_outline_material.set_shader_parameter("outline_color", outline_color)

func _process_light():
	return []

func get_requirements() -> Array[Requirement]:
	var reqs: Array[Requirement] = []
	if use_total_intensity:
		# Single aggregated requirement ignoring color and/or polar per flags
		var r_total = Requirement.new(dir, req_1_color, min_total_intensity, min_polar, max_polar, true, use_color, use_polar)
		reqs.append(r_total)
		return reqs
	# Otherwise, build per-color requirements with individual min intensities
	var r1 = Requirement.new(dir, req_1_color, req_1_min_intensity, min_polar, max_polar, false, use_color, use_polar)
	reqs.append(r1)
	if req_2_used:
		var r2 = Requirement.new(dir, req_2_color, req_2_min_intensity, min_polar, max_polar, false, use_color, use_polar)
		reqs.append(r2)
	if req_3_used:
		var r3 = Requirement.new(dir, req_3_color, req_3_min_intensity, min_polar, max_polar, false, use_color, use_polar)
		reqs.append(r3)
	return reqs

func get_hover_info() -> Array[Dictionary]:
	if beams_in.size() == 0:
		return [ {"text": "No Input", "color": Color.WHITE}]
	
	beams_in.sort_custom(func(a, b): return LightData.compare(a.data, b.data))

	var entries: Array[Dictionary] = []
	for b in beams_in:
		if b.data.dir == dir:
			var readout = b.data.format_readout()
			entries.append(readout)
	
	return entries
