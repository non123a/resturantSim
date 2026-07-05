extends Area2D

@export var ingredient_name = ""
@export var ingredient_texture : Texture2D
@export var next_stage = ""
var start_position
var dragging = false


func _ready():

	start_position = global_position

	$Sprite2D.texture = ingredient_texture


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

				var areas = get_overlapping_areas()

				if areas.size() > 0:

					for area in areas:

						if area.has_method("ingredient_dropped"):
							area.ingredient_dropped(self)
							return

				global_position = start_position
func get_ingredient_name():
	return ingredient_name
	
func get_next_stage():
	return next_stage
	
