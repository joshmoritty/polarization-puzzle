class_name Sensor
extends LightObject

@export var dir: LightData.Dir
@onready var label: Label = %"GUI".get_node("MarginContainer/SensorReadout")

@export var min_polar: int
@export var max_polar: int
@export var use_total_intensity: bool
@export var min_total_intensity: float

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

func _process_light():
	return []

func get_requirements() -> Array[Requirement]:
	var reqs: Array[Requirement] = []
	if use_total_intensity:
		# Single aggregated requirement with color = null, min intensity = min_total_intensity
		var r_total = Requirement.new(dir, null, min_total_intensity, min_polar, max_polar, true)
		reqs.append(r_total)
		return reqs
	# Otherwise, build per-color requirements with individual min intensities
	var r1 = Requirement.new(dir, req_1_color, req_1_min_intensity, min_polar, max_polar, false)
	reqs.append(r1)
	if req_2_used:
		var r2 = Requirement.new(dir, req_2_color, req_2_min_intensity, min_polar, max_polar, false)
		reqs.append(r2)
	if req_3_used:
		var r3 = Requirement.new(dir, req_3_color, req_3_min_intensity, min_polar, max_polar, false)
		reqs.append(r3)
	return reqs

func get_hover_info() -> String:
	if beams_in.size() == 0:
		return ""
	
	beams_in.sort_custom(func(a, b): return LightData.compare(a.data, b.data))

	var blocks: Array[String] = []
	for b in beams_in:
		if b.data.dir == dir:
			blocks.append(b.data.format_readout())
	
	return "\n---\n".join(blocks)
