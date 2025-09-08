class_name PolarizationWheel
extends Control

signal value_changed(value: int)

@export var min_value: int = 0
@export var max_value: int = 179
@export var wheel_texture: Texture2D
var current_value: int = 0
var is_dragging: bool = false

var center: Vector2
var radius: float
var last_mouse_pos: Vector2

# Outline shader materials
var _filter_outline_shader: Shader
var _2d_outline_shader: Shader
var _filter_outline_material: ShaderMaterial
var _hover_outline_material: ShaderMaterial
var _original_material: Material
var _is_hovered: bool = false

func _ready():
	custom_minimum_size = Vector2(200, 200)
	
	# Load outline shaders
	_filter_outline_shader = load("res://assets/shaders/filter_outline.gdshader")
	_2d_outline_shader = load("res://assets/shaders/2d_outline.gdshader")
	
	# Create shader materials
	_filter_outline_material = ShaderMaterial.new()
	_filter_outline_material.shader = _filter_outline_shader
	
	_hover_outline_material = ShaderMaterial.new()
	_hover_outline_material.shader = _2d_outline_shader
	
	# Store original material
	_original_material = material
	
	# Set initial outline (filter outline when not hovered)
	material = _filter_outline_material
	
	# Connect signals
	gui_input.connect(_on_gui_input)
	resized.connect(_resized)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Initialize center and radius
	_resized()

func _resized():
	# Update center and radius when the control is resized
	center = size / 2
	radius = min(size.x, size.y) / 2 # Remove the -10 margin to fill entire node
	queue_redraw()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				var local_pos = mouse_event.position
				var distance = local_pos.distance_to(center)
				if distance <= radius:
					is_dragging = true
					last_mouse_pos = local_pos # Store initial position, but don't change angle yet
					# Show hover outline when dragging starts
					material = _hover_outline_material
			else:
				is_dragging = false
				# Update outline based on current hover state when dragging stops
				_update_outline_material()
	elif event is InputEventMouseMotion and is_dragging:
		var motion_event = event as InputEventMouseMotion
		_update_value_from_mouse_delta(motion_event.position)

func _update_value_from_mouse_delta(current_mouse_pos: Vector2):
	# Calculate the angle change based on mouse movement
	var last_direction = last_mouse_pos - center
	var current_direction = current_mouse_pos - center
	
	var last_angle = last_direction.angle()
	var current_angle = current_direction.angle()
	
	# Calculate the angle difference
	var angle_delta = current_angle - last_angle
	
	# Handle wraparound (e.g., from 179° to -179°)
	if angle_delta > PI:
		angle_delta -= 2 * PI
	elif angle_delta < -PI:
		angle_delta += 2 * PI
	
	# Convert to degrees
	var angle_delta_deg = rad_to_deg(angle_delta)
	
	# For exact mapping: 90° polarization = 90° rotation, 179° polarization = 179° rotation
	# So we have a 1:1 mapping for the first 180° range, then it loops
	var new_polarization_value = current_value + angle_delta_deg
	
	# Handle looping: after 179°, it goes back to 0°, and before 0°, it goes to 179°
	while new_polarization_value >= 180.0:
		new_polarization_value -= 180.0
	while new_polarization_value < 0.0:
		new_polarization_value += 180.0
	
	# Round and clamp to valid range
	var new_value = int(round(clamp(new_polarization_value, min_value, max_value)))
	
	if new_value != current_value:
		current_value = new_value
		value_changed.emit(current_value)
		queue_redraw()
	
	# Update last mouse position for next delta calculation
	last_mouse_pos = current_mouse_pos

func set_value(value: int):
	current_value = clamp(value, min_value, max_value)
	queue_redraw()

func get_value() -> int:
	return current_value

func _draw():
	if not wheel_texture:
		return
	
	# Ensure center and radius are calculated (in case _resized hasn't been called yet)
	if center == Vector2.ZERO:
		center = size / 2
		radius = min(size.x, size.y) / 2 # Remove the -10 margin to fill entire node
	
	# Draw the wheel texture rotated by current value
	# With 1:1 mapping: 90° polarization = 90° wheel rotation
	var visual_rotation = current_value
	var rotation_rad = deg_to_rad(visual_rotation)
	var wheel_size = Vector2(size.x, size.y) # Use full node size instead of radius * 2
	
	# Apply rotation around center and draw
	draw_set_transform(center, rotation_rad, Vector2.ONE)
	draw_texture_rect(wheel_texture, Rect2(-wheel_size / 2, wheel_size), false)
	
	# Reset transform
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _on_mouse_entered():
	_is_hovered = true
	# Update outline material based on current state
	_update_outline_material()

func _on_mouse_exited():
	_is_hovered = false
	# Update outline material based on current state
	_update_outline_material()

# Helper function to update the outline material based on current state
func _update_outline_material():
	if is_dragging or _is_hovered:
		# Show hover outline when dragging or hovering
		material = _hover_outline_material
	else:
		# Show filter outline when neither dragging nor hovering
		material = _filter_outline_material
