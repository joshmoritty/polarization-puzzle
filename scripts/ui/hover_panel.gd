extends PanelContainer

@onready var name_label: Label = get_node("%HoverName")
@onready var readout_label: Label = get_node("%HoverReadout")

func _ready():
	# Detach from container layout so we can freely position
	top_level = true

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

func set_content(title: String, body: String) -> void:
	if name_label:
		name_label.text = title
	if readout_label:
		readout_label.visible = body != ""
		readout_label.text = body

func update_from_selection(selected_objs: Array, selected_beams: Array) -> void:
	var any_hover := selected_objs.size() > 0 or selected_beams.size() > 0
	visible = any_hover
	if not any_hover:
		set_content("", "")
		return

	var title := ""
	var body := ""

	# Determine object title and object text first (top-most object wins)
	if selected_objs.size() > 0:
		var top_obj: Node = selected_objs[0]
		title = _get_obj_display_name(top_obj)
		if top_obj and top_obj.has_method("get_hover_info"):
			var obj_txt: String = top_obj.get_hover_info()
			if obj_txt != "":
				body = obj_txt
	elif selected_beams.size() > 0:
		title = "Light"

	# Append beam sections from same position, sorted and joined
	if selected_beams.size() > 0:
		selected_beams.sort_custom(func(a, b): return LightData.compare(a.beam.data, b.beam.data))
		var lines: Array[String] = []
		for bs in selected_beams:
			var s: String = bs.get_hover_info()
			if s != "":
				lines.append(s)
		if lines.size() > 0:
			if body != "":
				body += "\n\n"
			body += "\n---\n".join(lines)

	set_content(title, body)

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
