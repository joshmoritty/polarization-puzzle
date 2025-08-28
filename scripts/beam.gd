class_name Beam

var data: LightData
var from: Vector2i
var length: int
var mesh_coord: Vector2i
var mesh: MeshInstance3D

func _init(
	p_data: LightData,
	p_from: Vector2i,
	p_length: int,
	p_mesh_coord: Vector2i,
	view: SubViewport,
	tilemap: TileMapLayer
):
	data = p_data
	from = p_from
	length = p_length
	mesh_coord = p_mesh_coord
	
	mesh = view.find_child("%d %d" % [mesh_coord.x, mesh_coord.y])
	
	var dir = data.dir
	if dir == LightData.Dir.UP_RIGHT:
		mesh.rotation_degrees.y = 270
	elif dir == LightData.Dir.DOWN_RIGHT:
		mesh.rotation_degrees.y = 180
	elif dir == LightData.Dir.DOWN_LEFT:
		mesh.rotation_degrees.y = 90
	else:
		mesh.rotation_degrees.y = 0
		
	mesh.rotation_degrees.x = data.polar
	var opacity = 1;
	var wave_color = lerp(Color(1, 0.5, 0, opacity), Color(1, 1, 0.25, opacity), data.intensity)
	var axis_color = lerp(Color(1, 0.4, 0, opacity), Color(1, 0.8, 0, opacity), data.intensity)
	mesh.set_instance_shader_parameter("wave_color", wave_color)
	mesh.set_instance_shader_parameter("connector_color", axis_color)
	mesh.set_instance_shader_parameter("axis_color", axis_color)
	mesh.set_instance_shader_parameter("amplitude", data.intensity * 0.4)
	var dir_vec = Controller.dir_to_vec(dir)
	
	var sprite = Sprite2D.new()
	var tex = AtlasTexture.new()
	var atlas = view.get_texture()
	tex.atlas = atlas
	tex.region = Rect2(mesh_coord.y * 32, mesh_coord.x * 32, 32, 32)
	sprite.texture = tex
	sprite.position = tilemap.map_to_local(from)
	tilemap.add_child(sprite)
	
	for i in range(1, length):
		var dupe = sprite.duplicate() as Sprite2D
		dupe.position = tilemap.map_to_local(from + dir_vec * i)
		tilemap.add_child(dupe)
