extends PanelContainer

var sensor: Sensor
@export var screen_offset := Vector2(0, 0)

var _vbox: VBoxContainer
var _requirement_labels: Array[Label] = []

func _init(p_sensor: Sensor = null) -> void:
	sensor = p_sensor
	top_level = true
	_build_structure()

func _ready() -> void:
	# Initial update of requirement text
	_update_requirements()

func _build_structure() -> void:
	# Create the internal structure
	var margin := MarginContainer.new()
	add_child(margin)
	
	_vbox = VBoxContainer.new()
	margin.add_child(_vbox)
	
	# Create Goal label
	var goal_label := Label.new()
	goal_label.text = "Goal"
	goal_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))
	var display_font = load("res://assets/fonts/ari-w9500-display.ttf")
	goal_label.add_theme_font_override("font", display_font)
	_vbox.add_child(goal_label)
	
	# Pre-generate requirement labels based on sensor requirements
	if sensor and sensor.has_method("get_requirements"):
		var reqs: Array = sensor.get_requirements()
		for i in range(reqs.size()):
			var label := Label.new()
			label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			label.custom_minimum_size = Vector2.ZERO
			_requirement_labels.append(label)
			_vbox.add_child(label)

func _process(_dt: float) -> void:
	if sensor == null:
		visible = false
		return
	visible = true

	# Update requirements every frame for real-time checkbox updates
	_update_requirements()

	# Size to content each frame
	size = get_combined_minimum_size()

	# Position so that the bottom-left of the panel sits at the sensor's screen position
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()
	var sensor_screen: Vector2 = canvas_xform * sensor.global_position
	global_position = sensor_screen - Vector2(0, size.y) + screen_offset

func _update_requirements() -> void:
	if not _vbox or not sensor:
		return
	
	# Just update the text and color of existing requirement labels
	if sensor.has_method("get_requirements"):
		var reqs: Array = sensor.get_requirements()
		for i in range(min(reqs.size(), _requirement_labels.size())):
			var req_summary = reqs[i].get_summary(sensor.beams_in)
			_requirement_labels[i].text = req_summary["text"]
			_requirement_labels[i].modulate = req_summary["color"]
