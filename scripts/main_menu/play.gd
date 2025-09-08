extends Button

@export var first_level: PackedScene

func _pressed() -> void:
	if first_level:
		SceneManager.change_scene_with_loading(first_level.resource_path)
	else:
		# Fallback to level 1 if no first_level is set
		SceneManager.change_scene_with_loading("res://scenes/levels/level_1.tscn")
