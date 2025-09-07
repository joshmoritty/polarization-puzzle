extends PanelContainer

var sensor: Sensor
@export var screen_offset := Vector2(0, 0)

var _body: Label
var _vbox: VBoxContainer

func _init(p_sensor: Sensor = null) -> void:
	sensor = p_sensor
	top_level = true
	_build_structure()

func _ready() -> void:
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
	
	# Create template body label (hidden)
	_body = Label.new()
	_body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_body.visible = false
	_vbox.add_child(_body)

func _process(_dt: float) -> void:
	if sensor == null:
		visible = false
		return
	visible = true

	# Size to content each frame
	size = get_combined_minimum_size()

	# Position so that the bottom-left of the panel sits at the sensor's screen position
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()
	var sensor_screen: Vector2 = canvas_xform * sensor.global_position
	global_position = sensor_screen - Vector2(0, size.y) + screen_offset

func _update_requirements() -> void:
	if not _vbox or not _body or not sensor:
		return
	
	# Hide the original body label and ensure it takes no space
	_body.visible = false
	_body.size = Vector2.ZERO
	_body.custom_minimum_size = Vector2.ZERO
	
	# Remove any previously generated requirement labels (but keep Goal label and body label)
	var goal_label = _vbox.get_child(0) if _vbox.get_child_count() > 0 else null
	for child in _vbox.get_children():
		if child != _body and child != goal_label and child is Label:
			child.queue_free()
	
	# Add new colored labels for each requirement by cloning the original body label
	if sensor.has_method("get_requirements"):
		var reqs: Array = sensor.get_requirements()
		for r in reqs:
			var req_summary = r.get_summary()
			var label := _body.duplicate() as Label
			label.text = req_summary["text"]
			label.modulate = req_summary["color"]
			label.visible = true
			# Reset size constraints on cloned label
			label.custom_minimum_size = Vector2.ZERO
			_vbox.add_child(label)
