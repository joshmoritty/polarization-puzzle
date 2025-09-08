extends Node

# Scene manager to handle transitions through loading screen

func change_scene_with_loading(destination_scene: String):
	
	# First go to loading scene
	get_tree().change_scene_to_file("res://scenes/loading.tscn")
	
	# Wait for loading scene to be ready, then set its destination
	await get_tree().process_frame
	await get_tree().process_frame  # Wait an extra frame to ensure loading scene is fully ready
	
	var loading_scene = get_tree().current_scene
	if loading_scene and loading_scene.has_method("set_destination"):
		loading_scene.set_destination(destination_scene)
	else:
		# Fallback: go directly to destination
		get_tree().change_scene_to_file(destination_scene)
