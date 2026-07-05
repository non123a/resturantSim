extends Area2D

@export var ingredient_name = ""

var start_position
var dragging = false

func _ready():
	start_position = global_position


func _process(delta):

	if dragging:
		global_position = get_global_mouse_position()


func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				dragging = true
			else:
				dragging = false
				global_position = start_position
