extends Camera2D

var _is_panning := false

# Zoom settings
var min_zoom := 2.0
var max_zoom := 4.0
var default_zoom := 3.0
var zoom_step := 0.5

func _ready() -> void:
	# Ensure this camera controls the 2D view
	make_current()
	
	# Set default zoom
	zoom = Vector2(default_zoom, default_zoom)

func _unhandled_input(event: InputEvent) -> void:
	# Handle zoom with scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_in()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_out()
			get_viewport().set_input_as_handled()
		# Hold and drag Middle Mouse to pan
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_panning:
		# Convert screen-pixel motion to world-units using zoom
		position -= event.relative / zoom
		get_viewport().set_input_as_handled()
	# Handle zoom with keyboard
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
			_zoom_in()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_MINUS:
			_zoom_out()
			get_viewport().set_input_as_handled()

func _zoom_in():
	var new_zoom = zoom.x + zoom_step
	if new_zoom <= max_zoom:
		zoom = Vector2(new_zoom, new_zoom)

func _zoom_out():
	var new_zoom = zoom.x - zoom_step
	if new_zoom >= min_zoom:
		zoom = Vector2(new_zoom, new_zoom)
