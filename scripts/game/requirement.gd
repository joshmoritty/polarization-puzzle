class_name Requirement

var dir: LightData.Dir
var color: LightColor.LightColorEnum
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
	var total_intensity = 0
	for beam in beams:
		if (beam.data.dir == dir
			and beam.data.color == color
			and beam.data.polar >= min_polar
			and beam.data.polar <= max_polar):
			if use_total_intensity:
				total_intensity += beam.data.intensity
			elif beam.data.intensity >= min_intensity:
				return true
	if use_total_intensity:
		return total_intensity >= min_intensity
	return false

func format_summary() -> String:
	var lines: Array[String] = []
	lines.append("Direction: %s" % LightData.dir_to_string(dir))
	lines.append("Color: %s" % LightColor.enum_to_string(color))
	var intensity_label = "Total Intensity" if use_total_intensity else "Intensity"
	lines.append("%s: >= %.2f" % [intensity_label, min_intensity])
	lines.append("Polarization: %d°-%d°" % [min_polar, max_polar])
	return "\n".join(lines)
