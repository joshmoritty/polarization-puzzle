extends Camera2D

var _is_panning := false

# Zoom settings
var min_zoom := 2.0
var max_zoom := 4.0
var default_zoom := 3.0
var zoom_step := 0.5

# Pan settings
var pan_speed := 500.0 # pixels per second at 1x zoom

# Arrow key panning state
var _arrow_keys_pressed := {
	"left": false,
	"right": false,
	"up": false,
	"down": false
}

func _ready() -> void:
	# Ensure this camera controls the 2D view
	make_current()
	
	# Set default zoom
	zoom = Vector2(default_zoom, default_zoom)
	
	# Add to camera group for easier reference
	add_to_group("camera")

func _process(delta: float) -> void:
	# Handle smooth arrow key panning
	var pan_direction := Vector2.ZERO
	
	if _arrow_keys_pressed["left"]:
		pan_direction.x -= 1
	if _arrow_keys_pressed["right"]:
		pan_direction.x += 1
	if _arrow_keys_pressed["up"]:
		pan_direction.y -= 1
	if _arrow_keys_pressed["down"]:
		pan_direction.y += 1
	
	if pan_direction != Vector2.ZERO:
		# Normalize diagonal movement and adjust speed based on zoom level
		pan_direction = pan_direction.normalized()
		var adjusted_speed = pan_speed / zoom.x
		position += pan_direction * adjusted_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	# Handle zoom with scroll wheel (always available)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_in()
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_out()
			get_viewport().set_input_as_handled()
			return
		# Hold and drag Left Mouse to pan (only if no interactive object is clicked and no dialog is open)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			# Don't handle panning if a filter dialog is open - let controller handle it for dialog closing
			var controller = get_tree().get_first_node_in_group("controller")
			if controller and controller.filter_dialog and controller.filter_dialog.visible:
				return
			
			if event.pressed:
				# Check if we're clicking on an interactive object
				var space_state := get_world_2d().direct_space_state
				var params := PhysicsPointQueryParameters2D.new()
				params.position = get_global_mouse_position()
				# Check for Object Areas (collision layer used by filters, sensors, etc.)
				params.collision_mask = (1 << 3) | (1 << 4)
				params.collide_with_areas = true
				params.collide_with_bodies = false
				var results := space_state.intersect_point(params, 16)
				
				# Only start panning if no interactive objects were hit
				if results.is_empty():
					_is_panning = true
					get_viewport().set_input_as_handled()
			else:
				if _is_panning:
					_is_panning = false
					get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _is_panning:
		# Convert screen-pixel motion to world-units using zoom
		position -= event.relative / zoom
		get_viewport().set_input_as_handled()
	# Handle zoom with keyboard
	elif event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
				_zoom_in()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_MINUS:
				_zoom_out()
				get_viewport().set_input_as_handled()
		
		# Handle arrow key press/release for smooth panning
		if event.keycode == KEY_LEFT:
			_arrow_keys_pressed["left"] = event.pressed
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT:
			_arrow_keys_pressed["right"] = event.pressed
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_UP:
			_arrow_keys_pressed["up"] = event.pressed
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			_arrow_keys_pressed["down"] = event.pressed
			get_viewport().set_input_as_handled()

func _zoom_in():
	var new_zoom = zoom.x + zoom_step
	if new_zoom <= max_zoom:
		zoom = Vector2(new_zoom, new_zoom)

func _zoom_out():
	var new_zoom = zoom.x - zoom_step
	if new_zoom >= min_zoom:
		zoom = Vector2(new_zoom, new_zoom)
