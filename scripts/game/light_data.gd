class_name LightData

enum Dir {UP_RIGHT, DOWN_RIGHT, DOWN_LEFT, UP_LEFT}

var dir: Dir
var intensity: float
var polar: int
var color: LightColor.LightColorEnum

func _init(p_dir: Dir, p_intensity: float, p_polar: int, p_color: LightColor.LightColorEnum):
	dir = p_dir
	intensity = p_intensity
	polar = p_polar
	color = p_color

func dir_to_string() -> String:
	match dir:
		Dir.UP_RIGHT:
			return "Up-Right"
		Dir.DOWN_RIGHT:
			return "Down-Right"
		Dir.DOWN_LEFT:
			return "Down-Left"
		Dir.UP_LEFT:
			return "Up-Left"
		_:
			return str(dir)

func format_readout() -> String:
	var lines: Array[String] = []
	lines.append("Direction: %s" % dir_to_string())
	lines.append("Color: %s" % LightColor.enum_to_string(color))
	lines.append("Intensity: %.2f" % intensity)
	lines.append("Polarization: %.2f" % float(polar))
	return "\n".join(lines)

func equals(data: LightData):
	return (
		dir == data.dir
		and color == data.color
		and intensity == data.intensity
		and polar == data.polar
	)
