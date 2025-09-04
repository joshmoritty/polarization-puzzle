class_name Requirement

var dir: LightData.Dir
var color
var min_intensity: float
var min_polar: int
var max_polar: int
var use_total_intensity: bool

func _init(
	p_dir,
	p_color,
	p_min_intensity,
	p_min_polar,
	p_max_polar,
	p_use_total_intensity
):
	dir = p_dir
	color = p_color
	min_intensity = p_min_intensity
	min_polar = p_min_polar
	max_polar = p_max_polar
	use_total_intensity = p_use_total_intensity
	
func is_successful(beams: Array[Beam]) -> bool:
	var total_intensity: float = 0.0
	for beam in beams:
		var d := beam.data
		if d.dir != dir:
			continue
		if d.polar < min_polar or d.polar > max_polar:
			continue
		if color != null and d.color != color:
			continue

		if use_total_intensity:
			total_intensity += d.intensity
		else:
			if d.intensity >= min_intensity:
				return true
	if use_total_intensity:
		return total_intensity >= min_intensity
	return false

func format_summary() -> String:
	var lines: Array[String] = []
	var color_str: String = "Any" if color == null else LightColor.enum_to_string(color)
	lines.append("Color: %s" % color_str)
	var intensity_label = "Total Intensity" if use_total_intensity else "Intensity"
	if min_intensity > 0.0001:
		lines.append("%s: >= %.2f" % [intensity_label, min_intensity])
	lines.append("Polarization: %d°-%d°" % [min_polar, max_polar])
	return "\n".join(lines)
