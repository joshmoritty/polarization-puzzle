extends PanelContainer

@onready var name_label: Label = get_node("%HoverName")
@onready var vbox: VBoxContainer = get_node("%HoverReadout").get_parent()

# Cache for tracking when content actually changes
var _last_selected_objs: Array = []
var _last_selected_beams: Array = []
var _cached_title: String = ""
var _cached_entries: Array[Dictionary] = []

# Pool of reusable labels to avoid constant creation/destruction
var _label_pool: Array[Label] = []
var _active_labels: Array[Label] = []

func _ready():
	# Detach from container layout so we can freely position
	top_level = true
	# Remove the original readout_label since we'll generate labels from scratch
	var readout_label = get_node("%HoverReadout")
	if readout_label:
		readout_label.queue_free()

func _process(_delta: float) -> void:
	# If visible, follow the cursor on the right side, clamped to viewport
	if not visible:
		return
	# Shrink/grow to fit current content when running as top-level (no parent container managing size)
	size = get_combined_minimum_size()
	var mouse := get_viewport().get_mouse_position()
	var vp := get_viewport_rect().size
	var panel_size := size
	var offset := Vector2(16, 16)
	var pos := mouse + offset
	pos.x = clamp(pos.x, 8, vp.x - panel_size.x - 8)
	pos.y = clamp(pos.y, 8, vp.y - panel_size.y - 8)
	global_position = pos

func set_content(title: String, colored_entries: Array[Dictionary]) -> void:
	if name_label:
		name_label.text = title
		name_label.visible = title != ""
	
	# Return all active labels to the pool
	for label in _active_labels:
		label.visible = false
		_label_pool.append(label)
	_active_labels.clear()
	
	# Create/reuse labels for new content
	for entry in colored_entries:
		var label: Label
		if _label_pool.size() > 0:
			# Reuse from pool
			label = _label_pool.pop_back()
		else:
			# Create new label
			label = Label.new()
			vbox.add_child(label)
		
		label.text = entry["text"]
		label.modulate = entry["color"]
		label.visible = true
		_active_labels.append(label)

func update_from_selection(selected_objs: Array, selected_beams: Array) -> void:
	# Check if content has actually changed
	if _selection_unchanged(selected_objs, selected_beams):
		return
	
	# Cache the current selection
	_last_selected_objs = selected_objs.duplicate()
	_last_selected_beams = selected_beams.duplicate()
	
	var any_hover := selected_objs.size() > 0 or selected_beams.size() > 0
	visible = any_hover
	if not any_hover:
		_cached_title = ""
		_cached_entries.clear()
		set_content("", [])
		return

	var title := ""
	var colored_entries: Array[Dictionary] = []

	# Determine object title and object text first (top-most object wins)
	if selected_objs.size() > 0:
		var top_obj: Node = selected_objs[0]
		title = _get_obj_display_name(top_obj)
		if top_obj and top_obj.has_method("get_hover_info"):
			var obj_entries = top_obj.get_hover_info()
			colored_entries.append_array(obj_entries)
	elif selected_beams.size() > 0:
		title = "Light"

	# Append beam sections from same position, sorted
	if selected_beams.size() > 0:
		selected_beams.sort_custom(func(a, b): return LightData.compare(a.beam.data, b.beam.data))
		for bs in selected_beams:
			if bs and bs.has_method("get_hover_info"):
				var beam_entries = bs.get_hover_info()
				colored_entries.append_array(beam_entries)

	# Cache and set content
	_cached_title = title
	_cached_entries = colored_entries.duplicate()
	set_content(title, colored_entries)

# Check if the selection has actually changed
func _selection_unchanged(selected_objs: Array, selected_beams: Array) -> bool:
	if selected_objs.size() != _last_selected_objs.size() or selected_beams.size() != _last_selected_beams.size():
		return false
	
	# Check objects
	for i in range(selected_objs.size()):
		if selected_objs[i] != _last_selected_objs[i]:
			return false
	
	# Check beams
	for i in range(selected_beams.size()):
		if selected_beams[i] != _last_selected_beams[i]:
			return false
	
	return true

func _get_obj_display_name(top_obj: Node) -> String:
	if top_obj is Filter:
		return "Polarizing Filter"
	if top_obj is Source or top_obj is MultiSource or top_obj is SingleSource:
		return "Light Source"
	if top_obj is Sensor:
		return "Sensor"
	if top_obj is Gate:
		var state := "(Open)" if top_obj.open else "(Closed)"
		return "Gate %s" % state
	if top_obj is Junction:
		if top_obj.in_dirs.size() == 1 and top_obj.out_dirs.size() == 1:
			return "Mirror"
		elif top_obj.in_dirs.size() == 1:
			return "Splitter"
		else:
			return "Merger"
	return top_obj.get_class()
