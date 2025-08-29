class_name Controller
extends Node2D

var objs: Dictionary[Vector2i, LightObject] = {}
var beams: Array[Beam] = []
@onready var ground = %"GroundTiles" as TileMapLayer
@onready var tilemap: TileMapLayer = %"ObjectTiles"
@onready var view: SubViewport = %"SubViewport"
@onready var label: Label = %"HoverReadout"
var _outline_shader := load("res://assets/2d_outline.gdshader")
var _hovered_sprite: CanvasItem = null

func _ready():
	for pos in objs:
		var obj = objs[pos]
		if obj is Source:
			construct_beam(pos, obj.process_light(null))

func _unhandled_input(event: InputEvent) -> void:
	# Update UI readout on hover via physics point query; clear when none
	if event is InputEventMouseMotion and label:
		var space_state := get_world_2d().direct_space_state
		var params := PhysicsPointQueryParameters2D.new()
		# Use world coordinates for physics queries
		params.position = get_global_mouse_position()
		# Hit BeamSection Areas (bit 4) and Object Areas (bit 5)
		params.collision_mask = (1 << 3) | (1 << 4)
		params.collide_with_areas = true
		params.collide_with_bodies = false
		var results := space_state.intersect_point(params, 8)
		results.sort_custom(y_sort)
		var found_beam := false
		var new_hovered: CanvasItem = null
		for hit in results:
			var area: Area2D = hit.get("collider") as Area2D
			if not area:
				continue
			var parent := area.get_parent()
			if parent is BeamSection:
				var sec: BeamSection = parent
				label.text = sec.beam.data.format_readout()
				new_hovered = sec
				found_beam = true
				break
			elif parent is LightObject:
				new_hovered = parent
				break
		if not found_beam:
			label.text = ""
		# Apply/remove outline shader
		if _hovered_sprite != new_hovered:
			# Remove from old
			if _hovered_sprite:
				_hovered_sprite.material = null
			# Apply to new
			_hovered_sprite = new_hovered
			if _hovered_sprite:
				var mat := ShaderMaterial.new()
				mat.shader = _outline_shader
				_hovered_sprite.material = mat

func y_sort(a: Dictionary, b: Dictionary):
	var a_area = a.get("collider") as Area2D
	var b_area = b.get("collider") as Area2D
	return a_area.get_parent().position.y > b_area.get_parent().position.y

func construct_beam(pos: Vector2i, data: LightData):
	var dir_vec = dir_to_vec(data.dir)
	var from = pos + dir_vec
	var length = 0
	
	while true:
		var check_pos = from + dir_vec * length
		if (objs.has(check_pos)
			or ground.get_cell_source_id(check_pos + Vector2i(1, 1)) == -1):
			break
		length += 1
	
	if length > 0:
		var beam_n = beams.size()
		var mesh_coord = Vector2i(beam_n / 5, beam_n % 5)
		var beam = Beam.new(data, from, length, mesh_coord, view, tilemap)
		beams.append(beam)
	
	var end = from + dir_vec * length
	if objs.has(end):
		var end_obj = objs[end]
		var out_light = end_obj.process_light(data)
		if out_light != null:
			construct_beam(end, out_light)

static func dir_to_vec(dir: LightData.Dir):
	if dir == LightData.Dir.UP_RIGHT:
		return Vector2i(0, -1)
	elif dir == LightData.Dir.DOWN_RIGHT:
		return Vector2i(1, 0)
	elif dir == LightData.Dir.DOWN_LEFT:
		return Vector2i(0, 1)
	elif dir == LightData.Dir.UP_LEFT:
		return Vector2i(-1, 0)
	return Vector2i(0, 0)

func register_obj(obj: Node2D):
	var tm = %"ObjectTiles" as TileMapLayer
	var tilepos = tm.local_to_map(obj.position)
	objs.set(tilepos, obj)
