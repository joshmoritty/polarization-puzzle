class_name Controller
extends Node2D

var objs: Dictionary[Vector2i, LightObject] = {}
var beam_n = 0
@onready var ground = %"GroundTiles" as TileMapLayer
@onready var tilemap: TileMapLayer = %"ObjectTiles"
@onready var view: SubViewport = %"SubViewport"
@onready var label: Label = %"HoverReadout"
var _outline_shader := load("res://assets/2d_outline.gdshader")
var _hovered_sprite: CanvasItem = null
@onready var filter_dialog: Control = $"CanvasLayer/FilterDialog"
@onready var fd_slider: HSlider = filter_dialog.get_node("VBox/Slider") as HSlider
@onready var fd_value: Label = filter_dialog.get_node("VBox/Value") as Label
var _active_filter: Filter = null

func _ready():
	for pos in objs:
		var obj = objs[pos]
		if obj is Source:
			obj.build_beams()

func _unhandled_input(event: InputEvent) -> void:
	# When dialog open, suppress hover readout and allow outside-click close
	if filter_dialog and filter_dialog.visible:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var rect := filter_dialog.get_global_rect()
			if not rect.has_point(get_viewport().get_mouse_position()):
				_close_filter_dialog()
		return

	# Update UI readout on hover via physics point query; clear when none
	if event is InputEventMouseMotion and label:
		var space_state := get_world_2d().direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		# Use world coordinates for physics queries
		params.position = get_global_mouse_position()
		# Hit BeamSection Areas (bit 4) and Object Areas (bit 5)
		params.collision_mask = (1 << 3) | (1 << 4)
		params.collide_with_areas = true
		params.collide_with_bodies = false

		var results := space_state.intersect_point(params, 8)
		var hovered = _max_y_hit(results)
		if hovered is BeamSection:
			label.text = hovered.beam.data.format_readout()
		else:
			label.text = ""
		
		# Apply/remove outline shader
		if _hovered_sprite != hovered:
			# Remove from old
			if _hovered_sprite:
				_hovered_sprite.material = null
			# Apply to new
			_hovered_sprite = hovered
			if _hovered_sprite:
				var mat := ShaderMaterial.new()
				mat.shader = _outline_shader
				_hovered_sprite.material = mat

	# Open/retarget filter dialog on left click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var space_state := get_world_2d().direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		params.position = get_global_mouse_position()
		params.collision_mask = (1 << 3) | (1 << 4)
		params.collide_with_areas = true
		params.collide_with_bodies = false
		var results := space_state.intersect_point(params, 8)
		var clicked = _max_y_hit(results)

		if clicked is Filter:
			_open_filter_dialog(clicked as Filter)

func _open_filter_dialog(f: Filter) -> void:
	_active_filter = f
	if fd_slider and fd_value and filter_dialog:
		fd_slider.value = clampi(f.polar, 0, 179)
		fd_value.text = str(int(fd_slider.value))
		if not filter_dialog.visible:
			filter_dialog.visible = true
		# Connect signals once
		# Configure slider for integer steps and range
		fd_slider.min_value = 0
		fd_slider.max_value = 179
		fd_slider.step = 1
		fd_slider.rounded = true
		# Connect once
		if not fd_slider.value_changed.is_connected(_on_slider_changed):
			fd_slider.value_changed.connect(_on_slider_changed)

func _on_slider_changed(value: float) -> void:
	if _active_filter:
		_active_filter.polar = int(value)
		fd_value.text = str(int(value))
		_active_filter.build_beams()

func _close_filter_dialog() -> void:
	if filter_dialog:
		filter_dialog.visible = false
	_active_filter = null

func _max_y_hit(hits: Array[Dictionary]):
	var max_y = - INF
	var max_obj: Node2D = null
	for hit in hits:
		var collider = hit.get("collider") as Area2D
		var parent = collider.get_parent() as Node2D
		var y = parent.position.y
		if y > max_y:
			max_y = y
			max_obj = parent
	return max_obj

func get_next_mesh_coord():
	var mesh_coord = Vector2i(beam_n / 5, beam_n % 5)
	beam_n += 1
	return mesh_coord

static func dir_to_vec(dir: LightData.Dir):
	if dir == LightData.Dir.UP_RIGHT:
		return Vector2i(0, -1)
	elif dir == LightData.Dir.DOWN_RIGHT:
		return Vector2i(1, 0)
	elif dir == LightData.Dir.DOWN_LEFT:
		return Vector2i(0, 1)
	elif dir == LightData.Dir.UP_LEFT:
		return Vector2i(-1, 0)
	return Vector2i(0, 0)

func register_obj(obj: Node2D):
	if not tilemap:
		tilemap = %"ObjectTiles"
	
	var tilepos = tilemap.local_to_map(obj.position)
	objs.set(tilepos, obj)
	return tilepos
