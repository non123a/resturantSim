extends Control

const DASHBOARD_SCENE := "res://scenes/dashboard/dashboard.tscn"

@onready var end_panel: CanvasItem = $"../EndPanel"
@onready var new_game_confirm: CanvasItem = $"../NewGameConfirm"


func _ready() -> void:
	ensure_ui_cancel_has_escape()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	if visible:
		resume_game()
		get_viewport().set_input_as_handled()
		return

	if get_tree().paused or is_another_modal_open():
		return

	pause_game()
	get_viewport().set_input_as_handled()


func ensure_ui_cancel_has_escape() -> void:
	if not InputMap.has_action("ui_cancel"):
		InputMap.add_action("ui_cancel")

	for input_event in InputMap.action_get_events("ui_cancel"):
		if input_event is InputEventKey:
			if input_event.keycode == KEY_ESCAPE or input_event.physical_keycode == KEY_ESCAPE:
				return

	var escape_event := InputEventKey.new()
	escape_event.keycode = KEY_ESCAPE
	InputMap.action_add_event("ui_cancel", escape_event)


func is_another_modal_open() -> bool:
	return end_panel.visible or new_game_confirm.visible


func pause_game() -> void:
	show()
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
	hide()


func _on_continue_button_pressed() -> void:
	AudioManager.play_ui_click()
	resume_game()


func _on_back_button_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file(DASHBOARD_SCENE)
