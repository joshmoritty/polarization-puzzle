class_name Controller
extends Node2D

var objs: Dictionary[Vector2i, LightObject] = {}
var beams_used: Array[bool] = []
var _outline_shader := load("res://assets/shaders/2d_outline.gdshader")
var _active_filter: Filter = null
var _hovered_sprites: Array[CanvasItem] = []
@onready var ground = %"GroundTiles" as TileMapLayer
@onready var tilemap: TileMapLayer = %"ObjectTiles"
@onready var view: SubViewport = %"SubViewport"
@onready var gui: CanvasLayer = %"GUI"
@onready var label: Label = gui.get_node("MarginContainer/HoverReadout")
@onready var objectives_label: Label = gui.get_node("MarginContainer/Objectives")
@onready var filter_dialog: Control = gui.get_node("MarginContainer/FilterDialog")
@onready var fd_slider: HSlider = filter_dialog.get_node("MarginContainer/VBox/Slider") as HSlider
@onready var fd_value: Label = filter_dialog.get_node("MarginContainer/VBox/Value") as Label
@onready var finish_dialog: PanelContainer = gui.get_node("MarginContainer/FinishDialog")
@onready var finish_continue: Button = finish_dialog.get_node("MarginContainer/VBox/HBox/Continue")
@onready var finish_main_menu: Button = finish_dialog.get_node("MarginContainer/VBox/HBox/MainMenu")

func _ready():
	for i in range(25):
		beams_used.push_back(false)
		
	for pos in objs:
		var obj = objs[pos]
		if obj is Source:
			obj.build_beams()

	# Connect finish dialog buttons once
	if finish_continue and not finish_continue.pressed.is_connected(_on_finish_continue):
		finish_continue.pressed.connect(_on_finish_continue)
	if finish_main_menu and not finish_main_menu.pressed.is_connected(_on_finish_main_menu):
		finish_main_menu.pressed.connect(_on_finish_main_menu)

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

		var results := space_state.intersect_point(params, 16)
		var text_out := ""
		# Find the position with the lowest y among hits, then collect items at that position
		var selected_pos: Vector2
		var max_y := -INF
		for hit in results:
			var collider = hit.get("collider") as Area2D
			var parent := collider.get_parent() as Node2D
			if parent == null:
				continue
			var p := parent.position
			if p.y > max_y:
				max_y = p.y
				selected_pos = p
		
		var selected_beams: Array[BeamSection] = []
		var selected_objs: Array[LightObject] = []
		if max_y > -INF:
			for hit in results:
				var collider = hit.get("collider") as Area2D
				var parent = collider.get_parent()
				if parent == null:
					continue
				var p2 := (parent as Node2D).position
				if p2 == selected_pos:
					if parent is BeamSection:
						selected_beams.append(parent)
					elif parent is LightObject:
						selected_objs.append(parent)
		# Build text: object info first (single top-most if multiple at same pos)
		if selected_objs.size() > 0:
			var top_obj: LightObject = selected_objs[0]
			if top_obj and top_obj.has_method("get_hover_info"):
				var obj_txt := top_obj.get_hover_info()
				if obj_txt != "":
					text_out = obj_txt
		# Then beams: sort by LightData.compare and append all from same pos
		if selected_beams.size() > 0:
			selected_beams.sort_custom(func(a, b): return LightData.compare(a.beam.data, b.beam.data))
			var lines: Array[String] = []
			for bs in selected_beams:
				var s := bs.get_hover_info()
				if s != "":
					lines.append(s)
			if lines.size() > 0:
				if text_out != "":
					text_out += "\n\n"
				text_out += "\n---\n".join(lines)
		label.text = text_out
		# Apply/remove outline shader: outline all selected beam sections; otherwise top-most item
		# Clear previous outlines
		for ci in _hovered_sprites:
			if ci:
				ci.material = null
		_hovered_sprites.clear()
		if selected_beams.size() >= 2:
			for bs in selected_beams:
				var mat := ShaderMaterial.new()
				mat.shader = _outline_shader
				bs.material = mat
				_hovered_sprites.append(bs)
		else:
			# Outline a single top-most element in selected group
			var to_outline: CanvasItem = null
			if selected_objs.size() > 0:
				to_outline = selected_objs[0]
			elif selected_beams.size() > 0:
				to_outline = selected_beams[0]
			if to_outline:
				var mat2 := ShaderMaterial.new()
				mat2.shader = _outline_shader
				to_outline.material = mat2
				_hovered_sprites.append(to_outline)

	# After input handling, update objectives each motion event for responsiveness
	_update_objectives()

	# Open/retarget filter dialog on left click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var space_state := get_world_2d().direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		params.position = get_global_mouse_position()
		params.collision_mask = (1 << 3) | (1 << 4)
		params.collide_with_areas = true
		params.collide_with_bodies = false
		var results := space_state.intersect_point(params, 16)
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
	for i in range(beams_used.size()):
		if !beams_used[i]:
			beams_used[i] = true
			var mesh_coord = Vector2i(i / 5, i % 5)
			return mesh_coord

func free_mesh_coord(coord: Vector2i):
	var i = coord.x * 5 + coord.y
	beams_used[i] = false

func register_obj(obj: Node2D):
	if not tilemap:
		tilemap = %"ObjectTiles"
	
	var tilepos = tilemap.local_to_map(obj.position)
	objs.set(tilepos, obj)
	return tilepos

func _update_objectives():
	if not objectives_label:
		return
	var all_reqs: Array[String] = []
	var all_met := true
	# Build objectives text from all Sensor requirements
	for pos in objs:
		var obj = objs[pos]
		if obj is Sensor:
			var sensor := obj as Sensor
			var reqs := sensor.get_requirements()
			for r in reqs:
				all_reqs.append(r.format_summary())
				var met := r.is_successful(sensor.beams_in)
				if not met:
					all_met = false
	var text := ""
	if all_reqs.size() > 0:
		text = "Objectives:\n" + ("\n---\n".join(all_reqs))
	objectives_label.text = text
	if all_met and all_reqs.size() > 0:
		_show_finish_dialog()

func _show_finish_dialog():
	if finish_dialog and not finish_dialog.visible:
		finish_dialog.visible = true

func _on_finish_continue():
	# Placeholder: hook into your level loading system
	# For now, just hide the dialog
	if finish_dialog:
		finish_dialog.visible = false

func _on_finish_main_menu():
	if finish_dialog:
		finish_dialog.visible = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
