extends Control

@onready var level_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/LevelGrid
@onready var back_button: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton

# Array of level scene paths
var level_scenes: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn",
	"res://scenes/levels/level_6.tscn"
]

func _ready():
	visible = false # Start hidden
	_setup_level_buttons()
	back_button.pressed.connect(_on_back_pressed)

func _setup_level_buttons():
	# Clear any existing buttons
	for child in level_grid.get_children():
		child.queue_free()
	
	# Wait one frame for children to be properly freed
	await get_tree().process_frame
	
	# Create buttons for each level
	for i in range(level_scenes.size()):
		var button := Button.new()
		button.text = "Level " + str(i + 1)
		button.custom_minimum_size = Vector2(140, 60)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		# Connect button press to load the corresponding level
		var level_index = i # Capture the index in a local variable
		button.pressed.connect(func(): _load_level(level_index))
		
		level_grid.add_child(button)

func _load_level(level_index: int):
	if level_index >= 0 and level_index < level_scenes.size():
		SceneManager.change_scene_with_loading(level_scenes[level_index])

func _on_back_pressed():
	hide_level_selector()

func show_level_selector():
	visible = true

func hide_level_selector():
	visible = false
