extends Button

@onready var level_selector: Control = %"LevelSelector"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	if level_selector:
		level_selector.show_level_selector()
