class_name ObjectivePanel
extends PanelContainer

var sensor: Sensor
@export var screen_offset := Vector2(0, 0)

var _vbox: VBoxContainer
var _requirement_labels: Array[Label] = []

func _init(p_sensor: Sensor = null) -> void:
	sensor = p_sensor
	top_level = true
	
	# Make the panel ignore mouse input so it doesn't interfere with game interaction
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_build_structure()

func _ready() -> void:
	# Initial update of requirement text
	_update_requirements()

func _build_structure() -> void:
	# Create the internal structure
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore mouse input
	add_child(margin)
	
	_vbox = VBoxContainer.new()
	_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore mouse input
	margin.add_child(_vbox)
	
	# Create Goal label
	var goal_label := Label.new()
	goal_label.text = "Goal"
	goal_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))
	goal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore mouse input
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
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore mouse input
			_requirement_labels.append(label)
			_vbox.add_child(label)
	
	# Set up corner styling based on sensor position preference
	_setup_corner_styling()

func _process(_dt: float) -> void:
	if sensor == null:
		visible = false
		return
	visible = true

	# Update requirements every frame for real-time checkbox updates
	_update_requirements()

	# Size to content each frame
	size = get_combined_minimum_size()

	# Position based on sensor's preference (left or right side)
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()
	var sensor_screen: Vector2 = canvas_xform * sensor.global_position
	
	if sensor.objective_panel_on_left:
		# Position to the left of the sensor (bottom-left corner of panel at sensor position)
		global_position = sensor_screen - Vector2(size.x, size.y) + screen_offset
	else:
		# Position to the right of the sensor (bottom-right corner of panel at sensor position)
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

func _setup_corner_styling() -> void:
	if not sensor:
		return
	
	# Create a custom StyleBoxFlat for different corner configurations
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.501961) # Match existing panel color
	
	# Set corner radius based on position
	if sensor.objective_panel_on_left:
		# Panel on left: rounded corners except bottom-right
		style_box.corner_radius_top_left = 16
		style_box.corner_radius_top_right = 16
		style_box.corner_radius_bottom_left = 16
		style_box.corner_radius_bottom_right = 0
	else:
		# Panel on right: rounded corners except bottom-left
		style_box.corner_radius_top_left = 16
		style_box.corner_radius_top_right = 16
		style_box.corner_radius_bottom_left = 0
		style_box.corner_radius_bottom_right = 16
	
	# Apply the custom style
	add_theme_stylebox_override("panel", style_box)
