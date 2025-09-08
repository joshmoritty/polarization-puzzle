extends Control

var destination_scene: String = ""

func _ready():
	# Wait 1 second before transitioning to the destination scene
	await get_tree().create_timer(0.2).timeout
	
	if destination_scene != "":
		get_tree().change_scene_to_file(destination_scene)
	else:
		# Fallback to main menu if no destination is set
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func set_destination(scene_path: String):
	destination_scene = scene_path
