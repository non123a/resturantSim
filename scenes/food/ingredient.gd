extends Area2D

@export var ingredient_name = ""
@export var ingredient_id = ""
@export var ingredient_texture : Texture2D
@export var food_id = ""
@export var is_source = false
var start_position
var home_position
var dragging = false
var drop_in_progress = false


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
				if is_source:
					spawn_drag_instance()
				else:
					begin_drag_at(global_position)


func _input(event):
	if not dragging:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if drop_in_progress:
				return

			dragging = false
			drop_in_progress = true
			AudioManager.play_drop()

			var accepted = await get_tree().current_scene.try_drop_ingredient(self)
			if not accepted:
				global_position = start_position

			if not is_queued_for_deletion():
				drop_in_progress = false


func spawn_drag_instance():
	var instance = duplicate()
	get_parent().add_child(instance)

	instance.is_source = false
	instance.ingredient_name = ingredient_name
	instance.ingredient_id = ingredient_id
	instance.ingredient_texture = ingredient_texture
	instance.food_id = food_id
	instance.dragging = false
	instance.drop_in_progress = false
	instance.visible = true
	instance.monitoring = true
	instance.input_pickable = true
	instance.set_process(true)
	instance.set_process_input(true)
	instance.get_node("Sprite2D").texture = ingredient_texture
	instance.begin_drag_at(global_position)


func begin_drag_at(position):
	if drop_in_progress:
		return

	set_home_position(position)
	dragging = true
	AudioManager.play_drag()


func get_ingredient_name():
	if ingredient_id != "":
		return ingredient_id
	return ingredient_name

func get_food_id():
	if food_id != "":
		return food_id
	return get_ingredient_name()

func set_home_position(position):
	start_position = position
	home_position = position
	global_position = position
