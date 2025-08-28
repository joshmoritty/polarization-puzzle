class_name Controller
extends Node2D

var objs: Dictionary[Vector2i, LightObject] = {}
var beams: Array[Beam] = []
@onready var ground = %"GroundTiles" as TileMapLayer
@onready var tilemap: TileMapLayer = %"ObjectTiles"
@onready var view: SubViewport = %"SubViewport"

func _ready():
	for pos in objs:
		var obj = objs[pos]
		if obj is Source:
			construct_beam(pos, obj.process_light(null))

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
