class_name BeamSection
extends Sprite2D

func _init(pos: Vector2, viewpath: NodePath):
	position = pos
	texture = ViewportTexture.new()
	texture.viewport_path = viewpath
