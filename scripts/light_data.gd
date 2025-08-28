class_name LightData

enum Dir {UP_RIGHT, DOWN_RIGHT, DOWN_LEFT, UP_LEFT}

var dir: Dir
var intensity: float
var polar: int

func _init(p_dir: Dir, p_intensity: float, p_polar: int):
	dir = p_dir
	intensity = p_intensity
	polar = p_polar
