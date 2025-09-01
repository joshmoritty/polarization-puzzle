class_name Beam

var controller: Controller
var data: LightData
var from: Vector2i
var length: int = 0
var mesh_coord: Vector2i
var mesh: MeshInstance3D
var end_obj: LightObject = null

func _init(
	p_data: LightData,
	p_from: Vector2i,
	p_controller: Controller
):
	data = p_data
	from = p_from
	controller = p_controller

	build()

	mesh_coord = controller.get_next_mesh_coord()
	mesh = controller.view.find_child("%d %d" % [mesh_coord.x, mesh_coord.y])
	
	update_sprite()

	var dir_vec = Controller.dir_to_vec(data.dir)
	
	var tex = AtlasTexture.new()
	var atlas = controller.view.get_texture()
	tex.atlas = atlas
	tex.region = Rect2(mesh_coord.y * 32, mesh_coord.x * 32, 32, 32)
	
	for i in range(length):
		var section = BeamSection.new(self, controller.tilemap.map_to_local(from + dir_vec * i), tex)
		controller.tilemap.add_child(section)

func build():
	var dir_vec = Controller.dir_to_vec(data.dir)

	while true:
		var check_pos = from + dir_vec * length
		if (controller.objs.has(check_pos)
			or controller.ground.get_cell_source_id(check_pos + Vector2i(1, 1)) == -1):
			break
		length += 1
	
	var end = from + dir_vec * length
	if controller.objs.has(end):
		end_obj = controller.objs[end]
		end_obj.beams_in.push_back(self)
		end_obj.build_beams()

func update_sprite():
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
	var color = LightColor.enum_to_col(data.color)
	var opacity = 1;
	var wave_color = lerp(Color(color.min_wave, opacity), Color(color.max_wave, opacity), data.intensity)
	var axis_color = lerp(Color(color.min_axis, opacity), Color(color.max_axis, opacity), data.intensity)
	mesh.set_instance_shader_parameter("wave_color", wave_color)
	mesh.set_instance_shader_parameter("connector_color", axis_color)
	mesh.set_instance_shader_parameter("axis_color", axis_color)
	mesh.set_instance_shader_parameter("amplitude", data.intensity * 0.4)

func update(p_data: LightData):
	data = p_data
	update_sprite()
	if end_obj:
		end_obj.build_beams()
