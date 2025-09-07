extends PanelContainer

@export var sensor: Sensor
@export var screen_offset := Vector2(0, 0)

var _body: Label

func _ready() -> void:
	top_level = true
	_resolve_body_label()

func _process(_dt: float) -> void:
	if sensor == null:
		visible = false
		return
	visible = true

	# Update content from this sensor's requirements
	_resolve_body_label()
	var text := ""
	if sensor.has_method("get_requirements"):
		var reqs: Array = sensor.get_requirements()
		var lines: Array[String] = []
		for r in reqs:
			lines.append(r.format_summary())
		text = "\n---\n".join(lines)
	if _body:
		_body.text = text

	# Size to content each frame
	size = get_combined_minimum_size()

	# Position so that the bottom-left of the panel sits at the sensor's screen position
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()
	var sensor_screen: Vector2 = canvas_xform * sensor.global_position
	global_position = sensor_screen - Vector2(0, size.y) + screen_offset

func _resolve_body_label() -> void:
	if _body and is_instance_valid(_body):
		return
	var vb := get_node_or_null("MarginContainer/VBoxContainer")
	if vb:
		var children := vb.get_children()
		for i in range(children.size()):
			if children[i] is Label and i > 0:
				_body = children[i]
				return

	# This panel is a per-sensor instance; cloning is handled by ObjectivePanels.gd
