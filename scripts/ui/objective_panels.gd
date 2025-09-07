extends Control

func _ready() -> void:
	# Make the container ignore mouse input so it doesn't interfere with game interaction
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_generate_panels()

func _generate_panels() -> void:
	# Find all sensors in the scene
	var sensors: Array[Node] = get_tree().get_root().find_children("*", "Sensor", true, false)
	if sensors.is_empty():
		return
	
	# Remove previously generated panels
	for child in get_children():
		if child is PanelContainer:
			child.queue_free()
	
	# For each sensor, create a new ObjectivePanel with the sensor as parameter
	var objective_panel_script = preload("res://scripts/ui/objective_panel.gd")
	for s in sensors:
		var panel = objective_panel_script.new(s)
		add_child.call_deferred(panel)

func regenerate() -> void:
	_generate_panels()
