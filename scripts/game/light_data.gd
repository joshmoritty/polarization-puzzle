class_name LightData

enum Dir {DOWN_RIGHT, DOWN_LEFT, UP_LEFT, UP_RIGHT}

var dir: Dir
var intensity: float
var polar: int
var color: LightColor.LightColorEnum

func _init(p_dir: Dir, p_intensity: float, p_polar: int, p_color: LightColor.LightColorEnum):
	dir = p_dir
	intensity = p_intensity
	polar = p_polar
	color = p_color

static func dir_to_string(d: Dir) -> String:
	match d:
		Dir.UP_RIGHT:
			return "Up-Right"
		Dir.DOWN_RIGHT:
			return "Down-Right"
		Dir.DOWN_LEFT:
			return "Down-Left"
		Dir.UP_LEFT:
			return "Up-Left"
		_:
			return str(d)

func format_readout() -> String:
	var lines: Array[String] = []
	lines.append("Color: %s" % LightColor.enum_to_string(color))
	lines.append("Intensity: %.2f" % intensity)
	lines.append("Polarization: %d°" % int(polar))
	return "\n".join(lines)

func equals(data: LightData):
	return (
		dir == data.dir
		and color == data.color
		and intensity == data.intensity
		and polar == data.polar
	)

static func compare(a: LightData, b: LightData):
	return (a.dir < b.dir or
		(a.dir == b.dir and (a.color < b.color or
		(a.color == b.color and (a.intensity < b.intensity or
		(a.intensity == b.intensity and a.polar < b.polar))))))
