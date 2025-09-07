class_name Source
extends LightObject

@export var dir: LightData.Dir

func get_hover_info() -> Array[Dictionary]:
	if beams_out.size() == 0:
		return []
	# Sort by light comparator and list all outgoing beams
	beams_out.sort_custom(func(a, b): return LightData.compare(a.data, b.data))
	var entries: Array[Dictionary] = []
	for b in beams_out:
		var readout = b.data.format_readout()
		entries.append(readout)
	return entries
