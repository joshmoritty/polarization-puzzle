extends Camera2D

var _is_panning := false

func _ready() -> void:
	# Ensure this camera controls the 2D view
	make_current()

func _unhandled_input(event: InputEvent) -> void:
	# Hold and drag Middle Mouse to pan
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_is_panning = event.pressed
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_panning:
		# Convert screen-pixel motion to world-units using zoom
		position -= event.relative / zoom
		get_viewport().set_input_as_handled()
