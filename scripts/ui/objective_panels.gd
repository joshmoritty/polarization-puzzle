extends Node

@onready var _template: PanelContainer = $ObjectivePanel

func _ready() -> void:
	# Ensure template exists and is hidden
	if _template:
		_template.visible = false
		_template.top_level = true
	_generate_panels()

func _generate_panels() -> void:
	if _template == null:
		return
	# Find all sensors in the scene
	var sensors: Array[Node] = get_tree().get_root().find_children("*", "Sensor", true, false)
	if sensors.is_empty():
		return
	# Remove previously generated panels (keep only the template)
	for child in get_children():
		if child != _template and child is PanelContainer and child.get_script() == _template.get_script():
			child.queue_free()
	# For each sensor, create a panel clone and bind
	for s in sensors:
		var clone := _template.duplicate() as PanelContainer
		add_child.call_deferred(clone)
		clone.set_deferred("sensor", s)
		clone.visible = true

func regenerate() -> void:
	_generate_panels()
