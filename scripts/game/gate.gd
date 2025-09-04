class_name Gate
extends LightObject

var open = false
@onready var closed_texture = texture
var open_texture: Texture2D

@export var dir: LightData.Dir

@export_group("Requirement 1")
@export var req_1_dir: LightData.Dir
@export var req_1_color: LightColor.LightColorEnum
@export var req_1_min_intensity: float
@export var req_1_min_polar: int
@export var req_1_max_polar: int

@export_group("Requirement 2")
@export var req_2_used: bool
@export var req_2_dir: LightData.Dir
@export var req_2_color: LightColor.LightColorEnum
@export var req_2_min_intensity: float
@export var req_2_min_polar: int
@export var req_2_max_polar: int

func _ready():
	super._ready()
	var path = closed_texture.resource_path
	open_texture = load(path.substr(0, path.length() - 4) + "_open.png")

func _process_light():
	var req_1 = Requirement.new(req_1_dir, req_1_color, req_1_min_intensity, req_1_min_polar, req_1_max_polar, false)
	var req_1_successful = req_1.is_successful(beams_in)
	var req_2_successful = true
	
	if req_2_used:
		var req_2 = Requirement.new(req_2_dir, req_2_color, req_2_min_intensity, req_2_min_polar, req_2_max_polar, false)
		req_2_successful = req_2.is_successful(beams_in)

	open = req_1_successful and req_2_successful
	
	_update_sprite()
	
	if !open:
		return []
	
	var lights_out: Array[LightData] = []
	for beam in beams_in:
		var data = beam.data
		if data.dir != dir:
			continue
		
		lights_out.push_back(LightData.new(dir, data.intensity, data.polar, data.color))

	return lights_out

func _update_sprite():
	if open and texture != open_texture:
		texture = open_texture
	elif !open and texture != closed_texture:
		texture = closed_texture

func get_hover_info() -> String:
	var blocks: Array[String] = []
	blocks.append("REQUIRES:")
	# Requirement 1 summary
	var r1_req := Requirement.new(req_1_dir, req_1_color, req_1_min_intensity, req_1_min_polar, req_1_max_polar, false)
	blocks.append("Direction: %s\n%s" % [LightData.dir_to_string(req_1_dir), r1_req.format_summary()])
	# Requirement 2 if used
	if req_2_used:
		var r2_req := Requirement.new(req_2_dir, req_2_color, req_2_min_intensity, req_2_min_polar, req_2_max_polar, false)
		blocks.append("Direction: %s\n%s" % [LightData.dir_to_string(req_2_dir), r2_req.format_summary()])
	return "\n".join(blocks)
