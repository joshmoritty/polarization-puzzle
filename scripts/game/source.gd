class_name Source
extends LightObject

@export var dir: LightData.Dir

func get_hover_info() -> String:
	if beams_out.size() == 0:
		return ""
	# Sort by light comparator and list all outgoing beams
	beams_out.sort_custom(func(a, b): return LightData.compare(a.data, b.data))
	var blocks: Array[String] = []
	for b in beams_out:
		blocks.append(b.data.format_readout())
	return "\n---\n".join(blocks)
