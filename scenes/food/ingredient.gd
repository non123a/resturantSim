extends Area2D

@export var ingredient_name = ""
@export var ingredient_texture : Texture2D
@export var food_id = ""
var start_position
var home_position
var dragging = false


func _ready():

	start_position = global_position
	home_position = global_position

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

				var accepted = await get_tree().current_scene.try_drop_ingredient(self)
				if not accepted:
					global_position = start_position
func get_ingredient_name():
	return ingredient_name

func get_food_id():
	if food_id != "":
		return food_id
	return ingredient_name

func set_home_position(position):
	start_position = position
	home_position = position
	global_position = position
