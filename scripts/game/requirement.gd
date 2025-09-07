class_name Requirement

var dir: LightData.Dir
var color: LightColor.LightColorEnum
var min_intensity: float
var min_polar: int
var max_polar: int
var use_total_intensity: bool
var use_color: bool
var use_polar: bool

func _init(
	p_dir,
	p_color,
	p_min_intensity,
	p_min_polar,
	p_max_polar,
	p_use_total_intensity,
	p_use_color := true,
	p_use_polar := true
):
	dir = p_dir
	color = p_color
	min_intensity = p_min_intensity
	min_polar = p_min_polar
	max_polar = p_max_polar
	use_total_intensity = p_use_total_intensity
	use_color = p_use_color
	use_polar = p_use_polar
	
func is_successful(beams: Array[Beam]) -> bool:
	var total_intensity: float = 0.0
	for beam in beams:
		var d := beam.data
		if d.dir != dir:
			continue
		if use_polar and (d.polar < min_polar or d.polar > max_polar):
			continue
		if use_color and d.color != color:
			continue

		if use_total_intensity:
			total_intensity += d.intensity
		else:
			if d.intensity >= min_intensity:
				return true
	if use_total_intensity:
		return total_intensity >= min_intensity
	return false

func get_summary(beams: Array[Beam] = []) -> Dictionary:
	var lines: Array[String] = []
	var intensity_label = "Total Intensity" if use_total_intensity else "Intensity"
	
	# Check if requirements are fulfilled to add checkboxes
	var intensity_fulfilled := false
	var polar_fulfilled := false
	
	if beams.size() > 0:
		# Check intensity requirement fulfillment independently
		if min_intensity > 0.0001:
			if use_total_intensity:
				var total_intensity: float = 0.0
				for beam in beams:
					var d := beam.data
					if d.dir != dir:
						continue
					if use_color and d.color != color:
						continue
					# For total intensity, we don't filter by polarization for intensity check
					total_intensity += d.intensity
				intensity_fulfilled = total_intensity >= min_intensity
			else:
				for beam in beams:
					var d := beam.data
					if d.dir != dir:
						continue
					if use_color and d.color != color:
						continue
					# For individual intensity, we don't filter by polarization for intensity check
					if d.intensity >= min_intensity:
						intensity_fulfilled = true
						break
		else:
			# If no minimum intensity requirement, intensity is always fulfilled
			intensity_fulfilled = true
		
		# Check polarization requirement fulfillment independently
		if use_polar:
			for beam in beams:
				var d := beam.data
				if d.dir != dir:
					continue
				if use_color and d.color != color:
					continue
				# For polarization check, we don't filter by intensity
				if d.polar >= min_polar and d.polar <= max_polar:
					polar_fulfilled = true
					break
		else:
			# If no polarization requirement, polarization is always fulfilled
			polar_fulfilled = true
	
	# Add intensity line with checkbox
	if min_intensity > 0.0001:
		var checkbox = "[V]" if intensity_fulfilled else "[X]"
		lines.append("%s %s: >= %.2f" % [checkbox, intensity_label, min_intensity])
	
	# Add polarization line with checkbox
	var polar_str := "Any" if not use_polar else "%d°-%d°" % [min_polar, max_polar]
	var polar_checkbox = "[V]" if polar_fulfilled else "[X]"
	lines.append("%s Polarization: %s" % [polar_checkbox, polar_str])
	
	var text := "\n".join(lines)
	
	var display_color: Color = Color.WHITE
	if use_color:
		display_color = LightColor.get_display_color(color)
	
	return {"text": text, "color": display_color}
