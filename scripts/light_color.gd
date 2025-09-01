class_name LightColor

enum LightColorEnum {RED, YELLOW, GREEN, BLUE, PURPLE}

static var RED = new(Color(0.4, 0, 0), Color(1, 0.1, 0.1), Color(0.75, 0.2, 0), Color(1, 0.4, 0.3))
static var YELLOW = new(Color(1, 0.5, 0), Color(1, 1, 0.25), Color(1, 0.6, 0), Color(1, 0.8, 0))
static var GREEN = new(Color(0, 0.25, 0), Color(0, 0.6, 0), Color(0, 0.4, 0), Color(0.2, 0.75, 0))
static var BLUE = new(Color(0, 0, 0.4), Color(0.2, 0.2, 1), Color(0, 0.3, 0.75), Color(0.2, 0.6, 1))
static var PURPLE = new(Color(0.3, 0, 0.3), Color(0.8, 0, 0.8), Color(0.5, 0, 0.5), Color(1, 0.3, 1))

var min_wave: Color
var max_wave: Color
var min_axis: Color
var max_axis: Color

func _init(p_min_wave: Color, p_max_wave: Color, p_min_axis: Color, p_max_axis: Color):
	min_wave = p_min_wave
	max_wave = p_max_wave
	min_axis = p_min_axis
	max_axis = p_max_axis

static func enum_to_col(e: LightColorEnum):
	match e:
		LightColorEnum.RED:
			return RED
		LightColorEnum.YELLOW:
			return YELLOW
		LightColorEnum.GREEN:
			return GREEN
		LightColorEnum.BLUE:
			return BLUE
		LightColorEnum.PURPLE:
			return PURPLE

static func enum_to_string(e: LightColorEnum):
	match e:
		LightColorEnum.RED:
			return "Red"
		LightColorEnum.YELLOW:
			return "Yellow"
		LightColorEnum.GREEN:
			return "Green"
		LightColorEnum.BLUE:
			return "Blue"
		LightColorEnum.PURPLE:
			return "Purple"
